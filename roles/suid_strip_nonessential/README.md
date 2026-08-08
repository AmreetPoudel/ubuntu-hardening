# Role: suid_strip_nonessential

## Description
Strips SUID bit from non-essential utilities (chfn, chsh, gpasswd, newgrp).

## System Commands & Modifications
- `chmod u-s,g-s /usr/bin/chfn /usr/bin/chsh /usr/bin/gpasswd /usr/bin/newgrp`

## Manual Rollback Steps
```bash
sudo chmod u+s /usr/bin/chfn /usr/bin/chsh /usr/bin/gpasswd /usr/bin/newgrp
```
