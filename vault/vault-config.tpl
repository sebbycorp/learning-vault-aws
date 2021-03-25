#!/bin/bash

#Get IP
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"



#Utils
sudo apt-get install unzip

sudo hostnamectl set-hostname ${vault_name} 

#Download Consul


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
ExecStart=/usr/bin/consul agent -server -ui -node=vault -bind=${local_ipv4} -config-dir=/etc/consul.d/
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl

sudo cat << EOF > /etc/consul.d/consul.hcl
{
}
EOF

sudo systemctl daemon-reload
sudo systemctl start consul
sudo systemctl enable consul


sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo apt-get update

sudo apt  install jq -y

#cert bot install 
sudo apt-get install certbot -y
sudo certbot certonly --standalone -d ${vault_name} -m sebastian@maniak.io --agree-tos --eff-email

fullchain.pem

#Install vault


export VAULT_VERSION="1.7.0"
export VAULT_URL="https://releases.hashicorp.com/vault"

curl --silent --remote-name \
  ${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

curl --silent --remote-name \
  ${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS

curl --silent --remote-name \
  ${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig

#Unzip the downloaded package and move the consul binary to /usr/bin/. Check consul is available on the system path.

unzip vault_${VAULT_VERSION}_linux_amd64.zip

#vault
sudo mv vault /usr/local/bin/
sudo chown root:root /usr/local/bin/vault

vault -autocomplete-install
complete -C /usr/local/bin/vault vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
sudo useradd --system --home /etc/vault.d --shell /bin/false vault

sudo mkdir --parents /etc/vault.d
sudo touch /etc/vault.d/vault.hcl
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl

sudo mkdir /opt/raft
sudo chown -R vault:vault /opt/raft


sudo cat << EOF > /etc/vault.d/vault.hcl
storage "consul" {
       address = "127.0.0.1:8500"
       path = "vault/"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  cluster_address  = "${vault_name}:8201"
  tls_disable = 0
  tls_cert_file = "/etc/letsencrypt/live/${vault_name}/fullchain.pem"
  tls_key_file = "/etc/letsencrypt/live/${vault_name}/privkey.pem"
}
cluster_addr  = "https://${vault_name}:8201"
api_addr =  "https://${vault_name}:8200"
ui = true
EOF



sudo cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault
Documentation=https://www.vault.io/

[Service]
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


export VAULT_ADDR="https://${vault_name}:8200"
export VAULT_SKIP_VERIFY=true


sudo systemctl daemon-reload
sudo systemctl start vault
sudo systemctl enable vault
sudo systemctl status vault
