#!/bin/bash -x

systemd-resolve --flush-caches
docker pull scatteredplayers/show:x86
docker system prune -f
# docker rmi -f scatteredplayers/show:x86
# docker rmi -f scatteredplayers/nginx:x86
docker-compose up