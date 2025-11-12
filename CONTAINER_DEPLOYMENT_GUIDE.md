# F5 AI Agents Workflow Design Hub - Container Deployment Guide

This guide provides detailed instructions for deploying the F5 AI Agents Workflow Design Hub using Docker containers on standalone MacOS, Windows, and Kubernetes environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Docker Deployment on MacOS](#docker-deployment-on-macos)
- [Docker Deployment on Windows](#docker-deployment-on-windows)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Configuration Options](#configuration-options)
- [Redeployment and Updates](#redeployment-and-updates)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### For Docker (MacOS & Windows)

**MacOS:**
- Docker Desktop for Mac (version 4.0 or later)
  - Download: https://docs.docker.com/desktop/install/mac-install/
- At least 4GB RAM allocated to Docker
- 10GB free disk space

**Windows:**
- Docker Desktop for Windows (version 4.0 or later)
  - Download: https://docs.docker.com/desktop/install/windows-install/
- WSL 2 backend enabled
- At least 4GB RAM allocated to Docker
- 10GB free disk space

### For Kubernetes

- Kubernetes cluster (1.19+)
- `kubectl` configured and connected to your cluster
- At least 2GB RAM and 2 CPU cores available
- StorageClass configured for persistent volumes
- (Optional) Ingress controller installed (e.g., NGINX Ingress Controller)

---

## Docker Deployment on MacOS

### Step 1: Install Docker Desktop

1. Download and install Docker Desktop from https://docs.docker.com/desktop/install/mac-install/
2. Launch Docker Desktop and ensure it's running (check the whale icon in the menu bar)
3. Open Terminal

### Step 2: Clone the Repository

```bash
git clone https://github.com/maximuslee1226/Flowise.git
cd Flowise
```

### Step 3: Build and Run with Docker Compose

```bash
# Build and start the container in detached mode
docker-compose up -d

# Check if the container is running
docker-compose ps

# View logs (optional)
docker-compose logs -f flowise
```

### Step 4: Access the Application

Open your browser and navigate to:
```
http://localhost:3000
```

### Step 5: Stop the Application

```bash
# Stop the container
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers with volumes (WARNING: This deletes all data)
docker-compose down -v
```

### MacOS-Specific Troubleshooting

**Issue: Port 3000 already in use**
```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or change the port in docker-compose.yml
# ports:
#   - '3001:3000'
```

**Issue: Docker Desktop not starting**
```bash
# Reset Docker Desktop from Troubleshoot menu
# Or reinstall Docker Desktop
```

---

## Docker Deployment on Windows

### Step 1: Install Docker Desktop

1. Download Docker Desktop from https://docs.docker.com/desktop/install/windows-install/
2. Enable WSL 2 during installation
3. Restart your computer if prompted
4. Launch Docker Desktop and ensure it's running (check system tray)

### Step 2: Clone the Repository

Open PowerShell or Command Prompt:

```powershell
git clone https://github.com/maximuslee1226/Flowise.git
cd Flowise
```

### Step 3: Build and Run with Docker Compose

```powershell
# Build and start the container in detached mode
docker-compose up -d

# Check if the container is running
docker-compose ps

# View logs (optional)
docker-compose logs -f flowise
```

### Step 4: Access the Application

Open your browser and navigate to:
```
http://localhost:3000
```

### Step 5: Stop the Application

```powershell
# Stop the container
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers with volumes (WARNING: This deletes all data)
docker-compose down -v
```

### Windows-Specific Troubleshooting

**Issue: WSL 2 not installed**
```powershell
# Install WSL 2
wsl --install

# Set WSL 2 as default
wsl --set-default-version 2
```

**Issue: Port 3000 already in use**
```powershell
# Find process using port 3000
netstat -ano | findstr :3000

# Kill the process
taskkill /PID <PID> /F

# Or change the port in docker-compose.yml
```

**Issue: Line ending problems**
```bash
# Configure git to use Unix line endings
git config --global core.autocrlf false
git config --global core.eol lf

# Re-clone the repository
```

---

## Kubernetes Deployment

### Step 1: Prepare Your Cluster

Ensure your Kubernetes cluster is running and `kubectl` is configured:

```bash
# Check cluster connection
kubectl cluster-info

# Check available nodes
kubectl get nodes
```

### Step 2: Build and Push Docker Image

First, build the Docker image and push it to your container registry:

```bash
# Build the image
docker build -t your-registry/f5-flowise:latest .

# Tag the image (if needed)
docker tag flowise:latest your-registry/f5-flowise:latest

# Push to registry
docker push your-registry/f5-flowise:latest
```

**Note:** Update `kubernetes/deployment.yaml` with your image name:
```yaml
image: your-registry/f5-flowise:latest
```

### Step 3: Deploy to Kubernetes

```bash
# Navigate to project directory
cd Flowise

# Apply all Kubernetes manifests
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/persistent-volume.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Optional: Apply ingress if you have an ingress controller
kubectl apply -f kubernetes/ingress.yaml
```

### Step 4: Verify Deployment

```bash
# Check namespace
kubectl get namespace f5-flowise

# Check all resources
kubectl get all -n f5-flowise

# Check pod status
kubectl get pods -n f5-flowise

# View pod logs
kubectl logs -n f5-flowise -l app=f5-ai-agents -f

# Check service
kubectl get service -n f5-flowise
```

### Step 5: Access the Application

**Option 1: Using LoadBalancer (Cloud providers)**

```bash
# Get the external IP
kubectl get service flowise-service -n f5-flowise

# Access via external IP
# http://<EXTERNAL-IP>:3000
```

**Option 2: Using NodePort**

Edit `kubernetes/service.yaml` to use NodePort:
```yaml
spec:
  type: NodePort
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30000  # Choose a port between 30000-32767
```

Apply the change:
```bash
kubectl apply -f kubernetes/service.yaml

# Access via any node IP
# http://<NODE-IP>:30000
```

**Option 3: Using Port Forwarding (Development)**

```bash
# Forward local port to pod
kubectl port-forward -n f5-flowise svc/flowise-service 3000:3000

# Access at http://localhost:3000
```

**Option 4: Using Ingress (Production)**

Configure `kubernetes/ingress.yaml` with your domain:
```yaml
spec:
  rules:
  - host: flowise.yourdomain.com
```

Apply and access via your domain:
```bash
kubectl apply -f kubernetes/ingress.yaml
# Access at http://flowise.yourdomain.com
```

### Step 6: Scale the Deployment (Optional)

```bash
# Scale to 3 replicas
kubectl scale deployment flowise-deployment -n f5-flowise --replicas=3

# Verify scaling
kubectl get pods -n f5-flowise
```

---

## Configuration Options

### Environment Variables

Configure the application by editing:
- **Docker**: `docker-compose.yml` or create a `.env` file
- **Kubernetes**: `kubernetes/configmap.yaml`

#### Common Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Application port | `3000` |
| `NODE_ENV` | Environment (production/development) | `production` |
| `DATABASE_PATH` | Database storage path | `/root/.flowise` |
| `FLOWISE_USERNAME` | Username for authentication | (optional) |
| `FLOWISE_PASSWORD` | Password for authentication | (optional) |
| `RATE_LIMIT_MAX` | Max requests per duration | (optional) |
| `RATE_LIMIT_DURATION` | Duration in minutes | (optional) |

#### Example: Enable Authentication

**Docker Compose:**
```yaml
environment:
  - FLOWISE_USERNAME=admin
  - FLOWISE_PASSWORD=SecurePassword123!
```

**Kubernetes ConfigMap:**
```yaml
data:
  FLOWISE_USERNAME: "admin"
  FLOWISE_PASSWORD: "SecurePassword123!"
```

### Persistent Storage

**Docker:**
Data is stored in the named volume `f5_flowise_data`. To back up:
```bash
# Create backup
docker run --rm -v f5_flowise_data:/data -v $(pwd):/backup alpine tar czf /backup/flowise-backup.tar.gz -C /data .

# Restore backup
docker run --rm -v f5_flowise_data:/data -v $(pwd):/backup alpine tar xzf /backup/flowise-backup.tar.gz -C /data
```

**Kubernetes:**
Data is stored in PersistentVolumeClaim `flowise-data-pvc`. To adjust storage:
```yaml
# Edit kubernetes/persistent-volume.yaml
resources:
  requests:
    storage: 20Gi  # Change size as needed
```

---

## Redeployment and Updates

### Docker (MacOS & Windows)

#### Update to Latest Code

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up -d --build

# Or rebuild without cache
docker-compose build --no-cache
docker-compose up -d
```

#### Preserve Data During Update

```bash
# Stop container but keep volumes
docker-compose down

# Pull latest code
git pull origin main

# Rebuild and start
docker-compose up -d --build
```

### Kubernetes

#### Rolling Update

```bash
# Update the image version in deployment.yaml
# Then apply the changes
kubectl apply -f kubernetes/deployment.yaml

# Watch the rollout
kubectl rollout status deployment/flowise-deployment -n f5-flowise

# Check rollout history
kubectl rollout history deployment/flowise-deployment -n f5-flowise
```

#### Rollback Deployment

```bash
# Rollback to previous version
kubectl rollout undo deployment/flowise-deployment -n f5-flowise

# Rollback to specific revision
kubectl rollout undo deployment/flowise-deployment -n f5-flowise --to-revision=2
```

#### Update Configuration

```bash
# Edit configmap
kubectl edit configmap flowise-config -n f5-flowise

# Or apply updated file
kubectl apply -f kubernetes/configmap.yaml

# Restart pods to pick up new config
kubectl rollout restart deployment/flowise-deployment -n f5-flowise
```

---

## Troubleshooting

### Docker Issues

#### Container Won't Start

```bash
# Check logs
docker-compose logs flowise

# Check container status
docker-compose ps

# Restart container
docker-compose restart flowise
```

#### Out of Memory

Edit `docker-compose.yml` to increase memory:
```yaml
services:
  flowise:
    deploy:
      resources:
        limits:
          memory: 4G
```

#### Port Conflicts

Change the port mapping in `docker-compose.yml`:
```yaml
ports:
  - '3001:3000'  # Access at http://localhost:3001
```

### Kubernetes Issues

#### Pod Not Starting

```bash
# Describe pod to see events
kubectl describe pod -n f5-flowise -l app=f5-ai-agents

# Check pod logs
kubectl logs -n f5-flowise -l app=f5-ai-agents

# Check for image pull errors
kubectl get events -n f5-flowise --sort-by='.lastTimestamp'
```

#### Insufficient Resources

```bash
# Check node resources
kubectl top nodes

# Reduce resource requests in deployment.yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
```

#### PersistentVolumeClaim Pending

```bash
# Check PVC status
kubectl get pvc -n f5-flowise

# Describe PVC
kubectl describe pvc flowise-data-pvc -n f5-flowise

# Check available storage classes
kubectl get storageclass

# Update persistent-volume.yaml with correct storageClassName
```

#### Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints flowise-service -n f5-flowise

# Test from within cluster
kubectl run -it --rm debug --image=alpine --restart=Never -n f5-flowise -- sh
# Inside pod:
wget -O- http://flowise-service:3000/api/v1/ping
```

### General Issues

#### Application Health Check Failing

```bash
# Check health endpoint
curl http://localhost:3000/api/v1/ping

# Should return: OK
```

#### Database Corruption

```bash
# Docker: Remove volume and recreate
docker-compose down -v
docker-compose up -d

# Kubernetes: Delete PVC and recreate
kubectl delete pvc flowise-data-pvc -n f5-flowise
kubectl apply -f kubernetes/persistent-volume.yaml
kubectl rollout restart deployment/flowise-deployment -n f5-flowise
```

---

## Additional Resources

- **Docker Documentation**: https://docs.docker.com/
- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Flowise Documentation**: https://docs.flowiseai.com/
- **Project Repository**: https://github.com/maximuslee1226/Flowise

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review application logs
3. Open an issue at https://github.com/maximuslee1226/Flowise/issues

---

**Last Updated**: 2025-11-12
