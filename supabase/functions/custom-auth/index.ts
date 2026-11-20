import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.48.1";
import nodemailer from "npm:nodemailer@6.9.16";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

const SMTP_HOST = Deno.env.get("SMTP_HOST") || "smtp.gmail.com";
const SMTP_PORT = Number(Deno.env.get("SMTP_PORT")) || 465;
const SMTP_USER = Deno.env.get("SMTP_USER") || "baharchale20@gmail.com";
const rawPass = Deno.env.get("SMTP_APP_PASSWORD") || "ukyh lkrn kire tppw";
const SMTP_APP_PASSWORD = rawPass.replace(/\s+/g, "");

const HMAC_SECRET = Deno.env.get("HMAC_SECRET") || "bahar_chale_secure_otp_salt_v2_2026";

async function computeHmac(message: string): Promise<string> {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(HMAC_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(message));
  return Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: SMTP_PORT,
  secure: true,
  auth: {
    user: SMTP_USER,
    pass: SMTP_APP_PASSWORD,
  },
});

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const action = body.action;

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Action 1: Send OTP to Real Email (checks active vs suspended accounts)
    if (action === "send-otp") {
      const email = (body.email || "").trim().toLowerCase();
      const name = (body.name || "यात्री").trim();

      if (!email.includes("@") || !email.includes(".")) {
        return new Response(JSON.stringify({ success: false, error: "अवैध ईमेल पता। (Invalid email address.)" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      // Check if user already exists in auth.users
      const { data: listData } = await supabaseAdmin.auth.admin.listUsers();
      const existingUser = listData?.users?.find(
        (u) => (u.email || "").toLowerCase() === email
      );

      if (existingUser) {
        // Check if account was suspended / deleted
        const { data: profile } = await supabaseAdmin
          .from("profiles")
          .select("account_status, is_active, signup_count")
          .eq("id", existingUser.id)
          .maybeSingle();

        const isSuspended = profile && (profile.account_status === "suspended" || profile.is_active === false);
        if (!isSuspended) {
          return new Response(JSON.stringify({
            success: false,
            error: "यह ईमेल पहले से पंजीकृत है। कृपया 'साइन इन' पर जाकर पासवर्ड से लॉगिन करें। (This email is already registered. Please Sign In.)"
          }), {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }
      }

      // Generate random 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const timestamp = Date.now().toString();
      const signature = await computeHmac(`${email}:${otp}:${timestamp}`);
      const token = btoa(`${email}:${timestamp}:${signature}`);

      const textBody = `नमस्ते ${name},\n\nबाहर चलें (Bahar Chale) में आपका स्वागत है।\nआपका 6-अंकों का सत्यापन कोड (OTP) है: ${otp}\n\nयह कोड 10 मिनट के लिए मान्य है। कृपया इसे किसी के साथ साझा न करें।\n\nसफर साथ में, आसान हर राह।\nटीम बाहर चलें (Bahar Chale)`;

      const htmlBody = `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 12px; background: #ffffff;">
          <div style="text-align: center; margin-bottom: 20px;">
            <h2 style="color: #0F766E; margin: 0; font-size: 22px;">Bahar Chale • बाहर चलें</h2>
            <p style="color: #64748b; font-size: 13px; margin: 4px 0 0 0;">सफर साथ में, आसान हर राह।</p>
          </div>
          <div style="background: #F0FDFA; border-left: 4px solid #0F766E; padding: 12px 16px; border-radius: 6px; margin-bottom: 20px;">
            <p style="margin: 0; color: #134E4A; font-size: 14px; font-weight: bold;">नमस्ते ${name},</p>
            <p style="margin: 6px 0 0 0; color: #134E4A; font-size: 13px;">आपके खाते के सत्यापन हेतु 6-अंकों का OTP कोड नीचे दिया गया है:</p>
          </div>
          <div style="text-align: center; padding: 18px; background: #f8fafc; border-radius: 8px; margin-bottom: 20px;">
            <span style="font-size: 34px; font-weight: bold; letter-spacing: 8px; color: #0F766E;">${otp}</span>
            <p style="margin: 8px 0 0 0; font-size: 12px; color: #64748b;">यह कोड 10 मिनट के लिए मान्य है।</p>
          </div>
          <p style="color: #94a3b8; font-size: 11px; margin: 0; text-align: center;">🛡️ सुरक्षा हेतु यह कोड किसी के साथ साझा न करें।</p>
        </div>
      `;

      await transporter.sendMail({
        from: `Bahar Chale <${SMTP_USER}>`,
        replyTo: SMTP_USER,
        to: email,
        subject: `Bahar Chale - Your OTP: ${otp} (सत्यापन कोड)`,
        text: textBody,
        html: htmlBody,
      });

      return new Response(JSON.stringify({
        success: true,
        token,
        message: "OTP सफलतापूर्वक भेजा गया।"
      }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Action 2: Verify OTP
    if (action === "verify-otp") {
      const email = (body.email || "").trim().toLowerCase();
      const enteredOtp = (body.otp || "").trim();
      const rawToken = (body.token || "").trim();

      if (!rawToken || !enteredOtp) {
        return new Response(JSON.stringify({ success: false, error: "OTP या टोकन अनुपलब्ध है।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      let parts: string[];
      try {
        parts = atob(rawToken).split(":");
      } catch {
        return new Response(JSON.stringify({ success: false, error: "अमान्य टोकन।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const [tokenEmail, tokenTimestamp, tokenSig] = parts;
      if (tokenEmail !== email) {
        return new Response(JSON.stringify({ success: false, error: "ईमेल मेल नहीं खाता।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const ageMs = Date.now() - parseInt(tokenTimestamp, 10);
      if (ageMs > 10 * 60 * 1000) {
        return new Response(JSON.stringify({ success: false, error: "OTP समाप्त (expired) हो चुका है। कृपया पुनः भेजें।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const expectedSig = await computeHmac(`${email}:${enteredOtp}:${tokenTimestamp}`);
      if (expectedSig !== tokenSig) {
        return new Response(JSON.stringify({ success: false, error: "गलत OTP कोड। कृपया ईमेल पर आया सही कोड दर्ज करें।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const verifiedTimestamp = Date.now().toString();
      const verifiedSig = await computeHmac(`VERIFIED:${email}:${verifiedTimestamp}`);
      const verifiedToken = btoa(`VERIFIED:${email}:${verifiedTimestamp}:${verifiedSig}`);

      return new Response(JSON.stringify({ success: true, verifiedToken, message: "OTP सत्यापित हुआ।" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Action 3: Complete Sign Up / Re-Signup with Password, Legal Consent & Audit
    if (action === "complete-signup") {
      const email = (body.email || "").trim().toLowerCase();
      const password = (body.password || "").trim();
      const name = (body.name || "यात्री").trim();
      const verifiedToken = (body.verifiedToken || "").trim();
      const termsAccepted = body.termsAccepted === true;
      const termsVersion = (body.termsVersion || "v1.0-2026").trim();
      const termsConsentText = (body.termsConsentText || "I accept the Bahar Chale Terms of Service, Privacy Policy, and Community Ride Coordination Guidelines under IT Act 2000 & DPDP Act 2023.").trim();

      if (!termsAccepted) {
        return new Response(JSON.stringify({
          success: false,
          error: "पंजीकरण के लिए नियम व शर्तें स्वीकार करना अनिवार्य है। (Please accept Terms & Conditions.)"
        }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      if (!verifiedToken || password.length < 6) {
        return new Response(JSON.stringify({ success: false, error: "पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      let vParts: string[];
      try {
        vParts = atob(verifiedToken).split(":");
      } catch {
        return new Response(JSON.stringify({ success: false, error: "अमान्य सत्यापन टोकन।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const [tag, vEmail, vTimestamp, vSig] = vParts;
      if (tag !== "VERIFIED" || vEmail !== email) {
        return new Response(JSON.stringify({ success: false, error: "सत्यापन अमान्य है। कृपया पुनः OTP सत्यापित करें।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      if (Date.now() - parseInt(vTimestamp, 10) > 15 * 60 * 1000) {
        return new Response(JSON.stringify({ success: false, error: "सत्यापन सत्र समाप्त हो गया। कृपया पुनः OTP भेजें।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const expectedVSig = await computeHmac(`VERIFIED:${email}:${vTimestamp}`);
      if (expectedVSig !== vSig) {
        return new Response(JSON.stringify({ success: false, error: "अमान्य सुरक्षा हस्ताक्षर।" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      // Check if user already exists
      const { data: listData } = await supabaseAdmin.auth.admin.listUsers();
      const existingUser = listData?.users?.find(
        (u) => (u.email || "").toLowerCase() === email
      );

      const ipAddress = req.headers.get("x-real-ip") || req.headers.get("cf-connecting-ip") || "";
      const userAgent = req.headers.get("user-agent") || "";
      const nowIso = new Date().toISOString();

      let userId: string;

      if (existingUser) {
        // Check if suspended / inactive
        const { data: profile } = await supabaseAdmin
          .from("profiles")
          .select("account_status, is_active, signup_count")
          .eq("id", existingUser.id)
          .maybeSingle();

        const isSuspended = profile && (profile.account_status === "suspended" || profile.is_active === false);
        if (isSuspended) {
          // Re-activate previously removed account with new credentials
          userId = existingUser.id;
          await supabaseAdmin.auth.admin.updateUserById(userId, {
            password: password,
            user_metadata: { full_name: name, name: name },
          });

          const currentCount = profile?.signup_count || 1;

          await supabaseAdmin.from("profiles").update({
            display_name: name,
            is_active: true,
            account_status: "active",
            deleted_at: null,
            signup_count: currentCount + 1,
            id_verified: false,
            verification_status: "unverified",
            id_type: null,
            id_number_masked: null,
            id_number_hash: null,
            terms_accepted: true,
            terms_accepted_at: nowIso,
            terms_version: termsVersion,
            terms_consent_text: termsConsentText,
            updated_at: nowIso,
          }).eq("id", userId);

          // Log re-registration
          await supabaseAdmin.from("account_lifecycle_logs").insert({
            user_id: userId,
            email: email,
            action: "re_signup",
            reason: `User re-registered after account removal (Registration #${currentCount + 1})`,
            metadata: { signup_count: currentCount + 1, ip_address: ipAddress },
          });

          return new Response(JSON.stringify({ success: true, message: "खाता सफलतापूर्वक पुनः सक्रिय हुआ।" }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        } else {
          return new Response(JSON.stringify({
            success: false,
            error: "यह ईमेल पहले से पंजीकृत है। कृपया 'साइन इन' पर जाकर पासवर्ड से लॉगिन करें।"
          }), {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }
      }

      // Fresh new user registration
      const { data: newUserData, error: createErr } = await supabaseAdmin.auth.admin.createUser({
        email: email,
        password: password,
        email_confirm: true,
        user_metadata: { full_name: name, name: name },
      });
      if (createErr) throw createErr;
      userId = newUserData.user.id;

      // Upsert into public.profiles
      await supabaseAdmin.from("profiles").upsert({
        id: userId,
        display_name: name,
        email: email,
        is_active: true,
        account_status: "active",
        signup_count: 1,
        terms_accepted: true,
        terms_accepted_at: nowIso,
        terms_version: termsVersion,
        terms_consent_text: termsConsentText,
        updated_at: nowIso,
      });

      // Insert audit record into user_consent_logs
      await supabaseAdmin.from("user_consent_logs").insert({
        user_id: userId,
        email: email,
        consent_type: "TERMS_AND_PRIVACY",
        terms_version: termsVersion,
        consent_statement: termsConsentText,
        ip_address: ipAddress,
        user_agent: userAgent,
        created_at: nowIso,
      });

      // Insert lifecycle log
      await supabaseAdmin.from("account_lifecycle_logs").insert({
        user_id: userId,
        email: email,
        action: "signup",
        reason: "Initial registration",
        metadata: { ip_address: ipAddress, user_agent: userAgent },
      });

      return new Response(JSON.stringify({ success: true, message: "खाता सफलतापूर्वक पंजीकृत हुआ।" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Action 4: Remove / Suspend User Account
    if (action === "remove-account") {
      const email = (body.email || "").trim().toLowerCase();
      const userId = (body.userId || "").trim();
      const reason = body.reason || "User requested account removal";
      const nowIso = new Date().toISOString();

      if (!userId) {
        return new Response(JSON.stringify({ success: false, error: "User ID is required." }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      // Mark profile inactive & suspended
      await supabaseAdmin.from("profiles").update({
        is_active: false,
        account_status: "suspended",
        deleted_at: nowIso,
        updated_at: nowIso,
      }).eq("id", userId);

      // Cancel user's hosted rides that are currently active
      await supabaseAdmin.from("rides").update({
        status: "cancelled",
        updated_at: nowIso,
      }).eq("owner_id", userId).eq("status", "active");

      // Cancel user's pending or accepted ride requests
      await supabaseAdmin.from("ride_requests").update({
        status: "cancelled",
        updated_at: nowIso,
      }).eq("requester_id", userId).in("status", ["pending", "accepted"]);

      // Insert audit log
      await supabaseAdmin.from("account_lifecycle_logs").insert({
        user_id: userId,
        email: email,
        action: "account_removed",
        reason: reason,
        created_at: nowIso,
        metadata: { client_agent: req.headers.get("user-agent") },
      });

      return new Response(JSON.stringify({ success: true, message: "खाता सफलतापूर्वक निष्कासित/निलंबित कर दिया गया है।" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ success: false, error: "अज्ञात कार्रवाई।" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ success: false, error: err.message || "सर्वर त्रुटि" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
