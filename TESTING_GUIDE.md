# Complete Testing Guide for webhook-crossai

## 🧪 **Comprehensive Testing Strategy**

This guide covers all testing procedures for the CrossAI WhatsApp webhook, from local development to production validation.

---

## 🏗️ **Testing Environment Setup**

### Prerequisites
```bash
# Node.js 18+ installed
node --version  # Should be 18.x or higher

# Git installed
git --version

# curl installed (for manual testing)
curl --version

# Optional: Vercel CLI for production testing
npm install -g vercel
```

### Project Setup
```bash
# Clone and setup
git clone https://github.com/Odiabackend099/webhook-crossai.git
cd webhook-crossai
npm install

# Setup environment
cp .env.example .env
# Edit .env with your test tokens
```

---

## 🔧 **Environment Configuration for Testing**

### Generate Test Tokens
```bash
# Generate secure VERIFY_TOKEN (32 characters)
node -e "console.log('VERIFY_TOKEN=' + require('crypto').randomBytes(16).toString('hex'))"

# Generate secure META_APP_SECRET (64 characters) 
node -e "console.log('META_APP_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"
```

### Test Environment Variables
```bash
# .env file for testing
VERIFY_TOKEN=60fcd503ef1fdffba5eca6b6a53b05d8
META_APP_SECRET=2b96301695159c25aa5e7644477eaa500b05ad28b9d38b0238e456b0be504a4d
NODE_ENV=development
PORT=3000
```

---

## 🚀 **Local Development Testing**

### Step 1: Start Development Server
```bash
# Terminal 1: Start server
npm run dev
# Expected output: "Dev server http://localhost:3000"
```

### Step 2: Health Endpoint Test
```bash
# Terminal 2: Test health endpoint
curl -s http://localhost:3000/ | jq .
# Expected: {"ok": true, "ts": "2025-09-15T..."}

# Performance test (5 iterations)
for i in {1..5}; do
  time curl -s http://localhost:3000/ > /dev/null
done
# Expected: All under 100ms
```

### Step 3: Webhook Verification Testing
```bash
# Test with correct token
curl "http://localhost:3000/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=60fcd503ef1fdffba5eca6b6a53b05d8&hub.challenge=test123"
# Expected: test123

# Test with wrong token
curl "http://localhost:3000/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=wrong_token&hub.challenge=test123"
# Expected: HTTP 403 Forbidden

# Test missing parameters
curl "http://localhost:3000/api/webhooks/whatsapp/crossai"
# Expected: HTTP 403 Forbidden
```

### Step 4: HMAC Signature Testing
```bash
# Run automated HMAC test
npm run test:hmac
# Expected output:
# ✅ Valid signature test: PASS
# ✅ Invalid signature test: PASS

# Run comprehensive production test
npm run test:production
# Expected: All tests PASS
```

---

## 🔐 **Security Testing**

### HMAC Signature Validation
```bash
# Test 1: Valid signature with real WhatsApp payload
node scripts/production-hmac-test.js
# Should show:
# === PRODUCTION HMAC SIGNATURE TEST ===
# Valid signature test: PASS
# Invalid signature test: PASS
```

### Timing Attack Resistance
```bash
# Test timing-safe comparison
node -e "
const crypto = require('crypto');
const secret = '2b96301695159c25aa5e7644477eaa500b05ad28b9d38b0238e456b0be504a4d';
const body = JSON.stringify({test: 'data'});
const sig1 = 'sha256=' + crypto.createHmac('sha256', secret).update(body).digest('hex');
const sig2 = 'sha256=wrong_signature';

console.log('Correct signature length:', sig1.length);
console.log('Wrong signature length:', sig2.length);
console.log('Lengths equal:', sig1.length === sig2.length);
"
# Verifies timing-safe comparison prerequisites
```

### Input Validation Testing
```bash
# Test oversized payload
curl -X POST http://localhost:3000/api/webhooks/whatsapp/crossai \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature-256: sha256=invalid" \
  -d "$(python3 -c "print('{\"large\":\"' + 'x'*10000 + '\"}')")"
# Expected: HTTP 403 (rejected due to invalid signature)

# Test malformed JSON
curl -X POST http://localhost:3000/api/webhooks/whatsapp/crossai \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature-256: sha256=invalid" \
  -d "invalid json"
# Expected: HTTP 403 (rejected due to invalid signature)
```

---

## 📊 **Performance Testing**

### Response Time Testing
```bash
# Latency measurement script
for i in {1..10}; do
  echo "Test $i:"
  time curl -s http://localhost:3000/ > /dev/null
  sleep 0.1
done
# Target: All under 100ms
```

### Load Testing (Basic)
```bash
# Concurrent requests test
for i in {1..20}; do
  curl -s http://localhost:3000/ &
done
wait
echo "Concurrent test completed"
# Should handle 20 concurrent requests without errors
```

### Memory Usage Monitoring
```bash
# Start server with memory monitoring
node --max-old-space-size=512 dev-server.js &
SERVER_PID=$!

# Generate some load
for i in {1..100}; do
  curl -s http://localhost:3000/ > /dev/null
done

# Check memory usage (Linux/Mac)
ps -p $SERVER_PID -o pid,vsz,rss,comm
kill $SERVER_PID
```

---

## 🌐 **Production Testing**

### Pre-Deployment Testing
```bash
# Verify all files present
ls -la
# Should include: package.json, vercel.json, api/, scripts/

# Verify dependencies
npm audit
# Should show no critical vulnerabilities

# Verify environment template
cat .env.example
# Should not contain real secrets
```

### Vercel Deployment Testing
```bash
# Deploy to staging/preview
vercel

# Test deployed preview
PREVIEW_URL=$(vercel ls | grep webhook-crossai | awk '{print $2}')
curl "$PREVIEW_URL/"
# Expected: {"ok": true, "ts": "..."}

# Deploy to production
vercel --prod
```

### Production Endpoint Testing
```bash
# Replace with your actual production URL
PROD_URL="https://webhook-crossai.vercel.app"

# Test 1: Health check
curl -s "$PROD_URL/" | jq .
# Expected: {"ok": true, "ts": "..."}

# Test 2: Webhook verification (use your real token)
curl "$PROD_URL/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=YOUR_REAL_TOKEN&hub.challenge=production_test"
# Expected: production_test

# Test 3: Invalid requests
curl "$PROD_URL/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=wrong&hub.challenge=test"
# Expected: HTTP 403
```

---

## 📱 **WhatsApp Integration Testing**

### Meta Console Verification
1. **Meta Developer Console** → Your App → **WhatsApp** → **Configuration**
2. **Callback URL**: `https://webhook-crossai.vercel.app/api/webhooks/whatsapp/crossai`
3. **Verify Token**: Your production VERIFY_TOKEN
4. Click **"Verify and Save"**
5. Should show: **"✅ Webhook verified successfully"**

### End-to-End Message Testing
```bash
# Monitor webhook logs
vercel logs https://webhook-crossai.vercel.app --follow &

# Send test message to your WhatsApp Business number
# Check logs for message processing

# Expected log output:
# WhatsApp MSG { from: '234801234567', type: 'text', text: 'test message' }
```

### Webhook Field Testing
Test each webhook field type:

#### 1. Messages
- Send text message → Check logs
- Send image → Check logs  
- Send document → Check logs

#### 2. Message Status Updates
- Send message → Check delivery status in logs

#### 3. Account Updates
- Change business profile → Check logs

---

## 🧪 **Automated Test Scripts**

### Test Runner Script
```bash
#!/bin/bash
# test-runner.sh

echo "🧪 Running CrossAI Webhook Test Suite"
echo "====================================="

# Test 1: Health Check
echo "1. Health Check Test..."
HEALTH=$(curl -s http://localhost:3000/ | jq -r .ok)
if [ "$HEALTH" = "true" ]; then
    echo "✅ Health check PASSED"
else
    echo "❌ Health check FAILED"
    exit 1
fi

# Test 2: Webhook Verification
echo "2. Webhook Verification Test..."
CHALLENGE=$(curl -s "http://localhost:3000/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=$VERIFY_TOKEN&hub.challenge=test123")
if [ "$CHALLENGE" = "test123" ]; then
    echo "✅ Webhook verification PASSED"
else
    echo "❌ Webhook verification FAILED"
    exit 1
fi

# Test 3: HMAC Validation
echo "3. HMAC Validation Test..."
npm run test:hmac > /tmp/hmac_test.log 2>&1
if grep -q "Valid signature test: PASS" /tmp/hmac_test.log; then
    echo "✅ HMAC validation PASSED"
else
    echo "❌ HMAC validation FAILED"
    cat /tmp/hmac_test.log
    exit 1
fi

echo "🎉 All tests PASSED!"
```

### Performance Test Script
```javascript
// performance-test.js
import fetch from 'node-fetch';

const BASE_URL = 'http://localhost:3000';
const TEST_ITERATIONS = 100;

async function runPerformanceTest() {
    console.log(`🚀 Running performance test (${TEST_ITERATIONS} iterations)`);
    
    const times = [];
    
    for (let i = 0; i < TEST_ITERATIONS; i++) {
        const start = Date.now();
        
        try {
            const response = await fetch(BASE_URL);
            const data = await response.json();
            
            if (!data.ok) {
                throw new Error('Health check failed');
            }
            
            const end = Date.now();
            times.push(end - start);
            
        } catch (error) {
            console.error(`❌ Test ${i + 1} failed:`, error.message);
            return;
        }
    }
    
    const avg = times.reduce((a, b) => a + b) / times.length;
    const min = Math.min(...times);
    const max = Math.max(...times);
    
    console.log(`📊 Performance Results:`);
    console.log(`   Average: ${avg.toFixed(2)}ms`);
    console.log(`   Min: ${min}ms`);
    console.log(`   Max: ${max}ms`);
    console.log(`   Target: <100ms`);
    console.log(`   Status: ${avg < 100 ? '✅ PASSED' : '❌ FAILED'}`);
}

runPerformanceTest().catch(console.error);
```

---

## 🔍 **Debugging & Troubleshooting**

### Enable Debug Logging
```bash
# Local development with debug logs
DEBUG=* npm run dev

# Or specific debug categories
DEBUG=express:* npm run dev
```

### Common Test Failures

#### "Health endpoint not responding"
```bash
# Check if server started
ps aux | grep node

# Check port availability
netstat -tlnp | grep 3000

# Check for errors
npm run dev 2>&1 | tee debug.log
```

#### "Webhook verification failed"
```bash
# Verify token format
echo $VERIFY_TOKEN | wc -c  # Should be 33 (32 chars + newline)

# Check URL encoding
curl -v "http://localhost:3000/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=$VERIFY_TOKEN&hub.challenge=test"
```

#### "HMAC signature invalid"
```bash
# Verify secret format
echo $META_APP_SECRET | wc -c  # Should be 65 (64 chars + newline)

# Test HMAC generation manually
node -e "
const crypto = require('crypto');
const secret = process.env.META_APP_SECRET;
const body = JSON.stringify({test: 'data'});
const sig = 'sha256=' + crypto.createHmac('sha256', secret).update(body).digest('hex');
console.log('Generated signature:', sig);
"
```

### Log Analysis
```bash
# Search for errors in logs
grep -i error debug.log

# Search for specific webhook events
grep "WhatsApp MSG" debug.log

# Count successful requests
grep "200" debug.log | wc -l
```

---

## ✅ **Testing Checklist**

### Pre-Deployment Testing
- [ ] Health endpoint responds correctly
- [ ] Webhook verification with valid token succeeds
- [ ] Webhook verification with invalid token fails (403)
- [ ] HMAC signature validation passes with valid signature
- [ ] HMAC signature validation fails with invalid signature (403)
- [ ] Response times under 100ms consistently
- [ ] No memory leaks in extended testing
- [ ] All dependencies security-audited
- [ ] Environment template contains no secrets

### Production Testing
- [ ] Vercel deployment successful
- [ ] Environment variables configured correctly
- [ ] Production health endpoint responsive
- [ ] Meta Console webhook verification successful
- [ ] Webhook fields subscribed correctly
- [ ] Test WhatsApp message processed correctly
- [ ] Error handling working (invalid requests rejected)
- [ ] Performance metrics within targets
- [ ] Security validations passing
- [ ] Monitoring and logging functional

### Acceptance Criteria
- [ ] All automated tests pass
- [ ] Manual testing successful
- [ ] Security audit complete
- [ ] Performance requirements met
- [ ] Documentation updated
- [ ] Production deployment verified
- [ ] End-to-end WhatsApp integration working

---

## 📊 **Test Reporting**

### Generate Test Report
```bash
# Run complete test suite and generate report
{
    echo "# CrossAI Webhook Test Report"
    echo "Generated: $(date)"
    echo ""
    
    echo "## Health Test"
    curl -s http://localhost:3000/ | jq .
    echo ""
    
    echo "## Performance Test"
    for i in {1..5}; do
        time curl -s http://localhost:3000/ > /dev/null
    done 2>&1 | grep real
    echo ""
    
    echo "## Security Test"
    npm run test:hmac
    
} > test-report.md
```

**🎯 Testing Complete!**

Your webhook is now thoroughly tested and ready for production deployment!