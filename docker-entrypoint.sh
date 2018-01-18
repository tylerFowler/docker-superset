#!/bin/bash

cat <<EOF >> $SUPERSET_HOME/superset_config.py
CACHE_CONFIG = {
  'CACHE_TYPE': 'RedisCache',
  'CACHE_REDIS_URL': 'localhost:6379'
}
EOF