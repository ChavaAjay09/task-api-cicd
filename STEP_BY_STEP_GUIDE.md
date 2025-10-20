# 🚀 Step-by-Step CI/CD Pipeline Guide

## Step 1: Use Docker Compose for Development

### **1.1 Start the Development Environment**

Open a terminal in your project directory and run:

```powershell
# Navigate to your project directory (if not already there)
cd "c:\D\vs code\Task_1_api"

# Start all services (API + MongoDB) with build
docker-compose up --build
```

**What this does:**
- Builds the Docker image for your Spring Boot application
- Starts MongoDB container
- Starts your API container
- Creates a network for communication between containers
- Shows real-time logs from both services

### **1.2 Verify Services Are Running**

You should see output like:
```
✔ Network task_1_api_task-api-network  Created
✔ Volume task_1_api_mongodb_data       Created  
✔ Container task-api-mongodb           Healthy
✔ Container task-api-app               Started
```

### **1.3 Check Application Health**

Open a new terminal and test:
```powershell
# Test health endpoint
curl http://localhost:8080/actuator/health

# Or use PowerShell
Invoke-WebRequest http://localhost:8080/actuator/health
```

Expected response:
```json
{"status":"UP","components":{"mongo":{"status":"UP"}}}
```

### **1.4 Stop Services (When Done)**

To stop the development environment:
```powershell
# Stop and remove containers
docker-compose down

# Or just stop (Ctrl+C in the terminal running docker-compose)
```

---

## Step 2: Push to GitHub to Trigger CI/CD Pipeline

### **2.1 Initialize Git Repository (if not already done)**

```powershell
# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Spring Boot API with CI/CD pipeline"
```

### **2.2 Create GitHub Repository**

1. Go to [GitHub.com](https://github.com)
2. Click the **"+"** button → **"New repository"**
3. Repository name: `task-api-cicd` (or your preferred name)
4. Description: `Spring Boot Task API with CI/CD Pipeline`
5. Set to **Public** or **Private** (your choice)
6. **Don't** initialize with README, .gitignore, or license (we already have files)
7. Click **"Create repository"**

### **2.3 Connect Local Repository to GitHub**

```powershell
# Add GitHub remote (replace YOUR_USERNAME and YOUR_REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### **2.4 Verify Pipeline Triggers**

After pushing, the CI/CD pipeline will automatically start:
- Go to your GitHub repository
- Click the **"Actions"** tab
- You should see a workflow run starting

---

## Step 3: Test API Endpoints Using test-api.http

### **3.1 Install REST Client Extension (if not already installed)**

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for **"REST Client"**
4. Install the extension by Huachao Mao

### **3.2 Open the Test File**

1. In VS Code, open `test-api.http`
2. You'll see various HTTP requests ready to test

### **3.3 Run Individual Tests**

Click **"Send Request"** above each request:

#### **Test 1: Health Check**
```http
### Health Check
GET http://localhost:8080/actuator/health
```
Expected: `200 OK` with health status

#### **Test 2: Get All Tasks**
```http
### Get all tasks
GET http://localhost:8080/api/tasks
```
Expected: `200 OK` with empty array `[]`

#### **Test 3: Create a Task**
```http
### Create a new task
PUT http://localhost:8080/api/tasks
Content-Type: application/json

{
  "id": "test-001",
  "name": "CI/CD Test Task",
  "owner": "Pipeline Tester",
  "command": "echo Hello from CI/CD Pipeline!"
}
```
Expected: `200 OK` with task details

#### **Test 4: Execute Task**
```http
### Execute task command
PUT http://localhost:8080/api/tasks/test-001/execute
```
Expected: `200 OK` with command output

### **3.4 Alternative: Command Line Testing**

If you prefer command line:
```powershell
# Health check
curl http://localhost:8080/actuator/health

# Get tasks
curl http://localhost:8080/api/tasks

# Create task
curl -X PUT http://localhost:8080/api/tasks -H "Content-Type: application/json" -d '{\"id\":\"test-001\",\"name\":\"Test Task\",\"owner\":\"Tester\",\"command\":\"echo Hello!\"}'

# Execute task
curl -X PUT http://localhost:8080/api/tasks/test-001/execute
```

---

## Step 4: Monitor Pipeline in GitHub Actions

### **4.1 Access GitHub Actions**

1. Go to your GitHub repository
2. Click the **"Actions"** tab
3. You'll see workflow runs listed

### **4.2 Understanding the Pipeline**

Your pipeline has these jobs:

#### **Job 1: Run Tests**
- Sets up Java 17
- Starts MongoDB service
- Runs Maven tests
- Duration: ~2-3 minutes

#### **Job 2: Build Application**
- Compiles and packages the JAR
- Uploads build artifacts
- Duration: ~1-2 minutes

#### **Job 3: Build and Push Docker Image**
- Builds multi-platform Docker image
- Pushes to GitHub Container Registry
- Duration: ~3-5 minutes

#### **Job 4: Security Scan**
- Scans Docker image for vulnerabilities
- Uploads results to GitHub Security tab
- Duration: ~1-2 minutes

#### **Job 5: Deploy (if configured)**
- Deploys to staging/production
- Sends notifications

### **4.3 Monitor Pipeline Progress**

1. **Click on a workflow run** to see details
2. **Click on individual jobs** to see logs
3. **Green checkmark** = Success
4. **Red X** = Failed
5. **Yellow circle** = In progress

### **4.4 View Pipeline Logs**

To see detailed logs:
1. Click on the workflow run
2. Click on a specific job (e.g., "Run Tests")
3. Expand the steps to see detailed output
4. Look for any errors in red

### **4.5 Download Artifacts**

After successful build:
1. Go to the workflow run
2. Scroll down to **"Artifacts"** section
3. Download `jar-artifact` to get the built JAR file

### **4.6 View Container Images**

After successful Docker build:
1. Go to your repository main page
2. Click **"Packages"** on the right side
3. You'll see your Docker images listed
4. Images are tagged with branch names and commit SHAs

---

## 🔧 Troubleshooting Common Issues

### **Docker Compose Issues**
```powershell
# If port 8080 is busy
netstat -ano | findstr :8080
# Kill the process using the port

# If MongoDB fails to start
docker-compose logs mongodb

# Reset everything
docker-compose down -v
docker system prune -f
```

### **GitHub Actions Issues**
- **Build fails**: Check Java version and dependencies in logs
- **Docker build fails**: Verify Dockerfile syntax
- **Tests fail**: Check MongoDB connection and test configuration

### **API Testing Issues**
- **Connection refused**: Ensure `docker-compose up` is running
- **404 errors**: Check if application started successfully
- **500 errors**: Check application logs with `docker-compose logs task-api`

---

## 📊 Success Indicators

### **✅ Docker Compose Success:**
- Both containers start without errors
- Health endpoint returns `{"status":"UP"}`
- API endpoints respond correctly

### **✅ GitHub Pipeline Success:**
- All jobs show green checkmarks
- Docker image appears in Packages
- No failed tests or build errors

### **✅ API Testing Success:**
- Health check returns 200 OK
- CRUD operations work correctly
- Task execution returns command output

---

## 🎯 Next Steps After Success

1. **Customize deployment targets** in `.github/workflows/ci-cd.yml`
2. **Add more tests** to improve coverage
3. **Configure notifications** for deployment status
4. **Set up staging/production environments**
5. **Add monitoring and logging** for production use

Your CI/CD pipeline is now fully operational! 🚀
