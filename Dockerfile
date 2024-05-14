# base image from https://hub.docker.com/_/nginx
FROM nginx

# copy files from host-system path html (contains index.html)
# into container under path: /usr/share/nginx/html
COPY html /usr/share/nginx/html
