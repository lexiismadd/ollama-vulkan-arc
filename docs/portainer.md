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
Set up GitHub webhook (see PORTAINER.md) so Portainer rebuilds when you push changes!

## Tips for Easy Management

1. **Use branches:** Create `dev` branch for testing changes
2. **Tag releases:** Use git tags for stable versions
3. **Document changes:** Update README.md with each modification
4. **Test locally first:** Run `docker compose build` before pushing
5. **Use .env:** Never hardcode values, always use environment variable