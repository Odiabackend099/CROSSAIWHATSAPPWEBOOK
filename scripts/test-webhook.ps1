# Test script for WhatsApp webhook verification and signature validation

Write-Host "Testing WhatsApp Webhook Implementation" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Configuration - Update these values to match your environment
$WEBHOOK_URL = "https://crossai.odia.dev/api/webhooks/whatsapp/crossai"
$VERIFY_TOKEN = "DWqYkAeTibcbfgFU8I3l2rQ21qDWnc1"
$APP_SECRET = $env:META_APP_SECRET # Set this environment variable

if (-not $APP_SECRET) {
    Write-Host "WARNING: META_APP_SECRET environment variable not set" -ForegroundColor Yellow
    Write-Host "Skipping signature validation tests" -ForegroundColor Yellow
    $SKIP_SIGNATURE_TESTS = $true
} else {
    Write-Host "Using APP_SECRET from environment variable" -ForegroundColor Green
    $SKIP_SIGNATURE_TESTS = $false
}

# Test 1: GET request (verification)
Write-Host "`n1. Testing GET request (verification)..." -ForegroundColor Cyan
$GET_URL = "${WEBHOOK_URL}?hub.mode=subscribe&hub.verify_token=${VERIFY_TOKEN}&hub.challenge=123456"
Write-Host "URL: $GET_URL" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri $GET_URL -Method GET -SkipCertificateCheck
    if ($response.StatusCode -eq 200 -and $response.Content -eq "123456") {
        Write-Host "✅ GET request test PASSED" -ForegroundColor Green
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    } else {
        Write-Host "❌ GET request test FAILED" -ForegroundColor Red
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ GET request test FAILED with exception: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: POST request without signature (if APP_SECRET not set)
if ($SKIP_SIGNATURE_TESTS) {
    Write-Host "`n2. Testing POST request (without signature validation)..." -ForegroundColor Cyan
    $BODY = '{"object":"whatsapp_business_account","entry":[{"id":"test","changes":[{"value":{"messaging_product":"whatsapp"},"field":"messages"}]}]}'
    
    try {
        $response = Invoke-WebRequest -Uri $WEBHOOK_URL -Method POST -Body $BODY -ContentType "application/json" -SkipCertificateCheck
        if ($response.StatusCode -eq 200 -and $response.Content -eq "EVENT_RECEIVED") {
            Write-Host "✅ POST request test PASSED" -ForegroundColor Green
            Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
            Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
        } else {
            Write-Host "❌ POST request test FAILED" -ForegroundColor Red
            Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
            Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ POST request test FAILED with exception: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    # Test 2: POST request with signature validation
    Write-Host "`n2. Testing POST request (with signature validation)..." -ForegroundColor Cyan
    $BODY = '{"object":"whatsapp_business_account","entry":[{"id":"test","changes":[{"value":{"messaging_product":"whatsapp"},"field":"messages"}]}]}'
    
    # Compute x-hub-signature-256
    $hmac = New-Object System.Security.Cryptography.HMACSHA256 ([Text.Encoding]::UTF8.GetBytes($APP_SECRET))
    $hash = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($BODY))
    $sig  = "sha256=" + ($hash | ForEach-Object ToString x2) -join ""
    
    Write-Host "Signature: $sig" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $WEBHOOK_URL -Method POST -Body $BODY -ContentType "application/json" -Headers @{"x-hub-signature-256" = $sig} -SkipCertificateCheck
        if ($response.StatusCode -eq 200 -and $response.Content -eq "EVENT_RECEIVED") {
            Write-Host "✅ POST request with signature test PASSED" -ForegroundColor Green
            Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
            Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
        } else {
            Write-Host "❌ POST request with signature test FAILED" -ForegroundColor Red
            Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
            Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ POST request with signature test FAILED with exception: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 3: POST request with invalid signature
    Write-Host "`n3. Testing POST request (with INVALID signature)..." -ForegroundColor Cyan
    $INVALID_SIG = "sha256=invalidsignature"
    
    try {
        $response = Invoke-WebRequest -Uri $WEBHOOK_URL -Method POST -Body $BODY -ContentType "application/json" -Headers @{"x-hub-signature-256" = $INVALID_SIG} -SkipCertificateCheck
        if ($response.StatusCode -eq 401) {
            Write-Host "✅ Invalid signature rejection test PASSED" -ForegroundColor Green
            Write-Host "   Status: $($response.StatusCode) (Expected 401)" -ForegroundColor Gray
        } else {
            Write-Host "❌ Invalid signature rejection test FAILED" -ForegroundColor Red
            Write-Host "   Status: $($response.StatusCode) (Expected 401)" -ForegroundColor Gray
        }
    } catch {
        # Some clients throw exceptions for non-2xx status codes
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Host "✅ Invalid signature rejection test PASSED" -ForegroundColor Green
            Write-Host "   Status: 401 (Expected)" -ForegroundColor Gray
        } else {
            Write-Host "❌ Invalid signature rejection test FAILED with exception: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Test 4: Health check endpoint
Write-Host "`n4. Testing health check endpoint..." -ForegroundColor Cyan
$HEALTH_URL = "https://crossai.odia.dev/api/webhooks/whatsapp/_health"

try {
    $response = Invoke-WebRequest -Uri $HEALTH_URL -Method GET -SkipCertificateCheck
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Health check test PASSED" -ForegroundColor Green
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Health check test FAILED" -ForegroundColor Red
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Health check test FAILED with exception: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest completed!" -ForegroundColor Green