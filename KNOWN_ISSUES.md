## Known Issues

---
Known issues capture problems and describe solutions.

1. [Issue 1:](#1-issue-1) Mac with *M1*-CPU:  *"image platform does not match host platform"*
2. [Issue 2:](#2-issue-2) with *GitBash*: *"failed to create shim task: OCI runtime create failed"*
3. [Issue 3:](#3-issue-3) with *GitBash*: *"the input device is not a TTY"*


&nbsp;

---

### 1.) Issue 1:

Error on Mac with *M1*-Chip: *"The requested image's platform (linux/amd64) does not match the detected host platform"*.

Solution: specify Intel/amd64 base-image for building Docker images:

In `Dockerfile`, use (example):
```
FROM --platform=linux/amd64 adoptopenjdk/openjdk11:alpine
```
for:
```
FROM adoptopenjdk/openjdk11:alpine
```

References:
- *"The requested image's platform (linux/amd64) does not match the 
detected host platform"*, [stackoverflow](https://stackoverflow.com/questions/69054921/docker-on-mac-m1-gives-the-requested-images-platform-linux-amd64-does-not-m).
- *"Choosing the right Docker Image for your Apple M1 Pro"*,
[link](https://collabnix.com/choosing-the-right-docker-image-for-your-apple-m1-pro).


&nbsp;

---

### 2.) Issue 2
Error when using *GitBash*: *"docker: Error response from daemon: failed to create
shim task: OCI runtime create failed: runc create failed: unable to start
container process: exec: stat C:/Program Files (x86)/Git/usr/bin/sh.exe:
no such file or directory"*.

Solution: disable GitBash/MinGW/MSYS path conversion by setting:
`export MSYS_NO_PATHCONV=1` in *.bashrc*
or
use `//` instead of `/` for root-directory.

Example:

```perl
docker run --rm -it openjdk11/app.jar_img //bin/sh      # double //
```

References:
- *"Stop MinGW and MSYS from mangling path names given at the
command line"*, [stackoverflow](https://stackoverflow.com/questions/7250130/how-to-stop-mingw-and-msys-from-mangling-path-names-given-at-the-command-line).


&nbsp;

---

### 3.) Issue 3
Error: *"the input device is not a TTY"*.

Solution: prepend `winpty` before the docker command. Use alias for docker command in *.bashrc*:

```
alias docker='winpty docker'
```

Example:

```
winpty docker run --rm -it openjdk11/app.jar_img /bin/sh
```

or with alias for docker command in *.bashrc*:

```
docker run --rm -it openjdk11/app.jar_img /bin/sh
```

References:
- *"The input device is not a TTY"*,
[GitHub](https://github.com/vercel/hyper/issues/2888).
- *"TTY Error running interactive docker on Bash on Windows"*,
[GitHub](https://github.com/docker/for-win/issues/1588).


&nbsp;

---
