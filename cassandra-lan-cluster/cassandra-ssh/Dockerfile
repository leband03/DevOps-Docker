FROM cassandra:4.1.5

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd

# Непривилегированный пользователь для SSH
RUN useradd -m -s /bin/bash admin \
    && mkdir -p /home/admin/.ssh \
    && chown -R admin:admin /home/admin/.ssh \
    && chmod 700 /home/admin/.ssh

# SSH: только по ключу 
RUN sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?ChallengeResponseAuthentication\s+.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?UsePAM\s+.*/UsePAM no/' /etc/ssh/sshd_config

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/start.sh"]
