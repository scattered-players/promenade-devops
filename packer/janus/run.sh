#!/bin/bash
close_it_down(){
    docker kill $(docker ps -aq)
}

trap "close_it_down" SIGINT
trap "close_it_down" SIGTERM

# docker run \
#     -p 80:80 \
#     -p 443:443 \
#     -p 8088:8088 \
#     -p 8089:8089 \
#     -p 7088:7088 \
#     -p 7889:7889 \
#     -p 8188:8188 \
#     -p 8989:8989 \
#     -p 7188:7188 \
#     -p 7989:7989 \
#     -p 20000-40000:20000-40000 \
#     -v /mnt/secret/letsencrypt:/etc/letsencrypt \
#     scatteredplayers/janus

docker system prune -f && docker rmi scatteredplayers/janus:x86
docker run --rm --network=host -v /mnt/secret/letsencrypt:/etc/letsencrypt scatteredplayers/janus:x86 &

wait