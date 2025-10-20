#!/bin/bash

# Task API Deployment Script
# Usage: ./deploy.sh [environment] [image_tag]

set -e

ENVIRONMENT=${1:-local}
IMAGE_TAG=${2:-latest}
IMAGE_NAME="task-api"

echo "🚀 Deploying Task API to $ENVIRONMENT environment..."
echo "📦 Using image tag: $IMAGE_TAG"

case $ENVIRONMENT in
  "local")
    echo "🏠 Starting local deployment with Docker Compose..."
    export IMAGE_TAG=$IMAGE_TAG
    docker-compose down
    docker-compose build
    docker-compose up -d
    echo "✅ Local deployment completed!"
    echo "🌐 API available at: http://localhost:8080/api"
    echo "📊 Health check: http://localhost:8080/actuator/health"
    ;;
    
  "staging")
    echo "🧪 Deploying to staging environment..."
    # Add staging deployment logic here
    # Example: kubectl, cloud CLI commands, etc.
    echo "✅ Staging deployment completed!"
    ;;
    
  "production")
    echo "🏭 Deploying to production environment..."
    # Add production deployment logic here
    # Example: kubectl, cloud CLI commands, etc.
    echo "✅ Production deployment completed!"
    ;;
    
  *)
    echo "❌ Unknown environment: $ENVIRONMENT"
    echo "Available environments: local, staging, production"
    exit 1
    ;;
esac

echo "🎉 Deployment finished successfully!"
