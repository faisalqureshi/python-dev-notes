<!-- ---
to: html
title: Docker setup for ML 
author: Faisal Z. Qureshi   
email: faisal.qureshi@ontariotechu.ca
date: May 19, 2021
institution: Ontario Tech University
subtitle: Accessing host GPUs
institute: Ontario Tech University
sansfont: Gill Sans
titlegraphic: ontario-tech-univ-logo.png
web: http://faculty.uoit.ca/qureshi
page-numbers: True
geometry: margin=2cm
highlight: kate
css: "notes-style.css"
template: "notes-template.html"

--- -->

# Setting up docker for ML 

Machine Learning (ML) requires access to serious computing hardware, most notably Graphical Processing Units (GPUs) capable of crunching vast amount of data in order to train complicated deep (learning) neural networks models.  NVidia is currently the dominant GPU provider on the market.  A large fraction of deep learning models rely upon NVidia GPUs.  Before we setup a docker environment that has access to GPUs available on the host machine, lets ensure that the following works.  To keep things simple, lets assume that you are using a Linux system.

1. [Nvidia GPU](https://developer.nvidia.com/cuda-gpus) hardware is correctly installed on your machine.
2. You have downloaded and installed the latest [drivers](https://www.nvidia.com/Download/index.aspx) for your GPU/OS combination.
3. You have also installed the correct version of Nvidia [cuda toolkit](https://developer.nvidia.com/cuda-toolkit).
4. In addition, you have also installed [Docker](https://docs.docker.com/engine/install/ubuntu/) and [docker-compose](https://docs.docker.com/compose/install/).

**Which GPUs are available**

Use the following commands to see GPU hardware available on your machine.

~~~bash
$ nvidia-smi
~~~

**Which version of cuda is installed**

Use the following command to check cuda compiler version installed on your machine.

~~~bash
$ nvcc --version
~~~

**Which version of linux is this system**

Check linux version

~~~bash
$ cat /etc/*release
~~~

Alternately, you can use `lsb_release -d` command.

You can install lsb package if not already installed

~~~bash
$ apt-get -y install lsb-core
~~~

# Nvidia Container Toolkit

Nvidia has provided [Nvidia Container Toolkit](https://github.com/NVIDIA/nvidia-docker) package that allows GPUs to be made available within the docker container.  Install it as follows

~~~bash
$ sudo apt-get install -y nvidia-docker2
$ sudo systemctl restart docker
~~~

# Setting up Nvidia/cuda container

You're almost there.

## Option 1

You can `docker pull` to get a pre-built container.  Check [here](https://docs.nvidia.com/deeplearning/frameworks/user-guide/index.html) and [here](https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/unsupported-tags.md) for more information.

~~~bash
$ docker pull nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04
~~~

This will require `docker login`.

## Option 2

This is my preferred way of doing things.  Create a `Dockerfile` as follows.  The first line is important and it specifies the base image nvidia/cuda image to build from.  The rest is standard docker stuff as seen [here](python-dev.html).

**Dockerfile**

~~~txt
FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y build-essential python3 python3-pip python-dev sudo

RUN mkdir -p /tmp
COPY requirements.txt /tmp/
RUN pip3 -q install pip --upgrade
RUN pip3 install -r /tmp/requirements.txt -f https://download.pytorch.org/whl/torch_stable.html

RUN groupadd -g 1010 dockeruser
RUN useradd -r -m -g 1010 dockeruser
RUN chown -R dockeruser /home/dockeruser
RUN chmod -R g+rwx /home/dockeruser
USER dockeruser
~~~

Since I am interested in [PyTorch](https://pytorch.org), my `requirements.txt` file contains the following.

**requirements.txt**

~~~txt
torch==1.8.0+cu111
torchvision==0.9.0+cu111
matplotlib
jupyter
~~~

Find out the appropriate torch package with the correct cuda support [here](https://download.pytorch.org/whl/torch_stable.html).  This sort of needs to match with the cuda support available on the host and also the nvidia/cuda base image that you use as the base image (as seen in the docker file).

### Building your own nvidia/cuda docker container

Build docker container as usual.

~~~bash
$ docker build -t myml .
~~~

# Run container 

You can run docker container as follows

~~~bash
$ docker run -it --gpus=all --ipc=host myml bash
~~~

From within you can see if PyTorch is able to access host GPUs as follows.

~~~bash
[Container] $ python3
Python 3.6.9 (default, Jan 26 2021, 15:33:00)
[GCC 8.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import torch
>>> torch.cuda.is_available()
True
>>> torch.cuda.get_device_name(0)
'GeForce GTX TITAN X'
>>> torch.cuda.get_device_name(1)
'GeForce GTX 980'
>>>
~~~

*Happy hacking!*
