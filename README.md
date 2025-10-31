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

