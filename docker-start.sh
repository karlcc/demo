#!/bin/bash

# Quick start script for Symfony Demo Application Docker setup

set -e

echo "🚀 Setting up Symfony Demo Application with Docker..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo "📝 Creating environment configuration..."
    cp .env.docker .env.local

    # Generate a random secret
    SECRET=$(openssl rand -hex 32)
    sed -i.bak "s/your-secret-key-here-change-in-production/${SECRET}/" .env.local
    rm .env.local.bak

    echo "✅ Environment configuration created with random secret key"
else
    echo "ℹ️  Environment configuration already exists"
fi

# Create data directory if it doesn't exist
mkdir -p data

echo "🏗️  Building Docker containers..."
docker-compose build --no-cache

echo "🚀 Starting containers..."
docker-compose up -d

echo "⏳ Waiting for application to start..."
sleep 10

# Check if container is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Application is running!"

    # Get the actual port being used
    if [ -n "$SERVER_PORT" ]; then
        PORT=$SERVER_PORT
    else
        PORT=8100
    fi

    echo ""
    echo "🌐 Access your application at: http://localhost:$PORT"
    echo ""
    echo "📋 Useful commands:"
    echo "  docker-compose logs -f    # View logs"
    echo "  docker-compose down       # Stop containers"
    echo "  docker-compose exec symfony-app bash  # Access container shell"
    echo ""
    echo "🔧 Symfony commands (run from inside container):"
    echo "  docker-compose exec symfony-app php bin/console cache:clear"
    echo "  docker-compose exec symfony-app php bin/console doctrine:migrations:migrate"
    echo "  docker-compose exec symfony-app ./bin/phpunit"
    echo ""
    echo "💡 To use a different port: SERVER_PORT=9000 docker-compose up --build"
else
    echo "❌ Failed to start application. Check logs with: docker-compose logs"
    exit 1
fi