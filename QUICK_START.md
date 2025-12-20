# Quick Start Guide - Beats Music NFT Marketplace

Get your Beats Music NFT Marketplace up and running in Portainer in 5 minutes!

## 🚀 Fastest Way to Deploy (Recommended for Local Portainer)

### Step 1: Build the Docker Image

**On Windows:**
```batch
.\scripts\docker-build.bat
```

**On Linux/Mac:**
```bash
chmod +x scripts/*.sh
./scripts/docker-build.sh
```

Wait for build to complete (3-5 minutes first time).

### Step 2: Save Image for Portainer

**On Windows:**
```batch
.\scripts\docker-push.bat
```
Then select option `3` (Save as TAR file)

**On Linux/Mac:**
```bash
./scripts/docker-push.sh
```
Then select option `4` (Save as TAR file)

This creates `beats-nft-marketplace-latest.tar` file.

### Step 3: Import to Portainer

1. Open Portainer in browser: `http://[YOUR_SERVER_IP]:9000`
2. Login with your credentials
3. Select your Docker environment
4. Click **Images** in left sidebar
5. Click **Import** button
6. Click **Select file** and choose `beats-nft-marketplace-latest.tar`
7. Click **Upload**
8. Wait for import to complete

### Step 4: Create Container

1. Click **Containers** in left sidebar
2. Click **Add container**
3. Fill in:
   - **Name**: `beats-music-nft-marketplace`
   - **Image**: `beats-nft-marketplace:latest`

4. Click **publish a new network port**:
   - **Host**: `3000`
   - **Container**: `3000`

5. Click **add environment variable** for each:
   ```
   NODE_ENV = production
   NEXT_PUBLIC_SUI_NETWORK = testnet
   NEXT_PUBLIC_RPC_URL = https://fullnode.testnet.sui.io:443
   ```

6. Set **Restart policy**: `Unless stopped`

7. Click **Deploy the container**

### Step 5: Access Your Application

Open in browser:
- From same machine: `http://localhost:3000`
- From network: `http://[YOUR_SERVER_IP]:3000`

---

## 🔄 Alternative: Using Docker Compose

If you prefer Docker Compose instead:

```bash
# Start with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## ✅ Verify Deployment

Check if container is running:

1. In Portainer:
   - Go to **Containers**
   - Status should be green (running)

2. Check logs:
   - Click on container name
   - Click **Logs** tab
   - Look for: `ready started server on 0.0.0.0:3000`

3. Test in browser:
   - Navigate to `http://[YOUR_SERVER_IP]:3000`
   - You should see the Beats marketplace homepage

---

## 🔧 Common Issues

### Container Won't Start
**Check logs in Portainer**:
- Click container → Logs tab
- Look for error messages

**Port already in use**:
- Change host port to `3001` or `8080`

### Can't Access from Browser
**Check firewall**:
- Windows: Allow port 3000 in Windows Firewall
- Linux: `sudo ufw allow 3000/tcp`

**Check container is running**:
- Status should be green in Portainer
- Try restarting the container

### Wallet Connection Issues
- Make sure you're using HTTPS (set up reverse proxy)
- Install Sui wallet browser extension
- Check browser console for errors

---

## 📚 Next Steps

After successful deployment:

1. **Set up HTTPS** (recommended for production):
   - See [PORTAINER_DEPLOYMENT.md](./PORTAINER_DEPLOYMENT.md#configure-reverse-proxy-optional-but-recommended)

2. **Configure custom domain**:
   - Use nginx or traefik reverse proxy
   - Point your domain to server IP

3. **Monitor your application**:
   - Use Portainer's Stats tab
   - Set up health check alerts

4. **Update the application**:
   - Rebuild image with new changes
   - Import new tar file to Portainer
   - Recreate container

---

## 📖 Full Documentation

- **Comprehensive Portainer Guide**: [PORTAINER_DEPLOYMENT.md](./PORTAINER_DEPLOYMENT.md)
- **Docker Details**: See Docker section in [README.md](./README.md#-docker-deployment)
- **Environment Variables**: [frontend/.env.example](./frontend/.env.example)

---

## 🆘 Need Help?

1. Check [PORTAINER_DEPLOYMENT.md - Troubleshooting](./PORTAINER_DEPLOYMENT.md#troubleshooting)
2. View container logs in Portainer
3. Verify environment variables are set correctly
4. Check Sui network status at [https://sui.io/networkstatus](https://sui.io/networkstatus)

---

## Summary

**What you created:**
- ✅ Optimized Docker image (~150MB)
- ✅ Ready for local Portainer deployment
- ✅ Production-ready configuration
- ✅ Easy to update and maintain

**Your application is now accessible at:**
```
http://[YOUR_SERVER_IP]:3000
```

Enjoy your Beats Music NFT Marketplace! 🎵🖼️
