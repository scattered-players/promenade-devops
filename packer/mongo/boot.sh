#!/bin/bash -x

export MONGO_INITDB_ROOT_USERNAME=$(cat /mnt/secret/service-secrets/mongo-user)
export MONGO_INITDB_ROOT_PASSWORD=$(cat /mnt/secret/service-secrets/mongo-password)

docker pull mongo
docker system prune -f
docker-compose rm -v
docker-compose up