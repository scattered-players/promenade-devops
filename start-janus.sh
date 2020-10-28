#!/bin/bash

# Set up infra for local development
cd terraform
terraform apply \
  -auto-approve \
  -var 'run_janus=true' \
  -var 'janus_server_count=1'