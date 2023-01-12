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

# Changing permission
ADD devops-training/ /git-repo/files/
RUN chown gituser /git-repo \
    && chown gituser /etc/ssh
 
# Creating an empty repo
RUN git init --bare /git-repo/devops-training.git \
    && git config --global --add safe.directory /git-repo/files

CMD rc-service sshd start \
    && tail -f
