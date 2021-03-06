FROM ubuntu:latest

LABEL description="Setting a development Docker container.  Docker compose file maps dockeruser seen here to the current user on the host, greatly simplifying code development by side-stepping prickly permission issues."
LABEL author="Faisal Qureshi"
LABEL contact="faisal.qureshi@ontariotechu.ca"


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y update

RUN apt-get install sqlite3 -y

RUN apt-get install -y \
    build-essential \
    python3.9 \
    python3-pip \
    python-dev \
    sudo

RUN mkdir -p /tmp
COPY requirements.txt /tmp/
RUN pip3 -q install pip --upgrade
RUN pip3 install -r /tmp/requirements.txt

RUN groupadd -g 1010 dockeruser
RUN useradd -r -m -g 1010 dockeruser 
RUN chown -R dockeruser /home/dockeruser
RUN chmod -R g+rwx /home/dockeruser
USER dockeruser
