## Assignment D12: Docker

This assignment will setup Docker and demonstrate its basic use.
If you already have Docker, you can use that installation.

---

### Challenges

- [Challenge D1-1:](#d1-challenge-1) Docker Setup and CLI - (4 Pts)

- [Challenge D1-2:](#d1-challenge-2) Run hello-world container - (3 Pts)

- [Challenge D1-3:](#d1-challenge-3) Run minimal Alpine container - (3 Pts)

- [Challenge D2:](README_D2.md) Containerize Java application - (6 Pts)

- [Challenge DX:](README_DX.md) Extra Points (not required) - (+6 Extra Pts)

Refer to [known issues](https://github.com/sgra64/docker/blob/main/KNOWN_ISSUES.md) for problems.


&nbsp;

---

### D1) Challenge 1

Install Docker. Open a terminal and type commands:

```sh
> docker --version
Docker version 20.10.17, build 100c701
> docker --help
...

> docker ps                 ; dockerd is not running
error during connect: This error may indicate that the docker daemon is not runn
ing.

> docker ps                 ; dockerd is now running, no containers yet
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

If you can't run the `docker` command, the client-side *docker-CLI* (Command-Line-Interface)
may not be installed or is not on the PATH. If `docker ps` says: "can't connect",
the *Docker engine* (server-side: *dockerd* ) is not running and must be started.

(4 Pts)


&nbsp;

---
### D1) Challenge 2

Run the *hello-world* container from Docker-Hub:
[hello-world](https://hub.docker.com/_/hello-world):

```sh
> docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete
Digest: sha256:62af9efd515a25f84961b70f973a798d2eca956b1b2b026d0a4a63a3b0b6a3f2
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Show the container image loaded on your system:

```sh
> docker image ls
REPOSITORY       TAG           IMAGE ID       CREATED         SIZE
hello-world      latest        feb5d9fea6a5   12 months ago   13.3kB
```

Show that the container is still present after the end of execution:

```sh
> docker ps -a
CONTAINER ID  IMAGE        COMMAND   CREATED    STATUS     PORTS   NAMES
da16000022e0  hello-world  "/hello"  6 min ago  Exited(0)  magical_aryabhata
```

Re-start the container with an attached (-a) *stdout* terminal.
Refer to the container either by its ID (here: *da16000022e0* ) or by its
generated NAME (here: *magical_aryabhata* ).

```sh
> docker start da16000022e0 -a          or: docker start magical_aryabhata -a
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Re-run will create a new container and execut it. `docker ps -a ` will then
show two containers created from the same image.

```sh
> docker run hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.

> docker ps -a
CONTAINER ID  IMAGE        COMMAND   CREATED    STATUS     PORTS   NAMES
da16000022e0  hello-world  "/hello"  6 min ago  Exited(0)  magical_aryabhata
40e605d9b027  hello-world  "/hello"  4 sec ago  Exited(0)  pedantic_rubin
```

"Run" always creates new containers while "start" restarts existing containers.

(3 Pts)


&nbsp;

---
### D1) Challenge 3

[Alpine](https://www.alpinelinux.org) is a minimal base image that has become
popular for building lean containers (few MB as opposed to 100's of MB or GB's).
Being mindful of resources is important for container deployments in cloud
environments where large numbers of containers are deployed and resource use
is billed.

Pull the latest Alpine image from Docker-Hub (no container is created with just
pulling the image). Mind image sizes: hello-world (13.3kB), alpine (5.54MB).

```sh
> docker pull alpine:latest
docker pull alpine:latest
latest: Pulling from library/alpine
Digest: sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad
Status: Image is up to date for alpine:latest
docker.io/library/alpine:latest

> docker image ls
REPOSITORY       TAG           IMAGE ID       CREATED         SIZE
hello-world      latest        feb5d9fea6a5   12 months ago   13.3kB
alpine           latest        9c6f07244728   8 weeks ago     5.54MB
```

Create and run an Alpine container executing an interactive shell `/bin/sh` attached to the terminal ( `-it` ). It launches the shell that runs commands inside the Alpine
container.

**GitBash:**
if error occurs: *OCI runtime exec failed: exec failed: unable to start container
process: exec: ... no such file or directory* occurs, use:
`//bin//sh` instead of `/bin/sh`,
(see [known issues](https://github.com/sgra64/docker/blob/main/KNOWN_ISSUES.md#2-issue-2)).

```sh
> docker run -it alpine:latest /bin/sh
# ls -la
total 64
drwxr-xr-x    1 root     root          4096 Oct  5 18:32 .
drwxr-xr-x    1 root     root          4096 Oct  5 18:32 ..
-rwxr-xr-x    1 root     root             0 Oct  5 18:32 .dockerenv
drwxr-xr-x    2 root     root          4096 Aug  9 08:47 bin
drwxr-xr-x    5 root     root           360 Oct  5 18:32 dev
drwxr-xr-x    1 root     root          4096 Oct  5 18:32 etc
drwxr-xr-x    2 root     root          4096 Aug  9 08:47 home
drwxr-xr-x    7 root     root          4096 Aug  9 08:47 lib
drwxr-xr-x    5 root     root          4096 Aug  9 08:47 media
drwxr-xr-x    2 root     root          4096 Aug  9 08:47 mnt
drwxr-xr-x    2 root     root          4096 Aug  9 08:47 opt
dr-xr-xr-x  179 root     root             0 Oct  5 18:32 proc
drwx------    1 root     root          4096 Oct  5 18:36 root
drwxr-xr-x    2 root     root          4096 Aug  9 08:47 run
drwxr-xr-x    2 root     root          4096 Aug  9 08:47 sbin
drwxr-xr-x    2 root     root          4096 Aug  9 08:47 srv
dr-xr-xr-x   13 root     root             0 Oct  5 18:32 sys
drwxrwxrwt    2 root     root          4096 Aug  9 08:47 tmp
drwxr-xr-x    7 root     root          4096 Aug  9 08:47 usr
drwxr-xr-x   12 root     root          4096 Aug  9 08:47 var

# whoami
root

# uname -a
Linux aab69035680f 5.10.124-linuxkit #1 SMP Thu Jun 30 08:19:10 UTC 2022 x86_64

# exit
```

Commands after the `#` prompt (*root* prompt) are executed by the `/bin/sh` shell
inside the container. 

`# exit` ends the shell process and returns to the surrounding shell. The container
will go into a dormant (inactive) state.

```sh
> docker ps -a
CONTAINER ID  IMAGE         COMMAND   CREATED    STATUS     PORTS   NAMES
aab69035680f  alpine:latest "/bin/sh" 9 min ago  Exited     boring_ramanujan
```

The container can be restarted with any number of `/bin/sh` shell processes.

Containers are executed by **process groups** - so-called
[cgroups](https://en.wikipedia.org/wiki/Cgroups) used by
[LXC](https://wiki.gentoo.org/wiki/LXC) -
that share the same environment (filesystem view, ports, etc.), but are isolated
from process groups of other containers.

Start a shell process in the dormant Alpine-container to re-activate.
The start command will execute the default command that is built into the container
(see the COMMAND column: `"/bin/sh"`). The option `-ai` attaches *stdout* and *stdin*
of the terminal to the container.

Write *"Hello, container"* into a file: `/tmp/hello.txt`. Don't leave the shell.

```sh
> docker start aab69035680f -ai
# echo "Hello, container!" > /tmp/hello.txt
# cat /tmp/hello.txt
Hello, container!
#
```

Start another shell in another terminal for the container. Since it refers to the same
container, both shell processes share the same filesystem.
The second shell can therefore see the file created by the first and append another
line, which again will be seen by the first shell.

```sh
> docker start aab69035680f -ai
# cat /tmp/hello.txt
Hello, container!
# echo "How are you?" >> /tmp/hello.txt
```

First terminal:

```sh
# cat /tmp/hello.txt
Hello, container!
How are you?
#
```

In order to perform other commands than the default command in a running container,
use `docker exec`.

Execute command: `cat /tmp/hello.txt` in a third terminal:

```sh
docker exec aab69035680f cat /tmp/hello.txt
Hello, container!
How are you?
```

The execuition creates a new process that runs in the container seeing its filesystem
and other resources.

Explain the next command:

- What is the result?

- How many processes are involved?

- Draw a skech with the container, processes and their stdin/-out connections.

```sh
echo "echo That\'s great to hear! >> /tmp/hello.txt" | \
        docker exec -i aab69035680f /bin/sh
```

When all processes have exited, the container will return to the dormant state.
It will preserve the created file.

(3 Pts)
