# Ollama with Vulkan Support for Intel Arc GPUs

Docker setup for running Ollama with Vulkan acceleration on Intel Arc GPUs (tested on Arc A770).

## Features

- ✅ Latest Ollama with Vulkan support
- ✅ Full Intel Arc GPU acceleration
- ✅ Optional Open WebUI interface
- ✅ Easy configuration via environment variables
- ✅ Portainer compatible

## Quick Start

### Using Docker Compose

1. Clone this repository:
```
git clone https://github.com/lexiismadd/ollama-vulkan-arc.git
cd ollama-vulkan-arc
```

2. Copy and configure environment:
```bash
cp .env.example .env
# Edit .env with your preferences
```

3. Build and start:
```bash
docker compose build
docker compose up -d
```

4. Test:
```bash
docker exec ollama-vulkan-arc ollama pull llama3.2
docker exec ollama-vulkan-arc ollama run llama3.2
```

### Using Portainer

See [Portainer Setup](#portainer-setup) below.

## Configuration

Edit `.env` file to customize:

- `OLLAMA_VERSION` - Ollama version to build
- `OLLAMA_NUM_GPU` - GPU layer offloading (999 = all layers)
- `OLLAMA_NUM_CTX` - Context window size
- `MEMORY_LIMIT` - Maximum RAM usage
- `ENABLE_WEBUI` - Enable/disable Open WebUI

## Portainer Setup

1. In Portainer, go to **Stacks** → **Add stack**
2. Choose **Git Repository**
3. Enter your repository URL: `https://github.com/lexiismadd/ollama-vulkan-arc`
4. Set **Compose path**: `docker-compose.yml`
5. Add environment variables or upload your `.env` file
6. Click **Deploy the stack**

See [detailed Portainer instructions](docs/portainer.md).

## Monitoring GPU Usage

```bash
# Install tools
sudo apt install intel-gpu-tools

# Monitor GPU
sudo intel_gpu_top
```

## Updating Ollama

1. Edit `.env` and update `OLLAMA_VERSION`
2. Rebuild:
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Troubleshooting

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions.

## Requirements

- Intel Arc GPU (A770, A750, A380, etc.)
- Intel GPU drivers installed
- Docker or Podman
- Docker Compose

## Performance

Expected tokens/s on Arc A770 16GB:
- Small models (3-8B): 50-100+ tokens/s
- Medium models (13-20B): 20-40 tokens/s
- Large models (30-70B): 5-15 tokens/s

## Contributing

Feel free to open issues or submit pull requests!

## License

MIT License - feel free to use and modify.

## Acknowledgments

- [Ollama](https://github.com/ollama/ollama)
- [Intel IPEX-LLM](https://github.com/intel/ipex-llm)
- Vulkan support contributors
```

## Step 4: Create Enhanced docker-compose.yml

Update your docker-compose.yml to use environment variables:
````yaml
services:
  ollama-vulkan:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        OLLAMA_VERSION: ${OLLAMA_VERSION:-v0.12.6}
    container_name: ollama-vulkan-arc
    restart: unless-stopped
    
    devices:
      - /dev/dri:/dev/dri
    
    ports:
      - "${OLLAMA_PORT:-11434}:11434"
    
    volumes:
      - ollama-models:/root/.ollama
    
    environment:
      - OLLAMA_HOST=${OLLAMA_HOST:-0.0.0.0:11434}
      - OLLAMA_NUM_GPU=${OLLAMA_NUM_GPU:-999}
      - OLLAMA_NUM_CTX=${OLLAMA_NUM_CTX:-16384}
      - ZES_ENABLE_SYSMAN=${ZES_ENABLE_SYSMAN:-1}
      - ONEAPI_DEVICE_SELECTOR=${ONEAPI_DEVICE_SELECTOR:-}
    
    mem_limit: ${MEMORY_LIMIT:-32g}
    shm_size: ${SHARED_MEMORY:-16g}
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    profiles:
      - webui
    ports:
      - "${WEBUI_PORT:-8080}:8080"
    volumes:
      - open-webui:/app/backend/data
    environment:
      - OLLAMA_BASE_URL=http://ollama-vulkan:11434
    depends_on:
      ollama-vulkan:
        condition: service_healthy

volumes:
  ollama-models:
    driver: local
  open-webui:
    driver: local
````

## Step 5: Add Portainer-Specific Documentation

Create `docs/portainer.md`:
````markdown
# Portainer Setup Guide

## Method 1: Deploy from Git Repository (Recommended)

1. **In Portainer UI:**
   - Navigate to **Stacks** → **Add stack**
   - Stack name: `ollama-vulkan-arc`

2. **Build method:**
   - Select **Git Repository**
   - Repository URL: `https://github.com/lexiismadd/ollama-vulkan-arc`
   - Repository reference: `refs/heads/main` (or your branch)
   - Compose path: `docker-compose.yml`

3. **Authentication (if private repo):**
   - Enable authentication
   - Username: Your GitHub username
   - Personal access token: [Create one here](https://github.com/settings/tokens)

4. **Environment variables:**
   Click **Add an environment variable** for each:
   - `OLLAMA_VERSION` = `v0.12.6`
   - `OLLAMA_NUM_GPU` = `999`
   - `OLLAMA_NUM_CTX` = `16384`
   - `MEMORY_LIMIT` = `32g`
   - `SHARED_MEMORY` = `16g`
   - `OLLAMA_PORT` = `11434`
   - `WEBUI_PORT` = `8080`

5. **Enable Open WebUI (optional):**
   - Scroll to **Profiles**
   - Add profile: `webui`

6. **Deploy:**
   - Click **Deploy the stack**
   - Wait 20-30 minutes for initial build

## Method 2: Upload docker-compose.yml

1. **Prepare files locally:**
```bash
   git clone https://github.com/lexiismadd/ollama-vulkan-arc
   cd ollama-vulkan-arc
   cp .env.example .env
   # Edit .env with your settings
```

2. **In Portainer:**
   - Navigate to **Stacks** → **Add stack**
   - Stack name: `ollama-vulkan-arc`
   - Select **Upload**
   - Upload your `docker-compose.yml`

3. **Upload environment file:**
   - Click **Load variables from .env file**
   - Upload your `.env` file

4. **Deploy:**
   - Click **Deploy the stack**

## Method 3: Web Editor

1. **In Portainer:**
   - Navigate to **Stacks** → **Add stack**
   - Stack name: `ollama-vulkan-arc`
   - Select **Web editor**

2. **Paste docker-compose.yml content:**
   Copy the content from your repository

3. **Add environment variables:**
   Add variables as in Method 1

4. **Deploy:**
   - Click **Deploy the stack**

## Managing Your Stack in Portainer

### View Logs
1. Go to **Stacks** → Click your stack
2. Click on **ollama-vulkan** service
3. Click **Logs**

### Update Stack
1. Go to **Stacks** → Click your stack
2. Click **Editor**
3. Click **Pull and redeploy** if using Git
4. Or edit and click **Update the stack**

### Restart Services
1. Go to **Stacks** → Click your stack
2. Select service (ollama-vulkan)
3. Click **Restart**

### Execute Commands
1. Go to **Stacks** → Click your stack
2. Click on **ollama-vulkan** service
3. Click **Console**
4. Click **Connect**
5. Run: `ollama pull llama3.2`

## Automatic Updates from GitHub

### Set up Webhook (Auto-update on git push)

1. **In Portainer:**
   - Go to your stack
   - Scroll to **Webhooks**
   - Enable webhook
   - Copy the webhook URL

2. **In GitHub:**
   - Go to repository **Settings** → **Webhooks**
   - Click **Add webhook**
   - Paste Portainer webhook URL
   - Content type: `application/json`
   - Select: **Just the push event**
   - Click **Add webhook**

Now when you push to GitHub, Portainer will auto-update!

## Troubleshooting in Portainer

### Stack won't deploy
- Check **Logs** in the stack view
- Verify device `/dev/dri` exists on host
- Ensure Intel drivers are installed on host

### Build takes too long
- First build takes 20-30 minutes (compiling Ollama)
- Subsequent builds are faster (cached layers)
- Monitor progress in stack logs

### GPU not detected
- Check host has `/dev/dri/` devices
- Verify stack has device mapping
- Check container logs for Vulkan errors

### Out of memory
- Reduce `MEMORY_LIMIT` in environment variables
- Reduce `SHARED_MEMORY`
- Update stack to apply changes
````

## Step 6: Commit and Push
````bash
# Create .env from example
cp .env.example .env

# Add all files
git add .

# Commit
git commit -m "Initial commit: Ollama with Vulkan support for Intel Arc"

# Push to GitHub
git push origin main
````

## Step 7: Deploy in Portainer

Now you can deploy in Portainer:

1. **Go to Portainer** → **Stacks** → **Add stack**
2. **Stack name:** `ollama-vulkan-arc`
3. **Build method:** Git Repository
4. **Repository URL:** `https://github.com/lexiismadd/ollama-vulkan-arc`
5. **Compose path:** `docker-compose.yml`
6. **Add environment variables** or upload your `.env` file
7. **Deploy!**

## Making Modifications

### To update Ollama version:
1. Edit `.env` in your repo: `OLLAMA_VERSION=v0.13.0`
2. Commit and push to GitHub
3. In Portainer: Stack → **Pull and redeploy**

### To change configuration:
1. Edit `.env` or `docker-compose.yml`
2. Commit and push
3. In Portainer: **Pull and redeploy**

### To enable auto-updates:
Set up GitHub webhook (see portainer.md) so Portainer rebuilds when you push changes!

## Tips for Easy Management

1. **Use branches:** Create `dev` branch for testing changes
2. **Tag releases:** Use git tags for stable versions
3. **Document changes:** Update README.md with each modification
4. **Test locally first:** Run `docker compose build` before pushing
5. **Use .env:** Never hardcode values, always use environment variables