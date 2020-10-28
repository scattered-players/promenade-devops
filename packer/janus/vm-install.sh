#!/bin/bash -ex

short_short_name=$1

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y docker-compose s3fs tmux

sudo usermod -aG docker $USER

sudo mkdir -p /mnt/secret
sudo chown 1000:1000 /mnt/secret
echo "s3fs#${short_short_name}-secret /mnt/secret fuse _netdev,rw,uid=1000,gid=1000,allow_other,iam_role=${short_short_name}-janus-role" | sudo tee -a /etc/fstab

#sudo systemctl disable janus;
sudo cp janus.service /etc/systemd/system/janus.service;
sudo systemctl enable janus;

echo -e "./status.sh\n./status-feed.sh\n./monitor.sh\ntmux new-session  'htop' \\; split-window './status-feed.sh'" > /home/ubuntu/.bash_history

echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "0";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades

sudo DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confnew" -y upgrade