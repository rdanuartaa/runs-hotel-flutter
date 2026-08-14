import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GoogleAuth } from "npm:google-auth-library";
import * as nodemailer from "npm:nodemailer";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

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

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { userId, title, body: bodyText, dataPayload } = await req.json();

    if (!userId || !title || !bodyText) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Get FCM token
    const { data: user } = await supabase
      .from("users")
      .select("fcm_token, email")
      .eq("id", userId)
      .single();

    if (!user) {
      return new Response(JSON.stringify({ error: "User not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

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

    if (!user.fcm_token) {
      // If no fcm token but email exists, return success for email
      return new Response(JSON.stringify({ success: true, message: "Email sent, no FCM token" }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "{}");
    const clientEmail = serviceAccount.client_email;
    const privateKey = serviceAccount.private_key;
    const projectId = serviceAccount.project_id;

    if (!clientEmail || !privateKey || !projectId) {
      return new Response(JSON.stringify({ error: "Firebase config missing" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

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
            data: dataPayload || {},
          },
        }),
      }
    );

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`FCM Error: ${errText}`);
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
