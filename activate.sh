#!/bin/bash

# F5 AI Agents Workflow Design Hub - Environment Activation Script
# This script activates the development environment for the project

echo "🚀 Activating F5 AI Agents Workflow Design Hub environment..."
echo ""

# Change to project directory if not already there
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Activate Node.js version via NVM
if [ -f .nvmrc ]; then
    if command -v nvm &> /dev/null; then
        echo "📦 Loading Node.js version from .nvmrc..."
        nvm use
        if [ $? -ne 0 ]; then
            echo "⚠️  Node version from .nvmrc not installed. Installing now..."
            nvm install
            nvm use
        fi
    else
        echo "⚠️  NVM not found. Please install NVM or ensure Node.js $(cat .nvmrc) is installed."
    fi
else
    echo "⚠️  .nvmrc file not found. Using system Node.js version."
fi

echo ""

# Activate Python virtual environment
if [ -d venv ]; then
    echo "🐍 Activating Python virtual environment..."
    source venv/bin/activate
    echo "✅ Python virtual environment activated"
else
    echo "⚠️  Python virtual environment not found at ./venv"
    echo "   Create it with: python3.11 -m venv venv"
fi

echo ""

# Set Node.js memory options
export NODE_OPTIONS="--max-old-space-size=8192"
echo "💾 Node.js memory limit set to 8GB"

# Set Python path for node-gyp
if [ -d venv ]; then
    export PYTHON=$(which python)
    export npm_config_python=$PYTHON
    echo "🔧 Python path configured for native module builds"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Environment activated successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Current Environment:"
echo "   Node.js:  $(node --version)"
if command -v python &> /dev/null; then
    echo "   Python:   $(python --version 2>&1)"
fi
if command -v pnpm &> /dev/null; then
    echo "   pnpm:     $(pnpm --version)"
else
    echo "   pnpm:     ⚠️  Not installed. Run: npm install -g pnpm"
fi
echo ""
echo "📂 Project Directory: $SCRIPT_DIR"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Next Steps:"
echo "   • Install dependencies: pnpm install"
echo "   • Build project:        pnpm build"
echo "   • Start application:    pnpm start"
echo "   • Development mode:     pnpm dev"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
