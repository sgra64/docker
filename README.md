## Assignment DB1: Build FREERIDER_DB Database (MySQL)

This assignment will build a [MySQL](https://en.wikipedia.org/wiki/MySQL)
Database for the *freerider* car-sharing reservation service using Docker.

The [Entity-Relationship Diagram]()
shows the schema of the *freerider* database:

<img src="https://github.com/sgra64/docker/blob/markup/DB12-freerider/freerider_ERD.png?raw=true" alt="drawing" width="600"/>

---

### Challenges

- DB.1: [Databases Recap](#db1-databases-recap) - (5 Pts)

- DB.2: [Build MySQL Database Server](#db2-build-mysql-database-server) - (3 Pts)

- DB.3: [Build Simple Database](#db3-build-simple-database) - (2 Pts)

- DB.4: [Build *FREERIDER_DB* Database](#db4-build-freerider_db-database) - (5 Pts)


&nbsp;

### DB.1) Databases Recap

[MySQL](https://en.wikipedia.org/wiki/MySQL) is the 2nd-most popular Relational
Database Management System (RDBMS)
([statistics](https://www.statista.com/statistics/809750/worldwide-popularity-ranking-database-management-systems)).

A **Relational Database** organizes data into tables in which data can be related
to each other, e.g. *RESERVATION*'s belong to *CUSTOMER*'s.

- **Entity** represents a class of data objects that share a set of **Attributes**.
    Entities (objects) are stored as rows in a table (rows are also sometimes called
    *tuples*).

    Types of attributes in databases differ from types in programming languages:

    - 

- **Key** is an attribute (or a set of attributes) in a table that uniquely identifies
    each data object. **PRIMARY-KEY** is an attribute with soley that purpose and is
    often named *"ID"*. It is often assigned by the database that makes sure the ID is
    not used by other data objects.

    - numbers (e.g. type *long*) are efficient types for keys.

    - strings (e.g. type *VARCHAR*) can also be used, but are less efficient.

- **Relations** express connections between data across tables.
    Types of relations are:

    - **FOREIGN-KEY** relations, which are attributes in one table referring to a
        KEY-attribute in another table. Foreign keys represent **1 : n** relations,
        such as each *RESERVATION* belongs to one *CUSTOMER*.

    - **RELATIONSHIP-TABLES** represent **n : m** relations between two tables,
        such as between tables *PROFESSOR* and *STUDENT* when each professor has
        many students and each student has multiple professors.

        An *n : m* relationship is represented by a separate relationship table
        *PROFESSOR_STUDENT*, which as (at least) two *foreign keys*: *STUDENT_ID*
        pointing to a student in the *STUDENT* table and *PROFESSOR_ID* pointing
        to a professor in the *PROFESSOR* table.

- **Database-Schema** is the definition of the set of tables occuring in a database
    including all relations. The
    [relational model](https://en.wikipedia.org/wiki/Relational_model)
    was created by English computer scientist
    [Edgar F. Codd](https://en.wikipedia.org/wiki/Edgar_F._Codd) at IBM in 1969
    where all data is represented in terms of tuples, grouped into relations.

    Database schema contain table definitions: *CREATE_TABLE(...)*.

    - **Entity-Relationship Diagram (ERD)** is used to model database schemata.
        There are two types:

        - [Classic ERD](https://en.wikipedia.org/wiki/Entity-relationship_model),
            Peter Chen 1967, uses squares for entities and circles for attributes.
            It quickly becomes overloaded and is therefore rarely used today.

        - [Crow’s Foot Notation](https://vertabelo.com/blog/crow-s-foot-notation),
            Gordon Everest 1976 (Fifth IEEE Computing Conference) uses a more compact
            notation closer to a
            [UML Class Diagram](https://en.wikipedia.org/wiki/Class_diagram) and is
            therefore prefered today.

- **Transaction** in databases is a *"logical unit of work"* that yields a desired
    result.

    - *Read-transactions* (*queries*) do not change data.

    - *Write-transactions* (*insertions, updates, deletions*) change data.

    - *Singular SQL-statements* are executed as transactions.

    - *Multiple SQL-statements* can be treated as multiple, independent transations
        or can be grouped into one transaction using `START TRANSACTION`, `COMMIT`
        and `ROLLBACK` (see
        [MsSQL description](https://dev.mysql.com/doc/refman/8.0/en/commit.html)).

- **ACID** properties of relational databases describe assurances databases
    give:

    - **(A) Atomicity** -- is the assurance that a database operation is either
        fully executed or nothing has changed (there are no partial data changes).

    - **(C) Consistency** -- is the assurance that data is free of contradictions
        before and after a transaction. Examples of contradictions are: same *ID*
        used for different data objects, NULL *ID*, *FOREIGN-KEYS* with invalid
        values (no corresponding object).

        Consistency rules are described as *CONSTRAINTS* in SQL schema.

    - **(I) Isolation** -- is the assurance that concurrent or interleaved execution
        of transactions produces the expected result without interferences.

    - **(D) Durability** -- is the assurance that data is safely stored until
        deleted by a transaction regardless of system failures.

- **SQL** is the *Standard Query Language* for relational databases (refer to
    [www.w3schools.com/sql](https://www.w3schools.com/sql)).


&nbsp;

DB.1) Questions, tasks:

1. Write one sentence in German for each bold-marked term above.

1. Draw a (crow-foot) ERD that shows that a reservation can be paid in multiple
    installments (payments). For example, Eric has reserved a car for a week
    on Mallorca that costs 786€. Eric pays in three installments: 200€ upfront,
    550€ at pickup at the airport and the remaining 36€ for tolls and parking
    two weeks after return.

1. Define a query that lists Eric's payments for that reservation.

1. What is a [JOIN](https://en.wikipedia.org/wiki/Join_(SQL)) operation?

1. What is the difference between *"implicit"* and *"explicit"* JOIN?
    Which should be preferred?


&nbsp;

### DB.2) Build MySQL Database Server

Most *Database Management Systems (DBMS)* use a client-server model, and so
is MySQL:

- A *server process* called *mysqld* runs on a server machine, in this
    deployment in a Docker container.

- The *d* in *mysqld* stands for *daemon*-process, which is in Unix a
    continuously running process.
    
- Process *mysqld* is a network-service, which means it expects requests
    arriving at TCP-port:
    [3306](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers).

- Client processes such as the command-line client: *mysql* (no *d*) send
    database requests (SQL statements) to an `IP` address of the machine
    or container where the server process *mysqld* listens on port `3306`.

    The server process *mysqld* answers requests and sends results
    (the *"result set"*) back to the client. Command-line client: *mysql*
    then outputs results in the terminal.

*Building a database* means to install and configure the *mysqld* server
software on a machine and configure that the *mysqld* server gets started
when the system starts.

Manually [installing MySQL](https://dev.mysql.com/doc/refman/8.4/en/installing.html)
is possible, but not trivial.

Docker images exist for
[mysql](https://hub.docker.com/_/mysql)
that can be used to launch a container with a ready-to-go MySQL database.

A container can be created from that image that runs a *mysqld* server process
with no custom database. 

```sh
# create transient container named 'mysqld' from image 'mysql:8.4'
docker run --name mysqld-container -d --rm \
    -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
    -e MYSQL_ROOT_PASSWORD= \
    -p3306:3306 \
    mysql:8.4
```

Show the *mysqld* container is running:

```sh
docker ps       # show container is running
```
```
CONTAINER ID   IMAGE       CREATED     STATUS   PORTS                    NAMES
ea6cbabc15a7   mysql:8.4   a min ago   Up       0.0.0.0:3306->3306/tcp   mysqld-container
```

```sh
# show running processes inside container (with: mysqld)
docker top mysqld-container
```
```
UID            PID         PPID        C
STIME          TTY         TIME        CMD
19:15          ?           00:00:07    mysqld  <-- mysqld process
19:20          ?           00:00:00    bash
```

Start a new *bash* process in the container and *"attach"* its input/output
to the terminal:

```sh
docker exec -it mysqld-container bash
```
The prompt `bash-5.1#` of the *bash* process running inside the container appears:

```sh
bash-5.1# whoami
root
bash-5.1# pwd
/
bash-5.1# ls -la
...
```

Inside the container, the client-program *mysql* is available that can
be used to connect to the *mysqld* database server process:

```sh
bash-5.1# mysql --user=root     # log into database as 'root' user
```
```
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.4.0 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

Database (SQL) commands can be issued from the `mysql>` prompt (mind the `;` at the end):

```sh
mysql> show databases;
```

Only system databases are shown, there is no other database yet:

```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)
```

User and access information can be queried in the `mysql` table:

```sh
mysql> select * from mysql;
```
```
+-----------+------------------+
| host      | user             |
+-----------+------------------+
| %         | root             |
| localhost | mysql.infoschema |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
+-----------+------------------+
5 rows in set (0.00 sec)
```


&nbsp;

### DB.3) Build Simple Database

Create a new database `UNI`, switch to this database and create two
tables `PROFESSOR` and `STUDENT`:

```sh
mysql> create database UNI;
mysql> use UNI;
mysql> 
```

Tables can now be created and records filled in:

```sql
CREATE TABLE PROFESSOR (
  `ID` int AUTO_INCREMENT,
  `NAME` varchar(60) DEFAULT NULL,
  PRIMARY KEY (ID)
);

CREATE TABLE STUDENT (
  `ID` int AUTO_INCREMENT,
  `NAME` varchar(60) DEFAULT NULL,
  PRIMARY KEY (ID)
);

show tables;

INSERT INTO PROFESSOR (NAME) VALUES
    ('Graupner'), ('Meyer'), ('Lohmann')
;
INSERT INTO STUDENT (NAME) VALUES
    ('Brinkmann, C.'), ('Akyil, B.'), ('Albaryak, K.'), ('Bernier, A.'), ('Blenau, H.'), ('Bui, P.')
;
```

SQL-queries:

```sh
mysql> select * from PROFESSOR;
```
```
+----+----------+
| ID | NAME     |
+----+----------+
|  1 | Graupner |
|  2 | Meyer    |
|  3 | Lohmann  |
+----+----------+
```

```sh
mysql> select * from STUDENT;
```
```
+----+---------------+
| ID | NAME          |
+----+---------------+
|  1 | Brinkmann, C. |
|  2 | Akyil, B.     |
|  3 | Albaryak, K.  |
|  4 | Bernier, A.   |
|  5 | Blenau, H.    |
|  6 | Bui, P.       |
+----+---------------+
6 rows in set (0.00 sec)
```

<!-- Extend the database to store that:

- `Prof. Graupner` has students: `1, 3, 5, 2, 4, 6`

- `Prof. Meyer` has students: `2, 4, 6`

- `Prof. Lohmann` has students: `3, 4, 6, 1`

```sql
CREATE TABLE PROFESSOR_STUDENT (
  `ID` int AUTO_INCREMENT,
  `PROFESSOR_ID` int NOT NULL,
  `STUDENT_ID` int NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT PROFESSOR_ID FOREIGN KEY (PROFESSOR_ID) REFERENCES PROFESSOR (ID),
  CONSTRAINT STUDENT_ID FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT (ID)
);

INSERT INTO PROFESSOR_STUDENT (PROFESSOR_ID, STUDENT_ID) VALUES
    (1, 1), (1, 3), (1, 5), (1, 2), (1, 4), (1, 6),
    (2, 1), (2, 1), (2, 1),
    (3, 3), (3, 4), (3, 6), (3, 1);
```

Run a query that shows all students (names) of `Prof. Meyer`.

select STUDENT.NAME FROM STUDENT WHERE STUDENT.ID=PROFESSOR_STUDENT.STUDENT_ID
AND PROFESSOR.NAME='Prof. Meyer';

select STUDENT.NAME FROM STUDENT
INNER JOIN PROFESSOR_STUDENT ON PROFESSOR_STUDENT.STUDENT_ID=STUDENT.ID
INNER JOIN PROFESSOR_STUDENT ON PROFESSOR_STUDENT.PROFESSOR_ID=PROFESSOR.ID
-->

Database servers should be properly shut down from inside the server:

```sh
mysql> shutdown;
```

This command shuts down the database server and ends the container
(which was created as a *transient container* with `--rm`).


&nbsp;

### DB.4) Build *FREERIDER_DB* Database

Building a customized database that already has a schema built-in can be
achieved by creating an *image* with the *FREERIDER_DB* database.

Furthermore, containers should
[not hold data](https://developers.redhat.com/blog/2016/02/24/10-things-to-avoid-in-docker-containers).

In the previous *mysqld-container*, data of the database was stored
in an container-internal path: `/var/lib/mysql`, which resided in the
*r/w*-image associated with the container.

This *r/w*-image was lost with exiting the container and with it the
content of the database.

Therefore, data from the container-internal path `/var/lib/mysql`
must be mapped to a location outside the container, for which
Docker supports two methods:

- [bind mounts](https://docs.docker.com/storage/bind-mounts) and

- [volume mounts](https://docs.docker.com/storage/volumes).

[Bind mounts](https://docs.docker.com/storage/bind-mounts) link a directory
from the host system to a container-internal path. All files in the directory
in the host system are visible inside the container - and all changes made
in the container are visible in the host system.

The Problem with this approach is when host system and container use different
file systems such as Windows (host) and Linux (container). Differences can
cause data corruption and are hence not recommended.

[volume mounts](https://docs.docker.com/storage/volumes) link a
container-internal directory to an external data store (*"volume"*),
which is not accessible by the host filesystem directly.

Volume are under the control of Docker and not directly accessible by
the host system. Differences in file systems between host system and
container play no role.


&nbsp;

**Step 1: Create Volume to store Database Data**

A volume is created with:

```sh
docker volume create mysqld-vol
```

```sh
docker volume ls            # show new volume
```

```
DRIVER    VOLUME NAME
local     11a773607f72a260f90521bc15ffc32d9360cb9873bcd8ee2e5e2303e401deeb
local     caa11620dbcfe8f6692ddcedfdc753f4eb3240f85b0d7ed07085541cc4d0becd
local     mysqld-vol    <-- new volume
```


&nbsp;

**Step 2: Build Image for *freerider-mysqld* Container**

[Dockerfile](Dockerfile) describes additions performed in an underlying
`mysql` image that create the `FREERIDER_DB` database by 

```Dockerfile
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
```

Using this [Dockerfile](Dockerfile), the image named `freerider/mysqld-img:1.0`
for the *FREERIDER_DB* database server can be built (the command must be
executed in the directory where the Dockerfile resides):

```sh
docker build -t freerider-mysqld-img:1.0 --no-cache .
```

```
[+] Building 0.0s (0/0)  docker:default
2024/05/30 22:56:22 http2: server: error reading preface from client //./pipe/do
[+] Building 2.0s (10/10) FINISHED                               docker:default
 => [internal] load build definition from Dockerfile                       0.1s
 => => transferring dockerfile: 745B                                       0.0s
 => [internal] load metadata for docker.io/library/mysql:8.4               0.0s
 => [internal] load .dockerignore                                          0.0s
 => => transferring context: 2B                                            0.0s
 => CACHED [1/5] FROM docker.io/library/mysql:8.4                          0.0s
 => [internal] load build context                                          0.0s
 => => transferring context: 127B                                          0.0s
 => [2/5] COPY init_freerider_access.sql /tmp                              0.2s
 => [3/5] COPY init_freerider_schema.sql /tmp                              0.1s
 => [4/5] COPY sample_data.sql /tmp                                        0.2s
 => [5/5] RUN cat /tmp/init_freerider_access.sql /tmp/init_freerider_sche  0.5s
 => exporting to image                                                     0.4s
 => => exporting layers                                                    0.2s
 => => writing image sha256:334389640cbce38486863c521a464952dd3bade844bb6  0.0s
 => => naming to docker.io/library/freerider-mysqld-img:1.0                0.0s
```

Show the new image:

```sh
docker image ls freerider-mysqld-img:1.0
```
```
REPOSITORY             TAG       IMAGE ID       CREATED         SIZE
freerider-mysqld-img   1.0       fc7fb9738788   2 minutes ago   578MB
```


&nbsp;

**Step 3: Create *mysqld* Container from Image**

A new container with name `freerider-mysqld` can be created from the image:

- binding volume `mysqld-vol` to container-internal path `/var/lib/mysql` and

- mapping the container-internal port `3306` as external port accessible
    on the host system.

```sh
docker run --name freerider-mysqld -d \
    -p 3306:3306 \
    -v mysqld-vol:/var/lib/mysql \
    --restart unless-stopped \
    freerider-mysqld-img:1.0
```

The new container running *mysqld* can now be accessed, e.g.
by attaching a *bash* process:

```sh
docker exec -it freerider-mysqld bash
```

A user account for database *FREERIDER_DB* has been created with
[init_freerider_access.sql](init_freerider_access.sql) that was
built into the image.

```
bash-5.1# mysql --user=freerider --password=free.ride
```

```sh
mysql> show databases;
```
```
+--------------------+
| Database           |
+--------------------+
| FREERIDER_DB       |      <-- FREERIDER_DB is present
| information_schema |
| performance_schema |
+--------------------+
3 rows in set (0.01 sec)
```

```sh
mysql> use FREERIDER_DB;
mysql> show tables;
```
```
+------------------------+
| Tables_in_FREERIDER_DB |
+------------------------+
| CUSTOMER               |  <-- CUSTOMER table exists
+------------------------+
1 row in set (0.01 sec)
```

```sh
mysql> select * from CUSTOMER;
```
```
Empty set (0.00 sec)        <-- no CUSTOMER data yet
```

Customer data can be loaded from a file that was built into the
container in Dockerfile.

Quite mysql:
```sh
mysql> quit;

bash-5.1# cat /tmp/sample_data.sql
```
```
USE FREERIDER_DB;
DELETE FROM CUSTOMER;
INSERT INTO CUSTOMER (ID, NAME, CONTACT, STATUS) VALUES
    (1, 'Meyer, Eric', 'eme22@gmail.com', 'Active'),
    (2, 'Sommer, Tina', '030 22458 29425', 'Active'),
    (3, 'Schulze, Tim', '+49 171 2358124', 'Active')
;
```

Load that data into the database using the `mysql` client:

```sh
bash-5.1# cat /tmp/sample_data.sql | mysql --user=freerider --password=free.ride
```

Reopen the database and show data:

```sh
mysql> use FREERIDER_DB;
mysql> select * from CUSTOMER;
```
Customer data now show:

```
+----+--------------+-----------------+--------+
| ID | NAME         | CONTACT         | STATUS |
+----+--------------+-----------------+--------+
|  1 | Meyer, Eric  | eme22@gmail.com | Active |
|  2 | Sommer, Tina | 030 22458 29425 | Active |
|  3 | Schulze, Tim | +49 171 2358124 | Active |
+----+--------------+-----------------+--------+
3 rows in set (0.00 sec)
```


&nbsp;

**Step 4: Stop / (Re-) Start the Container**

Shutting down a database is always initiated by the database server
process with the `shutdown` command (requires `root` access):

Re-login as user `root` into the database server:

```sh
bash-5.1# /usr/sbin/mysqld stop     # properly shutdown mysql

bash-5.1# mysql --user=root         # or from within the database
mysql> shutdown;
```

To restart the container:

```sh
docker start freerider-mysqld
```

Repeat the query and show customers are still there:

```
+----+--------------+-----------------+--------+
| ID | NAME         | CONTACT         | STATUS |
+----+--------------+-----------------+--------+
|  1 | Meyer, Eric  | eme22@gmail.com | Active |
|  2 | Sommer, Tina | 030 22458 29425 | Active |
|  3 | Schulze, Tim | +49 171 2358124 | Active |
+----+--------------+-----------------+--------+
3 rows in set (0.00 sec)
```

Complete the schema in
[init_freerider_schema.sql](init_freerider_schema.sql)
for tables `VEHICLE` and `RESERVATION` based on the ER-Diagram
(remove comments and fill in attributes at the `@TODO` label).

You can experiment with the schema in the running database.

Adjust [sample_data.sql](sample_data.sql) to load data
for all tables.

When the schema is correct and data load:

- remove the volume

- rebuild the image and

- rebuild the volume and the container such that it now holds
    data for all three tables.


&nbsp;

```
mysql> select * from CUSTOMER;
+----+--------------+-----------------+--------+
| ID | NAME         | CONTACT         | STATUS |
+----+--------------+-----------------+--------+
|  1 | Meyer, Eric  | eme22@gmail.com | Active |
|  2 | Sommer, Tina | 030 22458 29425 | Active |
|  3 | Schulze, Tim | +49 171 2358124 | Active |
+----+--------------+-----------------+--------+
3 rows in set (0.00 sec)

mysql> select * from VEHICLE;
+------+----------+---------------+-------+----------+----------+----------+
| ID   | MAKE     | MODEL         | SEATS | CATEGORY | POWER    | STATUS   |
+------+----------+---------------+-------+----------+----------+----------+
| 1001 | VW       | Golf          |     4 | Sedan    | Gasoline | Active   |
| 1002 | VW       | Golf          |     4 | Sedan    | Hybrid   | Active   |
| 1200 | VW       | Multivan Life |     8 | Van      | Gasoline | Active   |
| 2000 | BMW      | 320d          |     4 | Sedan    | Diesel   | Active   |
| 3000 | Mercedes | EQS           |     4 | Sedan    | Electric | Active   |
| 6000 | Tesla    | Model 3       |     4 | Sedan    | Electric | Active   |
| 6001 | Tesla    | Model S       |     4 | Sedan    | Electric | Serviced |
+------+----------+---------------+-------+----------+----------+----------+
7 rows in set (0.00 sec)

mysql> select * from RESERVATION;
+--------+-------------+------------+---------------------+---------------------+----------------+----------------+----------+
| ID     | CUSTOMER_ID | VEHICLE_ID | BEGIN               | END                 | PICKUP         | DROPOFF        | STATUS   |
+--------+-------------+------------+---------------------+---------------------+----------------+----------------+----------+
| 145373 |           2 |       6001 | 2022-12-04 20:00:00 | 2022-12-04 23:00:00 | Berlin Wedding | Hamburg        | Inquired |
| 201235 |           1 |       1002 | 2022-12-20 10:00:00 | 2022-12-20 20:00:00 | Berlin Wedding | Berlin Wedding | Booked   |
| 351682 |           2 |       6000 | 2024-05-30 21:55:10 | 2024-05-30 23:55:10 | Berlin Wedding | Hamburg        | Inquired |
| 382565 |           2 |       3000 | 2022-12-18 18:00:00 | 2022-12-18 18:10:00 | Berlin Wedding | Hamburg        | Inquired |
| 682351 |           2 |       6000 | 2022-12-18 10:00:00 | 2022-12-18 16:00:00 | Potsdam        | Teltow         | Inquired |
+--------+-------------+------------+---------------------+---------------------+----------------+----------------+----------+
5 rows in set (0.00 sec)
```


&nbsp;

Refer to [known issues](KNOWN_ISSUES.md) for problems.
