#!/bin/bash -ex

# Setup terraform
cd terraform
terraform init

# Setup the base infrastructure, get SSL certs, format mongo volume
terraform apply \
  -auto-approve \
  -var 'run_cert_service=true'

SHOW_SHORT_NAME=$(terraform output show_short_name)
  
# Break down un-needed infra from that first pass
terraform apply \
  -auto-approve

# Build AMIs
cd ../packer
./create-amis.sh $SHOW_SHORT_NAME
./create-mongo-volume.sh $SHOW_SHORT_NAME

# Set up infra for the show
cd ../terraform
terraform apply \
  -auto-approve \
  -var 'run_show=true'

./get-admin-url.sh