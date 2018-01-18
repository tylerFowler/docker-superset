#!/bin/bash -ex

if [ $1 = "UP" ]; then
    /usr/local/bin/docker-compose pull
    /usr/local/bin/docker-compose up -d
elif [ $1 = "DOWN" ]; then
    /usr/local/bin/docker-compose stop
    /usr/local/bin/docker-compose rm --force -v
fi
