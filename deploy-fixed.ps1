# Deploy script with Hobby plan compatible vercel.json
$RepoUrl = "https://github.com/Odiabackend099/webhook-crossai.git"
$WorkingDir = "C:\temp\webhook-crossai-fixed"

Write-Host "🚀 Deploying Hobby-compatible webhook to GitHub..." -ForegroundColor Green

# Clean setup
if (Test-Path $WorkingDir) { Remove-Item -Path $WorkingDir -Recurse -Force }
New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null
Set-Location $WorkingDir

# Initialize Git
git init
git remote add origin $RepoUrl

# Create structure
New-Item -ItemType Directory -Path "api\webhooks\whatsapp" -Force | Out-Null
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
New-Item -ItemType Directory -Path "docs" -Force | Out-Null

# Source path
$SourcePath = "c:\Users\OD~IA\Desktop\Odiadev-2025\ODIADEV TTS\Crossai webhook whatsapp"

Write-Host "📦 Copying files with fixed vercel.json..." -ForegroundColor Yellow

# Copy main application files
Copy-Item "$SourcePath\api\webhooks\whatsapp\crossai.js" "api\webhooks\whatsapp\" -Force
Copy-Item "$SourcePath\dev-server.js" "." -Force  
Copy-Item "$SourcePath\package.json" "." -Force
Copy-Item "$SourcePath\vercel.json" "." -Force  # This now has the fixed config
Copy-Item "$SourcePath\.gitignore" "." -Force

# Copy scripts
Copy-Item "$SourcePath\scripts\production-hmac-test.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\hmac-post.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\verify-get.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\curl-examples.sh" "scripts\" -Force

# Copy documentation (using the updated README)
Copy-Item "$SourcePath\NEW_REPO_README.md" "README.md" -Force
Copy-Item "$SourcePath\DEPLOYMENT_GUIDE.md" "docs\" -Force
Copy-Item "$SourcePath\TESTING_GUIDE.md" "docs\" -Force
Copy-Item "$SourcePath\PRODUCTION_TEST_REPORT.md" "docs\PRODUCTION_REPORT.md" -Force

# Create .env.example
@"
# WhatsApp webhook verification token (exactly 32 chars recommended)
VERIFY_TOKEN=CHANGE_ME_32_CHAR_RANDOM

# Meta App secret (from Meta App → Settings → Basic)
META_APP_SECRET=CHANGE_ME_META_APP_SECRET

# Optional: Environment setting
NODE_ENV=production

# Local dev only
PORT=3000
"@ | Out-File -FilePath ".env.example" -Encoding UTF8

# Create LICENSE
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
"@ | Out-File -FilePath "LICENSE" -Encoding UTF8

# Display the fixed vercel.json
Write-Host "`n✅ Fixed vercel.json (Hobby plan compatible):" -ForegroundColor Green
Get-Content "vercel.json" | Write-Host -ForegroundColor Cyan

# Configure Git
git config user.name "CrossAI Team"
git config user.email "crossai@odiadev.com"

# Stage and commit
Write-Host "`n💾 Creating commit..." -ForegroundColor Yellow
git add .
git commit -m "🚀 Initial commit: Hobby plan compatible CrossAI WhatsApp webhook

✅ FIXED: Removed multiple regions from vercel.json for Hobby plan compatibility
✅ Complete WhatsApp Cloud API webhook implementation
✅ HMAC SHA-256 signature validation with timing-safe comparison  
✅ Comprehensive testing suite with production validation
✅ Vercel serverless deployment (single region, Hobby compatible)
✅ Complete documentation and deployment guides

📋 Deployment Instructions:
1. Import to Vercel (Framework: Other)
2. Add environment variables:
   - VERIFY_TOKEN (32-char random string)  
   - META_APP_SECRET (from Meta App Settings)
   - NODE_ENV=production (optional)
3. Deploy and get URL: https://webhook-crossai.vercel.app
4. Configure Meta App webhook with your URL
5. Test with: curl '<url>/api/webhooks/whatsapp/crossai?hub.mode=subscribe&hub.verify_token=<token>&hub.challenge=12345'

🎯 Ready for production WhatsApp traffic!"

# Push to GitHub
Write-Host "`n🚀 Pushing to GitHub..." -ForegroundColor Yellow
try {
    git push -u origin main
    Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host "`n🔗 Repository: $RepoUrl" -ForegroundColor Cyan
    Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Go to Vercel Dashboard and import from GitHub" -ForegroundColor White
    Write-Host "2. Framework Preset: Other" -ForegroundColor White  
    Write-Host "3. Add environment variables (VERIFY_TOKEN, META_APP_SECRET)" -ForegroundColor White
    Write-Host "4. Deploy and test the webhook endpoint" -ForegroundColor White
    Write-Host "5. Configure Meta App with your webhook URL" -ForegroundColor White
} catch {
    Write-Host "❌ Push failed - check repository exists and credentials" -ForegroundColor Red
}

Write-Host "`n🎉 Deploy script complete!" -ForegroundColor Green
Write-Host "Working directory: $WorkingDir" -ForegroundColor Gray