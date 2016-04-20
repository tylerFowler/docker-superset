#!/bin/bash

set -eo pipefail

# check to see if the caravel config already exists, if it does skip to
# running the user supplied docker-entrypoint.sh, note that this means
# that users can copy over a prewritten caravel config and that will be used
# without being modified
echo "Checking for existing Caravel config..."
if [ ! -f $CARAVEL_HOME/caravel_config.py ]; then
  echo "No Caravel config found, creating from environment"
  touch $CARAVEL_HOME/caravel_config.py

  cat > $CARAVEL_HOME/caravel_config.py <<EOF
ROW_LIMIT = ${CAR_ROW_LIMIT}
WEBSERVER_THREADS = ${CAR_WEBSERVER_THREADS}
CARAVEL_WEBSERVER_PORT = ${CAR_WEBSERVER_PORT}
SECRET_KEY = '${CAR_SECRET_KEY}'
SQLALCHEMY_DATABASE_URI = '${CAR_META_DB_URI}'
CSRF_ENABLED = ${CAR_CSRF_ENABLED}
EOF
fi

# check for existence of /docker-entrypoint.sh & run it if it does
echo "Checking for docker-entrypoint"
if [ -f /docker-entrypoint.sh ]; then
  echo "docker-entrypoint found, running"
  chmod +x /docker-entrypoint.sh
  . docker-entrypoint.sh
fi

# set up Caravel if we haven't already
if [ ! -f $CARAVEL_HOME/.setup-complete ]; then
  echo "Running first time setup for Caravel"

  echo "Creating admin user ${ADMIN_USERNAME}"
  cat > $CARAVEL_HOME/admin.config <<EOF
${ADMIN_USERNAME}
${ADMIN_FIRST_NAME}
${ADMIN_LAST_NAME}
${ADMIN_EMAIL}
${ADMIN_PWD}
${ADMIN_PWD}

EOF

  /bin/sh -c '/usr/local/bin/fabmanager create-admin --app caravel < $CARAVEL_HOME/admin.config'

  rm $CARAVEL_HOME/admin.config

  echo "Initializing database"
  caravel db upgrade

  echo "Creating default roles and permissions"
  caravel init

  touch $CARAVEL_HOME/.setup-complete
fi

echo "Starting up Caravel"
caravel runserver
