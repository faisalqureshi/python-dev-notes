# axiom-analytics

## Steps

*0.* `cd setup`

*1.* Build docker 

~~~
docker build -t qureshi/axiom-analytics .
~~~

This can be achieved by running the script `image-build.sh`.

Note this line 

~~~txt
Successfully tagged qureshi/axiom-analytics:latest
~~~

which identifies that the image has been successfully built.  You'll need image tag to run the container.

*2.* Set external variables and spool up the container

User id

~~~
export user_id=$(id -u $USER)
~~~

and group id.

~~~
export group_id=$(id -g $USER)
~~~

Now spool up the container

~~~
docker-compose -f docker-compose.yml up rr
~~~

This can be achieved by running the script `container-run.sh`.

Note this line

~~~txt
Attaching to setup_rr_1
~~~

that identifies the container tag.  You'll need this to attach to this container.

*4.* Attach to this container

~~~
docker exec -it setup_rr_1 bash
~~~

This can be achieved by running the script `container-attach.sh`.

*5.* Within container prompt, run jupyter if needed

~~~
jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser
~~~

Then from another machine, you can connect to this jupyter instance via
SSH tunneling.

On another machine X

~~~
ssh panther -NL 8888:localhost:8888
~~~

Then on X, simply go to localhost:8888 to access the jupyter notebook running within the container that you just created.  You will need to unique token to access it.  Note it down when jupyter notebook spits it out.

