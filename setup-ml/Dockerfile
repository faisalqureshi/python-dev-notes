FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y build-essential \
    python3 \
    python3-pip \
    python-dev \
    python3-opencv \
    sudo 

RUN mkdir -p /tmp
COPY requirements.txt /tmp/
RUN pip3 -q install pip --upgrade
RUN pip3 install -r /tmp/requirements.txt -f https://download.pytorch.org/whl/torch_stable.html

RUN groupadd -g 1010 dockeruser
RUN useradd -r -m -g 1010 dockeruser 
RUN chown -R dockeruser /home/dockeruser
RUN chmod -R g+rwx /home/dockeruser
USER dockeruser
