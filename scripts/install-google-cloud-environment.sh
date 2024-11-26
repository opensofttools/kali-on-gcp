#!/bin/bash -e

# Install google cloud environment

rm /etc/hostname

wget http://ftp.us.debian.org/debian/pool/main/j/json-c/libjson-c5_0.18+ds-1_amd64.deb
dpkg -i libjson-c5_0.18+ds-1_amd64.deb
rm libjson-c5_0.18+ds-1_amd64.deb


# https://salsa.debian.org/cloud-team/google-compute-image-packages

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
DIST=bookworm
sudo tee /etc/apt/sources.list.d/google-cloud.list << EOM
deb https://packages.cloud.google.com/apt google-compute-engine-${DIST}-stable main
deb https://packages.cloud.google.com/apt cloud-sdk-${DIST} main
EOM

sudo apt update


#Install google packages
#https://cloud.google.com/compute/docs/images/install-guest-environment#debian

sudo apt install -y google-cloud-packages-archive-keyring
sudo apt install -y google-compute-engine gce-disk-expand && systemctl enable google-disk-expand

# sudo systemctl enable google-startup-scripts.service
# sudo systemctl enable google-shutdown-scripts.service

# Downgrade opensshd (client and server) to match versions on OOB debian 10 gcp instance, and regenerate host keys

# wget http://ftp.us.debian.org/debian/pool/main/o/openssh/openssh-client_7.9p1-10+deb10u2_amd64.deb
# dpkg --force-confold -i openssh-client_7.9p1-10+deb10u2_amd64.deb
# 
# wget http://ftp.us.debian.org/debian/pool/main/o/openssh/openssh-sftp-server_7.9p1-10+deb10u2_amd64.deb
# dpkg -i openssh-sftp-server_7.9p1-10+deb10u2_amd64.deb
# 
# wget http://ftp.us.debian.org/debian/pool/main/o/openssh/openssh-server_7.9p1-10+deb10u2_amd64.deb
# rm -r /etc/ssh/ssh_host*
# rm /etc/ssh/sshd_config
# UCF_FORCE_CONFFMISS=1 dpkg --force-confmiss -i openssh-server_7.9p1-10+deb10u2_amd64.deb
# service ssh start
# service ssh reload
