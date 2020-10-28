#!/bin/bash -ex

mkdir -p backups/latest
cd terraform
mongorestore --drop "$(terraform output mongo_connection_string)?authSource=admin" "../backups/latest"
