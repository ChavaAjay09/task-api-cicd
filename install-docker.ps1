# Docker Installation Helper Script
# This script helps install Docker Desktop on Windows

Write-Host "🐳 Docker Installation Helper" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️  This script should be run as Administrator for best results" -ForegroundColor Yellow
    Write-Host "💡 Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Cyan
}

# Check if Docker is already installed
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✅ Docker is already installed: $dockerVersion" -ForegroundColor Green
        
        # Test if Docker daemon is running
        docker info > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker daemon is running" -ForegroundColor Green
            Write-Host "🎉 You're ready to test! Run: .\test-docker.ps1" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "⚠️  Docker is installed but not running" -ForegroundColor Yellow
            Write-Host "💡 Please start Docker Desktop" -ForegroundColor Cyan
            exit 0
        }
    }
} catch {
    Write-Host "📋 Docker not found. Let's install it!" -ForegroundColor Yellow
}

# Check system requirements
Write-Host "`n📋 Checking System Requirements..." -ForegroundColor Yellow

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -ge 10) {
    Write-Host "✅ Windows version: $($osVersion.Major).$($osVersion.Minor) (Compatible)" -ForegroundColor Green
} else {
    Write-Host "❌ Windows version: $($osVersion.Major).$($osVersion.Minor) (Docker requires Windows 10+)" -ForegroundColor Red
    exit 1
}

# Check if WSL is available
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-for-Linux -ErrorAction SilentlyContinue
if ($wslFeature -and $wslFeature.State -eq "Enabled") {
    Write-Host "✅ WSL is enabled" -ForegroundColor Green
} else {
    Write-Host "⚠️  WSL is not enabled (required for Docker Desktop)" -ForegroundColor Yellow
    if ($isAdmin) {
        Write-Host "🔧 Enabling WSL..." -ForegroundColor Yellow
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-for-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Write-Host "✅ WSL features enabled (restart required)" -ForegroundColor Green
    } else {
        Write-Host "💡 Run as Administrator to enable WSL automatically" -ForegroundColor Cyan
    }
}

# Installation options
Write-Host "`n🚀 Docker Installation Options:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n1️⃣  Manual Download (Recommended):" -ForegroundColor Yellow
Write-Host "   • Go to: https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Gray
Write-Host "   • Download 'Docker Desktop for Windows'" -ForegroundColor Gray
Write-Host "   • Run the installer" -ForegroundColor Gray
Write-Host "   • Restart your computer" -ForegroundColor Gray

Write-Host "`n2️⃣  Using Winget (if available):" -ForegroundColor Yellow
Write-Host "   winget install Docker.DockerDesktop" -ForegroundColor Gray

Write-Host "`n3️⃣  Using Chocolatey (if available):" -ForegroundColor Yellow
Write-Host "   choco install docker-desktop" -ForegroundColor Gray

# Try automatic installation with winget
Write-Host "`n🤖 Attempting automatic installation with winget..." -ForegroundColor Yellow
try {
    $wingetVersion = winget --version 2>$null
    if ($wingetVersion) {
        Write-Host "✅ Winget available: $wingetVersion" -ForegroundColor Green
        
        $userChoice = Read-Host "Would you like to install Docker Desktop automatically? (y/N)"
        if ($userChoice -eq 'y' -or $userChoice -eq 'Y') {
            Write-Host "📦 Installing Docker Desktop..." -ForegroundColor Yellow
            winget install Docker.DockerDesktop
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Docker Desktop installation completed!" -ForegroundColor Green
                Write-Host "🔄 Please restart your computer and then run: .\test-docker.ps1" -ForegroundColor Cyan
            } else {
                Write-Host "❌ Installation failed. Please try manual installation." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "⚠️  Winget not available. Please use manual installation." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Automatic installation not available. Please use manual installation." -ForegroundColor Yellow
}

Write-Host "`n📋 Post-Installation Steps:" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host "1. Restart your computer" -ForegroundColor Gray
Write-Host "2. Start Docker Desktop from Start Menu" -ForegroundColor Gray
Write-Host "3. Accept terms and conditions" -ForegroundColor Gray
Write-Host "4. Wait for Docker to start (whale icon in system tray)" -ForegroundColor Gray
Write-Host "5. Run: .\test-docker.ps1" -ForegroundColor Gray

Write-Host "`n🔗 Helpful Links:" -ForegroundColor Cyan
Write-Host "• Docker Desktop Download: https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Gray
Write-Host "• WSL 2 Kernel Update: https://aka.ms/wsl2kernel" -ForegroundColor Gray
Write-Host "• Docker Documentation: https://docs.docker.com/" -ForegroundColor Gray

Write-Host "`n💡 Need Help?" -ForegroundColor Cyan
Write-Host "Check the TROUBLESHOOTING.md file for common issues and solutions." -ForegroundColor Gray
