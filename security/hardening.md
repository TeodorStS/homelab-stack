# Security Hardening

## UFW Firewall

### Default Rules
- Deny all incoming traffic by default
- Allow all outgoing traffic by default

### Allowed Ports
| Port | Protocol | Reason |
|------|----------|--------|
| 22   | TCP      | SSH remote access |
| 80   | TCP      | HTTP via Nginx |
| 443  | TCP      | HTTPS via Nginx |

### Commands Used
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

## Fail2ban

Protects against brute force attacks by banning IPs that 
fail authentication repeatedly.

### Configuration
- **Ban time:** 1 hour
- **Find time:** 10 minutes  
- **Max retries:** 5 attempts

### Protected Services
- SSH (port 22)

### Config location
`/etc/fail2ban/jail.local`
