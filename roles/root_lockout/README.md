# Role: root_lockout

## Description
Locks direct root password authentication, enforcing sudo-based administration.

## System Commands & Modifications
- `usermod -L root` or `passwd -l root`

## Manual Rollback Steps
```bash
sudo usermod -U root
```
