#!/bin/bash -x

systemd-resolve --flush-caches
docker pull scatteredplayers/show:multiplatform
docker system prune -f
# docker rmi -f scatteredplayers/show:multiplatform
# docker rmi -f scatteredplayers/nginx:multiplatform
docker-compose up