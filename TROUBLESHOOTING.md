# CI/CD Pipeline Troubleshooting Guide

## 🔧 Common Issues and Solutions

### **Local Development Issues**

#### **1. Maven Build Fails**
```bash
# Problem: Maven not found
# Solution: Use the bundled Maven
.\apache-maven-3.9.11\bin\mvn.cmd clean compile

# Problem: Java version mismatch
# Solution: Ensure Java 17+ is installed
java -version
```

#### **2. MongoDB Connection Issues**
```bash
# Problem: MongoDB not running
# Solution: Start MongoDB with Docker
docker run -d --name mongodb -p 27017:27017 mongo:7

# Problem: Connection refused
# Solution: Check MongoDB URI in application.properties
# Default: mongodb://localhost:27017/tasksdb
```

#### **3. Port Already in Use**
```bash
# Problem: Port 8080 already in use
# Solution: Find and kill the process
netstat -ano | findstr :8080
taskkill /PID <process_id> /F

# Or change port in application.properties
server.port=8081
```

### **Docker Issues**

#### **1. Docker Build Fails**
```bash
# Problem: Docker not installed
# Solution: Install Docker Desktop for Windows
# https://docs.docker.com/desktop/install/windows-install/

# Problem: Build context too large
# Solution: Check .dockerignore file is present and configured

# Problem: Out of disk space
# Solution: Clean Docker system
docker system prune -a
```

#### **2. Docker Compose Issues**
```bash
# Problem: Services won't start
# Solution: Check logs
docker-compose logs task-api
docker-compose logs mongodb

# Problem: Network issues
# Solution: Recreate network
docker-compose down
docker network prune
docker-compose up --build
```

### **GitHub Actions Pipeline Issues**

#### **1. Pipeline Fails on Push**
```yaml
# Problem: Workflow file syntax error
# Solution: Validate YAML syntax
# Use: https://www.yamllint.com/

# Problem: Missing permissions
# Solution: Check repository settings
# Settings → Actions → General → Workflow permissions
```

#### **2. Test Failures**
```bash
# Problem: Tests fail in CI but pass locally
# Solution: Check environment differences
# - MongoDB version
# - Java version
# - Environment variables

# Problem: Timeout issues
# Solution: Increase timeout in workflow
timeout-minutes: 30
```

#### **3. Docker Build Fails in CI**
```yaml
# Problem: Multi-platform build fails
# Solution: Use specific platform
platforms: linux/amd64

# Problem: Registry authentication fails
# Solution: Check GITHUB_TOKEN permissions
# Settings → Actions → General → Workflow permissions → Read and write
```

### **Deployment Issues**

#### **1. Container Registry Issues**
```bash
# Problem: Cannot push to registry
# Solution: Login to registry
docker login ghcr.io -u USERNAME -p TOKEN

# Problem: Image not found
# Solution: Check image name and tag
docker images | grep task-api
```

#### **2. Environment Configuration**
```bash
# Problem: Environment variables not set
# Solution: Check deployment configuration
# Kubernetes: ConfigMap/Secret
# Docker: environment section in compose file
# Cloud: Environment variables in service configuration
```

### **Performance Issues**

#### **1. Slow Build Times**
```yaml
# Solution: Enable caching in GitHub Actions
- name: Cache Maven dependencies
  uses: actions/cache@v3
  with:
    path: ~/.m2
    key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
```

#### **2. Large Docker Images**
```dockerfile
# Solution: Use multi-stage builds (already implemented)
# Solution: Use slim base images
FROM openjdk:17-jre-slim

# Solution: Clean up in same layer
RUN apt-get update && apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*
```

## 🔍 Debugging Commands

### **Local Debugging**
```bash
# Check application logs
.\apache-maven-3.9.11\bin\mvn.cmd spring-boot:run

# Check with specific profile
.\apache-maven-3.9.11\bin\mvn.cmd spring-boot:run -Dspring-boot.run.profiles=docker

# Run tests with verbose output
.\apache-maven-3.9.11\bin\mvn.cmd test -X
```

### **Docker Debugging**
```bash
# Check container logs
docker logs task-api-app

# Execute commands in container
docker exec -it task-api-app bash

# Check container health
docker inspect task-api-app | grep Health

# Check network connectivity
docker exec -it task-api-app curl http://mongodb:27017
```

### **Pipeline Debugging**
```bash
# Download workflow logs from GitHub
# Actions → Select workflow run → Download logs

# Test workflow locally with act
# Install: https://github.com/nektos/act
act -j test
```

## 📊 Monitoring and Health Checks

### **Application Health**
```bash
# Health endpoint
curl http://localhost:8080/actuator/health

# Detailed health info
curl http://localhost:8080/actuator/health | jq

# Application info
curl http://localhost:8080/actuator/info
```

### **Database Health**
```bash
# MongoDB connection test
docker exec -it mongodb mongosh --eval "db.adminCommand('ping')"

# Check database collections
docker exec -it mongodb mongosh tasksdb --eval "show collections"
```

## 🚨 Emergency Procedures

### **Rollback Deployment**
```bash
# GitHub Actions: Re-run previous successful deployment
# Manual: Deploy previous image tag
docker-compose down
export IMAGE_TAG=previous-working-tag
docker-compose up -d
```

### **Quick Fixes**
```bash
# Restart services
docker-compose restart task-api

# Scale down/up (if using orchestrator)
kubectl scale deployment task-api --replicas=0
kubectl scale deployment task-api --replicas=3

# Emergency stop
docker-compose down
```

## 📞 Getting Help

1. **Check logs first**: Application, container, and pipeline logs
2. **Verify configuration**: Environment variables, ports, connections
3. **Test locally**: Reproduce the issue in local environment
4. **Check dependencies**: Java, Maven, Docker versions
5. **Review recent changes**: Git history, configuration changes

## 🔗 Useful Links

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Maven Documentation](https://maven.apache.org/guides/)
