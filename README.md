# homelab-stack

A self-hosted infrastructure stack running multiple services behind an Nginx 
reverse proxy, with monitoring and security hardening.

Built as a learning project to develop real sysadmin skills including Docker,
reverse proxying, service management, and server hardening.

## Architecture
```
Internet → Nginx (port 80) → Uptime Kuma  (port 3001)
                           → Pingvin Share (port 3000)
                           → Gitea         (port 3002)
                           → Vaultwarden   (port 8080)
```

## Services

| Service | Purpose | Port |
|---|---|---|
| Nginx | Reverse proxy — single entry point for all traffic | 80 |
| Uptime Kuma | Monitors all services and alerts if they go down | 3001 |
| Pingvin Share | Lightweight file sharing via shareable links | 3000 |
| Gitea | Self-hosted Git server — like a private GitHub | 3002 |
| Vaultwarden | Self-hosted password manager (Bitwarden compatible) | 8080 |

## Security

- **UFW firewall** — only ports 22, 80 and 443 exposed
- **Fail2ban** — blocks IPs after 5 failed SSH attempts within 10 minutes
- **Reverse proxy** — services are never directly exposed to the internet

## Running Locally

### Prerequisites
- Docker & docker-compose
- WSL2 (if on Windows)

### Start all services
```bash
# Start Nginx
cd nginx && docker compose up -d

# Start Uptime Kuma
cd ../uptime-kuma && docker compose up -d

# Start Pingvin Share
cd ../pingvin && docker compose up -d

# Start Gitea
cd ../gitea && docker compose up -d

# Start Vaultwarden
cd ../vaultwarden && docker compose up -d
```

### Access services locally
- Uptime Kuma: http://localhost:3001
- Pingvin Share: http://localhost:3000
- Gitea: http://localhost:3002
- Vaultwarden: http://localhost:8080

## Roadmap

- [ ] Migrate to DigitalOcean server
- [ ] Add SSL certificates via Let's Encrypt
- [ ] Set up real domain routing
- [ ] Add automated backups
- [ ] Add more services

## What I Learned

- How Docker containers and images work
- How docker-compose manages multi-service stacks
- What a reverse proxy is and why Nginx is used in production
- How port mapping and volumes work
- UFW firewall rules and fail2ban configuration
- How to structure and document infrastructure as code
