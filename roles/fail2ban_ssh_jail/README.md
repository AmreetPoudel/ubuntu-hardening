# Role: fail2ban_ssh_jail

## Description
Configures Fail2ban to ban IPs for 1 hour after 3 failed SSH login attempts.

## System Commands & Modifications
- Writes `/etc/fail2ban/jail.d/sshd.local`
- `systemctl restart fail2ban`

## Manual Rollback Steps
```bash
sudo rm -f /etc/fail2ban/jail.d/sshd.local
sudo systemctl restart fail2ban
```
