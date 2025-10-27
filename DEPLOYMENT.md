# F5 AI Agent Workflow Design Hub Deployment Guide

This is a customized version of Flowise branded as "F5 AI Agent Workflow Design Hub". This guide provides detailed instructions for deploying the application in a containerized environment and installing it as a Progressive Web App (PWA) on Mac and Windows.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start with Docker](#quick-start-with-docker)
- [Development Setup](#development-setup)
- [Building from Source](#building-from-source)
- [Installing as PWA](#installing-as-pwa)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Git**: Version 2.x or higher
- **Docker**: Version 20.x or higher
- **Docker Compose**: Version 2.x or higher

### For Development Setup (Optional)
- **Node.js**: Version 18.x or higher
- **pnpm**: Version 8.x or higher

### System Requirements
- **RAM**: Minimum 4GB, recommended 8GB or more
- **Disk Space**: At least 10GB free space
- **OS**: macOS, Windows 10/11, or Linux

---

## Quick Start with Docker

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/maximuslee1226/Flowise.git

# Navigate to the project directory
cd Flowise
```

### Step 2: Start with Docker Compose

The F5 customized version includes a docker-compose configuration file:

```bash
# Start the application using docker-compose
docker-compose -f docker-compose-f5.yml up -d
```

This will:
- Pull the necessary Docker images
- Start the Flowise server on port 3000
- Mount necessary volumes for data persistence

### Step 3: Access the Application

Open your web browser and navigate to:
```
http://localhost:3000
```

You should see the F5 AI Agent Workflow Design Hub interface.

### Step 4: Stop the Application

To stop the application:

```bash
docker-compose -f docker-compose-f5.yml down
```

To stop and remove all data:

```bash
docker-compose -f docker-compose-f5.yml down -v
```

---

## Development Setup

For developers who want to run the application locally without Docker:

### Step 1: Clone the Repository

```bash
git clone https://github.com/maximuslee1226/Flowise.git
cd Flowise
```

### Step 2: Install pnpm

If you don't have pnpm installed:

```bash
# On macOS/Linux
npm install -g pnpm

# On Windows (PowerShell as Administrator)
npm install -g pnpm
```

### Step 3: Install Dependencies

```bash
pnpm install
```

This will install all dependencies for both the UI and server packages.

### Step 4: Configure Environment Variables

Create a `.env` file in the root directory (optional):

```bash
# Server Configuration
PORT=3000
HOST=localhost

# Database Configuration
DATABASE_PATH=~/.flowise

# Logging
LOG_LEVEL=debug
DEBUG=true
LOG_PATH=~/.flowise/logs

# Development Mode
NODE_ENV=development
```

### Step 5: Start the Development Server

```bash
pnpm start
```

This will:
- Start the backend server on port 3000
- Start the Vite dev server for the UI
- Open the application in your default browser

The application should be available at `http://localhost:3000`

---

## Building from Source

If you want to build the application for production:

### Step 1: Build the UI

```bash
cd packages/ui
pnpm build
```

This creates an optimized production build in `packages/ui/build/`.

### Step 2: Build the Server

```bash
cd packages/server
pnpm build
```

### Step 3: Start Production Server

```bash
cd packages/server
pnpm start
```

The production build will be served at `http://localhost:3000`.

---

## Installing as PWA

The F5 AI Agent Workflow Design Hub can be installed as a Progressive Web App on both Mac and Windows for a native app experience.

### On Mac

#### Option 1: Using Chrome/Edge

1. Open Chrome or Edge browser
2. Navigate to `http://localhost:3000` (or your deployed URL)
3. Click the **install icon** (⊕) in the address bar (right side)
   - Or click the three-dot menu → **Install F5 AI Agent Workflow Design Hub**
4. Click **Install** in the confirmation dialog
5. The app will be installed and opened in its own window
6. Find the app in:
   - **Applications** folder
   - **Launchpad**
   - **Dock** (if you keep it there)

#### Option 2: Using Safari

1. Open Safari browser
2. Navigate to `http://localhost:3000` (or your deployed URL)
3. Click **Share** button in the toolbar
4. Select **Add to Dock**
5. The app will appear in your Dock

### On Windows

#### Using Chrome/Edge

1. Open Chrome or Edge browser
2. Navigate to `http://localhost:3000` (or your deployed URL)
3. Click the **install icon** (⊕) in the address bar
   - Or click the three-dot menu (⋮) → **Install F5 AI Agent Workflow Design Hub**
4. Click **Install** in the confirmation dialog
5. The app will be:
   - Added to your Start Menu
   - Available as a desktop shortcut (if selected)
   - Pinnable to the Taskbar

### Verifying PWA Installation

The installed PWA should:
- Display the **F5 logo** as the app icon
- Show **"F5 AI Agent Workflow Design Hub (Built on Flowise)"** as the title
- Run in its own window without browser UI
- Be accessible from your system's application launcher

### Uninstalling the PWA

#### On Mac:
- Delete from Applications folder, or
- Right-click in Launchpad → Delete

#### On Windows:
- Right-click the app in Start Menu → **Uninstall**
- Or: Settings → Apps → Find "F5 AI Agent Workflow Design Hub" → Uninstall

#### In Browser:
- Chrome/Edge: `chrome://apps` or `edge://apps` → Right-click → **Remove from Chrome/Edge**

---

## Configuration

### Environment Variables

Create a `.env` file in the root directory to customize the deployment:

```bash
# Server Configuration
PORT=3000                          # Port for the server
HOST=0.0.0.0                       # Host address (use 0.0.0.0 for Docker)

# Database Configuration
DATABASE_PATH=/root/.flowise       # Path to store database
DATABASE_TYPE=sqlite               # Database type (sqlite/postgres/mysql)

# Security
FLOWISE_USERNAME=admin             # Admin username
FLOWISE_PASSWORD=your_password     # Admin password
SECRETKEY_OVERWRITE=mySecretKey    # Secret key for encryption

# Logging
LOG_LEVEL=info                     # Log level (debug/info/warn/error)
LOG_PATH=/root/.flowise/logs       # Log file path

# LangChain Configuration
LANGCHAIN_TRACING_V2=false         # Enable LangChain tracing
LANGCHAIN_API_KEY=                 # LangChain API key

# File Upload Limits
FLOWISE_FILE_SIZE_LIMIT=50mb       # Max file upload size

# CORS Configuration
CORS_ORIGINS=*                     # Allowed CORS origins (* for all)

# Rate Limiting
RATE_LIMIT_MAX=100                 # Max requests per window
RATE_LIMIT_DURATION=60000          # Rate limit window (ms)
```

### Docker Environment

When using Docker, create a `.env` file in the same directory as `docker-compose-f5.yml`:

```bash
PORT=3000
DATABASE_PATH=/root/.flowise
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=your_secure_password
```

---

## Troubleshooting

### Port Already in Use

If port 3000 is already in use:

```bash
# Change the port in .env file
PORT=3001

# Or use a different port with Docker
docker-compose -f docker-compose-f5.yml up -d
# Then edit docker-compose-f5.yml to use a different port mapping
```

### Database Connection Issues

If you encounter database issues:

```bash
# Reset the database (WARNING: This will delete all data)
rm -rf ~/.flowise

# Or with Docker
docker-compose -f docker-compose-f5.yml down -v
docker-compose -f docker-compose-f5.yml up -d
```

### Build Failures

If the build fails:

```bash
# Clean install dependencies
rm -rf node_modules
rm -rf packages/*/node_modules
pnpm install

# Clear pnpm cache
pnpm store prune

# Try building again
pnpm build
```

### PWA Not Updating

If the PWA shows old content after updates:

1. **Uninstall the PWA completely**
2. **Clear browser cache**:
   - Chrome: Settings → Privacy → Clear browsing data → Cached images and files
   - Safari: Develop → Empty Caches
3. **Restart the server**
4. **Reinstall the PWA**

### Docker Container Won't Start

```bash
# Check container logs
docker-compose -f docker-compose-f5.yml logs -f

# Rebuild containers
docker-compose -f docker-compose-f5.yml build --no-cache
docker-compose -f docker-compose-f5.yml up -d
```

---

## Customization Details

This version includes the following customizations from the original Flowise:

1. **Branding**:
   - App name: "F5 AI Agent Workflow Design Hub (Built on Flowise)"
   - F5 logo throughout the application
   - Custom PWA icons and favicon

2. **Modified Files**:
   - `packages/ui/index.html` - Updated title and meta tags
   - `packages/ui/public/index.html` - Updated public HTML template
   - `packages/ui/public/logo192.png` - F5 PWA icon (192x192)
   - `packages/ui/public/logo512.png` - F5 PWA icon (512x512)
   - `packages/ui/public/favicon.ico` - F5 favicon
   - `packages/ui/src/assets/images/f5_logo.png` - F5 logo for UI
   - `images/f5-logo.png` - Source F5 logo

3. **Configuration**:
   - `docker-compose-f5.yml` - Custom Docker Compose configuration

---

## Support and Contributing

For issues or questions:
- Original Flowise: https://github.com/FlowiseAI/Flowise
- This customized version: https://github.com/maximuslee1226/Flowise

---

## License

This project is based on Flowise, which is licensed under the Apache License 2.0.

---

**Generated with F5 AI Agent Workflow Design Hub (Built on Flowise)**
