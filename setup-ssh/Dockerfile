FROM ubuntu:latest

LABEL description="Running an ssh server within a Docker container."
LABEL author="Faisal Qureshi"
LABEL contact="faisal.qureshi@ontariotechu.ca"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y update
RUN apt-get install -y sudo

# If you want to install ssh server
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN groupadd -g 1010 dockeruser

# Use this if you want dockeruser to have sudo priviliges.  
# RUN useradd -r -m -s /bin/bash -g 1010 -G sudo dockeruser 
# Else use
RUN useradd -r -m -s /bin/bash -g 1010 -G sudo dockeruser 

# You can set user password here.  This is needed if you plan
# add this user to sudo group.  In any case, don't forget to  
# change the password if you plan to deploy this container.
RUN echo "dockeruser:123456" | chpasswd

# Set home folder for docker user
RUN mkdir /home/dockeruser/.ssh
RUN chown -R dockeruser:dockeruser /home/dockeruser
RUN chmod -R g+rwx /home/dockeruser
RUN chmod 700 /home/dockeruser/.ssh

# Start ssh server within this container.  You'll have to map
# container port 22 to an appropriate host port (not 22, please)
# so you can ssh into the container.
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]