#TODO - Add SSL to YAML File w/ Letsencrypt cert or self-signed.

#!/bin/bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo apt install awscli -y
curl -O https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.2-rc1.tgz
tar xvf ./harbor-offline-installer-v1.8.2-rc1.tgz
cd ./harbor/
publicdns=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
sed -i "s/hostname: reg.mydomain.com/hostname: $publicdns/" harbor.yml
sudo ./install.sh --with-clair (e
