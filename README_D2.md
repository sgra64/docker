## Assignment D2: Packaging Java Application in Docker Image (6 Pts)

This assignment refers to the project from assignment `A1`, which was
a *Java*-project that computes factorial factors of a number:

- [https://gitlab.bht-berlin.de/sgraupner/setup.se2](https://gitlab.bht-berlin.de/sgraupner/setup.se2) .

Result of the *Build-Process* of project `A1` was a packaged executable `.jar`
that could be delivered to a customer:

```
java -jar target/application-1.0.0-SNAPSHOT.jar n=100 n=1000
```

Output:

```
Hello, Factorizer
n=100
 - factorized: [2, 2, 5, 5]
n=1000
 - factorized: [2, 2, 2, 5, 5, 5]
done.
```

In this assignment, the executable `.jar` will be further packaged as a Docker image that
also includes the Java runtime environment (*JavaVM*) and hence is no longer required on
the target system.

The packaged *image* now can be distributed, e.g. through the Docker registry such as
[https://hub.docker.com](https://hub.docker.com) .

On a target system, no *JavaVM* is required to execute the program - it comes with the
images pulled from the registry.


---

### Steps


1. [Step 1:](#step-1-check-out-and-build-java-project) Check-out and Build *Java*-Project
            (1 Pt)

1. [Step 2:](#step-2-build-new-docker-image) Build new Docker *Image*
            (1 Pt)

1. [Step 3:](#step-3-create-container-from-image) Create *Container* from *Image*
            (1 Pt)

1. [Step 4:](#step-4-run-container) Run *Container*
            (1 Pt)

1. [Step 5:](#step-5-clean-up) Clean-up
            (1 Pt)

1. [Step 6:](#step-6-final-demonstration) Final Demonstration
            (1 Pt)


&nbsp;

---
### Step 1) Check-out and Build *Java*-Project

The Docker *build project* requires its own project directory, which is
created branch `D12-docker` is pulled from the repository:

```sh
git clone -b D12-docker --single-branch https://github.com/sgra64/docker.git D12-docker

cd D12-docker                   # cd into project directory
```

Content of Docker *build project* directory:

```
drwxr-xr-x 1     0 May 16 20:51 .git/
-rw-r--r-- 1   819 May 14 21:47 .gitignore
-rw-r--r-- 1  8880 May 16 20:56 Dockerfile
-rw-r--r-- 1  8880 May 16 20:56 README.md
-rw-r--r-- 1 12856 May 16 21:24 README_D2.md
```

Next, the *Java-build project* is pulled inside the project directory:

```sh
git clone git@gitlab.bht-berlin.de:sgraupner/setup.se2.git A1-java-build
```

Content of Docker *build project* directory:

```
drwxr-xr-x 1     0 May 16 20:51 .git/
-rw-r--r-- 1   819 May 14 21:47 .gitignore
drwxr-xr-x 1     0 May 16 21:33 A1-java-factorial/    <-- Java-build-project
-rw-r--r-- 1  8880 May 16 20:56 Dockerfile
-rw-r--r-- 1  8880 May 16 20:56 README.md
-rw-r--r-- 1 12856 May 16 21:24 README_D2.md
```

Build *Java-project* first:

```sh
cd A1-java-factorial                # cd into Java project directory
source .env/project.sh              # source the Java project
mk compile compile-tests
```

Include your code from Assignment A such that the *factorize()* - method
works.

```
mk run n=12                         # test application (12=2*2*3)
```
```
Hello, Factorizer
n=12
 - factorized: [2, 2, 3]
```

Since the Docker image uses `Java v11` (version 11), code compiled with
newer Java versions must be *"back-compiled"* for Java version 11:

```sh
javac -source 11 -target 11 $(find src/main -name '*.java') -d target/classes
javac -source 11 -target 11 $(find src/tests -name '*.java') -d target/test-classes
```

Run JUnit-tests and package the application as `.jar`:

```sh
mk run-tests                # make sure JUnit tests pass
mk package                  # package class files
ls -la target
```

The executable `.jar` was created in the `target` directory:

```
drwxr-xr-x 1    0 May 16 21:54 ./
drwxr-xr-x 1    0 May 16 21:47 ../
-rw-r--r-- 1 8238 May 16 21:54 application-1.0.0-SNAPSHOT.jar
drwxr-xr-x 1    0 May 16 21:47 classes/
drwxr-xr-x 1    0 May 16 21:41 resources/
drwxr-xr-x 1    0 May 16 21:50 test-classes/
```

Test the `.jar` is executable:

```sh
mk run-jar n=12             # package class files
java -jar target/application-1.0.0-SNAPSHOT.jar n=12
```
```
Hello, Factorizer
n=12
 - factorized: [2, 2, 3]
```

If tests are successful, the executable `.jar` is moved to the Docker-packaging
directory with name and `-SNAPSHOT` changed to `-RELEASE`:

```sh
cp target/application-1.0.0-SNAPSHOT.jar ../factorizer-1.0.0-RELEASE.jar

cd ..                       # cd back to the Docker-packaging directory
ls -la                      # release .jar is now in the Docker-packaging directory
```
```
drwxr-xr-x 1     0 May 16 22:25 ./
drwxr-xr-x 1     0 May 14 21:45 ../
drwxr-xr-x 1     0 May 16 20:51 .git/
-rw-r--r-- 1   819 May 14 21:47 .gitignore
drwxr-xr-x 1     0 May 16 21:47 A1-java-build/
-rw-r--r-- 1  8238 May 16 22:25 factorizer-1.0.0-RELEASE.jar
-rw-r--r-- 1   499 May 16 22:00 Dockerfile
```


&nbsp;

---
### Step 2) Build new Docker *Image*

[Dockerfile](Dockerfile) is used to create a new Docker image from a base image,
which is
[adoptopenjdk/openjdk11:alpine](https://hub.docker.com/r/adoptopenjdk/openjdk11)

that contains:

- the minimal
    [Alpine](https://www.alpinelinux.org),
    [*base image*](https://hub.docker.com/_/alpine) Unix environment,

- plus an image-layer that contains a `Java-11` JDK, which includes Java tools such as *javac*, *jar* etc.

Onto this two-level image stack, another image is layered containing:

- the executable `application-1.0.0-RELEASE.jar`.

[Dockerfile](Dockerfile) describes the process to create the new image layered above
[adoptopenjdk/openjdk11:alpine](https://hub.docker.com/r/adoptopenjdk/openjdk11):

```Dockerfile
# base image, https://hub.docker.com/r/adoptopenjdk/openjdk11
# Mac with M1-Chip use: FROM --platform=linux/amd64 adoptopenjdk/openjdk11:alpine
FROM adoptopenjdk/openjdk11:alpine

# create a new directory in the container: /opt/app
RUN mkdir /opt/app

# copy 'factorizer-1.0.0-RELEASE.jar' from the project directory into container: /opt/app
COPY factorizer-1.0.0-RELEASE.jar /opt/app

# define a command that executes when the container started with n=12
CMD ["java", "-jar", "/opt/app/factorizer-1.0.0-RELEASE.jar", "n=12"]
```

(Mac's with M1 Chip may need to specify `--platform=linux/amd64` in `FROM`, see
[Known Issues](https://github.com/sgra64/docker/blob/main/KNOWN_ISSUES.md))

The `docker build` command builds the new *image* named `factorizer-1.0.0_image`
using `Dockerfile` in the current directory ( `.` ):

```sh
# build new Docker image using Dockerfile in current directory '.'
docker build -t "factorizer-1.0.0_image" --no-cache .
```

Output in terminal:

```
[+] Building 25.0s (9/9) FINISHED                                docker:default
 => [internal] load .dockerignore                                          0.1s
 => => transferring context: 2B                                            0.0s
 => [internal] load build definition from Dockerfile                       0.1s
 => => transferring dockerfile: 557B                                       0.0s
 => [internal] load metadata for docker.io/adoptopenjdk/openjdk11:alpine   2.6s
 => [auth] adoptopenjdk/openjdk11:pull token for registry-1.docker.io      0.0s
 => [1/3] FROM docker.io/adoptopenjdk/openjdk11:alpine@sha256:efc3e6ed67  21.0s
 => => resolve docker.io/adoptopenjdk/openjdk11:alpine@sha256:efc3e6ed672  0.1s
 => => sha256:ac1aad2ba14d1fe6fd343451c88690fcfdd8886f152 6.49MB / 6.49MB  0.8s
 => => sha256:d31d0002f609d88949caf44a2bb79dd3d33e6f 196.23MB / 196.23MB  15.8s
 => => sha256:efc3e6ed67294adf9581c34afa35053535df94394fc0ec9 433B / 433B  0.0s
 => => sha256:0d6e69b689d66e30b8ff11a89204973a2fae854f89ea357 952B / 952B  0.0s
 => => sha256:df248bda2f0e0477748c087344c4c4c37262068aefa 5.29kB / 5.29kB  0.0s
 => => extracting sha256:ac1aad2ba14d1fe6fd343451c88690fcfdd8886f15296593  0.4s
 => => extracting sha256:d31d0002f609d88949caf44a2bb79dd3d33e6f3977d83895  4.7s
 => [internal] load build context                                          0.1s
 => => transferring context: 8.29kB                                        0.0s
 => [2/3] RUN mkdir /opt/app                                               0.6s
 => [3/3] COPY factorizer-1.0.0-RELEASE.jar /opt/app                       0.1s
 => exporting to image                                                     0.2s
 => => exporting layers                                                    0.1s
 => => writing image sha256:8207b42a370300573638e9131e7299f1faf73b24cbfbc  0.0s
 => => naming to docker.io/library/factorizer-1.0.0_image                  0.0s
```

Show new Docker image:

```sh
docker image ls factorizer-1.0.0_image
```

Output:

```
REPOSITORY               TAG       IMAGE ID       CREATED          SIZE
factorizer-1.0.0_image   latest    8207b42a3703   59 seconds ago   345MB
```


&nbsp;

---
### Step 3) Create *Container* from *Image*

Create container from new image, which also starts the container.

```sh
# create container from new image
docker run -it --name=factorizer_container -d factorizer-1.0.0_image
```

Show new container (not running):

```perl
# show new container
> docker ps -a
```

Output:

```
CONTAINER ID  IMAGE                   COMMAND                      STATUS      NAMES
d67cff5d6605   factorizer-1.0.0_image "java -jar /opt/app/…"       Exited (0)  factorizer_container
```

Since the container only runs the Java application, it exits immediately after
execution and does not need to be stopped. It is in an *"Exited"* status.


&nbsp;

---
### Step 4) Run *Container*

Start the container.

The `-ai` option attaches the terminal for stdin/stdout to see output.

```sh
# start container with -ai attached terminal for output
docker start -ai factorizer_container
```

Output:

```
Hello, Factorizer
n=12
 - factorized: [2, 2, 3]
```

Attach an interactive shell to the container to explore what is inside
(we actually create another container instance with `docker run` that gets
removed after exit with `--rm`):

```sh
# attach shell to the container
docker run --rm -it factorizer-1.0.0_image /bin/sh
```

A shell process (`/bin/sh`) running inside the the container prompts
for commands after `#`:

```sh
ls -la                      # release .jar is now in the Docker-packaging directory
```

Directories in the root directory `/` in the container:

```
total 72
drwxr-xr-x    1 root     root          4096 May 16 20:55 .
drwxr-xr-x    1 root     root          4096 May 16 20:55 ..
-rwxr-xr-x    1 root     root             0 May 16 20:55 .dockerenv
drwxr-xr-x    2 root     root          4096 Mar 29  2023 bin
drwxr-xr-x    5 root     root           360 May 16 20:55 dev
drwxr-xr-x    1 root     root          4096 May 16 20:55 etc
drwxr-xr-x    2 root     root          4096 Mar 29  2023 home
drwxr-xr-x    1 root     root          4096 May  5 17:54 lib
drwxr-xr-x    2 root     root          4096 May  5 17:54 lib64
drwxr-xr-x    5 root     root          4096 Mar 29  2023 media
drwxr-xr-x    2 root     root          4096 Mar 29  2023 mnt
drwxr-xr-x    1 root     root          4096 May 16 20:53 opt
dr-xr-xr-x  212 root     root             0 May 16 20:55 proc
drwx------    1 root     root          4096 May 16 20:55 root
drwxr-xr-x    2 root     root          4096 Mar 29  2023 run
drwxr-xr-x    2 root     root          4096 Mar 29  2023 sbin
drwxr-xr-x    2 root     root          4096 Mar 29  2023 srv
dr-xr-xr-x   12 root     root             0 May 16 20:55 sys
drwxrwxrwt    2 root     root          4096 Mar 29  2023 tmp
drwxr-xr-x    1 root     root          4096 May  5 17:54 usr
drwxr-xr-x    1 root     root          4096 Mar 29  2023 var
```

Navigate to the directory where [Dockerfile](Dockerfile) copied the `.jar`:

```sh
cd /opt/app
ls -la
```

The `.jar` file is there:

```
total 24
drwxr-xr-x    1 root     root          4096 May 16 20:53 .
drwxr-xr-x    1 root     root          4096 May 16 20:53 ..
-rwxr-xr-x    1 root     root          8238 May 16 20:25 factorizer-1.0.0-RELEASE.jar
```

Run the `.jar` file inside the container:

```sh
java -jar factorizer-1.0.0-RELEASE.jar n=136
```
```
Hello, Factorizer
n=136
 - factorized: [2, 2, 2, 17]
```

Test Java-Version:

```sh
java --version
```

The container has *OpenJDK* Java, not Oracle's Java in Version 11 (Code compiled
with Java version higher than 11 will cause a *class version error* and not run).

```
openjdk 11.0.23 2024-04-16
OpenJDK Runtime Environment Temurin-11.0.23+9 (build 11.0.23+9)
OpenJDK 64-Bit Server VM Temurin-11.0.23+9 (build 11.0.23+9, mixed mode)
```


&nbsp;

---
### Step 5) Clean-up

Removing containers and images keeps the environment clean.

Any container and any image should be deletable and reconstructable at any time.
Therefore, images and containers can be removed at any time (and reconstructed
when needed).

Remove the container first:

```sh
docker rm factorizer_container
```

Then remove the image:

```sh
docker image rm factorizer-1.0.0_image
or:
docker rmi factorizer-1.0.0_image
```


&nbsp;

---
### Step 6) Final Demonstration

Rebuild the container to demonstrate the assignment in class:

```sh
# rebuild docker image
docker build -t factorizer-1.0.0_image --no-cache .

# create transient (--rm) container and attach interactive shell process (-it)
docker run --rm -it factorizer-1.0.0_image /bin/sh

# run inside container:
java -jar /opt/app/factorizer-1.0.0-RELEASE.jar n=820
```
```
Hello, Factorizer
n=820
 - factorized: [2, 2, 5, 41]
```

The transient container (`--rm` - Option) was destroyed after exiting the
shell process.

```sh
# remove image
docker image rm factorizer-1.0.0_image
```
