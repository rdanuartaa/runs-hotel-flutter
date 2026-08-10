import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MIDTRANS_SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY")!;
const MIDTRANS_BASE_URL = Deno.env.get("MIDTRANS_IS_PRODUCTION") === "true"
  ? "https://app.midtrans.com/snap/v1/transactions"
  : "https://app.sandbox.midtrans.com/snap/v1/transactions";

serve(async (req) => {
  try {
    const { booking_id } = await req.json();
    const authHeader = req.headers.get("Authorization")!;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    // Get user
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return new Response("Unauthorized", { status: 401 });

    // Get booking with hotel and room details
    const { data: booking } = await supabase
      .from("bookings")
      .select("*, hotels(name), rooms(name)")
      .eq("id", booking_id)
      .single();

    if (!booking) return new Response("Booking not found", { status: 404 });

    const orderId = `HOTEL-${booking_id.slice(0, 8)}-${Date.now()}`;

    // Create Midtrans Snap transaction
    const midtransPayload = {
      transaction_details: {
        order_id: orderId,
        gross_amount: booking.total_price,
      },
      customer_details: {
        email: user.email,
        first_name: user.user_metadata?.full_name ?? "Guest",
      },
      item_details: [{
        id: booking.room_id,
        price: Math.floor(booking.total_price / booking.total_nights),
        quantity: booking.total_nights,
        name: `${booking.hotels.name} - ${booking.rooms.name}`,
      }],
      callbacks: {
        finish: "hotelbooking://payment/finish",
      },
    };

    const encoded = btoa(`${MIDTRANS_SERVER_KEY}:`);
    const midtransRes = await fetch(MIDTRANS_BASE_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${encoded}`,
      },
      body: JSON.stringify(midtransPayload),
    });

    const snapData = await midtransRes.json();

    // Save payment record
    await supabase.from("payments").insert({
      booking_id,
      user_id: user.id,
      midtrans_order_id: orderId,
      gross_amount: booking.total_price,
      snap_token: snapData.token,
      snap_redirect_url: snapData.redirect_url,
      status: "pending",
    });

    return new Response(JSON.stringify(snapData), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
