#/usr/bin/env bash

branch=${1};
parentBranch=${2};
rootDir=${3};
buildDir=${4};

##############
# Dockerfile #
##############

echo "FROM debian:${parentBranch}
MAINTAINER davask <docker@davaskweblimited.com>
USER root
LABEL dwl.server.os=\"debian ${branch}\"" > ${rootDir}/Dockerfile
echo '
# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive
# declare local
ENV DWL_LOCAL_LANG: en_US:en
ENV DWL_LOCAL: en_US.UTF-8
# RUN locale-gen ${DWL_LOCAL}
ENV LANG ${DWL_LOCAL}
ENV LANGUAGE ${DWL_LOCAL_LANG}
ENV LC_ALL ${DWL_LOCAL}
# declare main user
ENV DWL_USER_ID 1000
ENV DWL_USER_NAME username
ENV DWL_USER_PASSWD secret
# declare main user
ENV DWL_SSH_ACCESS false

# Update packages
RUN apt-get update && \
apt-get install -y apt-utils
RUN apt-get update && \
apt-get install -y \
locales \
openssl \
ca-certificates \
apt-transport-https \
software-properties-common \
openssh-server \
nano \
wget \
sudo

RUN apt-get autoremove -y; \
rm -rf /var/lib/apt/lists/*

# Update local
RUN locale-gen ${DWL_LOCAL}

RUN useradd -r \
--comment "dwl ssh user" \
--no-create-home \
--shell /bin/bash \
--uid 999 \
--no-user-group \
admin;
RUN echo "admin ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/admin
RUN chmod 0440 /etc/sudoers.d/admin

#configuration static
COPY ./build/etc/ssh/sshd_config \
./build/etc/ssh/sshd_config.factory-defaults \
/etc/ssh/

COPY ./build/dwl/envvar.sh \
./build/dwl/user.sh \
./build/dwl/ssh.sh \
./build/dwl/permission.sh \
./build/dwl/keeprunning.sh \
./build/dwl/init.sh \
/dwl/

EXPOSE 6408

ENTRYPOINT ["/bin/bash"]
CMD ["/dwl/init.sh", "tail -f /dev/null"]
RUN chown root:sudo -R /dwl
USER admin
WORKDIR /home/admin
' >> ${rootDir}/Dockerfile

echo "Dockerfile generated with debian:${branch}";
