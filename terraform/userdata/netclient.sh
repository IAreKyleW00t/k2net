#!/bin/bash
set -e # exit on any error

# Install AWS CLI
apt-get update
apt-get install -y zip unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /opt/awscliv2.zip
unzip /opt/awscliv2.zip -d /opt
/opt/aws/install
rm /opt/awscliv2.zip

# Install netclient
curl -fSsL "https://apt.netmaker.org/gpg.key" | tee /etc/apt/trusted.gpg.d/netclient.asc
curl -fSsL "https://apt.netmaker.org/debian.deb.txt" | tee /etc/apt/sources.list.d/netclient.list
apt-get update
apt-get install -y wireguard wireguard-tools netclient

# Join the network
netclient join -t "$(aws secretsmanager get-secret-value --region ${aws_region} --secret-id ${netmaker_secret_id} --query SecretString --output text)"
