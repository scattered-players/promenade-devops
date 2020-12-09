#!/bin/bash

# Set up infra for the show
cd terraform
terraform apply \
  -auto-approve \
  -var 'run_show=true'

sleep 15 

./get-admin-url.sh