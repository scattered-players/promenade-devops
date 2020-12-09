#!/bin/bash -ex

show_short_name="${1:-mirrors}"

old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-show-arm\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-show-arm\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "image_type=show" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-janus-arm\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-janus-arm\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "image_type=janus" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-mongo-arm\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-mongo-arm\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "image_type=mongo" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-maestro-arm\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-maestro-arm\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "image_type=maestro" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-drone-arm\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-drone-arm\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "image_type=drone" -var "show_short_name=${show_short_name}" image.json &

wait