#!/bin/bash -ex

mkdir -p backups
cd terraform
rm -fdr dump
backup_time=$(date --utc +%Y%m%d_%H%M%SZ)
mongodump --uri="$(terraform output mongo_connection_string)?authSource=admin" --out="../backups/${backup_time}"
cd ../backups
rm -fdr latest
cp -R $backup_time latest