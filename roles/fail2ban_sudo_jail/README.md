# Role: fail2ban_sudo_jail

## Description
Configures Fail2ban to ban IPs/accounts after repeated sudo failures.

## System Commands & Modifications
- Writes `/etc/fail2ban/jail.d/sudo.local`
- `systemctl restart fail2ban`

## Manual Rollback Steps
```bash
sudo rm -f /etc/fail2ban/jail.d/sudo.local
sudo systemctl restart fail2ban
```
