# Role: ssh_hardening

Hardens OpenSSH daemon via drop-in config `/etc/ssh/sshd_config.d/99-hardening.conf`. Disables root login, X11 forwarding, TCP forwarding, enforces strict ciphers and KEX algorithms.
