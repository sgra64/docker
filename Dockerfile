# Mac with M1-Chip use: FROM --platform=linux/amd64 adoptopenjdk/openjdk11:alpine
FROM adoptopenjdk/openjdk11:alpine
# base image, https://hub.docker.com/r/adoptopenjdk/openjdk11

# create a new directory in the container: /opt/app
RUN mkdir /opt/app

# copy 'factorizer-1.0.0-RELEASE.jar' from the project directory into container: /opt/app
COPY factorizer-1.0.0-RELEASE.jar /opt/app

# define a command that executes when the container started with n=12
CMD ["java", "-jar", "/opt/app/factorizer-1.0.0-RELEASE.jar", "n=12"]
