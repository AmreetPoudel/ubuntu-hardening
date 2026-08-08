# Role: compiler_restriction

## Description
Restricts C/C++ compilers (gcc, g++, as) to root execution (chmod 0700).

## System Commands & Modifications
- `chmod 0700 /usr/bin/gcc /usr/bin/g++ /usr/bin/as`

## Manual Rollback Steps
```bash
sudo chmod 0755 /usr/bin/gcc /usr/bin/g++ /usr/bin/as
```
