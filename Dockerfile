FROM debian:9

LABEL maintainer="ali.akrour@gmail.com"

ENV NOTVISIBLE "in users profile"
ARG DEBIAN_FRONTEND=noninteractive
ARG ROOT_PASS=default

RUN apt-get update \
 && apt-get install -y openssh-server python sudo \
 && apt-get install -y nginx \ 
 && apt-get clean -y \ 
 && mkdir /run/sshd \ 
 && echo "root:$ROOT_PASS" | chpasswd \
 && sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \ 
 && sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd \
 && echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22 80

CMD /usr/sbin/sshd && /usr/sbin/nginx -g "daemon off;"	 


