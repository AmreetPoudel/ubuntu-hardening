# Role: pkg_remove_legacy

## Description
Purges insecure, legacy networking packages (`inetutils-telnet`, `inetutils-telnetd`, `tftpd-hpa`, `xinetd`, `rsh-client`, `rsh-redone-client`, `talk`).

## Rollback
```bash
sudo apt install <package-name>
```
