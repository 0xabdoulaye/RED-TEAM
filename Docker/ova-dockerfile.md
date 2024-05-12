FROM hundred_box
RUN apt-get update 

EXPOSE 21
EXPOSE 22
EXPOSE 80

ENTRYPOINT service ssh start