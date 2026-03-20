# homelab-stack

A self-hosted infrastructure stack running multiple services on a real cloud 
server (Azure, France Central), accessible from anywhere in the world.

Built to develop real sysadmin skills including Docker, reverse proxying, 
service management, and server hardening.

## Live Services

| Service | URL | Purpose |
|---|---|---|
| Uptime Kuma | http://status.40.66.42.189.nip.io | Service monitoring |
| Pingvin Share | http://files.40.66.42.189.nip.io | File sharing |
| Gitea | http://git.40.66.42.189.nip.io | Self-hosted Git server |
| Vaultwarden | http://vault.40.66.42.189.nip.io | Password manager |

## Architecture
```
Internet → UFW Firewall (ports 80, 443, 22 only)
               ↓
           Nginx (reverse proxy)
               ↓
    ┌──────────────────────┐
    │  Uptime Kuma  :3001  │
    │  Pingvin Share :3000  │
    │  Gitea         :3002  │
    │  Vaultwarden   :8080  │
    └──────────────────────┘
```

## Stack

- **OS:** Ubuntu 24.04 LTS (Azure VM, France Central)
- **Docker** — all services run in isolated containers
- **docker-compose** — each service defined and managed separately
- **Nginx** — reverse proxy routing traffic to the right service
- **UFW** — firewall blocking everything except ports 22, 80, 443
- **Fail2ban** — blocks IPs after 5 failed SSH attempts
- **Swap file** — 2GB swap prevents RAM exhaustion crashes

## Running Locally

### Prerequisites
- Docker & docker-compose
- WSL2 (if on Windows)

### Start all services
```bash
git clone https://github.com/TeodorStS/homelab-stack.git
cd homelab-stack
cd uptime-kuma && docker compose up -d && cd ..
cd nginx && docker compose up -d && cd ..
cd pingvin && docker compose up -d && cd ..
cd gitea && docker compose up -d && cd ..
cd vaultwarden && docker compose up -d && cd ..
```

## Server Setup

On a fresh Ubuntu server:
```bash
# Add swap file first (prevents RAM crashes)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Install Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker

# Clone and start
git clone https://github.com/TeodorStS/homelab-stack.git
```

## Security

- UFW firewall — only ports 22, 80 and 443 exposed
- Fail2ban — blocks brute force SSH attempts
- Nginx reverse proxy — services never directly exposed to internet
- Swap file — server degrades gracefully under load instead of crashing

## Roadmap

- [x] Deploy on real cloud server
- [x] Nginx reverse proxy
- [x] SSL certificates via Let's Encrypt
- [ ] Portainer (Docker management UI)
- [ ] Homer (dashboard homepage)
- [ ] Grafana + Prometheus (metrics)
- [ ] Woodpecker CI + Gitea (CI/CD pipeline)
- [ ] Migrate to permanent domain

## What I Learned

- How Docker containers and images work
- How docker-compose manages multi-service stacks
- What a reverse proxy is and why Nginx is used in production
- How port mapping and Docker networking works on Linux vs Windows
- UFW firewall rules and fail2ban configuration
- How to diagnose and fix server crashes (RAM exhaustion → swap file)
- How to migrate a local stack to a real cloud server
