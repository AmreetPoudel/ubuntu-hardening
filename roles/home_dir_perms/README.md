# Role: home_dir_perms

## Description
Restricts user home directory permissions under /home to 0750.

## System Commands & Modifications
- `chmod 0750 /home/*`

## Manual Rollback Steps
```bash
sudo chmod 0755 /home/*
```
