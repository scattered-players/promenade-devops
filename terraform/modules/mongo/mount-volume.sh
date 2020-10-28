#!/bin/bash -ex

while [ -z `lsblk -f | grep xfs | awk '{ print $3 }'` ]; do
  echo "Waiting for volume to attach...";
  sleep 5;
done

device_id=`lsblk -f | grep xfs | awk '{ print $1 }'`
sudo mount "/dev/$device_id" /mnt/mongodb

EBS_UUID=$(sudo lsblk -f | grep xfs | awk '{ print $3}')
echo -e "UUID=\"${EBS_UUID}\" /mnt/mongodb xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab

sudo systemctl enable mongo

sudo reboot