#!/bin/bash -ex

show_short_name="${1:-mirrors}"

old_volume_id=`aws ec2 describe-volumes --filters "Name=tag:PromenadeShow,Values=${show_short_name}" "Name=tag:PromenadeResourceType,Values=mongo_volume"  --query "Volumes[0].VolumeId" --output text`
echo $old_volume_id
if [[ $old_volume_id != 'None' ]]; then
  aws ec2 delete-volume --volume-id $old_volume_id
fi
packer build -var "show_short_name=${show_short_name}" mongo.json