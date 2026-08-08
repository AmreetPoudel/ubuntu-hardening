# Role: nginx_hardening

## Description
Hardens Nginx headers, disables server_tokens, enforces TLSv1.2/1.3 ciphers.

## System Commands & Modifications
- Writes `/etc/nginx/conf.d/security.conf`
- `systemctl reload nginx`

## Manual Rollback Steps
```bash
sudo rm -f /etc/nginx/conf.d/security.conf
sudo systemctl reload nginx
```
