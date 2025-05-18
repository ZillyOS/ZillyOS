#!/bin/bash

# ZillyOS Development Environment Setup Script

echo "Setting up ZillyOS development environment..."

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js v18.0.0 or higher."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d 'v' -f 2)
NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d '.' -f 1)

if [ "$NODE_MAJOR_VERSION" -lt 18 ]; then
    echo "Node.js version $NODE_VERSION is not supported. Please install Node.js v18.0.0 or higher."
    exit 1
fi

echo "✅ Node.js v$NODE_VERSION detected"

# Check for npm
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install npm v8.0.0 or higher."
    exit 1
fi

NPM_VERSION=$(npm -v)
echo "✅ npm v$NPM_VERSION detected"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "⚠️ Docker is not installed. Some features may not work correctly."
    DOCKER_INSTALLED=false
else
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f 3 | cut -d ',' -f 1)
    echo "✅ Docker v$DOCKER_VERSION detected"
    DOCKER_INSTALLED=true
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    echo "NODE_ENV=development" > .env
    echo "LOG_LEVEL=debug" >> .env
    echo "✅ .env file created"
fi

# Install dependencies
echo "Installing dependencies..."
npm install
echo "✅ Dependencies installed"

# Set up Docker services if Docker is installed
if [ "$DOCKER_INSTALLED" = true ]; then
    echo "Starting development services with Docker..."
    
    if [ ! -f docker-compose.yml ]; then
        echo "Creating docker-compose.yml file..."
        cat > docker-compose.yml << EOL
version: '3'
services:
  redis:
    image: redis:latest
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    restart: always

volumes:
  redis-data:
EOL
        echo "✅ docker-compose.yml file created"
    fi
    
    docker-compose up -d
    echo "✅ Development services started"
fi

# Create VS Code settings if .vscode directory exists
if [ -d .vscode ]; then
    echo "Setting up VS Code configuration..."
    
    # Create settings.json if it doesn't exist
    if [ ! -f .vscode/settings.json ]; then
        cat > .vscode/settings.json << EOL
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": ["typescript"],
  "typescript.preferences.importModuleSpecifier": "non-relative",
  "typescript.tsdk": "node_modules/typescript/lib",
  "files.exclude": {
    "**/.git": true,
    "**/node_modules": true,
    "**/dist": true
  }
}
EOL
        echo "✅ VS Code settings created"
    fi
fi

echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Run 'npm run dev' to start the development server"
echo "2. Visit the documentation at ./DEVELOPMENT.md for more information" 