Caravel
===============

An extendable Docker image for Airbnb's [Caravel](airbnb.io/caravel) platform.

# Basic Setup

By default the Caravel meta database will be stored in a local sqlite database, in the most basic case getting a working Caravel instance up and running is as simple as:

```bash
docker run -d --name caravel -p 8088:8088 tylerfowler/caravel
```

The entrypoint script will set up an admin user for you using the `ADMIN_*` environment variables, with a default username and password of:

```
username: admin
password: caravel
```

## Modifying Admin Credentials

The admin user is created in the entrypoint script using the `ADMIN_*` environment variables in the Dockerfile, which should be overriden.

```bash
docker run -d --name caravel \
  -e ADMIN_USERNAME=myadminuser \
  -e ADMIN_FIRST_NAME=Some \
  -e ADMIN_LAST_NAME=Name \
  -e ADMIN_EMAIL=nobody@nowhere.com \
  -e ADMIN_PWD=mypassword \
  -p 8088:8088 \
tylerfowler/caravel
```

## Modifying Database Backends

In order to keep this image as lean as possible only the chosen backend will have drivers installed. In order to do this the `$DB_PACKAGES` and `$DB_PIP_PACKAGES` can be changed to reflect whatever drivers are needed, though in the future this will be changed to a switch where you can specify something like `$CARAVEL_BACKEND=mysql` and `$CARAVEL_DATASOURCE_TYPE=postgres`.

For example to use mysql as the Caravel backend and allow us to use Postgres as our datasource:
```bash
docker run -d --name caravel \
  -e DB_PACKAGES="libmysqlclient-dev libpq-dev" \
  -e DB_PIP_PACKAGES="mysqlclient psycopg2" \
  -e CAR_META_DB_URI="mysql://user:pwd@host:port/db" \
  -p 8088:8088 \
tylerfowler/caravel
```

This will install only the packages needed for MySQL and Postgres.

## Modifying the Caravel Configuration

The Caravel config file is generated dynamically in the entrypoint script using the `CAR_*` environment variables, for example to increase the row limit to 10000 and the number of webserver threads to 16:

```bash
docker run -d --name caravel \
  -e CAR_ROW_LIMIT=10000 \
  -e CAR_WEBSERVER_THREADS=16 \
  -p 8088:8088 \
tylerfowler/caravel
```

## Advanced Configuration via Custom Entrypoint

In order to correctly set up Caravel the entrypoint needs to be set the `caravel-init.sh` script, though if a more advanced configuration is required you can also supply your own entrypoint script.

In your Dockerfile add any script as long as it ends up at `/docker-entrypoint.sh`. This script will be run *after* the initial `caravel_config.py` is generated but before any of the Caravel setup commands are ran. Note that the environment variables will still be used to bootstrap the Caravel configuration file.

For example to add a Redis cache to your configuration:
```bash
#!/bin/bash

cat <<EOF >> $CARAVEL_HOME/caravel_config.py
CACHE_TYPE = redis
CACHE_REDIS_HOST = myredishost.com
CACHE_REDIS_PORT = 6379
EOF
```

After this is finished running Caravel will continue to configure itself as normal. Alternately, if the init script detects that a `caravel-config.py` file already exists under `$CARAVEL_HOME` then it will skip bootstrapping the file altogether and will use the user supplied config instead. Similarly after Caravel is finished setting itself up (migrating the DB, initializing, creating admin user, etc...) it will write an empty file at `$CARAVEL_HOME/.setup-complete` so that subsequent runs on a mounted volume will not set up Caravel from scratch. To take advantage of this fact simply mount the `$CARAVEL_HOME` directory (which is `/caravel` by default).

```bash
docker run -d --name caravel \
  -v /mycaravel:/caravel \
  -p 8088:8088 \
tylerfowler/caravel
```

Note, however, that even if an existing Caravel configuration is detected, any user supplied `docker-entrypoint.sh` file will **still be run**. So if need be write a file that can be checked for to ensure your script only runs once in the same fashion that the `caravel-init.sh` script does.

Enjoy!
