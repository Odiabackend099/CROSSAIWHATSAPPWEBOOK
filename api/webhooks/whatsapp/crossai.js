// CommonJS Vercel Node Function: GET verify + POST (optional HMAC)
const crypto = require("crypto");

function timingSafeEq(a, b) {
  const ab = Buffer.from(String(a), "utf8");
  const bb = Buffer.from(String(b), "utf8");
  if (ab.length !== bb.length) return false;
  return crypto.timingSafeEqual(ab, bb);
}

function getRawBody(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => (data += chunk));
    req.on("end", () => resolve(data));
    req.on("error", reject);
  });
}

module.exports = async (req, res) => {
  try {
    const VERIFY_TOKEN = process.env.VERIFY_TOKEN || "";
    const APP_SECRET = process.env.META_APP_SECRET || ""; // optional

    // 1) Meta webhook verification (GET)
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

    // 2) Webhook events (POST)
    if (req.method === "POST") {
      const raw = await getRawBody(req);
      const sig = req.headers["x-hub-signature-256"] || "";

      if (APP_SECRET) {
        const expected =
          "sha256=" + crypto.createHmac("sha256", APP_SECRET).update(raw).digest("hex");
        if (!timingSafeEq(expected, sig)) {
          return res.status(401).json({ ok: false, error: "invalid_signature" });
        }
      }

      let body = {};
      try { body = raw ? JSON.parse(raw) : (req.body || {}); } catch {}

      console.log("WABA event:", JSON.stringify(body, null, 2));
      return res.status(200).json({ ok: true });
    }

    res.setHeader("Allow", "GET, POST");
    return res.status(405).end("Method Not Allowed");
  } catch (err) {
    console.error("Webhook handler error:", err);
    return res.status(500).send("Internal Server Error");
  }
};