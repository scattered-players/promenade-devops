#!/bin/bash -x

systemd-resolve --flush-caches
docker pull scatteredplayers/maestro:x86
docker system prune -f
docker-compose up