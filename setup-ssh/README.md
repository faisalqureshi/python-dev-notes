---
author: Faisal Qureshi
email: faisal.qureshi@ontariotechu.ca

---

# Running an SSH server within a container

The [Dockerfile](./Dockerfile) shows how to run an SSH server within a container.

## Building image

~~~bash
$ docker build -t ssh-image .
~~~

## Run the container

~~~bash
$ docker run -d -P --name ssh-container ssh-image
~~~

If container already exists (or running), use `docker rm` to remove it as follows

~~~bash
$ docker rm --force ssh-container
~~~~

## Connecting using ssh

Use the following to see port mapping

~~~bash
$ docker port ssh-container
~~~

Next check the IP address of this container

~~~bash
$ docker inspect ssh-container
~~~

This returns a JSON string.  Look for IPAddress under Network setting.

Now ssh into the container

~~~bash
$ ssh dockeruser@localhost -p <PORT>
~~~

PORT can be found using `docker port` command as shown above.