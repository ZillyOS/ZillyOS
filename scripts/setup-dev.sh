#!/bin/bash

# ZillyOS Development Environment Setup Script
# This script helps configure your local development environment

echo "🚀 Setting up ZillyOS development environment..."

# Check for Node.js installation
echo "📋 Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v18 or later."
    exit 1
fi

NODE_VERSION=$(node -v)
echo "✅ Node.js ${NODE_VERSION} is installed."

# Check for npm installation
echo "📋 Checking npm installation..."
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm v9 or later."
    exit 1
fi

NPM_VERSION=$(npm -v)
echo "✅ npm ${NPM_VERSION} is installed."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Setup environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "🔧 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. Please review and update as needed."
else
    echo "ℹ️ .env file already exists, skipping creation."
fi

# Setup Git hooks
echo "🔧 Setting up Git hooks..."
npx husky install
chmod +x .husky/pre-commit
echo "✅ Git hooks configured."

# Create VS Code debugging configuration if using VS Code
if [ -d .vscode ]; then
    echo "🔧 Setting up VS Code debug configuration..."
    mkdir -p .vscode
    cat > .vscode/launch.json << 'EOL'
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/src/index.ts",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "runtimeArgs": ["-r", "ts-node/register"],
      "sourceMaps": true,
      "envFile": "${workspaceFolder}/.env"
    }
  ]
}
EOL
    echo "✅ VS Code debug configuration created."
fi

# Run type check to verify TypeScript setup
echo "🔍 Verifying TypeScript setup..."
npm run type-check

# Verify test setup
echo "🧪 Verifying test setup..."
npm test -- --silent

echo "🎉 Development environment setup complete!"
echo "📝 Next steps:"
echo "  1. Review and update the .env file"
echo "  2. Start the development server with: npm run dev"
echo "  3. Visit http://localhost:3000 in your browser"
echo "  4. Read the full development guide at: docs/DEVELOPMENT.md" 