module.exports = (req, res) => {
  const timestamp = new Date().toISOString();
  const region = process.env.VERCEL_REGION || "unknown";
  
  res.status(200).json({
    status: "healthy",
    timestamp,
    region,
    service: "WhatsApp Webhook"
  });
};