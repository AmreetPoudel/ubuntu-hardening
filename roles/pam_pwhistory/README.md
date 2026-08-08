# Role: pam_pwhistory

## Description
Prevents users from reusing their last 5 passwords via pam_pwhistory.so.

## System Commands & Modifications
- Edits `/etc/pam.d/common-password` adding `pam_pwhistory.so remember=5`

## Manual Rollback Steps
```bash
sudo sed -i '/pam_pwhistory.so/d' /etc/pam.d/common-password
```
