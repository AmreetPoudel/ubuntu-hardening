# Role: issue_content

## Description
Removes OS version details from /etc/issue banners to prevent OS fingerprinting.

## System Commands & Modifications
- Removes OS macros from `/etc/issue` and `/etc/issue.net`

## Manual Rollback Steps
```bash
sudo lsb_release -a > /etc/issue
```
