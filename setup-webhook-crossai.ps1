# PowerShell script to setup webhook-crossai repository
# Run this script from your new webhook-crossai directory

param(
    [string]$SourcePath = "c:\Users\OD~IA\Desktop\Odiadev-2025\ODIADEV TTS\Crossai webhook whatsapp",
    [string]$TargetPath = "."
)

Write-Host "🚀 Setting up webhook-crossai repository..." -ForegroundColor Green
Write-Host "Source: $SourcePath" -ForegroundColor Cyan
Write-Host "Target: $TargetPath" -ForegroundColor Cyan

# Create directory structure
Write-Host "`n📁 Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "$TargetPath\api\webhooks\whatsapp" -Force | Out-Null
New-Item -ItemType Directory -Path "$TargetPath\scripts" -Force | Out-Null
New-Item -ItemType Directory -Path "$TargetPath\docs" -Force | Out-Null

# Copy core application files
Write-Host "📦 Copying core application files..." -ForegroundColor Yellow
Copy-Item "$SourcePath\api\webhooks\whatsapp\crossai.js" "$TargetPath\api\webhooks\whatsapp\" -Force
Copy-Item "$SourcePath\dev-server.js" "$TargetPath\" -Force
Copy-Item "$SourcePath\package.json" "$TargetPath\" -Force
Copy-Item "$SourcePath\vercel.json" "$TargetPath\" -Force
Copy-Item "$SourcePath\.gitignore" "$TargetPath\" -Force

# Copy testing scripts
Write-Host "🧪 Copying testing scripts..." -ForegroundColor Yellow
Copy-Item "$SourcePath\scripts\production-hmac-test.js" "$TargetPath\scripts\" -Force
Copy-Item "$SourcePath\scripts\hmac-post.js" "$TargetPath\scripts\" -Force
Copy-Item "$SourcePath\scripts\verify-get.js" "$TargetPath\scripts\" -Force
Copy-Item "$SourcePath\scripts\curl-examples.sh" "$TargetPath\scripts\" -Force

# Copy documentation
Write-Host "📚 Copying documentation..." -ForegroundColor Yellow
Copy-Item "$SourcePath\NEW_REPO_README.md" "$TargetPath\README.md" -Force
Copy-Item "$SourcePath\DEPLOYMENT_GUIDE.md" "$TargetPath\docs\" -Force
Copy-Item "$SourcePath\TESTING_GUIDE.md" "$TargetPath\docs\" -Force
Copy-Item "$SourcePath\PRODUCTION_TEST_REPORT.md" "$TargetPath\docs\PRODUCTION_REPORT.md" -Force
Copy-Item "$SourcePath\SETUP_GUIDE.md" "$TargetPath\docs\" -Force

# Create environment template
Write-Host "🔧 Creating environment template..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath "$TargetPath\.env.example" -Encoding UTF8

# Create LICENSE file
Write-Host "⚖️ Creating LICENSE file..." -ForegroundColor Yellow
@"
MIT License

Copyright (c) 2025 CrossAI Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@ | Out-File -FilePath "$TargetPath\LICENSE" -Encoding UTF8

Write-Host "`n✅ Repository setup complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. npm install" -ForegroundColor White
Write-Host "2. cp .env.example .env" -ForegroundColor White
Write-Host "3. npm run dev" -ForegroundColor White
Write-Host "4. git add . && git commit -m 'Initial commit'" -ForegroundColor White
Write-Host "5. git push origin main" -ForegroundColor White
Write-Host "`n🚀 Ready for Vercel deployment!" -ForegroundColor Green

# Check if git is initialized
if (-not (Test-Path "$TargetPath\.git")) {
    Write-Host "`n⚠️  Don't forget to initialize Git:" -ForegroundColor Yellow
    Write-Host "git init" -ForegroundColor White
    Write-Host "git remote add origin https://github.com/Odiabackend099/webhook-crossai.git" -ForegroundColor White
}

Write-Host "`n📊 Files copied:" -ForegroundColor Cyan
Get-ChildItem -Path $TargetPath -Recurse -File | ForEach-Object {
    Write-Host "  $($_.FullName.Replace($TargetPath, ''))" -ForegroundColor Gray
}