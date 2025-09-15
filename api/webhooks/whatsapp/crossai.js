const crypto = require("crypto");

function timingSafeEqual(a, b) {
  try {
    const bufA = Buffer.from(a || "", "utf8");
    const bufB = Buffer.from(b || "", "utf8");
    if (bufA.length !== bufB.length) return false;
    return crypto.timingSafeEqual(bufA, bufB);
  } catch {
    return false;
  }
}

function validateSignature(req, appSecret) {
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
    const VERIFY_TOKEN = process.env.VERIFY_TOKEN || "";
    const APP_SECRET = process.env.META_APP_SECRET || "";

    // GET: Webhook verification
    if (req.method === "GET") {
      const { "hub.mode": mode, "hub.verify_token": token, "hub.challenge": challenge } = req.query || {};
      
      if (mode === "subscribe" && token === VERIFY_TOKEN && challenge) {
        console.log("Webhook verification successful");
        return res.status(200).send(challenge);
      }
      
      console.log("Webhook verification failed");
      return res.status(403).send("Forbidden");
    }

    // POST: Webhook events
    if (req.method === "POST") {
      if (APP_SECRET && !validateSignature(req, APP_SECRET)) {
        console.log("Invalid signature");
        return res.status(401).json({ error: "Invalid signature" });
      }

      console.log("WhatsApp webhook event:", JSON.stringify(req.body || {}, null, 2));
      
      return res.status(200).json({ 
        success: true, 
        timestamp: new Date().toISOString() 
      });
    }

    res.setHeader("Allow", "GET, POST");
    return res.status(405).json({ error: "Method not allowed" });

  } catch (error) {
    console.error("Webhook error:", error);
    return res.status(500).json({ 
      error: "Internal server error",
      timestamp: new Date().toISOString()
    });
  }
};