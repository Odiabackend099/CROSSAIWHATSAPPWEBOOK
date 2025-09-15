# Complete Deployment Guide for webhook-crossai

## 🎯 **Repository Setup**

### New Repository: `https://github.com/Odiabackend099/webhook-crossai.git`

This guide will walk you through setting up the CrossAI WhatsApp webhook from scratch in your new repository.

---

## 📁 **Project Files to Include**

### Core Files (Required)
```
webhook-crossai/
├── api/webhooks/whatsapp/crossai.js    # Main webhook handler
├── dev-server.js                       # Local development server
├── package.json                        # Dependencies and scripts
├── vercel.json                         # Vercel configuration
├── .gitignore                          # Git ignore patterns
└── .env.example                        # Environment template
```

### Testing & Scripts
```
├── scripts/
│   ├── curl-examples.sh                # Manual testing commands
│   ├── hmac-post.js                   # HMAC testing script
│   ├── verify-get.js                  # Verification testing
│   └── production-hmac-test.js         # Complete test suite
```

### Documentation
```
├── README.md                           # Main documentation
├── DEPLOYMENT_GUIDE.md                 # This guide
├── TESTING_GUIDE.md                    # Testing procedures
└── PRODUCTION_REPORT.md                # Test results
```

---

## 🔧 **Step-by-Step Setup**

### Step 1: Initialize New Repository
```bash
# Create new repository on GitHub: webhook-crossai
# Clone the empty repository
git clone https://github.com/Odiabackend099/webhook-crossai.git
cd webhook-crossai

# Initialize package.json
npm init -y
```

### Step 2: Copy Core Files
Copy these files from your current project to the new repository:

#### `package.json`
```json
{
  "name": "webhook-crossai",
  "version": "1.0.0",
  "type": "module",
  "description": "Production-ready WhatsApp Cloud API webhook for CrossAI platform",
  "main": "dev-server.js",
  "scripts": {
    "dev": "node dev-server.js",
    "start": "node dev-server.js",
    "test:hmac": "node scripts/hmac-post.js",
    "test:verify": "node scripts/verify-get.js",
    "test:production": "node scripts/production-hmac-test.js"
  },
  "dependencies": {
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "raw-body": "^2.5.2",
    "node-fetch": "^3.3.2"
  },
  "keywords": ["whatsapp", "webhook", "crossai", "vercel", "serverless"],
  "author": "CrossAI Team",
  "license": "MIT"
}
```

#### `vercel.json`
```json
{
  "version": 2,
  "regions": ["fra1", "iad1"],
  "functions": {
    "api/webhooks/whatsapp/crossai.js": {
      "runtime": "nodejs18.x",
      "memory": 128
    }
  }
}
```

#### `.gitignore`
```
node_modules/
.env
.env.*
!.env.example
.vercel/
.DS_Store
Thumbs.db
*.log
```

#### `.env.example`
```bash
# WhatsApp webhook verification token (exactly 32 chars recommended)
VERIFY_TOKEN=CHANGE_ME_32_CHAR_RANDOM

# Meta App secret (from Meta App → Settings → Basic)
META_APP_SECRET=CHANGE_ME_META_APP_SECRET

# Local dev only
NODE_ENV=development
PORT=3000

# Optional: For advanced testing and n8n integration
GRAPH_VERSION=v20.0
META_APP_ID=CHANGE_ME_APP_ID
WABA_ID=CHANGE_ME_WABA_ID
WABA_PHONE_NUMBER_ID=CHANGE_ME_PHONE_ID
WABA_BUSINESS_ID=CHANGE_ME_BUSINESS_ID
WABA_PERMANENT_TOKEN=CHANGE_ME_SYS_USER_TOKEN
```

### Step 3: Create Directory Structure
```bash
# Create required directories
mkdir -p api/webhooks/whatsapp
mkdir -p scripts
mkdir -p docs

# Copy the main webhook handler
# (Copy api/webhooks/whatsapp/crossai.js from current project)

# Copy the development server
# (Copy dev-server.js from current project)

# Copy all script files
# (Copy scripts/* from current project)
```

### Step 4: Install Dependencies
```bash
npm install
```

### Step 5: Initial Commit
```bash
git add .
git commit -m "Initial commit: Production-ready WhatsApp webhook"
git push origin main
```

---

## 🚀 **Vercel Deployment**

### Method 1: Vercel CLI (Recommended)
```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy to production
vercel --prod

# Note the deployment URL (e.g., https://webhook-crossai.vercel.app)
```

### Method 2: GitHub Integration
1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click **"New Project"**
3. Import from GitHub: `Odiabackend099/webhook-crossai`
4. Framework Preset: **Other** (or Node.js)
5. Deploy!

### Step 6: Configure Environment Variables
In **Vercel Dashboard** → Your Project → **Settings** → **Environment Variables**:

```bash
# Add these variables:
VERIFY_TOKEN=<generate_32_char_token>
META_APP_SECRET=<your_meta_app_secret>

# Generate VERIFY_TOKEN:
node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"
```

### Step 7: Deploy Health Check Endpoint
The health check endpoint has been added at:
`/api/webhooks/whatsapp/_health`

This endpoint returns a JSON response with the current timestamp and can be used for uptime monitoring.

---

## 🔗 **Meta App Configuration**

### Step 1: Access Meta Developer Console
1. Go to [Meta Developer Console](https://developers.facebook.com/)
2. Select your app → **WhatsApp** → **Configuration**

### Step 2: Configure Webhook
```
Callback URL: https://webhook-crossai.vercel.app/api/webhooks/whatsapp/crossai
Verify Token: <same_as_VERIFY_TOKEN_env_var>
```

### Step 3: Verify Webhook
1. Click **"Verify and Save"**
2. Should show **"✅ Success"**
3. If failed, check:
   - Vercel deployment status
   - Environment variables are set
   - URL is correct (no trailing slash)

### Step 4: Subscribe to Webhook Fields
Enable these webhook fields:
- ✅ `messages`
- ✅ `message_template_status_update`
- ✅ `account_update`
- ✅ `phone_number_name_update`

---

## 🧪 **Testing the Deployment**

### Test 1: Health Check
```bash
curl https://webhook-crossai.vercel.app/
# Expected: {"ok": true, "ts": "2025-09-15T..."}
```

### Test 2: Webhook Verification
```bash
curl "https://webhook-crossai.vercel.app/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=YOUR_TOKEN&hub.challenge=test123"
# Expected: test123
```

### Test 3: HMAC Validation
```bash
# Run the production test script
node scripts/production-hmac-test.js
# Expected: All tests PASS
```

### Test 4: Send Test WhatsApp Message
1. Send a message to your WhatsApp Business number
2. Check Vercel logs: `vercel logs https://webhook-crossai.vercel.app --follow`
3. Should see message processing logs

---

## 📊 **Monitoring & Maintenance**

### View Logs
```bash
# Real-time logs
vercel logs https://webhook-crossai.vercel.app --follow

# Last hour logs
vercel logs https://webhook-crossai.vercel.app --since 1h
```

### Health Monitoring
Set up monitoring for:
- Webhook endpoint availability
- Response time metrics
- Error rate tracking
- Memory usage

### Update Deployment
```bash
# Make changes to code
git add .
git commit -m "Update webhook functionality"
git push origin main

# Vercel auto-deploys on push (if GitHub integration enabled)
# Or manual deploy:
vercel --prod
```

---

## 🆘 **Troubleshooting Guide**

### Issue: Webhook Verification Fails
```bash
# Check environment variables
vercel env ls

# Test locally first
cp .env.example .env
# Edit .env with your tokens
npm run dev
curl "http://localhost:3000/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=YOUR_TOKEN&hub.challenge=test"
```

### Issue: HMAC Signature Invalid
```bash
# Verify Meta App Secret is correct
vercel env ls | grep META_APP_SECRET

# Test HMAC generation locally
node scripts/production-hmac-test.js
```

### Issue: 500 Internal Server Error
```bash
# Check function logs
vercel logs --follow

# Common causes:
# - Missing environment variables
# - Syntax errors in code
# - Memory limits exceeded
```

### Issue: Cold Start Timeouts
```bash
# Optimize function:
# - Reduce memory usage
# - Minimize dependencies
# - Use faster regions

# Update vercel.json regions:
{
  "regions": ["fra1"]  // Frankfurt (closest to Nigeria)
}
```

---

## 🔒 **Security Checklist**

### Environment Variables
- ✅ Never commit `.env` files to Git
- ✅ Use Vercel Dashboard for production secrets
- ✅ Rotate tokens periodically
- ✅ Use strong, random 32-character tokens

### Code Security
- ✅ HMAC validation on all POST requests
- ✅ Input validation and sanitization
- ✅ Error handling without information disclosure
- ✅ No sensitive data in logs

### Deployment Security
- ✅ HTTPS only (enforced by Vercel)
- ✅ Function memory limits set
- ✅ No unnecessary dependencies
- ✅ Regular security updates

---

## 📈 **Performance Optimization**

### Vercel Configuration
```json
{
  "regions": ["fra1"],          // Single region for Nigeria
  "functions": {
    "api/webhooks/whatsapp/crossai.js": {
      "runtime": "nodejs18.x",   // Latest stable
      "memory": 128              // Minimal for webhook
    }
  }
}
```

### Code Optimization
- ✅ Minimal dependencies
- ✅ Efficient JSON parsing
- ✅ Fast HMAC validation
- ✅ Early return patterns

### Monitoring Metrics
- Response time < 100ms target
- Memory usage < 50MB typical
- Error rate < 0.1%
- Uptime > 99.9%

---

## ✅ **Deployment Checklist**

### Pre-Deployment
- [ ] Repository created: `webhook-crossai`
- [ ] All files copied correctly
- [ ] Dependencies installed: `npm install`
- [ ] Local testing passed: `npm run dev`
- [ ] Environment template created: `.env.example`

### Vercel Deployment
- [ ] Vercel project created
- [ ] Environment variables configured
- [ ] Production deployment successful
- [ ] Health endpoint responding
- [ ] Function logs showing no errors

### Meta App Configuration
- [ ] Webhook URL configured
- [ ] Verification token set
- [ ] Webhook verification successful
- [ ] Webhook fields subscribed
- [ ] Test message processed

### Final Validation
- [ ] Production test suite passes
- [ ] HMAC validation working
- [ ] Error handling functional
- [ ] Performance metrics acceptable
- [ ] Security audit complete

---

**🎉 Deployment Complete!**

Your CrossAI WhatsApp webhook is now live and ready for production traffic at:
`https://webhook-crossai.vercel.app/api/webhooks/whatsapp/crossai`