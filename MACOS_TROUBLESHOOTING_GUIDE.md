# F5 AI Agents Workflow Design Hub - MacOS Troubleshooting Guide

This comprehensive troubleshooting guide covers common issues encountered when running the F5 AI Agents Workflow Design Hub directly on MacOS without Docker Desktop.

## Table of Contents

- [Prerequisites and System Requirements](#prerequisites-and-system-requirements)
- [Virtual Environment Setup](#virtual-environment-setup)
- [Common Build Errors](#common-build-errors)
- [Node.js Version Issues](#nodejs-version-issues)
- [Python and Native Module Issues](#python-and-native-module-issues)
- [Dependency Conflicts](#dependency-conflicts)
- [Memory and Performance Issues](#memory-and-performance-issues)
- [Package Manager Issues](#package-manager-issues)
- [Complete Clean Installation Process](#complete-clean-installation-process)
- [Advanced Troubleshooting](#advanced-troubleshooting)

---

## Prerequisites and System Requirements

### Minimum Requirements

- **MacOS**: 10.15 (Catalina) or later
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 10GB free space
- **Node.js**: 18.15.0 to 20.x (LTS versions)
- **Python**: 3.8 to 3.11 (3.12+ not supported due to distutils removal)
- **pnpm**: 8.x or 9.x

### Recommended Setup

```bash
# Check your current versions
node --version      # Should be v18.x or v20.x
python3 --version   # Should be 3.8 to 3.11
pnpm --version      # Should be 8.x or 9.x
```

---

## Virtual Environment Setup

Using virtual environments isolates dependencies and prevents conflicts with system packages or other projects.

### Why Use Virtual Environments?

- **Isolation**: Keeps project dependencies separate from system Python
- **Reproducibility**: Ensures consistent environment across team members
- **Cleanliness**: Prevents dependency conflicts between projects
- **Safety**: Protects system Python from modifications

### Option 1: Python Virtual Environment (venv)

#### Create Virtual Environment

```bash
cd /path/to/Flowise

# Create virtual environment named 'venv'
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Your prompt should now show (venv) prefix
# (venv) user@computer:~/Flowise$
```

#### Install Python Dependencies

```bash
# Ensure virtual environment is activated
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install setuptools (includes distutils replacement)
pip install setuptools wheel

# Verify installation
python -c "import setuptools; print('setuptools installed successfully')"
```

#### Deactivate Virtual Environment

```bash
# When done working
deactivate
```

#### Add to .gitignore

The virtual environment should not be committed to Git:

```bash
# Already in .gitignore, but verify
echo "venv/" >> .gitignore
echo "*.pyc" >> .gitignore
echo "__pycache__/" >> .gitignore
```

### Option 2: Node.js Environment with NVM

NVM (Node Version Manager) allows multiple Node.js versions without conflicts.

#### Install NVM

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Add to .zshrc (for zsh shell)
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc

# Reload shell configuration
source ~/.zshrc

# Verify NVM installation
nvm --version
```

#### Use NVM for Project

```bash
cd /path/to/Flowise

# Install Node.js 20 LTS
nvm install 20

# Use Node.js 20
nvm use 20

# Set as default
nvm alias default 20

# Create .nvmrc file for automatic version switching
echo "20" > .nvmrc

# Now, whenever you cd into this directory:
# nvm use  # Automatically uses version from .nvmrc
```

### Option 3: Combined Virtual Environment (Recommended)

Use both Python venv and NVM for complete isolation:

```bash
cd /path/to/Flowise

# 1. Set up Node.js environment
nvm install 20
nvm use 20
echo "20" > .nvmrc

# 2. Set up Python environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel

# 3. Install project dependencies
npm install -g pnpm
pnpm install

# 4. Build project
export NODE_OPTIONS="--max-old-space-size=8192"
pnpm build
```

### Activate Environments for Daily Work

Create a setup script for convenience:

```bash
# Create activate.sh in project root
cat > activate.sh << 'EOF'
#!/bin/bash

# Activate Node.js version
if [ -f .nvmrc ]; then
    nvm use
fi

# Activate Python virtual environment
if [ -d venv ]; then
    source venv/bin/activate
fi

# Set Node.js memory options
export NODE_OPTIONS="--max-old-space-size=8192"

echo "✅ Environment activated"
echo "Node: $(node --version)"
echo "Python: $(python --version)"
echo "pnpm: $(pnpm --version)"
EOF

chmod +x activate.sh

# Use it:
source ./activate.sh
```

---

## Common Build Errors

### Error 1: `ModuleNotFoundError: No module named 'distutils'`

**Cause**: Python 3.12+ removed the `distutils` module. Native Node.js modules need it for compilation.

**Solution 1: Use Python 3.11 or Earlier**

```bash
# Install Python 3.11 via Homebrew
brew install python@3.11

# Create virtual environment with Python 3.11
python3.11 -m venv venv
source venv/bin/activate

# Verify version
python --version  # Should show Python 3.11.x

# Install setuptools
pip install setuptools wheel

# Try building again
cd /path/to/Flowise
pnpm install
```

**Solution 2: Install setuptools in Virtual Environment**

```bash
# Activate virtual environment
cd /path/to/Flowise
source venv/bin/activate

# Install setuptools (includes distutils replacement)
pip install setuptools

# Set Python path for node-gyp
export PYTHON=$(which python3)

# Try building again
pnpm install
```

**Solution 3: System-wide setuptools (Not Recommended)**

```bash
# Only if virtual environment doesn't work
pip3 install setuptools

# Then build
cd /path/to/Flowise
pnpm install
```

### Error 2: `flowise-components#build: command exited (2)`

**Cause**: TypeScript compilation errors, often due to:
- Node.js version too new (23+)
- Insufficient memory
- Corrupted dependencies
- Type definition conflicts

**Solution**:

```bash
cd /path/to/Flowise

# Step 1: Check Node.js version
node --version

# If version is 23+, downgrade to 20 LTS
nvm install 20
nvm use 20

# Step 2: Complete clean
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/dist
rm -rf .turbo
rm pnpm-lock.yaml

# Step 3: Clear caches
pnpm store prune
npm cache clean --force

# Step 4: Increase memory and rebuild
export NODE_OPTIONS="--max-old-space-size=8192"
pnpm install
pnpm build

# Step 5: If still failing, build packages individually
cd packages/components
pnpm build

cd ../server
pnpm build

cd ../ui
pnpm build

cd ../..
```

### Error 3: `node-gyp` Build Failures

**Cause**: Missing C++ build tools or incompatible Python version.

**Solution**:

```bash
# Install Xcode Command Line Tools
xcode-select --install

# If already installed, reset it
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install

# Set up Python in virtual environment
cd /path/to/Flowise
python3 -m venv venv
source venv/bin/activate
pip install setuptools wheel

# Set Python path for node-gyp
export PYTHON=$(which python)
export npm_config_python=$PYTHON

# Install node-gyp globally
npm install -g node-gyp

# Try building again
pnpm install
```

---

## Node.js Version Issues

### Error: Node.js 23.x Causing TypeScript Errors

**Symptoms**:
- Type errors like `Property 'score' does not exist on type 'SearchResultData'`
- `ArrayBuffer` / `Buffer` type incompatibilities
- OpenTelemetry SDK type mismatches

**Cause**: Node.js 23 is too new (released October 2024) and has breaking changes.

**Solution: Use Node.js 20 LTS**

```bash
# Method 1: Using Homebrew
brew uninstall node
brew install node@20
brew link node@20 --force --overwrite

# Verify
node --version  # Should show v20.x.x

# Method 2: Using NVM (Recommended)
nvm install 20
nvm use 20
nvm alias default 20

# Create .nvmrc in project
cd /path/to/Flowise
echo "20" > .nvmrc

# Reinstall dependencies with correct Node version
rm -rf node_modules
rm pnpm-lock.yaml
npm install -g pnpm
pnpm install
pnpm build
```

### NVM Not Found After Installation

**Cause**: Shell configuration not loaded or incorrect shell.

**Solution for zsh (default on modern MacOS)**:

```bash
# Open .zshrc
nano ~/.zshrc

# Add these lines at the end:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Save (Ctrl+O, Enter, Ctrl+X)

# Reload shell
source ~/.zshrc

# Verify
nvm --version
```

**Solution for bash**:

```bash
# Open .bash_profile or .bashrc
nano ~/.bash_profile

# Add the same NVM lines as above
# Save and reload
source ~/.bash_profile

# Verify
nvm --version
```

**If NVM directory doesn't exist**:

```bash
# Remove any partial installation
rm -rf ~/.nvm

# Reinstall NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# The script should auto-configure your shell
# Close and reopen terminal
nvm --version
```

---

## Python and Native Module Issues

### Python Version Compatibility

**Compatible versions**: Python 3.8, 3.9, 3.10, 3.11
**Incompatible**: Python 3.12+ (removed distutils)

**Check and install correct Python version**:

```bash
# Check current version
python3 --version

# If Python 3.12+, install 3.11
brew install python@3.11

# Create alias (add to ~/.zshrc)
alias python3.11='/opt/homebrew/bin/python3.11'

# Create virtual environment with Python 3.11
python3.11 -m venv venv
source venv/bin/activate

# Verify
python --version  # Should show 3.11.x
```

### Native Module Compilation Failures

**Symptoms**:
- `sqlite3` build errors
- `faiss-node` compilation failures
- Missing header files

**Solution**:

```bash
cd /path/to/Flowise

# 1. Ensure virtual environment is active
source venv/bin/activate

# 2. Install Python build dependencies
pip install setuptools wheel

# 3. Install Xcode Command Line Tools
xcode-select --install

# 4. Set environment variables for native builds
export PYTHON=$(which python)
export npm_config_python=$PYTHON
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"

# 5. Clean and rebuild
rm -rf node_modules
rm pnpm-lock.yaml

# 6. Install with increased verbosity to see errors
pnpm install --reporter=append-only

# 7. If specific module fails, try rebuilding it
npx node-gyp rebuild
```

---

## Dependency Conflicts

### Symptom: Version Conflicts Between Packages

**Error messages like**:
- `ERESOLVE unable to resolve dependency tree`
- `Conflicting peer dependency`
- `Could not resolve dependency`

**Solution 1: Clean Install with Strict Version Resolution**

```bash
cd /path/to/Flowise

# Complete clean
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/dist
rm -rf .turbo
rm pnpm-lock.yaml

# Clean pnpm store
pnpm store prune

# Clean npm cache
npm cache clean --force

# Reinstall from scratch
pnpm install --no-frozen-lockfile

# If conflicts persist, force resolution
pnpm install --force
```

**Solution 2: Update Dependencies**

```bash
cd /path/to/Flowise

# Update to latest compatible versions
pnpm update --latest

# If specific package causes issues, update it
pnpm update <package-name>@latest

# Rebuild
pnpm build
```

**Solution 3: Check for Duplicate Dependencies**

```bash
# List all dependencies
pnpm list

# Find duplicates
pnpm list --depth=0

# Deduplicate if needed
pnpm dedupe
```

### npm vs pnpm Conflicts

**Don't mix package managers!** Choose one and stick with it.

**If you accidentally used both**:

```bash
cd /path/to/Flowise

# Remove all lock files and node_modules
rm -rf node_modules
rm -rf packages/*/node_modules
rm package-lock.json
rm pnpm-lock.yaml
rm yarn.lock

# Choose pnpm (recommended for this project)
npm install -g pnpm
pnpm install
```

### Specific Module Conflicts

**TypeScript version conflicts**:

```bash
# Check TypeScript version
npx tsc --version

# If wrong version, update it
pnpm add -D typescript@5.3.3 -w

# Rebuild
pnpm build
```

**Type definition conflicts**:

```bash
# Update Node.js type definitions
pnpm add -D @types/node@latest -w

# Update in specific package
cd packages/components
pnpm add -D @types/node@latest

cd ../..
pnpm build
```

---

## Memory and Performance Issues

### Error: JavaScript Heap Out of Memory

**Symptoms**:
- Build fails with `FATAL ERROR: Ineffective mark-compacts near heap limit`
- Exit code 134
- Build hangs or crashes

**Solution**:

```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=8192"

# Add to shell profile for persistence
echo 'export NODE_OPTIONS="--max-old-space-size=8192"' >> ~/.zshrc
source ~/.zshrc

# Also increase system limits
ulimit -n 10240

# Try building again
cd /path/to/Flowise
pnpm build

# If still failing, increase even more
export NODE_OPTIONS="--max-old-space-size=16384"
pnpm build
```

### Slow Build Times

**Optimize build performance**:

```bash
# Use turbo cache
pnpm build

# Build specific packages only
cd packages/components
pnpm build

# Skip type checking temporarily (development only)
pnpm build --no-check

# Use more CPU cores
export UV_THREADPOOL_SIZE=128

# Close other applications to free RAM
```

### Disk Space Issues

**Check and free up space**:

```bash
# Check disk usage
df -h

# Check project size
du -sh /path/to/Flowise
du -sh /path/to/Flowise/node_modules

# Clean up caches
pnpm store prune
npm cache clean --force

# Clean up old builds
cd /path/to/Flowise
rm -rf packages/*/dist
rm -rf .turbo

# Clean up Homebrew caches
brew cleanup

# Clean up old Node versions (if using NVM)
nvm cache clear
```

---

## Package Manager Issues

### pnpm Not Found After Installation

**Solution**:

```bash
# Reinstall pnpm globally
npm install -g pnpm

# Verify installation
which pnpm
pnpm --version

# If still not found, check npm global path
npm config get prefix

# Add to PATH if needed (add to ~/.zshrc)
export PATH="$(npm config get prefix)/bin:$PATH"
source ~/.zshrc

# Verify again
pnpm --version
```

### pnpm Store Corruption

**Symptoms**:
- Packages fail to install
- Checksum errors
- Corrupted symlinks

**Solution**:

```bash
# Clear pnpm store
pnpm store prune

# Verify store
pnpm store status

# If corrupted, remove completely
rm -rf ~/.pnpm-store
rm -rf ~/Library/pnpm

# Reinstall project dependencies
cd /path/to/Flowise
rm -rf node_modules
rm pnpm-lock.yaml
pnpm install
```

### Permission Errors

**Symptoms**:
- `EACCES: permission denied`
- `EPERM: operation not permitted`

**Solution**:

```bash
# Fix npm/pnpm global directory permissions
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}

# Or reinstall Node.js with correct permissions
brew uninstall node
brew install node@20
brew link node@20 --force --overwrite

# Reinstall pnpm
npm install -g pnpm

# Never use sudo with npm/pnpm in this project!
```

---

## Complete Clean Installation Process

If all else fails, follow this complete clean installation:

### Step 1: Clean System

```bash
# Stop any running Flowise processes
pkill -f flowise
pkill -f node

# Clean project directory
cd /path/to/Flowise
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/dist
rm -rf .turbo
rm pnpm-lock.yaml

# Clean virtual environment (if exists)
rm -rf venv

# Clean caches
pnpm store prune
npm cache clean --force
```

### Step 2: Set Up Environment

```bash
# Install/Update Xcode Command Line Tools
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install

# Install Node.js 20 LTS via NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshrc
nvm install 20
nvm use 20
nvm alias default 20

# Verify Node version
node --version  # Should be v20.x.x

# Install Python 3.11 (if not already)
brew install python@3.11
```

### Step 3: Create Virtual Environments

```bash
cd /path/to/Flowise

# Create .nvmrc for Node
echo "20" > .nvmrc

# Create Python virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip setuptools wheel

# Verify Python version
python --version  # Should be 3.11.x
```

### Step 4: Install Package Manager

```bash
# Install pnpm globally
npm install -g pnpm

# Verify
pnpm --version  # Should be 8.x or 9.x
```

### Step 5: Set Environment Variables

```bash
# Set Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=8192"

# Set Python path
export PYTHON=$(which python)
export npm_config_python=$PYTHON

# Add to shell profile for persistence
cat >> ~/.zshrc << 'EOF'

# Flowise environment variables
export NODE_OPTIONS="--max-old-space-size=8192"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

source ~/.zshrc
```

### Step 6: Install and Build

```bash
cd /path/to/Flowise

# Ensure virtual environment is active
source venv/bin/activate

# Install dependencies
pnpm install

# Build project
pnpm build

# If build succeeds, start the application
pnpm start

# Access at http://localhost:3000
```

### Step 7: Create Activation Script

```bash
# Create convenient activation script
cat > ~/flowise-env.sh << 'EOF'
#!/bin/bash

# Activate Flowise development environment
cd /path/to/Flowise

# Activate Node version
nvm use

# Activate Python virtual environment
source venv/bin/activate

# Set environment variables
export NODE_OPTIONS="--max-old-space-size=8192"
export PYTHON=$(which python)

echo "✅ Flowise environment activated"
echo "Node: $(node --version)"
echo "Python: $(python --version)"
echo "pnpm: $(pnpm --version)"
echo ""
echo "Ready to develop! Run 'pnpm start' to start the application."
EOF

chmod +x ~/flowise-env.sh

# Use it:
source ~/flowise-env.sh
```

---

## Advanced Troubleshooting

### Debug Build Process

**Run build with verbose logging**:

```bash
cd /path/to/Flowise

# Verbose pnpm
pnpm install --reporter=append-only --loglevel=debug

# Build specific package with verbose output
cd packages/components
pnpm build --verbose

# Check for TypeScript errors without building
npx tsc --noEmit
```

### Inspect Node Module Resolution

```bash
# Check where Node finds modules
node -e "console.log(require.resolve('typescript'))"

# List all installed packages
pnpm list --depth=0

# Check for peer dependency issues
pnpm list --depth=1 | grep "peer"

# Verify package versions
pnpm why <package-name>
```

### Check Python Module Resolution

```bash
# Ensure virtual environment is active
source venv/bin/activate

# Check where Python finds modules
python -c "import sys; print('\n'.join(sys.path))"

# Verify setuptools installation
python -c "import setuptools; print(setuptools.__version__)"

# Check if distutils available
python -c "from setuptools import distutils; print('distutils available')"
```

### Monitor Resource Usage During Build

```bash
# Monitor in separate terminal
# Terminal 1: Start monitoring
top -pid $(pgrep -f node)

# Terminal 2: Run build
cd /path/to/Flowise
pnpm build

# Or use Activity Monitor app on MacOS
```

### Check for Conflicting Processes

```bash
# Check what's using port 3000
lsof -i :3000

# Kill process if needed
kill -9 <PID>

# Check for other Node processes
ps aux | grep node

# Check for Python processes
ps aux | grep python
```

### Reset to Known Good State

```bash
cd /path/to/Flowise

# Stash any local changes
git stash

# Pull latest code
git pull origin main

# Follow complete clean installation process above
# ... (Steps 1-6 from Complete Clean Installation Process)
```

---

## Quick Reference: Common Commands

### Activate Environment

```bash
cd /path/to/Flowise
nvm use
source venv/bin/activate
export NODE_OPTIONS="--max-old-space-size=8192"
```

### Clean Everything

```bash
rm -rf node_modules packages/*/node_modules packages/*/dist .turbo pnpm-lock.yaml venv
pnpm store prune
npm cache clean --force
```

### Rebuild from Scratch

```bash
python3.11 -m venv venv
source venv/bin/activate
pip install setuptools wheel
pnpm install
pnpm build
```

### Start Development

```bash
source venv/bin/activate
nvm use
pnpm start  # or pnpm dev for development mode
```

---

## Getting Additional Help

If you've tried all troubleshooting steps and still encounter issues:

1. **Check GitHub Issues**: https://github.com/maximuslee1226/Flowise/issues
2. **Review Build Logs**: Save complete build output to file:
   ```bash
   pnpm build 2>&1 | tee build.log
   ```
3. **Collect Environment Info**:
   ```bash
   echo "=== System Info ===" > debug-info.txt
   sw_vers >> debug-info.txt
   echo "=== Node Version ===" >> debug-info.txt
   node --version >> debug-info.txt
   echo "=== Python Version ===" >> debug-info.txt
   python --version >> debug-info.txt
   echo "=== pnpm Version ===" >> debug-info.txt
   pnpm --version >> debug-info.txt
   echo "=== Git Branch ===" >> debug-info.txt
   git branch --show-current >> debug-info.txt
   echo "=== Git Commit ===" >> debug-info.txt
   git log --oneline -1 >> debug-info.txt
   ```
4. **Create Issue**: Include debug-info.txt and build.log when reporting issues

---

## Best Practices for Team Development

### 1. Use Consistent Environment

**Create .tool-versions file** (for asdf users):

```bash
cat > .tool-versions << EOF
nodejs 20.11.0
python 3.11.7
EOF
```

### 2. Document Team Setup

**Create SETUP.md** with your team's specific configuration:

```markdown
# Team Setup Guide

## Required Versions
- Node.js: 20.11.0 (via NVM)
- Python: 3.11.7
- pnpm: 9.x

## Setup Steps
1. Clone repo: `git clone https://github.com/maximuslee1226/Flowise.git`
2. Run: `source ./activate.sh`
3. Run: `pnpm install && pnpm build`
4. Run: `pnpm start`
```

### 3. Share Activation Script

Commit `activate.sh` to repository for team use.

### 4. Use Pre-commit Hooks

Ensure code quality before commits:

```bash
# Make husky hooks executable
chmod +x .husky/pre-commit

# Configure git hooks
git config core.hooksPath .husky
```

---

**Last Updated**: 2025-11-13

**Note**: This guide is based on real troubleshooting scenarios encountered during F5 AI Agents Workflow Design Hub development on MacOS.
