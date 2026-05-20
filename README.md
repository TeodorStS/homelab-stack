# homelab-stack

A self-hosted infrastructure stack running multiple services on a real cloud
server (Hetzner, Nuremberg), accessible from anywhere in the world.

Built to develop real sysadmin skills including Docker, reverse proxying,
service management, and server hardening.

## Live Services

| Service | URL | Purpose |
|---|---|---|
| Homer | https://dash.116.203.149.96.nip.io | Dashboard homepage |
| Uptime Kuma | https://status.116.203.149.96.nip.io | Service monitoring |
| Pingvin Share | https://files.116.203.149.96.nip.io | File sharing |
| Gitea | https://git.116.203.149.96.nip.io | Self-hosted Git server |
| Vaultwarden | https://vault.116.203.149.96.nip.io | Password manager |
| Portainer | https://portainer.116.203.149.96.nip.io | Docker management UI |
| Grafana | https://grafana.116.203.149.96.nip.io | Metrics dashboards |

## Known Issues

> ⚠️ **Homer dashboard shows "Not Secure" warning** — Homer loads over HTTPS but triggers a mixed content warning in the browser. The SSL certificate and nginx config are correct; the issue is caused by internal resource links. This is a known bug and will be fixed in a future update.

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

- **OS:** Ubuntu 24.04 LTS (Hetzner Cloud, Nuremberg)
- **Docker** — all services run in isolated containers
- **docker-compose** — each service defined and managed separately
- **Nginx** — reverse proxy routing traffic via subdomains
- **UFW** — firewall blocking everything except ports 22, 80, 443
- **Fail2ban** — blocks IPs after 5 failed SSH attempts
- **Swap file** — 2GB swap prevents RAM exhaustion crashes
- **Makefile** — shortcuts for managing all services (`make up`, `make down`, `make status`)
- **Healthchecks** — all services self-monitored with automatic restart on failure

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

# Get SSL certificates (stop nginx first)
cd nginx && docker compose down
sudo certbot certonly --standalone \
  -d vault.<SERVER_IP>.nip.io \
  -d dash.<SERVER_IP>.nip.io \
  -d status.<SERVER_IP>.nip.io \
  -d files.<SERVER_IP>.nip.io \
  -d git.<SERVER_IP>.nip.io \
  -d portainer.<SERVER_IP>.nip.io \
  -d grafana.<SERVER_IP>.nip.io \
  --email your@email.com --agree-tos --non-interactive
cd .. && make up
```

## Security

- UFW firewall — only ports 22, 80 and 443 exposed
- Fail2ban — blocks brute force SSH attempts
- Nginx reverse proxy — services never directly exposed to internet
- Swap file — server degrades gracefully under load instead of crashing
- SSH key authentication — password login disabled

## Roadmap

### Completed
- [x] Deploy on real cloud server (Hetzner)
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
- [x] SSL certificates via Let's Encrypt (HTTPS for all services)
- [x] Docker healthchecks on all services
- [x] Pinned Docker image versions
- [x] Makefile for service management
- [x] Migrated from Azure (France Central) to Hetzner (Nuremberg)

### Next Steps
- [ ] Fix Homer mixed content / "Not Secure" warning
- [ ] Add automated backups
- [ ] Authelia — two factor authentication layer
- [ ] Woodpecker CI + Gitea — full CI/CD pipeline
- [ ] Nginx Proxy Manager — visual UI for managing reverse proxy
- [ ] Migrate to permanent domain name
- [ ] Upgrade to larger server for Grafana + cAdvisor

## What I Learned

- How Docker containers and images work
- How docker-compose manages multi-service stacks
- What a reverse proxy is and why Nginx is used in production
- How port mapping and Docker networking works on Linux vs Windows
- UFW firewall rules and fail2ban configuration
- How to diagnose and fix server crashes (RAM exhaustion → swap file)
- How to migrate a live server stack to a new cloud provider
- How DNS routing works with subdomains
- Resource management on constrained servers
- How SSL certificates work with Let's Encrypt and nip.io
