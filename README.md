# homelab-stack

A self-hosted infrastructure stack running multiple services on a real cloud
server (Hetzner, Nuremberg), accessible from anywhere in the world.

Built to develop real sysadmin skills including Docker, reverse proxying,
service management, and server hardening.

## Live Services

| Service | URL | Purpose |
|---|---|---|
| Beszel | https://dash2.116.203.149.96.nip.io | CPU / RAM / disk / Docker container monitoring |
| Homepage | https://home.116.203.149.96.nip.io | Dashboard / service homepage |
| Vaultwarden | http://116.203.149.96:8080 | Password manager (not yet behind Nginx, exposed on raw port) |

## Known Issues

- Vaultwarden is exposed directly on port 8080, not yet routed through Nginx with TLS. Needs rebinding to 0.0.0.0 with UFW-only access plus an Nginx reverse-proxy config and cert, same pattern as Beszel/Homepage.
- tictactoe-web container is up on 127.0.0.1:5000 but the app itself isn't working correctly. Planned for a proper redesign/relaunch rather than a quick fix.

## Architecture

Internet reaches the box through the UFW firewall, which only allows ports 80, 443 and 22 (plus 8080 currently, temporarily, for Vaultwarden). Everything that passes through 80/443 hits Nginx, which reverse-proxies by subdomain to the right container: Beszel on port 8090 and Homepage on port 3000. Vaultwarden on port 8080 currently bypasses Nginx entirely, reachable directly with no TLS. tictactoe-web sits on port 5000, bound to localhost only, and isn't currently working.

## Stack

- OS: Ubuntu 24.04 LTS (Hetzner Cloud, Nuremberg)
- Docker: all services run in isolated containers
- docker-compose: each service defined and managed separately
- Nginx: reverse proxy routing traffic via subdomains (nip.io wildcard DNS)
- Certbot: Let's Encrypt certs, issued per-subdomain via standalone mode
- UFW: firewall, default deny incoming, explicit allow list
- Fail2ban: blocks IPs after repeated failed SSH attempts
- Makefile: shortcuts for managing services

## Services In Detail

### Beszel
System and Docker container monitoring: CPU, RAM, disk, network, per-container
stats. Hub and agent run on the same host (agent uses network_mode: host).
Bound to 0.0.0.0:8090 internally — not raw-exposed to the internet, since UFW
blocks external access; only Nginx's container-to-host proxy path reaches it.

### Homepage
Dashboard / service directory. Bound to 0.0.0.0:3000 internally, same exposure
model as Beszel. Config lives in homepage/config/ (gitignored, may contain
internal URLs/tokens).

### Vaultwarden
Password manager. Currently exposed directly on 0.0.0.0:8080 — a known,
intentional-for-now gap, next on the list to fix. Healthcheck was broken
(configured to use wget, which the image doesn't ship) and has been fixed to
use the image's own /healthcheck.sh script instead.

## Security Incident: Secrets Committed to Git History

Early in this repo's life, Vaultwarden's data directory (its encrypted SQLite
database and RSA private key) was accidentally committed to this **public**
repository, because `.gitignore` only excluded Gitea's and Pingvin's data
folders — Vaultwarden's was missed.

What was exposed: `vaultwarden/data/db.sqlite3` (encrypted vault contents) and
`vaultwarden/data/rsa_key.pem` (the instance's private key), across multiple
historical commits, in a public repo.

What was done about it:
1. Stopped tracking the files going forward (`git rm -r --cached vaultwarden/data`, added to `.gitignore`)
2. Rewrote git history entirely to remove the files from every past commit, using `git-filter-repo --path vaultwarden/data --invert-paths --force`
3. Force-pushed the rewritten history to GitHub, replacing the exposed history
4. Treated every credential stored in that vault as potentially compromised and rotated them, since a history rewrite cannot undo the fact the data was public for some period

Lesson: `.gitignore` needs to be set up **before** the first commit of any
service with real credentials, not patched in after the fact. A safer pattern
going forward is a repo-wide rule excluding all `*/data/` directories by
default, rather than an allow-list of specific folders.

## Sensitive Data Handling

The following are gitignored and must never be committed:
- `vaultwarden/data/`
- `beszel/data/`
- `homepage/config/`
- `.env` files

## Running Locally

Prerequisites: Docker and docker-compose.

Clone the repo, then bring up whichever service you need:

    git clone https://github.com/TeodorStS/homelab-stack.git
    cd homelab-stack
    cd beszel && docker compose up -d && cd ..
    cd homepage && docker compose up -d && cd ..
    cd vaultwarden && docker compose up -d && cd ..

## Server Setup Notes

Pattern used to get a new subdomain live for any service in this stack:

1. Add an Nginx server block in nginx/conf.d/NAME.conf: an HTTP-to-HTTPS
   redirect, plus an SSL server block proxying to 172.17.0.1:PORT.
2. Get a cert. This requires briefly stopping Nginx, since certbot's
   standalone mode needs port 80 free to complete the challenge:

       docker stop nginx
       sudo certbot certonly --standalone -d NAME.116.203.149.96.nip.io
       docker start nginx

3. Reload Nginx to pick up the new config and cert:

       docker exec nginx nginx -t
       docker exec nginx nginx -s reload

Important gotcha learned the hard way: any service Nginx needs to reach must
bind to 0.0.0.0:PORT, not 127.0.0.1:PORT. Nginx runs in its own container, so
a port bound only to the host's loopback interface is unreachable from
another container — even via the Docker bridge gateway (172.17.0.1). This
cost real debugging time on the Beszel setup (it looked like a DNS or cert
problem, but curl from inside the Nginx container to the bridge IP timed out
silently). The fix is to bind to 0.0.0.0 and rely on UFW to block external
access to that port instead.

## Roadmap

### Completed
- Deployed on real cloud server (Hetzner)
- Nginx reverse proxy with subdomain routing (nip.io + Let's Encrypt)
- UFW firewall hardening
- Fail2ban brute force protection
- Cleaned up dead/unused services: Grafana, Prometheus, cAdvisor, Pingvin, Homer, Memos, Portainer, Uptime Kuma and Gitea all removed
- Beszel set up for system and Docker monitoring
- Homepage set up as the dashboard
- Fixed Vaultwarden's healthcheck (wrong test command, not an app problem)
- Purged accidentally-committed Vaultwarden data and keys from git history, and rotated affected credentials

### Next Steps
- Move Vaultwarden behind Nginx: rebind to 0.0.0.0, add a subdomain and cert, close the raw UFW port 8080
- Fix or redesign tictactoe-web
- Decide on a Gitea replacement or rework
- Decide on a Memos replacement
- Decide on an Uptime Kuma replacement
- Decide on a Portainer replacement
- Buy a real domain, migrate off nip.io subdomains
- Build the portfolio site on the root domain once a domain is chosen

## What I Learned

- How Docker containers and images work
- How docker-compose manages multi-service stacks
- What a reverse proxy is and why Nginx is used in production
- How port mapping and Docker networking works, specifically why a service bound to 127.0.0.1 is invisible to other containers even on the same host
- UFW firewall rules and fail2ban configuration
- How SSL certificates work with Let's Encrypt and nip.io
- Why database files and private keys should never be committed to git, and how to purge them from history with git-filter-repo when they are
- Diagnosing failing Docker healthchecks caused by a missing binary in the image, rather than assuming the app itself is broken
