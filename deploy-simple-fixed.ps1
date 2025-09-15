# Simple deployment script with fixed vercel.json
$RepoUrl = "https://github.com/Odiabackend099/webhook-crossai.git"
$WorkingDir = "C:\temp\webhook-crossai-hobby"

Write-Host "Deploying Hobby-compatible webhook..." -ForegroundColor Green

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

Write-Host "Copying files..." -ForegroundColor Yellow

# Copy core files
Copy-Item "$SourcePath\api\webhooks\whatsapp\crossai.js" "api\webhooks\whatsapp\" -Force
Copy-Item "$SourcePath\dev-server.js" "." -Force
Copy-Item "$SourcePath\package.json" "." -Force
Copy-Item "$SourcePath\vercel.json" "." -Force
Copy-Item "$SourcePath\.gitignore" "." -Force

# Copy scripts
Copy-Item "$SourcePath\scripts\production-hmac-test.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\hmac-post.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\verify-get.js" "scripts\" -Force
Copy-Item "$SourcePath\scripts\curl-examples.sh" "scripts\" -Force

# Copy docs
Copy-Item "$SourcePath\NEW_REPO_README.md" "README.md" -Force
Copy-Item "$SourcePath\DEPLOYMENT_GUIDE.md" "docs\" -Force
Copy-Item "$SourcePath\TESTING_GUIDE.md" "docs\" -Force
Copy-Item "$SourcePath\PRODUCTION_TEST_REPORT.md" "docs\PRODUCTION_REPORT.md" -Force

# Create simple files
"# WhatsApp webhook verification token
VERIFY_TOKEN=CHANGE_ME_32_CHAR_RANDOM

# Meta App secret 
META_APP_SECRET=CHANGE_ME_META_APP_SECRET

# Optional
NODE_ENV=production
PORT=3000" | Out-File -FilePath ".env.example" -Encoding UTF8

"MIT License" | Out-File -FilePath "LICENSE" -Encoding UTF8

# Show vercel.json
Write-Host "Fixed vercel.json:" -ForegroundColor Green
Get-Content "vercel.json"

# Git setup
git config user.name "CrossAI Team"
git config user.email "crossai@odiadev.com"

# Commit
git add .
git commit -m "Hobby plan compatible CrossAI WhatsApp webhook - Fixed vercel.json for single region deployment"

# Push
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin main

Write-Host "Success! Repository: $RepoUrl" -ForegroundColor Green
Write-Host "Working directory: $WorkingDir" -ForegroundColor Gray