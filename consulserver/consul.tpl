#!/bin/bash

#Get IP
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#Utils
sudo apt-get install unzip
sudo hostnamectl set-hostname ${consul_name} 

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
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/server.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul server -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/server.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/server.hcl

sudo cat << EOF > /etc/consul.d/server.hcl
{
  "server": true,
  "node_name": ${consul_name},
  "advertise_addr": ${local_ipv4},
  "bind_addr": "{$local_ipv4}",
  "bootstrap_expect": 3,
  "client_addr": "0.0.0.0",
  "datacenter": "us-east-1",
  "data_dir": "/opt/consul/",
  "domain": "maniak.academy",
  "enable_script_checks": true,
    "dns_config": {
        "enable_truncate": true,
        "only_passing": true
    },
    "bootstrap_expect": 5,
    "enable_syslog": true,
    "encrypt": "9oxhbo+jUUi34tUe1XxdsgvfKK4TkmY3A=",
    "leave_on_terminate": true,
    "log_level": "INFO",
    "rejoin_after_leave": true,
    "retry_join": [
     "consul1.maniak.academy",
     "consul2.maniak.academy",
     "consul3.maniak.academy",
     "consul4.maniak.academy",
     "consul5.maniak.academy"

    ],
    "server": true,
    "start_join": [
     "consul1.maniak.academy",
     "consul2.maniak.academy",
     "consul3.maniak.academy",
     "consul4.maniak.academy",
     "consul5.maniak.academy"
    ],
    "ui": true
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