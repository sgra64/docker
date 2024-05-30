# use MySQL:8.4 base image as latest stable version
FROM docker.io/mysql:8.4

# must define root password as environment variable (here
# with empty password, which should not be in production)
ENV MYSQL_ALLOW_EMPTY_PASSWORD="yes"
ENV MYSQL_ROOT_PASSWORD=""

# define path to db_init.sql file inside container image
ARG DB_INIT_FILE=/docker-entrypoint-initdb.d/db_init.sql

# copy database init files into container (to /tmp)
COPY init_freerider_access.sql /tmp
COPY init_freerider_schema.sql /tmp
COPY sample_data.sql /tmp

# compound init files in db_init.sql used to initialize the
# MySQL database
RUN cat /tmp/init_freerider_access.sql /tmp/init_freerider_schema.sql >> $DB_INIT_FILE
