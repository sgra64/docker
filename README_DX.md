## Assignment DX: Create *Alpine-ssh* Container for *ssh*-Login (+6 Extra Pts)

Create a new Alpine container with name `alpine-ssh` and configure it for
[ssh](https://en.wikipedia.org/wiki/Secure_Shell) access.

```sh
docker run --name alpine-ssh -p 22:22 -it alpine:latest
```

Instructions for installation and confiduration can be found here:
["How to install OpenSSH server on Alpine Linux"](https://www.cyberciti.biz/faq/how-to-install-openssh-server-on-alpine-linux-including-docker) or here:
["Setting up a SSH server"](https://wiki.alpinelinux.org/wiki/Setting_up_a_SSH_server).

Add a local user *larry* with *sudo*-rights, install *sshd* listening on the
default port 22.

Write down commands that you used for setup and configuration to enable the
container to run *sshd*.

Verify that *sshd* is running in the container:

```sh
# ps -a
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sh
  254 root      0:00 sshd: /usr/sbin/sshd [listener] 0 of 10-100 startups
  261 root      0:00 ps -a
```

Show that *ssh* is working by login in as *larry* from another terminal:

```sh
> ssh larry@localhost

Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <http://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

54486c62d745:~$ whoami
larry

54486c62d745:~$ ls -la
total 32
drwxr-sr-x    1 larry    larry         4096 Oct  2 21:34 .
drwxr-xr-x    1 root     root          4096 Oct  2 20:40 ..
-rw-------    1 larry    larry          602 Oct  5 18:53 .ash_history

54486c62d745:~$ uname -a
Linux 54486c62d745 5.10.124-linuxkit #1 SMP Thu Jun 30 08:19:10 UTC 2022 x86_64 Linux
54486c62d745:~$
```
