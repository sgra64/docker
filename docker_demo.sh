# show docker daemon (dockerd, service/process) is running
docker --version

# show docker images and containers (-a, all)
docker ps -a
docker image ls
docker images

# pull image from registry, create(!) and run first container
docker pull hello-world:latest
docker image ls
docker run hello-world
docker ps -a
# 
# creates new container instance and runs hello-world program,
# after process exits, container (state) stays around and can be restarted
docker run --name hello-world hello-world
# 
# restart created container
docker start hello-world
# 
# create & run new container instance 
docker run hello-world

# create and run Ubuntu container (Ubuntu is a Linux distribution)
docker pull ubuntu:latest
docker image ls ubuntu
# create and run new container, execute /bin/bash inside container
# -it: link stdin/-out inside container to terminal to work with inner
# bash interactively (-it)
docker run --name ubuntu_container_01 -it ubuntu:latest /bin/bash
# 
# ... run bash commands inside container, e.g.
# echo "Hello ubuntu-container" >/tmp/hello.txt
# exit
# 
docker ps -a
docker start ubuntu_container_01 -ai     # restart container
# cat /tmp/hello.txt
# 
# perfom commands in a running(!) container (with at least one process)
docker exec ubuntu_container_01 cat /tmp/hello.txt

# create Alpine container (one of the smallest base images, https://www.alpinelinux.org)
docker pull alpine:latest
docker image ls
docker run --name alpine_container_01 -it alpine:latest /bin/sh
docker ps -a
docker start alpine_container_01 -ai
