# 🐳 Docker Setup Guide for Windows

## Quick Installation Steps

### **Option 1: Docker Desktop (Recommended)**

1. **Download Docker Desktop**:
   - Go to: https://docs.docker.com/desktop/install/windows-install/
   - Click "Docker Desktop for Windows"
   - Download the installer

2. **System Requirements**:
   - Windows 10/11 (64-bit)
   - WSL 2 feature enabled
   - Virtualization enabled in BIOS

3. **Installation**:
   - Run the downloaded installer
   - Follow the setup wizard
   - Restart your computer when prompted

4. **Verify Installation**:
   ```powershell
   docker --version
   docker-compose --version
   ```

### **Option 2: Alternative Installation Methods**

#### **Using Chocolatey** (if you have it):
```powershell
# Run as Administrator
choco install docker-desktop
```

#### **Using Winget**:
```powershell
# Run as Administrator
winget install Docker.DockerDesktop
```

## 🔧 Post-Installation Setup

### **1. Enable WSL 2 (if not already enabled)**
```powershell
# Run as Administrator
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-for-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart computer, then:
wsl --set-default-version 2
```

### **2. Start Docker Desktop**
- Launch Docker Desktop from Start Menu
- Wait for Docker to start (whale icon in system tray)
- Accept terms and conditions

### **3. Verify Docker is Working**
```powershell
# Test Docker
docker run hello-world

# Test Docker Compose
docker-compose --version
```

## 🧪 Testing Your Task API with Docker

Once Docker is installed, run these commands:

### **1. Quick Test - Build Docker Image**
```powershell
# Navigate to your project directory
cd "c:\D\vs code\Task_1_api"

# Build the Docker image
docker build -t task-api:test .

# Check if image was created
docker images task-api:test
```

### **2. Full Stack Test - Docker Compose**
```powershell
# Start the full application stack
docker-compose up --build

# In another terminal, test the API
curl http://localhost:8080/actuator/health
# or
Invoke-WebRequest http://localhost:8080/actuator/health

# Stop the stack
docker-compose down
```

### **3. Individual Container Testing**
```powershell
# Start MongoDB only
docker run -d --name test-mongodb -p 27017:27017 mongo:7

# Build and run your API
docker build -t task-api:test .
docker run -d --name test-api -p 8080:8080 -e MONGODB_URI=mongodb://host.docker.internal:27017/tasksdb task-api:test

# Test the API
curl http://localhost:8080/actuator/health

# Cleanup
docker stop test-api test-mongodb
docker rm test-api test-mongodb
```

## 🚨 Troubleshooting Common Issues

### **Issue 1: WSL 2 Installation Required**
```
Error: Docker Desktop requires WSL 2
```
**Solution**:
1. Enable WSL 2 (see commands above)
2. Install WSL 2 kernel update: https://aka.ms/wsl2kernel
3. Restart Docker Desktop

### **Issue 2: Virtualization Not Enabled**
```
Error: Hardware assisted virtualization and data execution protection must be enabled
```
**Solution**:
1. Restart computer
2. Enter BIOS/UEFI settings (usually F2, F12, or Del during boot)
3. Enable "Virtualization Technology" or "Intel VT-x/AMD-V"
4. Save and restart

### **Issue 3: Hyper-V Conflicts**
```
Error: Hyper-V is not available
```
**Solution**:
```powershell
# Run as Administrator
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### **Issue 4: Port Already in Use**
```
Error: Port 8080 is already allocated
```
**Solution**:
```powershell
# Find what's using the port
netstat -ano | findstr :8080

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
ports:
  - "8081:8080"  # Use port 8081 instead
```

## 🎯 Quick Docker Test Script

I'll create a script to test Docker once it's installed:
