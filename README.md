# homelab-stack

A self-hosted infrastructure stack running multiple services on a real cloud
server (Azure, France Central), accessible from anywhere in the world.

Built to develop real sysadmin skills including Docker, reverse proxying,
service management, and server hardening.

## Live Services

| Service | URL | Purpose |
|---|---|---|
| Homer | http://dash.40.66.42.189.nip.io | Dashboard homepage |
| Uptime Kuma | http://status.40.66.42.189.nip.io | Service monitoring |
| Pingvin Share | http://files.40.66.42.189.nip.io | File sharing |
| Gitea | http://git.40.66.42.189.nip.io | Self-hosted Git server |
| Vaultwarden | http://vault.40.66.42.189.nip.io | Password manager |
| Portainer | http://portainer.40.66.42.189.nip.io | Docker management UI |
| Grafana | http://grafana.40.66.42.189.nip.io | Metrics dashboards |

## Architecture
```
Internet → UFW Firewall (ports 80, 443, 22 only)
               ↓
           Nginx (reverse proxy)
               ↓
    ┌─────────────────────────────┐
    │  Homer          :8082       │
    │  Uptime Kuma    :3001       │
    │  Pingvin Share  :3000       │
    │  Gitea          :3002       │
    │  Vaultwarden    :8080       │
    │  Portainer      :9000       │
    │  Grafana        :3003       │
    │  Prometheus     :9090       │
    └─────────────────────────────┘
```

## Stack

- **OS:** Ubuntu 24.04 LTS (Azure VM, France Central)
- **Docker** — all services run in isolated containers
- **docker-compose** — each service defined and managed separately
- **Nginx** — reverse proxy routing traffic via subdomains
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
cd portainer && docker compose up -d && cd ..
cd homer && docker compose up -d && cd ..
cd grafana-prometheus && docker compose up -d && cd ..
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
- SSH key authentication — password login disabled

## Roadmap

### Completed
- [x] Deploy on real cloud server (Azure)
- [x] Nginx reverse proxy with subdomain routing
- [x] Uptime Kuma monitoring
- [x] Pingvin Share file sharing
- [x] Gitea self-hosted Git server
- [x] Vaultwarden password manager
- [x] Portainer Docker management UI
- [x] Homer dashboard
- [x] Grafana + Prometheus metrics
- [x] UFW firewall hardening
- [x] Fail2ban brute force protection
- [x] 2GB swap file

### Next Steps
- [ ] SSL certificates via Let's Encrypt (HTTPS for all services)
- [ ] Authelia — two factor authentication layer
- [ ] Woodpecker CI + Gitea — full CI/CD pipeline
- [ ] Nginx Proxy Manager — visual UI for managing reverse proxy
- [ ] Migrate to permanent domain name
- [ ] Add automated backups
- [ ] Upgrade to larger server for Grafana + cAdvisor

## What I Learned

- How Docker containers and images work
- How docker-compose manages multi-service stacks
- What a reverse proxy is and why Nginx is used in production
- How port mapping and Docker networking works on Linux vs Windows
- UFW firewall rules and fail2ban configuration
- How to diagnose and fix server crashes (RAM exhaustion → swap file)
- How to migrate a local stack to a real cloud server
- How DNS routing works with subdomains
- Resource management on constrained servers
