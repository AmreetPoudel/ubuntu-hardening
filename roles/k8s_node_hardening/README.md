# Role: k8s_node_hardening

## Description
Applies Kubelet CIS benchmarks, disables swap, and sets 0600 config perms.

## System Commands & Modifications
- `swapoff -a`
- `chmod 0600 /var/lib/kubelet/config.yaml`

## Manual Rollback Steps
```bash
sudo swapon -a
```
