## Build Personal Web-Site with *nginx* Container

A web-site needs a system that has an
[HTTP](https://en.wikipedia.org/wiki/HTTP)
(web-) server installed.
Apache [*httpd*](https://httpd.apache.org) has been the first, widely used
web-server. [*nginx*](https://www.nginx.com), ([nginx.org](https://nginx.org))
is a newer, also popular web-server
(see [usage statistics](https://w3techs.com/technologies/overview/web_server)).

Of course, a *nginx* can be natively installed and configured on a Linux-based
system (it does not run on *Windows*).

Alternatively, a pre-configured Docker image
[https://hub.docker.com/_/nginx](https://hub.docker.com/_/nginx)
can be used.

A simple web-site serves an HTML-file [html/index.html](html/index.html)
to show in a browser:

```html
<html>
  <head>
    <title>nginx</title>
  </head>
  <body>
    <h1>My personal Web Site</h1>
    About myself...
  </body>
</html>
```

File `index.html` must be placed under path `/usr/share/nginx/html` for *nginx*.


&nbsp;

### Approach 1: Web-Content inside Container

An small image *mywebsite-img* can be created and layered on the *nginx base image"
that contains the file at the proper location.

The following [Dockerfile](Dockerfile) is used to create this image:

```Dockerfile
# base image from https://hub.docker.com/_/nginx
FROM nginx

# copy files from host-system path html (contains index.html)
# into container under path: /usr/share/nginx/html
COPY html /usr/share/nginx/html
```

The image with name *mywebsite-img* is built from `Dockerfile`
assumed to be in the current (`.`) directory:

```sh
docker build -t mywebsite-img .
```

The base-image *nginx* is pulled from `Docker-Hub` and the new image layer
is created:

```
[+] Building 2.9s (8/8) FINISHED                                 docker:default
 => [internal] load .dockerignore                                          0.1s
 => => transferring context: 2B                                            0.0s
 => [internal] load build definition from Dockerfile                       0.0s
 => => transferring dockerfile: 245B                                       0.0s
 => [internal] load metadata for docker.io/library/nginx:latest            2.4s
 => [auth] library/nginx:pull token for registry-1.docker.io               0.0s
 => [internal] load build context                                          0.0s
 => => transferring context: 61B                                           0.0s
 => [1/2] FROM docker.io/library/nginx@sha256:8a8c4d7559ab1debb45c1b3ffef  0.1s
 => => resolve docker.io/library/nginx@sha256:8a8c4d7559ab1debb45c1b3ffef  0.1s
 => CACHED [2/2] COPY html /usr/share/nginx/html                           0.0s
 => exporting to image                                                     0.0s
 => => exporting layers                                                    0.0s
 => => writing image sha256:58cd99828c0367be5a939f4b39e58fdb9be1a924a2d95  0.0s
 => => naming to docker.io/library/mywebsite-img                           0.0s
```

A new container *mywebsite-container* can be created and started from the *mywebsite-img*:

```sh
docker run --name mywebsite-container -p 8080:80 -d mywebsite-img
```

The new container includes the runnig processes for *nginx* that serve
web-content on GET-requests from browsers. Internal *nginx* processes
(inside the container) listen on default HTTP-port `80`.
That (internal) port is mapped to port `8080` on the host system using
the `-p 8080:80` option.

Option `-d` means that the container will run permanently (as a *daemon*).

Pointing a browser at URL:

```
http://localhost:8080
```

will show the content from `index.html` in the browser:

```
My personal Web Site
About myself...
```

The container can be stopped and restarted:

```sh
docker stop container-nginx-mywebsite
docker start container-nginx-mywebsite
```

Changing content required that (interal) file `/usr/share/nginx/html/index.html`
is updated.

Attaching a shell process to the container can be used to get access to this file:

```sh
docker exec -it mywebsite-container sh
```
```
# cat /usr/share/nginx/html/index.html
```

Unfortunately, the *nginx* container is a minimal built (ca. 180MB) that does not
include editors.

VSCode can be used to attach a process to the container and open the file:

- Open the Docker tab (left), right-click the container and: *Attach Visual Studio Code*.
    This opens a new VSCode window. 

- Click *Open Folder* and select `/` as start directory. VSCode retrievs files from
    the container and shows them in the Editor panel.

- Navigate to path: `/usr/share/nginx/html` and open `index.html`.

- Update `index.html` and reload the page in the browser.


&nbsp;

### Approach 2: Web-Content mounted from Host-System

Alternatively to updating content inside the *nginx* container, content (file paths)
can be *mounted* from the host system into the container, where they appear as
regular directories.

To explore that option of a
[*bind-mount*](https://docs.docker.com/storage/bind-mounts),
the container and image need to be removed.

```sh
# stop container (processes) before container can be removed
docker stop mywebsite-container

# remove container
docker rm mywebsite-container

# remove image mywebsite-img
docker rm image mywebsite-img
```

Since web-content will be supplied from the host system and mounted into the container,
no new image layer needs to be created.

Instead, the new container is created from the base *nginx*-image with mount-paths using
the `--mount` or `-v` options (`-v` is older, only for *bind*-mounts).

Adjust `source`-path to where the `html`-directory resides.

```sh
docker run --name mywebsite-container \
    -p 8080:80 \
    -d \
    --mount type=bind,source="c:/Sven1/svgr/workspaces/docker/html",target="/usr/share/nginx/html" \
    nginx
```

Instead of the more general `--mount` option, the older `-v` option is often used for
*bind*-mounts:

```sh
    -v c:/Sven1/svgr/workspaces/docker/html:/usr/share/nginx/html:rw \
```

In this case, a newer version of the *nginx* image was available and got
loaded (this is always a possibility). When no version numbers are used,
the *latest* version of the *nginx* image is used - checked every time
a new container is created.

```
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
09f376ebb190: Already exists
a11fc495bafd: Already exists
933cc8470577: Already exists
999643392fb7: Already exists
971bb7f4fb12: Already exists
45337c09cd57: Already exists
de3b062c0af7: Already exists
Digest: sha256:dff52faf7d265f2822935e8dd9ab72764763b4e716f194fb6510ba87552d6d06
Status: Downloaded newer image for nginx:latest     <-- updated image loaded
c357d416b0a81d03a1275803dea106fd1540303260c3452c1acc7b5d2f9fb3a3
```

The container is running and *nginx* is serving content from the mounted path
from the host system.

Update file `html/index.html` in the host-system and reload the browser.


&nbsp;

### Docker-Compose


&nbsp;

### Clean-up

Docker allows to fully remove containers and images from the host system with
no traces left.

```sh
# stop container before container can be removed
docker stop mywebsite-container

# remove container
docker rm mywebsite-container

# remove image mywebsite-img and underlying nginx image
docker rm image mywebsite-img
docker rm image nginx

# since nginx also built upon other images that got loaded with nginx,
# dangling images may exist and can be removed as well
docker image prune -a
```


<!-- 
1. [Docker](                #1-docker)
2. [Getting Started](       #2-getting-started)

&nbsp;

## 1. Docker
 -->
