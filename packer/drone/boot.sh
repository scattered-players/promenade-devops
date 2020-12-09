#!/bin/bash -x

systemd-resolve --flush-caches
docker pull scatteredplayers/drone:multiplatform
docker system prune -f
sudo modprobe ifb numifbs=1
docker-compose up