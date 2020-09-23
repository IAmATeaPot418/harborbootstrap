#!/bin/bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose ; sudo chmod +x /usr/local/bin/docker-compose
sudo apt install awscli -y
curl -O https://storage.googleapis.com/harbor-releases/release-2.1.0/harbor-offline-installer-v2.1.0.tgz
tar xvf ./harbor-offline-installer-v2.1.0.tgz
cd ./harbor/
mv harbor.yml.tmpl harbor.yml
publicdns=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=US/ST=CA/L=Santa Clara/O=example/OU=Personal/CN=$publicdns" \
 -key ca.key \
 -out ca.crt
openssl genrsa -out yourdomain.com.key 4096
openssl req -sha512 -new \
    -subj "/C=US/ST=CA/L=Santa Clara/O=example/OU=Personal/CN=$publicdns" \
    -key yourdomain.com.key \
    -out yourdomain.com.csr
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$publicdns
EOF
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in yourdomain.com.csr \
    -out yourdomain.com.crt
sudo mkdir /etc/docker/certs.d
sudo mkdir /etc/docker/certs.d/yourdomain.com
sudo mkdir /etc/docker/certs.d/$publicdns && sudo cp yourdomain.com.cert /etc/docker/certs.d/$publicdns/ && sudo cp yourdomain.com.key /etc/docker/certs.d/$publicdns/ && sudo cp ca.crt /etc/docker/certs.d/$publicdns/
sudo systemctl restart docker
sudo cp yourdomain.com.crt /usr/local/share/ca-certificates/yourdomain.com.crt 
sudo update-ca-certificates
mydirectory=$(pwd)
sed -i "s/certificate: \/your\/certificate\/path/certificate: \/home\/ubuntu\/harbor\/yourdomain.com.crt/" harbor.yml
sed -i "s/private_key: \/your\/private\/key\/path/private_key: \/home\/ubuntu\/harbor\/yourdomain.com.key/" harbor.yml
sed -i "s/hostname: reg.mydomain.com/hostname: $publicdns/" harbor.yml
sudo ./install.sh --with-clair

