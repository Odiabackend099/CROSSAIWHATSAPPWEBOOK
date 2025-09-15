module.exports = async (req, res) => {
  try {
    const VERIFY_TOKEN = process.env.VERIFY_TOKEN || "";
    
    // Nigerian Network: Add request ID for debugging
    const requestId = Math.random().toString(36).substring(7);
    console.log([]  request from );

    if (req.method === "GET") {
      const q = req.query || {};
      const mode = q["hub.mode"];
      const token = q["hub.verify_token"];
      const challenge = q["hub.challenge"];
      
      console.log([] Verification attempt - mode: , token match: );
      
      if (mode === "subscribe" && token === VERIFY_TOKEN && challenge) {
        console.log([] Verification successful);
        return res.status(200).send(challenge);
      }
      console.log([] Verification failed);
      return res.status(403).send("Forbidden");
    }

    if (req.method === "POST") {
      console.log([] WhatsApp webhook:, JSON.stringify(req.body || {}, null, 2));
      
      // Nigerian Network: Quick response to prevent timeouts
      res.status(200).json({ ok: true, requestId });
      
      // Process webhook asynchronously if needed
      // TODO: Add your WhatsApp business logic here
      return;
    }

    res.setHeader("Allow", "GET, POST");
    return res.status(405).end("Method Not Allowed");
  } catch (err) {
    console.error("Webhook handler error:", err);
    return res.status(500).json({ error: "Internal Server Error", timestamp: new Date().toISOString() });
  }
};