// CommonJS Vercel Node Function  supports GET verify + optional POST HMAC check
const crypto = require("crypto");

function timingSafeEq(a, b) {
  const aBuf = Buffer.from(a || "", "utf8");
  const bBuf = Buffer.from(b || "", "utf8");
  if (aBuf.length !== bBuf.length) return false;
  return crypto.timingSafeEqual(aBuf, bBuf);
}

function validHmac(req, secret) {
  try {
    const sig = req.headers["x-hub-signature-256"] || "";
    const expected = "sha256=" + crypto.createHmac("sha256", secret).update(req.rawBody || JSON.stringify(req.body || {})).digest("hex");
    return timingSafeEq(sig, expected);
  } catch {
    return false;
  }
}

module.exports = async (req, res) => {
  try {
    const VERIFY_TOKEN = process.env.VERIFY_TOKEN || "";
    const APP_SECRET   = process.env.META_APP_SECRET || "";

    // Verification handshake
    if (req.method === "GET") {
      const q = req.query || {};
      if (q["hub.mode"] === "subscribe" && q["hub.verify_token"] === VERIFY_TOKEN && q["hub.challenge"]) {
        return res.status(200).send(q["hub.challenge"]);
      }
      return res.status(403).send("Forbidden");
    }

    // Webhook events
    if (req.method === "POST") {
      if (APP_SECRET && !validHmac(req, APP_SECRET)) {
        // If you haven't set APP_SECRET yet, this check is skipped.
        return res.status(401).json({ ok: false, error: "invalid_signature" });
      }
      console.log("Incoming WhatsApp event:", JSON.stringify(req.body || {}, null, 2));
      return res.status(200).json({ ok: true });
    }

    res.setHeader("Allow", "GET, POST");
    return res.status(405).send("Method Not Allowed");
  } catch (err) {
    console.error("Webhook handler error:", err);
    return res.status(500).send("Internal Server Error");
  }
};