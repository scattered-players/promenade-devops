#!/bin/bash

# Tear down infra for the show
cd terraform
terraform apply \
  -auto-approve