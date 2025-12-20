# Custom Domain Setup for Beats Music NFT Marketplace

This guide shows you how to access your Beats marketplace with a custom name like `beats.local` or `beats.yourdomain.com`.

## Quick Summary

| Method | Access URL | Best For | HTTPS |
|--------|-----------|----------|-------|
| Hosts File | `http://beats.local` | Local network only | No |
| Nginx Proxy Manager | `http://beats.local` or `https://beats.yourdomain.com` | Production, multiple services | Yes |
| Port 80 Mapping | `http://[SERVER_IP]` | Simple setup, no domain | No |

---

## Method 1: Simple Hosts File (Fastest Setup)

**Access as**: `http://beats.local`

### Windows

1. **Edit hosts file** (as Administrator):
   - Press `Win + X`, select "Terminal (Admin)" or "PowerShell (Admin)"
   - Run:
     ```powershell
     notepad C:\Windows\System32\drivers\etc\hosts
     ```

2. **Add this line** (replace with your server IP):
   ```
   192.168.1.100  beats.local
   ```

3. **Save** and close

4. **Access**: Open browser to `http://beats.local:3000`

### Mac/Linux

1. **Edit hosts file**:
   ```bash
   sudo nano /etc/hosts
   ```

2. **Add this line** (replace with your server IP):
   ```
   192.168.1.100  beats.local
   ```

3. **Save**: Press `Ctrl+X`, then `Y`, then `Enter`

4. **Access**: Open browser to `http://beats.local:3000`

### Configure on All Devices

Repeat the above on **every device** (PC, phone, tablet) that needs access.

**Limitations**:
- Must configure each device individually
- No HTTPS support
- Still need to specify port `:3000`

---

## Method 2: Nginx Proxy Manager (Recommended for Production)

**Access as**: `http://beats.local` or `https://beats.yourdomain.com`

### Step 1: Deploy Nginx Proxy Manager in Portainer

1. **In Portainer**: Go to **Stacks** → **Add stack**

2. **Name**: `nginx-proxy-manager`

3. **Web editor**: Paste this content:
   ```yaml
   version: '3.8'

   services:
     nginx-proxy-manager:
       image: 'jc21/nginx-proxy-manager:latest'
       container_name: nginx-proxy-manager
       restart: unless-stopped
       ports:
         - '80:80'      # HTTP
         - '81:81'      # Admin UI
         - '443:443'    # HTTPS
       volumes:
         - npm-data:/data
         - npm-letsencrypt:/etc/letsencrypt

   volumes:
     npm-data:
     npm-letsencrypt:
   ```

4. **Click**: Deploy the stack

### Step 2: Configure Nginx Proxy Manager

1. **Access admin UI**: `http://[YOUR_SERVER_IP]:81`

2. **Login** (first time):
   - Email: `admin@example.com`
   - Password: `changeme`

3. **Change password immediately**

### Step 3: Update Your Beats Container Port

Since Nginx will use port 80, update your Beats container:

1. **In Portainer**: Go to **Containers**
2. **Find**: `beats-music-nft-marketplace`
3. **Duplicate/Edit**
4. **Port mapping**: Change from `3000:3000` to `3001:3000` (or remove port mapping entirely)
5. **Recreate** container

### Step 4: Add Proxy Host

1. **In Nginx Proxy Manager**: Go to **Hosts** → **Proxy Hosts**

2. **Click**: Add Proxy Host

3. **Configure** "Details" tab:
   - **Domain Names**: `beats.local` (or your domain)
   - **Scheme**: `http`
   - **Forward Hostname/IP**: `beats-music-nft-marketplace`
   - **Forward Port**: `3000`
   - **Cache Assets**: ON
   - **Block Common Exploits**: ON
   - **Websockets Support**: ON

4. **For HTTPS** (optional), go to "SSL" tab:
   - **SSL Certificate**: Request a New SSL Certificate
   - **Use a DNS Challenge**: OFF (for Let's Encrypt HTTP)
   - **Force SSL**: ON
   - **HTTP/2 Support**: ON
   - **HSTS Enabled**: ON
   - **Email**: Your email address
   - **Agree to Terms**: Check

5. **Click**: Save

### Step 5: Configure DNS

**For local network (`beats.local`)**:
- Add `192.168.1.100  beats.local` to hosts file (as in Method 1)

**For internet domain (`beats.yourdomain.com`)**:
- In your domain registrar, add an A record:
  - **Name**: `beats` (or `@` for root domain)
  - **Type**: A
  - **Value**: Your server's public IP
  - **TTL**: 300 (or default)

### Step 6: Access Your Site

- **Local**: `http://beats.local` or `https://beats.local`
- **Internet**: `https://beats.yourdomain.com`

**Benefits**:
- ✅ No port numbers needed
- ✅ HTTPS with automatic SSL certificates
- ✅ Can manage multiple services
- ✅ Professional setup

---

## Method 3: Port 80 Mapping (No Domain)

**Access as**: `http://[SERVER_IP]` (no port needed)

Simply map container port 3000 to host port 80:

### In Portainer

1. **Edit container** `beats-music-nft-marketplace`
2. **Port mapping**: Change to `80:3000`
3. **Recreate** container
4. **Access**: `http://[SERVER_IP]` (e.g., `http://192.168.1.100`)

**Benefits**:
- ✅ No port number in URL
- ✅ Easy setup

**Limitations**:
- ❌ Still need to use IP address
- ❌ No HTTPS
- ❌ Port 80 can only be used by one service

---

## Method 4: Docker Compose with Custom Network

Use the updated `docker-compose.yml` that includes hostname and port 80 mapping.

1. **Deploy stack** in Portainer using `docker-compose.yml`
2. **Configure hosts file** (as in Method 1)
3. **Access**: `http://beats.local`

---

## Comparison Table

| Feature | Hosts File | Nginx Proxy | Port 80 | Docker Compose |
|---------|-----------|-------------|---------|----------------|
| Setup Difficulty | Easy | Medium | Very Easy | Easy |
| HTTPS Support | ❌ | ✅ | ❌ | ❌ |
| Custom Domain | Local only | ✅ | ❌ | Local only |
| No Port in URL | ❌ | ✅ | ✅ | ✅ |
| Multiple Services | ❌ | ✅ | ❌ | Limited |
| Auto SSL Renewal | ❌ | ✅ | ❌ | ❌ |

---

## Recommended Setup by Use Case

### Personal Local Network
→ **Method 1 (Hosts File)** or **Method 3 (Port 80)**

### Small Team/Office
→ **Method 2 (Nginx Proxy Manager)** with local domain

### Production/Internet
→ **Method 2 (Nginx Proxy Manager)** with real domain and HTTPS

### Multiple Services
→ **Method 2 (Nginx Proxy Manager)**

---

## Troubleshooting

### Can't Access Custom Domain

1. **Check DNS/Hosts**:
   ```bash
   # Windows
   ping beats.local

   # Should return your server IP
   ```

2. **Verify container is running**:
   - In Portainer, check container status is "running"

3. **Check Nginx logs** (if using Nginx Proxy Manager):
   - Portainer → Containers → nginx-proxy-manager → Logs

### HTTPS Certificate Fails

1. **Ensure port 80 is open** to the internet
2. **Verify DNS** propagation: https://dnschecker.org
3. **Check domain ownership** (for Let's Encrypt)
4. **Review Nginx Proxy Manager** certificate logs

### Still Shows Port in URL

- If using Nginx, ensure you're accessing via the proxy (port 80/443)
- Not via the direct container port (3000)

---

## Example Configurations

### For Home Lab
```
Domain: beats.local
Method: Nginx Proxy Manager
Access: http://beats.local
```

### For Small Business
```
Domain: beats.company.local
Method: Nginx Proxy Manager
Access: https://beats.company.local (with self-signed cert)
```

### For Production SaaS
```
Domain: beats.yourstartup.com
Method: Nginx Proxy Manager
Access: https://beats.yourstartup.com (with Let's Encrypt)
```

---

## Next Steps After Setup

1. **Test access** from multiple devices
2. **Set up monitoring** (Uptime Kuma, etc.)
3. **Configure firewall** rules if exposing to internet
4. **Set up backups** of Nginx Proxy Manager config
5. **Document your setup** for team members

---

## Additional Resources

- [Nginx Proxy Manager Docs](https://nginxproxymanager.com/guide/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Portainer Documentation](https://docs.portainer.io/)

---

**Need help?** Check the troubleshooting section in [PORTAINER_DEPLOYMENT.md](./PORTAINER_DEPLOYMENT.md)
