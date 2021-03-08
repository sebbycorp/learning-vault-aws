# learning-vault-aws

The following repo builds out my vault environment for learning how to deploy, configure and automate HashiCorp Vault

## Prerequisits
1. Access to AWS with permissions
2. Route 53 enabled with a valid domain 


## How to use this repo..
Clone/Download this code to your repo

```
git clone https://github.com/sebbycorp/learning-vault-aws.git
```

## Create a terraform.tfvars and fill in the following variables

```
access_ip       = "<local ip of my workstation>"
host_zone_id    = "<domain zone id>"
domain_name     = "<value>"
lb_record_name  = "<value>"
zone_name       = "<value>"
vault0_name     = "<value>"
vault1_name     = "<value>"
vault2_name     = "<value>"
consul0_name    = "<value>"
extconsul0_name = "<value>"
```


scp -i consul consul-agent-ca.pem dc1-server-consul-0.pem dc1-server-consul-0-key.pem ubuntu@consul2.maniak.academy:/etc/consul.d/