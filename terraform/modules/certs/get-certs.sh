#!/bin/bash -ex

sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install -y s3fs certbot

sudo mkdir -p /mnt/secret
# sudo chown 1000:1000 /mnt/secret
sudo s3fs "${show_short_name}-secret" -o iam_role="${show_short_name}-certs-role" /mnt/secret

# touch test.txt
# cp test.txt /mnt/secret/test.txt

sudo certbot certonly --standalone -m "${lets_encrypt_email}" -n --agree-tos --duplicate \
    -d "janus.${show_domain_name}" \
    -d "janus0.${show_domain_name}" \
    -d "janus1.${show_domain_name}" \
    -d "janus2.${show_domain_name}" \
    -d "janus3.${show_domain_name}" \
    -d "janus4.${show_domain_name}" \
    -d "janus5.${show_domain_name}" \
    -d "janus6.${show_domain_name}" \
    -d "janus7.${show_domain_name}" \
    -d "janus8.${show_domain_name}" \
    -d "janus9.${show_domain_name}"


sudo certbot certonly --standalone -m "${lets_encrypt_email}" -n --agree-tos --duplicate \
    -d "services.${show_domain_name}"

sudo cp -R /etc/letsencrypt /mnt/secret/letsencrypt