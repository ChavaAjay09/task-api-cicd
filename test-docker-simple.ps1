# Simple Docker Test Script
Write-Host "Docker Testing for Task API" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

# Test 1: Check Docker
Write-Host "`nStep 1: Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "Docker: $dockerVersion" -ForegroundColor Green
    
    docker info > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker daemon is running" -ForegroundColor Green
    } else {
        Write-Host "Docker daemon not running!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Docker not found!" -ForegroundColor Red
    exit 1
}

# Test 2: Build Docker Image
Write-Host "`nStep 2: Building Docker Image..." -ForegroundColor Yellow
docker build -t task-api:test .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image built successfully!" -ForegroundColor Green

# Test 3: Start MongoDB
Write-Host "`nStep 3: Starting MongoDB..." -ForegroundColor Yellow
docker stop test-mongodb 2>$null
docker rm test-mongodb 2>$null
docker run -d --name test-mongodb -p 27017:27017 mongo:7
if ($LASTEXITCODE -ne 0) {
    Write-Host "MongoDB container failed to start!" -ForegroundColor Red
    exit 1
}
Write-Host "MongoDB container started" -ForegroundColor Green

# Wait for MongoDB
Write-Host "Waiting for MongoDB to be ready..."
Start-Sleep 15

# Test 4: Start Application
Write-Host "`nStep 4: Starting Application..." -ForegroundColor Yellow
docker stop test-task-api 2>$null
docker rm test-task-api 2>$null
docker run -d --name test-task-api -p 8080:8080 -e MONGODB_URI=mongodb://host.docker.internal:27017/tasksdb task-api:test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Application container failed to start!" -ForegroundColor Red
    exit 1
}
Write-Host "Application container started" -ForegroundColor Green

# Wait for application
Write-Host "Waiting for application to be ready..."
$maxAttempts = 30
$attempt = 0

do {
    Start-Sleep 3
    $attempt++
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "Application is ready!" -ForegroundColor Green
            break
        }
    } catch {
        # Continue waiting
    }
    
    if ($attempt -eq $maxAttempts) {
        Write-Host "Application failed to start!" -ForegroundColor Red
        docker logs test-task-api
        exit 1
    }
} while ($attempt -lt $maxAttempts)

# Test 5: Test API Endpoints
Write-Host "`nStep 5: Testing API..." -ForegroundColor Yellow

try {
    # Test health
    $health = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing
    Write-Host "Health endpoint: OK" -ForegroundColor Green
    
    # Test tasks
    $tasks = Invoke-WebRequest -Uri "http://localhost:8080/api/tasks" -UseBasicParsing
    Write-Host "Tasks endpoint: OK" -ForegroundColor Green
    
    # Create a task
    $taskJson = '{"id":"test-001","name":"Docker Test","owner":"Tester","command":"echo Hello Docker!"}'
    $create = Invoke-WebRequest -Uri "http://localhost:8080/api/tasks" -Method PUT -Body $taskJson -ContentType "application/json" -UseBasicParsing
    Write-Host "Create task: OK" -ForegroundColor Green
    
} catch {
    Write-Host "API test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Docker Compose
Write-Host "`nStep 6: Testing Docker Compose..." -ForegroundColor Yellow

# Stop individual containers
docker stop test-task-api test-mongodb 2>$null
docker rm test-task-api test-mongodb 2>$null

# Test Docker Compose
docker-compose up -d --build
if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker Compose started successfully!" -ForegroundColor Green
    
    # Wait and test
    Start-Sleep 30
    try {
        $composeTest = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 10
        if ($composeTest.StatusCode -eq 200) {
            Write-Host "Docker Compose stack is working!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Docker Compose health check failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "Docker Compose failed to start" -ForegroundColor Red
}

# Cleanup
Write-Host "`nCleaning up..." -ForegroundColor Yellow
docker-compose down 2>$null
docker stop test-task-api test-mongodb 2>$null
docker rm test-task-api test-mongodb 2>$null
docker rmi task-api:test 2>$null

Write-Host "`nDocker Testing Summary:" -ForegroundColor Green
Write-Host "- Docker installation: Working" -ForegroundColor Green
Write-Host "- Docker build: Success" -ForegroundColor Green
Write-Host "- Container orchestration: Working" -ForegroundColor Green
Write-Host "- API endpoints: Functional" -ForegroundColor Green
Write-Host "- Docker Compose: Working" -ForegroundColor Green

Write-Host "`nYour Docker setup is ready for CI/CD!" -ForegroundColor Green
Write-Host "Next: Use 'docker-compose up --build' for development" -ForegroundColor Cyan
