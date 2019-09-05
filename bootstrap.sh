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
cd /home/ubuntu
openssl genrsa -out ca.key 4096
  openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=US/ST=CA/L=Santacon/O=Jamie/OU=Personal/CN=Ihavenoideathisisharbor" \
    -key ca.key \
    -out ca.crt
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=Ihavenoideathisisharbor
DNS.2=Ihavenoideathisisharbor1
DNS.3=Ihavenoideathisisharbor3
EOF
 openssl genrsa -out yourdomain.com.key 4096
  openssl req -sha512 -new \
    -subj "/C=TW/ST=Taipei/L=Taipei/O=example/OU=Personal/CN=yourdomain.com" \
    -key yourdomain.com.key \
    -out yourdomain.com.csr 
  openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in yourdomain.com.csr \
    -out yourdomain.com.crt
openssl x509 -inform PEM -in yourdomain.com.crt -out yourdomain.com.cert
curl -O https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.2-rc1.tgz
tar xvf ./harbor-offline-installer-v1.8.2-rc1.tgz
cd ./harbor/
password=$(openssl rand -base64 32)
publicdns=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
rm -f ./harbor.yml
curl -O https://github.com/IAmATeaPot418/harborbootstrap/blob/master/harbor.yml
sed -i "s/hostname: reg.mydomain.com/hostname: $publicdns/" harbor.yml
sed -i "s/password: MyProductionDBPassword@123456/hostname: $password/" harbor.yml
sudo ./install.sh --with-clair
