#!/bin/bash

#Get IP
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#Utils
sudo apt-get install unzip

#Download Consul

export CONSUL_VERSION="1.9.3"
export CONSUL_URL="https://releases.hashicorp.com/consul"

curl --silent --remote-name \
  ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

curl --silent --remote-name \
  ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS

curl --silent --remote-name \
  ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig

#Unzip the downloaded package and move the consul binary to /usr/bin/. Check consul is available on the system path.

unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/bin/

#The consul command features opt-in autocompletion for flags, subcommands, and arguments (where supported). Enable autocompletion.

consul -autocomplete-install
complete -C /usr/bin/consul consul

#Create a unique, non-privileged system user to run Consul and create its data directory.
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul



#Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul
Documentation=https://www.consul.io/
[Service]
ExecStart=/usr/bin/consul agent -server -ui -data-dir=/temp/consul -bootstrap-expect=1 -node=vault -bind=0.0.0.0 -config-dir=/etc/consul.d/
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/ui.json
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/ui.json

sudo cat << EOF > /etc/consul.d/ui.json
{
 "addresses": {
  "http": "0.0.0.0"
  }
}
EOF

sudo systemctl daemon-reload
sudo systemctl start consul
sudo systemctl enable consul

sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo apt-get update

#cert bot install 
sudo apt-get install certbot -y
#sudo certbot certonly --standalone -d c0.maniak.academy -m sebastian@maniak.io --agree-tos --eff-email


sudo apt  install jq -y