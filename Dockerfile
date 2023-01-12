FROM alpine:3

RUN adduser gituser --home /gituser --disabled-password \
    && passwd -u gituser  

# Configuring user for ssh
RUN apk add openrc openssh \
    && mkdir -p /gituser/.ssh \
    && chmod 0700 /gituser/.ssh \
    && ssh-keygen -A \
    && echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && rc-status \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel

# Getting my ssh key into container
ADD authorized_keys /gituser/.ssh/

RUN chown -R gituser:gituser /gituser/.ssh/ \
    && chmod -R 0700 /gituser/.ssh 

EXPOSE 22
# RUN /root/.ssh/key.pub > /root/.ssh/authorized_keys \
  #  && rm /root/.ssh/key.pub

# ENTRYPOINT [ "sh", "-c", "rc-status; re-service sshd start;" ]

CMD rc-service sshd start \
    && tail -f
