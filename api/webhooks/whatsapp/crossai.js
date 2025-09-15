module.exports = async (req, res) => {
  try {
    const VERIFY_TOKEN = process.env.VERIFY_TOKEN || "";

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

    if (req.method === "POST") {
      try { console.log("Incoming WhatsApp event:", JSON.stringify(req.body || {}, null, 2)); } catch (_) {}
      return res.status(200).json({ ok: true });
    }

    res.setHeader("Allow", "GET, POST");
    return res.status(405).end("Method Not Allowed");
  } catch (err) {
    console.error("Webhook handler error:", err);
    return res.status(500).send("Internal Server Error");
  }
};
