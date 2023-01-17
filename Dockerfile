FROM alpine:3

RUN adduser gituser --home /gituser --disabled-password \
    && passwd -u gituser  

# Configuring user for ssh
RUN apk add openrc openssh git\
    && mkdir -p /gituser/.ssh \
    && chmod 0700 /gituser/.ssh \
    && ssh-keygen -A \
    && echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && rc-status \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel

# Getting my ssh key into container
ADD authorized_keys /gituser/.ssh/

# Adding permission to ssh keys for connection 
RUN chown -R gituser:gituser /gituser/.ssh/ \
    && chmod -R 0700 /gituser/.ssh 

# Port 22 exposed for ssh
EXPOSE 22

# Getting git repo initialized and allowing gituser to push into
RUN mkdir /git-repo/ \
    && chown gituser:gituser /git-repo/ \
    && git init --bare /git-repo/devops.git \
    && chown -R gituser:gituser /git-repo/devops.git \
    && git config --global --add safe.directory /git-repo/devops.git

# Changing permission
#ADD devops-training/ /git-repo/files/
#RUN chown -R gituser:gituser /git-repo \
#    && chown gituser /etc/ssh
 
# Creating an empty repo
#RUN git init --bare /git-repo/devops-training.git \
#    && git config --global --add safe.directory /git-repo/files

CMD rc-service sshd start \
    && tail -f
