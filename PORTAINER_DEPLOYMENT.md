# Portainer Deployment Guide - Beats Music NFT Marketplace

This guide provides step-by-step instructions for deploying the Beats Music NFT Marketplace to a local Portainer instance.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Method 1: Manual Image Import (Recommended for Local)](#method-1-manual-image-import-recommended-for-local)
- [Method 2: Deploy from Git Repository](#method-2-deploy-from-git-repository)
- [Method 3: Local Docker Registry](#method-3-local-docker-registry)
- [Method 4: Docker Hub (Optional)](#method-4-docker-hub-optional)
- [Post-Deployment Configuration](#post-deployment-configuration)
- [Accessing Your Application](#accessing-your-application)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before deploying, ensure you have:

1. **Portainer installed and running** on your local server
   - Access Portainer at: `http://[SERVER_IP]:9000` or `http://localhost:9000`
   - Have admin credentials ready

2. **Docker installed** on your development machine (for building images)
   - Docker Desktop (Windows/Mac) or Docker Engine (Linux)
   - Verify with: `docker --version`

3. **Project files** cloned to your local machine
   ```bash
   git clone <your-repository-url>
   cd beats-music-nft-marketplace
   ```

---

## Method 1: Manual Image Import (Recommended for Local)

**Best for**: Single-server Portainer deployments without external registry access

### Step 1: Build the Docker Image Locally

Open a terminal in your project directory:

```bash
# Navigate to the project root
cd beats-music-nft-marketplace

# Build the Docker image
docker build -t beats-nft-marketplace:latest -f frontend/Dockerfile frontend/

# Verify the image was created
docker images | grep beats-nft-marketplace
```

Expected output:
```
beats-nft-marketplace   latest   abc123def456   2 minutes ago   150MB
```

### Step 2: Save Image as TAR File

```bash
# Save the image to a tar file
docker save -o beats-nft-marketplace.tar beats-nft-marketplace:latest

# Verify the tar file was created
ls -lh beats-nft-marketplace.tar
```

The tar file will be approximately 150-200MB.

### Step 3: Import Image into Portainer

1. **Open Portainer** in your web browser:
   - Navigate to `http://[SERVER_IP]:9000`
   - Log in with your credentials

2. **Select your environment**:
   - Click on your local Docker environment (usually named "local" or "primary")

3. **Navigate to Images**:
   - In the left sidebar, click **Images**

4. **Import the image**:
   - Click the **Import** button at the top
   - Click **Select file** and choose `beats-nft-marketplace.tar`
   - Click **Upload**
   - Wait for the import to complete (progress bar will show status)

5. **Verify import**:
   - You should see `beats-nft-marketplace:latest` in the images list

### Step 4: Create and Deploy Container

1. **Navigate to Containers**:
   - In the left sidebar, click **Containers**

2. **Add new container**:
   - Click **Add container** button

3. **Configure container settings**:

   **Basic Configuration**:
   - **Name**: `beats-music-nft-marketplace`
   - **Image**: `beats-nft-marketplace:latest`

   **Network ports configuration**:
   - Click **+ publish a new network port**
   - **Host**: `3000`
   - **Container**: `3000`
   - **Protocol**: `TCP`

   **Environment variables** (click **+ add environment variable** for each):
   ```
   NODE_ENV = production
   NEXT_PUBLIC_SUI_NETWORK = testnet
   NEXT_PUBLIC_RPC_URL = https://fullnode.testnet.sui.io:443
   NEXT_TELEMETRY_DISABLED = 1
   ```

   **Restart policy**:
   - Select **Unless stopped** (recommended for production)

   **Advanced container settings** (optional):
   - **Auto remove**: Unchecked
   - **Resource limits**: Set if needed (e.g., Memory: 512MB)

4. **Deploy the container**:
   - Click **Deploy the container**
   - Wait for the container to start (status should show "running")

5. **Verify deployment**:
   - Container status should be green (running)
   - Click on the container name to view logs
   - Look for: `ready started server on 0.0.0.0:3000`

---

## Method 2: Deploy from Git Repository

**Best for**: Frequent updates, automatic builds on code changes

### Step 1: Prepare Git Repository

Ensure your code is pushed to a Git repository (GitHub, GitLab, Bitbucket, or local Git server):

```bash
git add .
git commit -m "Add Docker configuration"
git push origin main
```

### Step 2: Deploy Stack in Portainer

1. **Open Portainer** and select your environment

2. **Navigate to Stacks**:
   - In the left sidebar, click **Stacks**

3. **Add new stack**:
   - Click **+ Add stack**
   - **Name**: `beats-nft-marketplace`

4. **Build method**: Select **Repository**

5. **Configure repository**:
   - **Repository URL**: Your Git repository URL
     - GitHub: `https://github.com/your-username/beats-music-nft-marketplace`
     - GitLab: `https://gitlab.com/your-username/beats-music-nft-marketplace`
     - Local: `http://[GIT_SERVER_IP]/beats-music-nft-marketplace.git`

   - **Repository reference**: `refs/heads/main` (or your branch name)

   - **Compose path**: `docker-compose.yml`

   - **Authentication** (if private repository):
     - Check **Use authentication**
     - Enter username and password/token

6. **Environment variables** (optional overrides):
   ```
   NEXT_PUBLIC_SUI_NETWORK=testnet
   ```

7. **Deploy the stack**:
   - Click **Deploy the stack**
   - Portainer will:
     1. Clone the repository
     2. Build the Docker image using the Dockerfile
     3. Start the container with docker-compose configuration

8. **Monitor deployment**:
   - View logs in real-time under the stack details
   - Wait for build to complete (may take 3-5 minutes first time)

### Step 3: Enable Auto-Updates (Optional)

1. **Edit the stack**
2. **Enable webhook**: Toggle on "Create a webhook"
3. **Copy webhook URL**: Use in your Git repository settings
4. Configure Git webhook to trigger on push events

---

## Method 3: Local Docker Registry

**Best for**: Multiple servers, repeated deployments across environments

### Step 1: Set Up Local Registry

On your Portainer server, run:

```bash
# Start a local Docker registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Verify registry is running
docker ps | grep registry
```

### Step 2: Build and Push to Local Registry

On your development machine:

```bash
# Build the image
docker build -t beats-nft-marketplace:latest -f frontend/Dockerfile frontend/

# Tag for local registry (replace SERVER_IP with your server's IP)
docker tag beats-nft-marketplace:latest [SERVER_IP]:5000/beats-nft-marketplace:latest

# Push to local registry
docker push [SERVER_IP]:5000/beats-nft-marketplace:latest
```

**Note**: If you get TLS/SSL errors, you may need to configure Docker to allow insecure registry:

Edit Docker daemon configuration:
- **Windows/Mac**: Docker Desktop → Settings → Docker Engine
- **Linux**: `/etc/docker/daemon.json`

Add:
```json
{
  "insecure-registries": ["[SERVER_IP]:5000"]
}
```

Restart Docker after changes.

### Step 3: Deploy from Local Registry in Portainer

1. **Navigate to Containers** → **Add container**

2. **Configure**:
   - **Name**: `beats-music-nft-marketplace`
   - **Image**: `[SERVER_IP]:5000/beats-nft-marketplace:latest`
   - Configure ports, environment variables as in Method 1

3. **Deploy the container**

---

## Method 4: Docker Hub (Optional)

**Best for**: Remote access, deploying to multiple locations

### Step 1: Create Docker Hub Account

- Sign up at [hub.docker.com](https://hub.docker.com)
- Create a repository: `your-username/beats-nft-marketplace`

### Step 2: Build and Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Build and tag image
docker build -t your-username/beats-nft-marketplace:latest -f frontend/Dockerfile frontend/

# Push to Docker Hub
docker push your-username/beats-nft-marketplace:latest
```

### Step 3: Deploy in Portainer

1. **Add container**
2. **Image**: `your-username/beats-nft-marketplace:latest`
3. Configure and deploy as in Method 1

---

## Post-Deployment Configuration

### Configure Reverse Proxy (Optional but Recommended)

For production use with custom domain and HTTPS:

#### Using Nginx Proxy Manager (in Portainer)

1. **Deploy Nginx Proxy Manager**:
   - In Portainer: Stacks → Add stack
   - Use this docker-compose:

```yaml
version: '3.8'
services:
  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

2. **Access Nginx Proxy Manager**:
   - Navigate to `http://[SERVER_IP]:81`
   - Default login:
     - Email: `admin@example.com`
     - Password: `changeme`
   - Change password immediately

3. **Add Proxy Host**:
   - Go to **Hosts** → **Proxy Hosts** → **Add Proxy Host**
   - **Domain Names**: `beats.yourdomain.com`
   - **Scheme**: `http`
   - **Forward Hostname/IP**: `beats-music-nft-marketplace` (container name)
   - **Forward Port**: `3000`
   - **SSL**: Request new SSL certificate (Let's Encrypt)

4. **Update DNS**:
   - Point `beats.yourdomain.com` to your server IP

---

## Accessing Your Application

### Local Access (Same Machine)
```
http://localhost:3000
```

### Network Access (Other Devices on LAN)
```
http://[SERVER_IP]:3000
```
Example: `http://192.168.1.100:3000`

### With Custom Domain
```
http://beats.yourdomain.com
```

### With HTTPS (After reverse proxy setup)
```
https://beats.yourdomain.com
```

**Note**: Sui wallet connections work better with HTTPS in production.

---

## Troubleshooting

### Container Won't Start

**Check logs**:
1. In Portainer, click on the container
2. Click **Logs** tab
3. Look for error messages

**Common issues**:
- Port 3000 already in use
  - Solution: Change host port to different value (e.g., 3001:3000)

- Missing environment variables
  - Solution: Verify all required env vars are set

- Build failed
  - Solution: Check Dockerfile syntax, ensure all files copied correctly

### Application Loads but Can't Connect to Sui Network

**Check**:
1. Environment variables are correctly set
2. `NEXT_PUBLIC_SUI_NETWORK` is `testnet` or `mainnet`
3. `NEXT_PUBLIC_RPC_URL` is accessible from container

**Test RPC endpoint**:
```bash
# From container
docker exec -it beats-music-nft-marketplace sh
wget -O- https://fullnode.testnet.sui.io:443
```

### Wallet Connection Fails

**Possible causes**:
- Not using HTTPS (wallets require secure context)
- Browser blocking third-party cookies
- Wallet extension not installed

**Solutions**:
- Set up HTTPS with reverse proxy
- Check browser console for errors
- Install Sui wallet extension (e.g., Sui Wallet, Ethos Wallet)

### Image Import Fails

**Check**:
- Tar file not corrupted: `tar -tzf beats-nft-marketplace.tar > /dev/null`
- Sufficient disk space on Portainer server
- Portainer has permissions to write to Docker

### Performance Issues

**Optimize**:
1. Increase container memory limit:
   - Container → Duplicate/Edit → Resources → Memory limit: 1GB

2. Check resource usage:
   - Container → Stats tab
   - Look for CPU/Memory usage

3. Enable container restart on failure:
   - Restart policy: **On failure**

### Cannot Access from Other Devices

**Check**:
1. Firewall rules allow port 3000
   - Windows: `netsh advfirewall firewall add rule name="Beats NFT" dir=in action=allow protocol=TCP localport=3000`
   - Linux: `sudo ufw allow 3000/tcp`

2. Container is bound to 0.0.0.0 (not 127.0.0.1)
   - Verify in docker-compose or container settings

3. Network connectivity
   - Ping server IP from other device
   - Check router/network configuration

---

## Updating the Application

### Method 1 (Manual Image Import)
1. Build new image with updated code
2. Save new tar file
3. Import to Portainer (overwrites existing image)
4. Recreate container (Portainer → Container → Recreate)

### Method 2 (Git Repository)
1. Push code changes to Git
2. In Portainer: Stack → Pull and redeploy
3. Portainer rebuilds and redeploys automatically

### Method 3 (Registry)
1. Build and push new image with updated tag
2. Update container image in Portainer
3. Recreate container

---

## Security Best Practices

1. **Change default ports**: Use non-standard ports if exposing to internet
2. **Enable HTTPS**: Always use SSL/TLS for production
3. **Firewall**: Only expose necessary ports
4. **Updates**: Keep Docker and Portainer updated
5. **Secrets**: Never commit .env files with sensitive data
6. **Monitoring**: Set up container health checks and alerts

---

## Support

For issues related to:
- **Docker/Portainer**: Check Portainer documentation
- **Sui blockchain**: Visit [Sui Documentation](https://docs.sui.io)
- **Application bugs**: Check container logs and GitHub issues

---

## Summary Comparison

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| Manual Import | Local single server | Simple, no registry needed | Manual updates |
| Git Repository | Active development | Auto-updates, version control | Requires Git repo |
| Local Registry | Multiple servers | Fast, local, reusable | Extra setup |
| Docker Hub | Public/multi-location | Accessible anywhere | Requires internet, public by default |

**Recommendation for local Portainer**: Start with **Method 1 (Manual Import)** for simplicity, upgrade to **Method 2 (Git)** when you need automatic updates.
