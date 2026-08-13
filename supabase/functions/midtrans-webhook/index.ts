import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { crypto } from "https://deno.land/std@0.177.0/crypto/mod.ts";
import { GoogleAuth } from "npm:google-auth-library";

const MIDTRANS_SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY")!;

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
    else if (status === "refund") paymentStatus = "refund";

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

    // Update booking status on successful payment
    if (paymentStatus === "settlement" || paymentStatus === "capture") {
      const { data: payment } = await supabase
        .from("payments")
        .select("booking_id, user_id")
        .eq("midtrans_order_id", body.order_id)
        .single();

      if (payment) {
        await supabase
          .from("bookings")
          .update({ status: "confirmed", updated_at: new Date().toISOString() })
          .eq("id", payment.booking_id);

        // Fetch user's FCM token
        const { data: user } = await supabase
          .from("users")
          .select("fcm_token")
          .eq("id", payment.user_id)
          .single();

        if (user && user.fcm_token) {
          const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "{}");
          const clientEmail = serviceAccount.client_email;
          const privateKey = serviceAccount.private_key;
          const projectId = serviceAccount.project_id;

          if (clientEmail && privateKey && projectId) {
            try {
              // Initialize GoogleAuth
              const auth = new GoogleAuth({
                credentials: {
                  client_email: clientEmail,
                  private_key: privateKey,
                },
                scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
              });

              // Get Access Token
              const client = await auth.getClient();
              const accessToken = await client.getAccessToken();

              // Send Notification
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
                        title: "Pembayaran Berhasil! 🎉",
                        body: "Terima kasih, pembayaran Anda telah kami terima.",
                      },
                      data: {
                        booking_id: payment.booking_id,
                        type: "payment_success",
                      },
                    },
                  }),
                }
              );

              if (!response.ok) {
                const errText = await response.text();
                console.error("FCM Send Error:", errText);
                await supabase.from("payments").update({ payment_type: 'FCM_ERROR: ' + errText.substring(0, 50) }).eq("midtrans_order_id", body.order_id);
              } else {
                console.log("FCM Notification sent successfully!");
                await supabase.from("payments").update({ payment_type: 'FCM_SUCCESS' }).eq("midtrans_order_id", body.order_id);
              }
            } catch (e) {
              console.error("Error sending FCM:", e);
              await supabase.from("payments").update({ payment_type: 'FCM_CATCH: ' + e.message.substring(0, 50) }).eq("midtrans_order_id", body.order_id);
            }
          } else {
             console.log("Firebase secrets are not fully set in Supabase.");
          }
        }
      }
    }

    // Cancel booking on failed payment
    if (["deny", "cancel", "expire"].includes(paymentStatus)) {
      const { data: payment } = await supabase
        .from("payments")
        .select("booking_id")
        .eq("midtrans_order_id", body.order_id)
        .single();

      if (payment) {
        await supabase
          .from("bookings")
          .update({ status: "cancelled", updated_at: new Date().toISOString() })
          .eq("id", payment.booking_id);
      }
    }

    return new Response("OK", { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
