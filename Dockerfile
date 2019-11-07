FROM ubuntu:18.04
MAINTAINER Mikalai Semashchuk <vitawt@gmail.com>

# Setup environment
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_V 7.3
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

# add and update sources
RUN apt-get update \
 && apt-get install -y apt-transport-https ca-certificates \
 && apt-get install -y language-pack-en-base software-properties-common apt-utils
RUN locale-gen en_US.UTF-8
RUN apt-get install -y software-properties-common \
 && apt-add-repository ppa:ondrej/php
RUN apt-get update

# install http
RUN apt-get install -y apache2 nano bash-completion unzip
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# install mysql
RUN apt-get install -y mysql-client mysql-server

# install php
RUN apt-get install -y libapache2-mod-php${PHP_V} php${PHP_V} php${PHP_V}-pdo php${PHP_V}-mysql php${PHP_V}-mbstring php${PHP_V}-xml php${PHP_V}-intl php${PHP_V}-tokenizer php${PHP_V}-gd php${PHP_V}-imagick php${PHP_V}-curl php${PHP_V}-zip php${PHP_V}-bcmath php${PHP_V}-mysql php${PHP_V}-mbstring

# install supervisord
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

# install sshd
RUN apt-get install -y openssh-server openssh-client passwd
RUN mkdir -p /var/run/sshd

#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:changeme' | chpasswd

# Put your own public key at id_rsa.pub for key-based login.
RUN mkdir -p /root/.ssh && touch /root/.ssh/authorized_keys && chmod 700 /root/.ssh
#ADD id_rsa.pub /root/.ssh/authorized_keys

ADD phpinfo.php /var/www/html/
ADD supervisord.conf /etc/
ADD runme.sh /tmp
RUN chmod +x /tmp/runme.sh

EXPOSE 22 80 443

CMD ["supervisord", "-n"]
