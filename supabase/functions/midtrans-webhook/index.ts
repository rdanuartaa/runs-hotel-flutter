import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { crypto } from "https://deno.land/std@0.177.0/crypto/mod.ts";
import { GoogleAuth } from "npm:google-auth-library";
import * as nodemailer from "npm:nodemailer";

const MIDTRANS_SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY")!;

async function sendEmail(to: string, subject: string, text: string, booking: any = null) {
  const email = Deno.env.get("SMTP_EMAIL");
  const pass = Deno.env.get("SMTP_PASSWORD");

  if (!email || !pass) {
    console.log("SMTP_EMAIL atau SMTP_PASSWORD belum di-set");
    return;
  }

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: email,
      pass: pass,
    },
  });

  let htmlTemplate = `
    <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
      <div style="background-color: #8B4513; padding: 20px; text-align: center; color: white;">
        <h1 style="margin: 0; font-size: 24px;">Runs Hotel</h1>
        <p style="margin: 0; font-size: 14px;">Official Notification</p>
      </div>
      <div style="padding: 20px;">
        <p>Dear Customer,</p>
        <p>${text}</p>
  `;

  if (booking) {
    htmlTemplate += `
      <div style="background-color: #f9f9f9; padding: 15px; border-radius: 8px; margin-top: 20px;">
        <h3 style="margin-top: 0; border-bottom: 2px solid #8B4513; padding-bottom: 10px; color: #8B4513;">E-Ticket / Detail Pesanan</h3>
        <p><strong>Booking ID:</strong> ${booking.id || '-'}</p>
        <p><strong>Hotel:</strong> ${booking.hotels?.name || '-'}</p>
        <p><strong>Tipe Kamar:</strong> ${booking.rooms?.name || '-'}</p>
        <p><strong>Check-in:</strong> ${booking.check_in_date || '-'}</p>
        <p><strong>Check-out:</strong> ${booking.check_out_date || '-'}</p>
        <p><strong>Total Harga:</strong> Rp ${booking.total_price ? booking.total_price.toLocaleString('id-ID') : '-'}</p>
      </div>
    `;
  }

  htmlTemplate += `
      </div>
      <div style="background-color: #f1f1f1; padding: 10px; text-align: center; font-size: 12px; color: #777;">
        <p>Terima kasih telah memilih Runs Hotel.</p>
        <p>&copy; ${new Date().getFullYear()} Runs Hotel. All rights reserved.</p>
      </div>
    </div>
  `;

  try {
    await transporter.sendMail({
      from: `"Runs Hotel" <${email}>`,
      to: to,
      subject: subject,
      text: text,
      html: htmlTemplate,
    });
    console.log("Email berhasil dikirim ke:", to);
  } catch (error) {
    console.error("Gagal mengirim email:", error);
  }
}

async function sendNotification(
  supabase: any,
  userId: string,
  title: string,
  bodyText: string,
  dataPayload: any,
  orderId: string
) {
  const { data: user } = await supabase
    .from("users")
    .select("fcm_token, email")
    .eq("id", userId)
    .single();

  if (user) {
    if (user.email) {
      let bookingDetails = null;
      if (dataPayload?.booking_id) {
        const { data: booking } = await supabase
          .from("bookings")
          .select("*, hotels(name), rooms(name)")
          .eq("id", dataPayload.booking_id)
          .single();
        bookingDetails = booking;
      }
      sendEmail(user.email, title, bodyText, bookingDetails);
    }

    if (user.fcm_token) {
    const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "{}");
    const clientEmail = serviceAccount.client_email;
    const privateKey = serviceAccount.private_key;
    const projectId = serviceAccount.project_id;

    if (clientEmail && privateKey && projectId) {
      try {
        const auth = new GoogleAuth({
          credentials: {
            client_email: clientEmail,
            private_key: privateKey,
          },
          scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
        });

        const client = await auth.getClient();
        const accessToken = await client.getAccessToken();

        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${accessToken.token}`,
            },
            body: JSON.stringify({
              message: {
                token: user.fcm_token,
                notification: {
                  title: title,
                  body: bodyText,
                },
                data: dataPayload,
              },
            }),
          }
        );

        if (!response.ok) {
          const errText = await response.text();
          console.error("FCM Send Error:", errText);
          await supabase.from("payments").update({ payment_type: 'FCM_ERROR: ' + errText.substring(0, 50) }).eq("midtrans_order_id", orderId);
        } else {
          console.log("FCM Notification sent successfully!");
          await supabase.from("payments").update({ payment_type: 'FCM_SUCCESS' }).eq("midtrans_order_id", orderId);
        }
      } catch (e) {
        console.error("Error sending FCM:", e);
        await supabase.from("payments").update({ payment_type: 'FCM_CATCH: ' + e.message.substring(0, 50) }).eq("midtrans_order_id", orderId);
      }
    } else {
       console.log("Firebase secrets are not fully set in Supabase.");
    }
    }
  }
}

serve(async (req) => {
  try {
    const body = await req.json();

    // Verify Midtrans signature
    const signatureInput = body.order_id + body.status_code + body.gross_amount + MIDTRANS_SERVER_KEY;
    const encoder = new TextEncoder();
    const data = encoder.encode(signatureInput);
    const hashBuffer = await crypto.subtle.digest("SHA-512", data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const signature = hashArray.map(b => b.toString(16).padStart(2, "0")).join("");

    if (signature !== body.signature_key) {
      return new Response("Invalid signature", { status: 403 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const status = body.transaction_status;
    const fraudStatus = body.fraud_status;

    let paymentStatus = "pending";
    if (status === "capture" && fraudStatus === "accept") paymentStatus = "capture";
    else if (status === "settlement") paymentStatus = "settlement";
    else if (["deny", "cancel", "expire"].includes(status)) paymentStatus = status;
    else if (status === "refund" || status === "partial_refund") paymentStatus = "refund";

    // Update payment record
    await supabase
      .from("payments")
      .update({
        status: paymentStatus,
        midtrans_transaction_id: body.transaction_id,
        payment_type: body.payment_type,
        payment_response: body,
        updated_at: new Date().toISOString(),
      })
      .eq("midtrans_order_id", body.order_id);

    // Get payment details to find user and booking
    const { data: payment } = await supabase
      .from("payments")
      .select("booking_id, user_id")
      .eq("midtrans_order_id", body.order_id)
      .single();

    if (!payment) {
      return new Response("Payment not found", { status: 404 });
    }

    // Update booking status and send notification based on payment status
    if (paymentStatus === "settlement" || paymentStatus === "capture") {
      await supabase
        .from("bookings")
        .update({ status: "confirmed", updated_at: new Date().toISOString() })
        .eq("id", payment.booking_id);

      await sendNotification(
        supabase,
        payment.user_id,
        "Pembayaran Berhasil! 🎉",
        "Terima kasih, pembayaran Anda telah kami terima.",
        { booking_id: payment.booking_id, type: "payment_success" },
        body.order_id
      );
    } else if (["deny", "cancel", "expire"].includes(paymentStatus)) {
      await supabase
        .from("bookings")
        .update({ status: "cancelled", updated_at: new Date().toISOString() })
        .eq("id", payment.booking_id);

      await sendNotification(
        supabase,
        payment.user_id,
        "Pembayaran Ditolak/Dibatalkan ❌",
        "Mohon maaf, transaksi pembayaran Anda gagal atau telah dibatalkan.",
        { booking_id: payment.booking_id, type: "payment_failed" },
        body.order_id
      );
    } else if (paymentStatus === "refund") {
      await supabase
        .from("bookings")
        .update({ status: "cancelled", updated_at: new Date().toISOString() }) // Usually refunded means cancelled booking
        .eq("id", payment.booking_id);

      await sendNotification(
        supabase,
        payment.user_id,
        "Refund Berhasil 💸",
        "Dana Anda telah berhasil dikembalikan ke metode pembayaran awal.",
        { booking_id: payment.booking_id, type: "payment_refunded" },
        body.order_id
      );
    }

    return new Response("OK", { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
