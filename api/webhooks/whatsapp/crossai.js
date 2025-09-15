// api/webhooks/whatsapp/crossai.js
// Vercel Node.js serverless function — battle-tested WhatsApp webhook
// - GET  : returns hub.challenge when token matches
// - POST : optional signature validation + 200 ACK

const crypto = require("crypto");

const VERIFY_TOKEN = process.env.WEBHOOK_VERIFY_TOKEN || ""; // EXACT string you put in Meta
const APP_SECRET   = process.env.META_APP_SECRET || "";      // Optional: enables signature check

async function readRaw(req) {
  const chunks = [];
  for await (const ch of req) chunks.push(ch);
  return Buffer.concat(chunks);
}

module.exports = async (req, res) => {
  try {
    if (req.method === "GET") {
      const mode = req.query["hub.mode"];
      const token = req.query["hub.verify_token"];
      const challenge = req.query["hub.challenge"];
      if (mode === "subscribe" && token === VERIFY_TOKEN && challenge) {
        return res.status(200).setHeader("Content-Type","text/plain").send(challenge);
      }
      return res.status(403).send("Forbidden");
    }

    if (req.method === "POST") {
      // 1) Read raw body exactly as Meta sent it
      const raw = await readRaw(req);

      // 2) Optional signature check (recommended in prod)
      if (APP_SECRET) {
        const sig = req.headers["x-hub-signature-256"] || "";
        const expected = "sha256=" + crypto.createHmac("sha256", APP_SECRET).update(raw).digest("hex");
        if (sig !== expected) return res.status(401).send("Invalid signature");
      }

      // 3) Ack immediately (Meta needs fast 200)
      res.status(200).send("EVENT_RECEIVED");

      // 4) Process asynchronously (don't block response)
      try {
        const body = JSON.parse(raw.toString("utf8"));
        console.log("WA event:", JSON.stringify(body));
        // TODO: queue → n8n/worker; handle messages & statuses
      } catch (e) {
        console.error("Parse error:", e);
      }
      return;
    }

    res.setHeader("Allow", "GET, POST");
    res.status(405).send("Method Not Allowed");
  } catch (err) {
    console.error("Webhook error:", err);
    res.status(500).send("Server error");
  }
};