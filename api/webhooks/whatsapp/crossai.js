// PRODUCTION WhatsApp Webhook - CommonJS format for Vercel
const crypto = require("crypto");

function timingSafeEqual(a, b) {
  try {
    const aBuf = Buffer.from(a || "", "utf8");
    const bBuf = Buffer.from(b || "", "utf8");
    if (aBuf.length !== bBuf.length) return false;
    return crypto.timingSafeEqual(aBuf, bBuf);
  } catch {
    return false;
  }
}

function validateHMAC(req, appSecret) {
  try {
    const signature = req.headers["x-hub-signature-256"] || "";
    const body = req.rawBody || JSON.stringify(req.body || {});
    const expected = "sha256=" + crypto.createHmac("sha256", appSecret).update(body).digest("hex");
    return timingSafeEqual(signature, expected);
  } catch {
    return false;
  }
}

module.exports = async (req, res) => {
  try {
    const VERIFY_TOKEN = process.env.WEBHOOK_VERIFY_TOKEN || "";
    const APP_SECRET = process.env.META_APP_SECRET || "";

    // GET: Verification challenge
    if (req.method === "GET") {
      const { "hub.mode": mode, "hub.verify_token": token, "hub.challenge": challenge } = req.query || {};
      
      if (mode === "subscribe" && token === VERIFY_TOKEN && challenge) {
        console.log(`✅ Webhook verification successful for token: ${token.substring(0, 8)}...`);
        return res.status(200).send(challenge);
      }
      
      console.log(`❌ Webhook verification failed - mode: ${mode}, token match: ${token === VERIFY_TOKEN}`);
      return res.status(403).send("Forbidden");
    }

    // POST: Webhook events
    if (req.method === "POST") {
      // HMAC validation (if APP_SECRET is set)
      if (APP_SECRET && !validateHMAC(req, APP_SECRET)) {
        console.log("❌ HMAC validation failed");
        return res.status(401).json({ error: "Invalid signature" });
      }

      // Log incoming webhook
      console.log("📱 WhatsApp Webhook Event:", JSON.stringify(req.body || {}, null, 2));
      
      // Quick acknowledgment for Nigerian networks
      return res.status(200).json({ 
        success: true, 
        timestamp: new Date().toISOString(),
        processed: true 
      });
    }

    // Unsupported method
    res.setHeader("Allow", "GET, POST");
    return res.status(405).json({ error: "Method not allowed" });

  } catch (error) {
    console.error("🚨 Webhook error:", error);
    return res.status(500).json({ 
      error: "Internal server error", 
      timestamp: new Date().toISOString() 
    });
  }
};