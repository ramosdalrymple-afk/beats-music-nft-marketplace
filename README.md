**Beats** is an interactive NFT Art Fair with a 
unique collection of 4,444. The project is a 
combination of NFT with staking of NFT’s 
and Play to Earn mechanics. The Beats 
exhibits Soul Collection of famous and 
legendary artists around the world. 

**Beats NFTs – Soul Collection** – are inspired 
by different kinds of music genre, featuring 
the legendary musicians around the world 
to pay tributes to their contribution to the 
music industry. With the Beats NFTs comes 
with $SOUL Token. The team has been 
working endlessly and looking forward to 
the development of the Musicverse. 

**Vision**

Connect different art and music 
enthusiasts around the world 
together through mesmerizing NFTs 
that are worth the value 

**Mission**

To offer a vibe of NFTs that are very 
much worth the value and to 
explore new types of NFT that are 
made not only to be collectibles 
but assets

**Why Beats?**

NFTs has brought an exciting era to the crypto world. 
2021 is the year when NFTs became the mainstream. 
It has federated the world of art and crypto. 
But to make it even more exciting, we are not just 
sticking to the traditional NFT art fairs.  We all know 
that music has the power to connect people. Our NFT 
is a unique way for people to create connections not 
only between fans and musicians, but also to attract 
community that are willing to support artists, 
musicians and gamers. It is an innovative experience 
where artists can showcase their unique creations 
and fans to enjoy and get the assets that are worth 
the value. Both users are able to access the more 
exciting ways to maximize their digital earnings like 
Beats, play-to-earn games and earning from 
listening to music. 

**Marketplace**

Beats Marketplace is the heart of the Beats' 
project. It is created to support the project 
perfectly. Designed to open doors to different 
creators everywhere and to be the main 
platform where they can auction their own 
creations or arts. The team has worked 
entirely to develop its own token which will 
generate higher demand for the market - 
the $SOUL Token. Every art is purchased 
using the $SOUL Token. With all these 
amazing features, it is one step away from a 
great and bigger community of Beats 
Marketplace users.

**$SOUL Token**

$SOUL Token will be used to create, power 
and sustain the Beats ecosystem.
To this end the team has created a 
tokenomics model that ensures enough 
token liquidity at each stage of project 
development as well as healthy token 
release rate compensated by a built-in 
token burn mechanism.

**Currency:**

$SOUL Token will serve as the basic currency
for Beats Marketplace.
Premium Services
$SOUL Token will be the ticket to accessing a
range of other In-app and cloud services as
development continues. Will also be used in
purchasing Merch, event ticket, auctions and
more!

---

## 🐳 Docker Deployment

The Beats Music NFT Marketplace can be easily deployed using Docker and Portainer.

### Quick Start with Docker

#### Prerequisites
- Docker installed on your system ([Get Docker](https://docs.docker.com/get-docker/))
- For Portainer deployment: Portainer instance running on your server

#### Option 1: Using Docker Compose (Recommended for Local Development)

```bash
# Clone the repository
git clone <repository-url>
cd beats-music-nft-marketplace

# Start the application
docker-compose up -d

# Access the application
open http://localhost:3000
```

The application will be available at `http://localhost:3000`

#### Option 2: Build and Run Manually

**On Windows:**
```batch
# Build the image
.\scripts\docker-build.bat

# Run the container
docker run -d -p 3000:3000 --name beats-nft beats-nft-marketplace:latest

# View logs
docker logs -f beats-nft
```

**On Linux/Mac:**
```bash
# Build the image
./scripts/docker-build.sh

# Run the container
docker run -d -p 3000:3000 --name beats-nft beats-nft-marketplace:latest

# View logs
docker logs -f beats-nft
```

### Deploying to Portainer

For detailed instructions on deploying to Portainer, see [PORTAINER_DEPLOYMENT.md](./PORTAINER_DEPLOYMENT.md)

**Quick Portainer Deployment:**

1. **Build and save the image:**
   ```bash
   # Windows
   .\scripts\docker-build.bat
   .\scripts\docker-push.bat
   # Select option 3 (Save as TAR file)

   # Linux/Mac
   ./scripts/docker-build.sh
   ./scripts/docker-push.sh
   # Select option 4 (Save as TAR file)
   ```

2. **Import to Portainer:**
   - Open Portainer UI (`http://[SERVER_IP]:9000`)
   - Go to **Images** → **Import**
   - Upload the generated `.tar` file
   - Create a container from the image

3. **Configure container:**
   - Port mapping: `3000:3000`
   - Environment variables:
     ```
     NODE_ENV=production
     NEXT_PUBLIC_SUI_NETWORK=testnet
     NEXT_PUBLIC_RPC_URL=https://fullnode.testnet.sui.io:443
     ```

4. **Access your application:**
   - `http://[SERVER_IP]:3000`

### Environment Variables

Configure these environment variables for deployment:

| Variable | Default | Description |
|----------|---------|-------------|
| `NEXT_PUBLIC_SUI_NETWORK` | `testnet` | Sui network (testnet or mainnet) |
| `NEXT_PUBLIC_RPC_URL` | Auto | Sui RPC endpoint URL |
| `NODE_ENV` | `production` | Node environment |
| `PORT` | `3000` | Application port |

See [frontend/.env.example](./frontend/.env.example) for all available options.

### Docker Image Details

**Multi-stage build for optimization:**
- Base image: `node:18-alpine`
- Production image size: ~150-200MB
- Non-root user for security
- Standalone Next.js output for minimal footprint

**Build arguments:**
```bash
# Build for specific platform
docker build --platform linux/amd64 -t beats-nft-marketplace:latest -f frontend/Dockerfile frontend/

# Build with custom tag
docker build -t beats-nft-marketplace:v1.0.0 -f frontend/Dockerfile frontend/
```

### Accessing from Network

**Local machine:**
```
http://localhost:3000
```

**Other devices on your network:**
```
http://[YOUR_SERVER_IP]:3000
```
Example: `http://192.168.1.100:3000`

**With custom domain (requires reverse proxy):**
```
https://beats.yourdomain.com
```

### Troubleshooting

**Container won't start:**
```bash
# Check logs
docker logs beats-nft

# Check if port is in use
netstat -an | grep 3000  # Linux/Mac
netstat -an | findstr 3000  # Windows
```

**Can't connect to Sui network:**
- Verify environment variables are set correctly
- Check if RPC endpoint is accessible from container
- Ensure firewall allows outbound connections

**Build fails:**
- Ensure you're in the project root directory
- Check Docker has enough disk space
- Verify Node.js dependencies are valid

For more troubleshooting, see [PORTAINER_DEPLOYMENT.md](./PORTAINER_DEPLOYMENT.md#troubleshooting)

### Production Recommendations

1. **Use HTTPS:** Set up reverse proxy (nginx/traefik) with SSL certificate
2. **Set resource limits:** Configure memory/CPU limits in Portainer
3. **Enable auto-restart:** Set restart policy to "unless-stopped"
4. **Monitor logs:** Use Portainer's built-in log viewer
5. **Update regularly:** Rebuild images when dependencies are updated

---

## 🛠️ Development

### Local Development (Without Docker)

```bash
cd frontend
npm install
npm run dev
```

Access at `http://localhost:3000`

### Smart Contracts (Move)

The backend uses Sui Move smart contracts deployed on Sui blockchain.

**Deployed Package IDs** (Testnet):
- BeatTaps: `0x989abceb5afcc1ee7f460b41e79f03ee4d3406191ee964da95db51a20fa95f27`
- Marketplace: `0x08ac46b00eb814de6e803b7abb60b42abbaf49712314f4ed188f4fea6d4ce3ec`
- Marketplace V2: `0xef31a73e2b31f94fc64fba29c65482857ef60c30a10932da7e86c74f9a9a4ac8`
- NFT Trading: `0x5281a724289520fadb5984c3686f8b63cf574d4820fcf584137a820516afa507`

**Build contracts:**
```bash
cd backend/marketplace
sui move build
```

**Test contracts:**
```bash
sui move test
```

**Publish contracts:**
```bash
sui client publish --gas-budget 100000000
```

---

## 📝 License

[Your License Here]
