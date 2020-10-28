#!/bin/bash -ex

device_id=`lsblk -o NAME,SIZE | grep '1G' |  awk '{ print $1 }'`
sudo mkfs -t xfs "/dev/$device_id"

sudo mkdir -p /mnt/mongodb
sudo chown 1000:1000 /mnt/mongodb
sudo mount "/dev/$device_id" /mnt/mongodb
sudo mkdir -p /mnt/mongodb/{data,log,journal}
sudo mkdir -p /mnt/mongodb/data/{db,configdb}