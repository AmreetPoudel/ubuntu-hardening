FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      systemd systemd-sysv systemd-resolved openssh-server sudo python3 python3-apt iproute2 kmod cron rsyslog \
      ca-certificates iptables procps dbus libpam-systemd nginx postgresql at \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -u 1001 -s /bin/bash admin && echo 'admin:Admin-pass-123' | chpasswd && usermod -aG sudo admin \
    && ssh-keygen -A && mkdir -p /run/sshd \
    && systemctl enable ssh
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
