FROM ubuntu
RUN apt-get update && apt-get install openssh-server -y
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN apt-get install nginx -y
RUN mkdir /var/run/sshd 
RUN useradd -m -s /bin/bash bilbo
RUN echo "bilbo:insecure_password" | chpasswd
EXPOSE 22
EXPOSE 80
CMD ["nginx", " "]
CMD ["/usr/sbin/sshd", "-D"]

ENTRYPOINT service ssh start && bash