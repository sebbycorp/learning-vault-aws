locals {
  vpc_cidr = "10.200.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "Security group for public access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

      }
    }
    bastion = {
      name        = "bastion_sg"
      description = "Security group for public access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }

      }
    }
    consul = {
      name        = "consul_sg"
      description = "Security group for public access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        nginx = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        dnstcp = {
          from        = 8600
          to          = 8600
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        dnsudp = {
          from        = 8600
          to          = 8600
          protocol    = "udp"
          cidr_blocks = [local.vpc_cidr]
        }
        HTTP = {
          from        = 8500
          to          = 8500
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        HTTPext = {
          from        = 8500
          to          = 8500
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        RPC = {
          from        = 8300
          to          = 8300
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        lanserfudp = {
          from        = 8301
          to          = 8301
          protocol    = "udp"
          cidr_blocks = [local.vpc_cidr]
        }
        lanserftcp = {
          from        = 8301
          to          = 8301
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        wanserfudp = {
          from        = 8301
          to          = 8301
          protocol    = "udp"
          cidr_blocks = [local.vpc_cidr]
        }
        wanserftcp = {
          from        = 8301
          to          = 8301
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
      }
    }
    vault = {
      name        = "vault_sg"
      description = "Security group for public access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        vaultapi = {
          from        = 8200
          to          = 8200
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        vaultrep = {
          from        = 8201
          to          = 8201
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}
