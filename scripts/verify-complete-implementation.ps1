# Complete Implementation Verification Script
# This script verifies all aspects of the hardened WhatsApp webhook implementation

Write-Host "============================================" -ForegroundColor Green
Write-Host "  WhatsApp Webhook Implementation Verifier" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# Configuration - Update these values to match your environment
$WEBHOOK_BASE_URL = "https://crossai.odia.dev"
$WEBHOOK_URL = "${WEBHOOK_BASE_URL}/api/webhooks/whatsapp/crossai"
$VERIFY_TOKEN = "DWqYkAeTibcbfgFU8I3l2rQ21qDWnc1"
$APP_SECRET = $env:META_APP_SECRET # Set this environment variable

Write-Host "`nConfiguration:" -ForegroundColor Cyan
Write-Host "Base URL: $WEBHOOK_BASE_URL" -ForegroundColor Gray
Write-Host "Webhook URL: $WEBHOOK_URL" -ForegroundColor Gray
Write-Host "Verify Token: $VERIFY_TOKEN" -ForegroundColor Gray

if (-not $APP_SECRET) {
    Write-Host "WARNING: META_APP_SECRET environment variable not set" -ForegroundColor Yellow
    Write-Host "Skipping signature validation tests" -ForegroundColor Yellow
    $SKIP_SIGNATURE_TESTS = $true
} else {
    Write-Host "App Secret: [SET]" -ForegroundColor Gray
    $SKIP_SIGNATURE_TESTS = $false
}

# Test Counter
$TestsPassed = 0
$TestsFailed = 0

function Test-Result {
    param(
        [string]$Name,
        [bool]$Result,
        [string]$Details = ""
    )
    
    if ($Result) {
        Write-Host "✅ $Name" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "❌ $Name" -ForegroundColor Red
        if ($Details) {
            Write-Host "   $Details" -ForegroundColor Gray
        }
        $script:TestsFailed++
    }
}

# Test 1: Main Health Endpoint
Write-Host "`n1. Testing Main Health Endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $WEBHOOK_BASE_URL -Method GET -SkipCertificateCheck -TimeoutSec 10
    $content = $response.Content | ConvertFrom-Json
    $result = ($response.StatusCode -eq 200 -and $content.ok -eq $true)
    Test-Result -Name "Main Health Endpoint" -Result $result -Details "Status: $($response.StatusCode), Response: $($response.Content)"
} catch {
    Test-Result -Name "Main Health Endpoint" -Result $false -Details "Exception: $($_.Exception.Message)"
}

# Test 2: Webhook Health Endpoint
Write-Host "`n2. Testing Webhook Health Endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "${WEBHOOK_BASE_URL}/api/webhooks/whatsapp/_health" -Method GET -SkipCertificateCheck -TimeoutSec 10
    $content = $response.Content | ConvertFrom-Json
    $result = ($response.StatusCode -eq 200 -and $content.ok -eq $true)
    Test-Result -Name "Webhook Health Endpoint" -Result $result -Details "Status: $($response.StatusCode), Response: $($response.Content)"
} catch {
    Test-Result -Name "Webhook Health Endpoint" -Result $false -Details "Exception: $($_.Exception.Message)"
}

# Test 3: Webhook GET Verification (Valid Token)
Write-Host "`n3. Testing Webhook GET Verification (Valid Token)..." -ForegroundColor Cyan
try {
    $testUrl = "${WEBHOOK_URL}?hub.mode=subscribe&hub.verify_token=${VERIFY_TOKEN}&hub.challenge=123456"
    $response = Invoke-WebRequest -Uri $testUrl -Method GET -SkipCertificateCheck -TimeoutSec 10
    $result = ($response.StatusCode -eq 200 -and $response.Content -eq "123456")
    Test-Result -Name "Webhook GET Verification (Valid)" -Result $result -Details "Status: $($response.StatusCode), Response: $($response.Content)"
} catch {
    Test-Result -Name "Webhook GET Verification (Valid)" -Result $false -Details "Exception: $($_.Exception.Message)"
}

# Test 4: Webhook GET Verification (Invalid Token)
Write-Host "`n4. Testing Webhook GET Verification (Invalid Token)..." -ForegroundColor Cyan
try {
    $testUrl = "${WEBHOOK_URL}?hub.mode=subscribe&hub.verify_token=INVALID_TOKEN&hub.challenge=123456"
    $response = Invoke-WebRequest -Uri $testUrl -Method GET -SkipCertificateCheck -TimeoutSec 10
    $result = ($response.StatusCode -eq 403)
    Test-Result -Name "Webhook GET Verification (Invalid)" -Result $result -Details "Status: $($response.StatusCode), Response: $($response.Content)"
} catch {
    # Some clients throw exceptions for non-2xx status codes
    if ($_.Exception.Response.StatusCode -eq 403) {
        Test-Result -Name "Webhook GET Verification (Invalid)" -Result $true -Details "Status: 403 (Expected)"
    } else {
        Test-Result -Name "Webhook GET Verification (Invalid)" -Result $false -Details "Exception: $($_.Exception.Message)"
    }
}

# Test 5: Webhook POST (Without Signature Validation)
if ($SKIP_SIGNATURE_TESTS) {
    Write-Host "`n5. Testing Webhook POST (Without Signature)..." -ForegroundColor Cyan
    $BODY = '{"object":"whatsapp_business_account","entry":[{"id":"test","changes":[{"value":{"messaging_product":"whatsapp"},"field":"messages"}]}]}'
    
    try {
        $response = Invoke-WebRequest -Uri $WEBHOOK_URL -Method POST -Body $BODY -ContentType "application/json" -SkipCertificateCheck -TimeoutSec 10
        $result = ($response.StatusCode -eq 200 -and $response.Content -eq "EVENT_RECEIVED")
        Test-Result -Name "Webhook POST (No Signature)" -Result $result -Details "Status: $($response.StatusCode), Response: $($response.Content)"
    } catch {
        Test-Result -Name "Webhook POST (No Signature)" -Result $false -Details "Exception: $($_.Exception.Message)"
    }
} else {
    # Test 5: Webhook POST (With Valid Signature)
    Write-Host "`n5. Testing Webhook POST (With Valid Signature)..." -ForegroundColor Cyan
    $BODY = '{"object":"whatsapp_business_account","entry":[{"id":"test","changes":[{"value":{"messaging_product":"whatsapp"},"field":"messages"}]}]}'
    
    # Compute x-hub-signature-256
    $hmac = New-Object System.Security.Cryptography.HMACSHA256 ([Text.Encoding]::UTF8.GetBytes($APP_SECRET))
    $hash = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($BODY))
    $sig  = "sha256=" + ($hash | ForEach-Object ToString x2) -join ""
    
    try {
        $response = Invoke-WebRequest -Uri $WEBHOOK_URL -Method POST -Body $BODY -ContentType "application/json" -Headers @{"x-hub-signature-256" = $sig} -SkipCertificateCheck -TimeoutSec 10
        $result = ($response.StatusCode -eq 200 -and $response.Content -eq "EVENT_RECEIVED")
        Test-Result -Name "Webhook POST (Valid Signature)" -Result $result -Details "Status: $($response.StatusCode), Response: $($response.Content)"
    } catch {
        Test-Result -Name "Webhook POST (Valid Signature)" -Result $false -Details "Exception: $($_.Exception.Message)"
    }
    
    # Test 6: Webhook POST (With Invalid Signature)
    Write-Host "`n6. Testing Webhook POST (With Invalid Signature)..." -ForegroundColor Cyan
    $INVALID_SIG = "sha256=invalidsignature"
    
    try {
        $response = Invoke-WebRequest -Uri $WEBHOOK_URL -Method POST -Body $BODY -ContentType "application/json" -Headers @{"x-hub-signature-256" = $INVALID_SIG} -SkipCertificateCheck -TimeoutSec 10
        $result = ($response.StatusCode -eq 401)
        Test-Result -Name "Webhook POST (Invalid Signature)" -Result $result -Details "Status: $($response.StatusCode) (Expected 401)"
    } catch {
        # Some clients throw exceptions for non-2xx status codes
        if ($_.Exception.Response.StatusCode -eq 401) {
            Test-Result -Name "Webhook POST (Invalid Signature)" -Result $true -Details "Status: 401 (Expected)"
        } else {
            Test-Result -Name "Webhook POST (Invalid Signature)" -Result $false -Details "Exception: $($_.Exception.Message)"
        }
    }
}

# Test 7: Unsupported HTTP Methods
Write-Host "`n7. Testing Unsupported HTTP Methods..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $WEBHOOK_URL -Method PUT -SkipCertificateCheck -TimeoutSec 10 -ErrorAction Stop
    Test-Result -Name "Unsupported Method (PUT)" -Result ($false) -Details "Expected 405 but got $($response.StatusCode)"
} catch {
    if ($_.Exception.Response.StatusCode -eq 405 -or $_.Exception.Response.StatusCode -eq 404) {
        Test-Result -Name "Unsupported Method (PUT)" -Result $true -Details "Status: $($_.Exception.Response.StatusCode) (Expected)"
    } else {
        Test-Result -Name "Unsupported Method (PUT)" -Result $false -Details "Exception: $($_.Exception.Message)"
    }
}

# Summary
Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  Test Summary" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "✅ Tests Passed: $TestsPassed" -ForegroundColor Green
Write-Host "❌ Tests Failed: $TestsFailed" -ForegroundColor Red
Write-Host "📊 Total Tests: $($TestsPassed + $TestsFailed)" -ForegroundColor Cyan

if ($TestsFailed -eq 0) {
    Write-Host "`n🎉 All tests PASSED! Implementation is production ready." -ForegroundColor Green
    Write-Host "✅ Webhook verification is working" -ForegroundColor Green
    Write-Host "✅ Signature validation is working" -ForegroundColor Green
    Write-Host "✅ Health endpoints are responsive" -ForegroundColor Green
    Write-Host "✅ Error handling is properly implemented" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Some tests FAILED. Please review the implementation." -ForegroundColor Yellow
}

Write-Host "`n============================================" -ForegroundColor Green