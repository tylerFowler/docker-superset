FROM python:2.7-wheezy
MAINTAINER Tyler Fowler <tylerfowler.1337@gmail.com>

# Caravel setup options
ENV CARAVEL_VERSION 0.8.8
ENV CARAVEL_HOME /caravel
ENV CAR_ROW_LIMIT 5000
ENV CAR_WEBSERVER_THREADS 8
ENV CAR_WEBSERVER_PORT 8088
ENV CAR_SECRET_KEY 'thisismysecretkey'
ENV CAR_META_DB_URI "sqlite:///${CARAVEL_HOME}/caravel.db"
ENV CAR_CSRF_ENABLED True

ENV PYTHONPATH $CARAVEL_HOME:$PYTHONPATH

# admin auth details
ENV ADMIN_USERNAME admin
ENV ADMIN_FIRST_NAME admin
ENV ADMIN_LAST_NAME user
ENV ADMIN_EMAIL admin@nowhere.com
ENV ADMIN_PWD caravel

# by default only includes PostgreSQL because I'm selfish
ENV DB_PACKAGES libpq-dev
ENV DB_PIP_PACKAGES psycopg2

RUN apt-get update \
&& apt-get install -y build-essential libssl-dev libffi-dev $DB_PACKAGES

RUN pip install $DB_PIP_PACKAGES flask-appbuilder
RUN pip install caravel==$CARAVEL_VERSION

# remove build dependencies
RUN apt-get remove -y build-essential libffi-dev \
&& apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir $CARAVEL_HOME

COPY caravel-init.sh /caravel-init.sh
RUN chmod +x /caravel-init.sh

VOLUME $CARAVEL_HOME
EXPOSE 8088

# since this can be used as a base image adding the file /docker-entrypoint.sh
# is all you need to do and it will be run *before* Caravel is set up
ENTRYPOINT [ "/caravel-init.sh" ]
