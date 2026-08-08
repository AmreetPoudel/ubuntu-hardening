# Role: pkg_remove_legacy

## Description
Purges legacy, unencrypted, and insecure network packages (telnet, rsh, xinetd, tftp).

## System Commands & Modifications
- `apt purge inetutils-telnet inetutils-telnetd tftpd-hpa xinetd rsh-client talk`

## Manual Rollback Steps
```bash
sudo apt install -y inetutils-telnet inetutils-telnetd tftpd-hpa xinetd
```
