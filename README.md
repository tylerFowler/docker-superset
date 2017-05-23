Superset
===============

[![](https://images.microbadger.com/badges/image/tylerfowler/superset.svg)](https://microbadger.com/images/tylerfowler/superset "Get your own image badge on microbadger.com")

An extendable Docker image for Airbnb's [Superset](airbnb.io/superset) platform.

# Basic Setup

By default the Superset meta database will be stored in a local sqlite database, in the most basic case getting a working Superset instance up and running is as simple as:

```bash
docker run -d --name superset -p 8088:8088 tylerfowler/superset
```

The entrypoint script will set up an admin user for you using the `ADMIN_*` environment variables, with a default username and password of:

```
username: admin
password: superset
```

## Modifying Admin Credentials

The admin user is created in the entrypoint script using the `ADMIN_*` environment variables in the Dockerfile, which should be overriden.

```bash
docker run -d --name superset \
  -e ADMIN_USERNAME=myadminuser \
  -e ADMIN_FIRST_NAME=Some \
  -e ADMIN_LAST_NAME=Name \
  -e ADMIN_EMAIL=nobody@nowhere.com \
  -e ADMIN_PWD=mypassword \
  -p 8088:8088 \
tylerfowler/superset
```

## Modifying Database Backends

In order to keep the base image as lean as possible only the Postgres driver is included and any other database drivers or libraries that are needed should be installed in a downstream image. To use a different backend you just need to install the appropriate drivers and modify the `$SUP_META_DB_URI` to be the database connection string for the backend, which is only used in the entrypoint script at runtime.

## Modifying the Superset Configuration

The Superset config file is generated dynamically in the entrypoint script using the `SUP_*` environment variables, for example to increase the row limit to 10000 and the number of webserver threads to 16:

```bash
docker run -d --name superset \
  -e SUP_ROW_LIMIT=10000 \
  -e SUP_WEBSERVER_THREADS=16 \
  -p 8088:8088 \
tylerfowler/superset
```

## Advanced Configuration via Custom Entrypoint

In order to correctly set up Superset the entrypoint needs to be set the `superset-init.sh` script, though if a more advanced configuration is required you can also supply your own entrypoint script.

In your Dockerfile add any script as long as it ends up at `/docker-entrypoint.sh`. This script will be run *after* the initial `superset_config.py` is generated but before any of the Superset setup commands are ran. Note that the environment variables will still be used to bootstrap the Superset configuration file.

For example to add a Redis cache to your configuration:
```bash
#!/bin/bash

cat <<EOF >> $SUPERSET_HOME/superset_config.py
CACHE_CONFIG = {
  'CACHE_TYPE': 'RedisCache',
  'CACHE_REDIS_URL': 'localhost:6379'
}
EOF
```

After this is finished running Superset will continue to configure itself as normal. Alternately, if the init script detects that a `superset-config.py` file already exists under `$SUPERSET_HOME` then it will skip bootstrapping the file altogether and will use the user supplied config instead. Similarly after Superset is finished setting itself up (migrating the DB, initializing, creating admin user, etc...) it will write an empty file at `$SUPERSET_HOME/.setup-complete` so that subsequent runs on a mounted volume will not set up Superset from scratch. To take advantage of this fact simply mount the `$SUPERSET_HOME` directory (which is `/superset` by default).

```bash
docker run -d --name superset \
  -v /mysuperset:/superset \
  -p 8088:8088 \
tylerfowler/superset
```

Note, however, that even if an existing Superset configuration is detected, any user supplied `docker-entrypoint.sh` file will **still be run**. So if need be write a file that can be checked for to ensure your script only runs once in the same fashion that the `superset-init.sh` script does.

Enjoy!
