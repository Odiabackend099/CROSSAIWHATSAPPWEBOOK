// api/webhooks/whatsapp/crossai.js
const crypto = require("crypto");
const getRawBody = require("raw-body");

function timingSafeEq(a, b) {
  const ab = Buffer.from(a || "", "utf8");
  const bb = Buffer.from(b || "", "utf8");
  if (ab.length !== bb.length) return false;
  return crypto.timingSafeEqual(ab, bb);
}

function isValidHmac(raw, secret, headerSig) {
  try {
    if (!secret) return true; // skip if not configured
    const expected = "sha256=" + crypto.createHmac("sha256", secret).update(raw).digest("hex");
    return timingSafeEq(headerSig || "", expected);
  } catch {
    return false;
  }
}

module.exports = async (req, res) => {
  try {
    const VERIFY_TOKEN = process.env.WEBHOOK_VERIFY_TOKEN || process.env.VERIFY_TOKEN || "";
    const APP_SECRET   = process.env.META_APP_SECRET || "";

    // GET: webhook verification
    if (req.method === "GET") {
      const q = req.query || {};
      const mode = q["hub.mode"];
      const token = q["hub.verify_token"];
      const challenge = q["hub.challenge"];
      if (mode === "subscribe" && token === VERIFY_TOKEN && challenge) {
        return res.status(200).send(challenge);
      }
      return res.status(403).send("Forbidden");
    }

    // POST: events
    if (req.method === "POST") {
      const raw = await getRawBody(req);                // <- raw buffer for HMAC
      const sig = req.headers["x-hub-signature-256"] || "";

      if (!isValidHmac(raw, APP_SECRET, sig)) {
        return res.status(401).json({ ok: false, error: "invalid_signature" });
      }

      let body = {};
      try { body = JSON.parse(raw.toString("utf8")); } catch {}
      console.log("Incoming WhatsApp event:", JSON.stringify(body, null, 2));

      // Always ack fast
      return res.status(200).json({ ok: true });
    }

    res.setHeader("Allow", "GET, POST");
    return res.status(405).send("Method Not Allowed");
  } catch (err) {
    console.error("Webhook handler error:", err);
    return res.status(500).send("Internal Server Error");
  }
};