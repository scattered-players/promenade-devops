#!/bin/bash -ex

show_short_name="${1:-mirrors}"
arch="${2:-arm64}"
[[ $arch = "arm64" ]] && instance_type="t4g.micro" || instance_type="t3a.micro"

old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-show-${arch}\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-show-${arch}\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "instance_type=${instance_type}" -var "arch=${arch}" -var "image_type=show" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-janus-${arch}\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-janus-${arch}\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "instance_type=${instance_type}" -var "arch=${arch}" -var "image_type=janus" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-mongo-${arch}\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-mongo-${arch}\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "instance_type=${instance_type}" -var "arch=${arch}" -var "image_type=mongo" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-maestro-${arch}\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-maestro-${arch}\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "instance_type=${instance_type}" -var "arch=${arch}" -var "image_type=maestro" -var "show_short_name=${show_short_name}" image.json &


old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-drone-${arch}\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-drone-${arch}\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi
packer build -var "instance_type=${instance_type}" -var "arch=${arch}" -var "image_type=drone" -var "show_short_name=${show_short_name}" image.json &

wait