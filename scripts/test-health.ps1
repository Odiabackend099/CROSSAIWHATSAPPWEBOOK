# Test script for the new health check endpoint
Write-Host "Testing Health Check Endpoints" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Configuration
$BASE_URL = "https://crossai.odia.dev"

# Test 1: Main health endpoint
Write-Host "`n1. Testing main health endpoint..." -ForegroundColor Cyan
$HEALTH_URL = "$BASE_URL/"

try {
    $response = Invoke-WebRequest -Uri $HEALTH_URL -Method GET -SkipCertificateCheck
    $content = $response.Content | ConvertFrom-Json
    
    if ($response.StatusCode -eq 200 -and $content.ok -eq $true) {
        Write-Host "✅ Main health endpoint test PASSED" -ForegroundColor Green
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Main health endpoint test FAILED" -ForegroundColor Red
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Main health endpoint test FAILED with exception: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Webhook-specific health check endpoint
Write-Host "`n2. Testing webhook health check endpoint..." -ForegroundColor Cyan
$WEBHOOK_HEALTH_URL = "$BASE_URL/api/webhooks/whatsapp/_health"

try {
    $response = Invoke-WebRequest -Uri $WEBHOOK_HEALTH_URL -Method GET -SkipCertificateCheck
    $content = $response.Content | ConvertFrom-Json
    
    if ($response.StatusCode -eq 200 -and $content.ok -eq $true) {
        Write-Host "✅ Webhook health check endpoint test PASSED" -ForegroundColor Green
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Webhook health check endpoint test FAILED" -ForegroundColor Red
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Webhook health check endpoint test FAILED with exception: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nHealth check tests completed!" -ForegroundColor Green