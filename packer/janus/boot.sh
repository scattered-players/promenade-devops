#!/bin/bash

docker system prune -f && docker rmi scatteredplayers/janus:x86
docker run --rm --network=host \
  -v /mnt/secret/letsencrypt:/etc/letsencrypt \
  -v /mnt/secret/janus-conf:/etc/janus \
  scatteredplayers/janus:x86