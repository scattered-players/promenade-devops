#!/bin/bash -x

systemd-resolve --flush-caches
docker pull scatteredplayers/maestro:multiplatform
docker system prune -f
docker-compose up