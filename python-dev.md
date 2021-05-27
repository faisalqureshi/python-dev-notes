---
to: html
title: Python development
author: Faisal Z. Qureshi   
email: faisal.qureshi@ontariotechu.ca
date: May 19, 2021
institution: Ontario Tech University
subtitle: Local and remote setups
institute: Ontario Tech University
sansfont: Gill Sans
titlegraphic: ontario-tech-univ-logo.png
web: http://faculty.uoit.ca/qureshi
page-numbers: True
geometry: margin=2cm
highlight: kate
css: "notes-style.css"
template: "notes-template.html"

---
# Introduction

This document provides recipies for setting up local or remote Python (and Jupyter notebook) development environments.  

## Using system Python

Most systems (linux, windows, mac) come pre-installed with some version of Python.  It is possible to use system Python for development; however, it is often a *bad* idea.  Especially so if you are working on two or more Python applications with conflicting dependencies or different Python versions.  *Do not do this.*

## Using `virtualenv` to create application specific Python environments (systems)

It is better to use `virtualenv` to set up application specific Python environments.  Say
I want to develop two Python applications: mars and moon.  mars requires Python 2.0 plus `numpy`; whereas, moon requires Python 3.9 and `pandas`.  It is best to create two different Python environments as follows.

### Create Python environment for mars

~~~bash
$ virtualenv -p python2 ~/mars
~~~

The above will create a folder mars in the home directory.  This folder will include python2.  Now you can activate this environment and install the packages that you need using `pip`.

~~~bash
$ source ~/mars/bin/activate
(mars) $ pip install numpy
~~~

That's it. You can use this Python as follows

~~~bash
(mars) $ python
Python 2.7.16 (default, Feb 28 2021, 12:34:25)
[GCC Apple LLVM 12.0.5 (clang-1205.0.19.59.6) [+internal-os, ptrauth-isa=deploy on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>>
~~~

When you want to revert to system Python, deactivate the environment.

~~~bash
(mars) $ deactivate
~~~

### Create Python environment for moon

~~~bash
$ virtualenv -p python3 ~/moon
~~~

The above will create a folder moon in the home directory.  This folder will include Python3.  Now you can activate this environment and install the packages that you need using `pip`.  For Python3 it is better to use `pip3` actually.

~~~bash
$ source ~/moon/bin/activate
(mars) $ pip3 install pandas
~~~

That's it.  You can use this Python as follows

~~~bash
(moon) $ python
Python 3.9.4 (default, Apr  5 2021, 01:50:46)
[Clang 12.0.0 (clang-1200.0.32.29)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>>
~~~

When you want to revert to system Python, deactivate the environment.

~~~bash
(moon) $ deactivate
~~~

### Some considerations

1. Once done with your virtual environment, feel free to nuke the directories.

~~~bash
$ rm -rf ~/mars
$ rm -rf ~/moon
~~~

2. `virtualenv` or `venv` assumes that you have Python X is already installed on your machine.  Note that `virtualenv` doesn't install Python or pip.  Check out OS documentation on how to install Python X and pip.  On OSX, I use `brew`.  One Linux, you can use `apt-get`.

3. It is best to use `requirements.txt` file to specify which Python packages you want to install in a particular environment.  To be safe, I often also specify the version numbers for these packages.  Consider the following sample `requirements.txt` file.

~~~txt
numpy==1.19.0
scipy==1.4.0
~~~

Then we can install these packages in an environment, say mars, as follows:

~~~bash
(mars) $ pip install -r requirements.txt
~~~

4. If you like the current Python environment, and you want to set up a requirements.txt file that you can later use to setup a similar environment, use pip as follows:

~~~bash
(mars) $ pip freeze > requirements.txt
~~~

Don't also forget to note down the Python version.

*Happy hacking!*

## Dockerfile for setting up local development environment

Dockerfile to setting up an image with a `dockeruser` user.  The user has a home directory `/home/dockeruser`. This image also has a `dockeruser` group with group id 1010.  User `dockeruser` is a member of this group.  Any member of this group has read-write permissions on the home directory.  This set up allows us to create and run a container with host users  that are also member of the `dockeruser` group.  We can then create files within the container that will appear at mounted host directories to come from valid host users.  See the attached docker-compose.yml file that creates and runs the container using host user $UID:$GID.

**Sample Dockerfile**

~~~txt
FROM ubuntu:latest

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
~~~

**Sample docker-compose file**

~~~txt
version: '3'
services:
    roadrunner:
      build: .
      image: test
      user: $UID:$GID
      working_dir: /home/dockeruser
      stdin_open: true
      volumes:
        - /Users/faisal/Dropbox/coding:/home/dockeruser/coding:rw
      tty: true
      ports: 
        - "8888:8888"
      group_add:
        - "1010"
      environment:
        - HOME="/home/dockeruser"
~~~

**Sample requirements.txt file**

~~~txt
jupyterlab==3.0.15
numpy==1.20.3
scipy==1.6.3
matplotlib==3.4.2
pandas==1.2.4
~~~

### Build

~~~bash
$ docker build -t test .
~~~

### Create and run container
  
~~~bash  
$ export UID=$(id -u $USER)
$ export GID=$(id -g $USER)
$ docker-compose -f docker-compose.yml roadrunner 
...
Attaching to docker-test2_roadrunner_1
~~~

Note down the name of the container image returned by docker-compose.  In the above case it is `docker-test2_roadrunner_1`

### Attach

Run bash shell

~~~bash
$ docker exec -it docker-test2_roadrunner_1 bash
~~~

You will be in container prompt now.  It may look something like

~~~bash
I have no name!@71329da46414:/home/dockeruser$
~~~

### A note about host user and container user

You can now see your container user information.  

~~~bash
I have no name!@71329da46414:/home/dockeruser$ id
uid=501 gid=20(dialout) groups=20(dialout),1010(dockeruser)
~~~

Note that your UID and GID matches those on the host.  This means any files that you create within the mounted host directory will have the correct host-user ownership/permissions.

Lets create a file within container

~~~bash
I have no name!@71329da46414:/home/dockeruser$ cd coding/
I have no name!@71329da46414:/home/dockeruser/coding$ touch boo
~~~

Now lets see its permissions in the host

~~~bash
$ ls -l
-rw-r--r--@  1 hostuser  hostgroup       0 19 May 08:18 boo
~~~

It works!

### Run Jupyter Notebook from within container

Do the following at container prompt

~~~bash
I have no name!@71329da46414:/home/dockeruser$ jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser
[I 12:21:42.373 NotebookApp] Writing notebook server cookie secret to /home/dockeruser/"/home/dockeruser"/.local/share/jupyter/runtime/notebook_cookie_secret
[W 2021-05-19 12:21:43.110 LabApp] 'ip' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[W 2021-05-19 12:21:43.110 LabApp] 'port' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[W 2021-05-19 12:21:43.110 LabApp] 'port' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[W 2021-05-19 12:21:43.110 LabApp] 'port' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[I 2021-05-19 12:21:43.119 LabApp] JupyterLab extension loaded from /usr/local/lib/python3.8/dist-packages/jupyterlab
[I 2021-05-19 12:21:43.119 LabApp] JupyterLab application directory is /usr/local/share/jupyter/lab
[I 12:21:43.124 NotebookApp] Serving notebooks from local directory: /home/dockeruser
[I 12:21:43.124 NotebookApp] Jupyter Notebook 6.4.0 is running at:
[I 12:21:43.124 NotebookApp] http://71329da46414:8888/?token=d3f623a50a07e566dd025b1cfdd304c48cdac0407eede6fc
[I 12:21:43.124 NotebookApp]  or http://127.0.0.1:8888/?token=d3f623a50a07e566dd025b1cfdd304c48cdac0407eede6fc
[I 12:21:43.124 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 12:21:43.128 NotebookApp]

    To access the notebook, open this file in a browser:
        file:///home/dockeruser/%22/home/dockeruser%22/.local/share/jupyter/runtime/nbserver-19-open.html
    Or copy and paste one of these URLs:
        http://71329da46414:8888/?token=d3f623a50a07e566dd025b1cfdd304c48cdac0407eede6fc
     or http://127.0.0.1:8888/?token=d3f623a50a07e566dd025b1cfdd304c48cdac0407eede6fc
~~~

And you can access this notebook via host using the URL provided above.

### Afterword

1. The jupyter notebook will have access to files in the mounted host folder.
2. If you create a new notebook, you can save it (a) within container or (b) in the mounted host folder.  (a) isn't persistent.  Don't do that.  Do (b).  Since the container is run as the host user, the file that you create will have the correct host-user ownership/permission.

*Happy hacking!*

## Remote setups

Soon you will outgrow your local machine, and you will need access to development servers with better compute and memory resources.  

1. Ensure that you are able to ssh into the server.  I highly recommned setting up key-based ssh-authentication.  Check out ssh documentation to see how that can be done.

2. Set up Python development environment on the server.  Use virualenv or docker as shown above.

### Accessing jupyter notebook on the remote server

1. Start the jupyter notebook on the remote server.  If using virtualenv, you can do the following: `jupyter notebook --port 8888 --no-browser`.  Be sure to write down the URL with authentication token.

2. Set up an ssh tunnel to the remote server: `ssh user@remote -NL 8888:localhost:8888`.  This will forward local port 8888 to remote port 8888.

3. Use the authentication token in (1) above, connect to the jupyter notebook at the remote host.

### Editing files on remote host

Gone are the days when you had to telnet into a remote and use vi to edit your code.  Modern source code editors such as Visual Studio can access remote files via ssh.  It gives you the impression that you are editing these files locally, but actually your changing the files on the remote.  The following works for Visual Studio.

1. Install the [Remote Development extension pack](https://code.visualstudio.com/docs/remote/ssh).

2. Use F1 to connect to ssh. 

This assumes that you are able to ssh into remote using key-authentication and that your ~/.ssh/config file is setup appropriately.

*Happy hacking!*
