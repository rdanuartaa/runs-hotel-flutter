import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GoogleAuth } from "npm:google-auth-library";

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

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
      .select("fcm_token")
      .eq("id", userId)
      .single();

    if (!user || !user.fcm_token) {
      return new Response(JSON.stringify({ error: "User or FCM token not found" }), {
        status: 404,
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
