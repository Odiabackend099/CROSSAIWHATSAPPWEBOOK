# Simple script to push webhook files to GitHub
$RepoUrl = "https://github.com/Odiabackend099/webhook-crossai.git"
$WorkingDir = "C:\temp\webhook-crossai"

Write-Host "🚀 Setting up webhook-crossai repository..." -ForegroundColor Green

# Create and navigate to working directory
if (Test-Path $WorkingDir) { Remove-Item -Path $WorkingDir -Recurse -Force }
New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null
Set-Location $WorkingDir

# Initialize repository
Write-Host "📥 Initializing repository..." -ForegroundColor Yellow
git init
git remote add origin $RepoUrl

# Create structure
New-Item -ItemType Directory -Path "api\webhooks\whatsapp" -Force | Out-Null
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null  
New-Item -ItemType Directory -Path "docs" -Force | Out-Null

# Copy core files
$SourcePath = "c:\Users\OD~IA\Desktop\Odiadev-2025\ODIADEV TTS\Crossai webhook whatsapp"
Write-Host "📦 Copying files..." -ForegroundColor Yellow

Copy-Item "$SourcePath\api\webhooks\whatsapp\crossai.js" "api\webhooks\whatsapp\" -Force
Copy-Item "$SourcePath\dev-server.js" "." -Force
Copy-Item "$SourcePath\package.json" "." -Force
Copy-Item "$SourcePath\vercel.json" "." -Force
Copy-Item "$SourcePath\.gitignore" "." -Force

Copy-Item "$SourcePath\scripts\production-hmac-test.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\hmac-post.js" "scripts\" -Force  
Copy-Item "$SourcePath\scripts\verify-get.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\curl-examples.sh" "scripts\" -Force

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

# Local dev only
NODE_ENV=development
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

# Configure git user
git config user.name "CrossAI Team"
git config user.email "crossai@odiadev.com"

# Stage and commit
Write-Host "💾 Creating commit..." -ForegroundColor Yellow
git add .
git commit -m "Initial commit: Production-ready CrossAI WhatsApp webhook

Features:
✅ Complete WhatsApp Cloud API webhook implementation  
✅ HMAC SHA-256 signature validation with timing-safe comparison
✅ Comprehensive testing suite with real crypto validation
✅ Vercel serverless deployment configuration
✅ Nigeria-first optimization (fra1, iad1 regions)
✅ Complete documentation and deployment guides
✅ Production-tested security and performance

Ready for Vercel deployment and Meta App integration."

# Push to GitHub
Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin main

Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
Write-Host "Repository: $RepoUrl" -ForegroundColor Cyan
Write-Host "Working directory: $WorkingDir" -ForegroundColor Gray