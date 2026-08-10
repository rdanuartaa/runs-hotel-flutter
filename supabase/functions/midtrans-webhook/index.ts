import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { crypto } from "https://deno.land/std@0.177.0/crypto/mod.ts";

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
        .select("booking_id")
        .eq("midtrans_order_id", body.order_id)
        .single();

      if (payment) {
        await supabase
          .from("bookings")
          .update({ status: "confirmed", updated_at: new Date().toISOString() })
          .eq("id", payment.booking_id);
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
