#!/bin/bash -ex

show_short_name="${1:-mirrors}"

old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-show-x86\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-show-x86\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi

old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-janus-x86\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-janus-x86\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi

old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-mongo-x86\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-mongo-x86\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi

old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-maestro-x86\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-maestro-x86\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi

old_ami_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-drone-x86\")) | .[0].ImageId"`
echo $old_ami_id
if [[ $old_ami_id != 'null' ]]; then
  old_snapshot_id=`aws ec2 describe-images --owners self | jq -r ".Images | map(select(.Name == \"${show_short_name}-drone-x86\")) | .[0].BlockDeviceMappings[0].Ebs.SnapshotId"`
  aws ec2 deregister-image --image-id $old_ami_id
  aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
fi