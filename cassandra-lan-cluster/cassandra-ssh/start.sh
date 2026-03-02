#!/usr/bin/env bash
set -euo pipefail

# Готовим директории SSH 
mkdir -p /home/admin/.ssh
chown -R admin:admin /home/admin
chmod 700 /home/admin/.ssh
touch /home/admin/.ssh/authorized_keys
chown admin:admin /home/admin/.ssh/authorized_keys
chmod 600 /home/admin/.ssh/authorized_keys

# Стартуем sshd в фоне
/usr/sbin/sshd
exec /usr/local/bin/docker-entrypoint.sh cassandra -f
