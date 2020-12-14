#!/bin/bash -x

systemd-resolve --flush-caches
docker pull scatteredplayers/maestro:main
docker system prune -f
docker-compose up