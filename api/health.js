module.exports = (req, res) => {
  const clientIP = req.headers['x-forwarded-for'] || req.connection.remoteAddress || 'unknown';
  const userAgent = req.headers['user-agent'] || 'unknown';
  const timestamp = new Date().toISOString();
  
  // Nigerian network diagnostics
  const isNigerianIP = clientIP.includes('196.') || clientIP.includes('41.'); // Common NG IP ranges
  const responseTime = Date.now();
  
  res.status(200).json({ 
    ok: true, 
    timestamp,
    clientIP: clientIP.substring(0, 10) + '...', // Privacy-safe
    userAgent: userAgent.substring(0, 50) + '...',
    nigerianNetwork: isNigerianIP,
    region: process.env.VERCEL_REGION || 'unknown',
    responseTimeMs: Date.now() - responseTime
  });
};