# --- Vault/main.tf ---


data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "random_id" "maniak_vault_id" {
  byte_length = 1
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "maniak_vault_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "maniak_vault1" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.vault_sg]
  subnet_id              = var.public_subnet1
  key_name               = aws_key_pair.maniak_vault_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/vault-config.tpl",
    {
      vault_name    = "vault1.maniak.academy"
      VAULT_VERSION = "1.6.3"
      VAULT_URL     = "https://releases.hashicorp.com/vault"
      local_ipv4    = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
           CONSUL_URL="https://releases.hashicorp.com/consul"
      CONSUL_VERSION ="1.9.3"
    }
  )
  tags = {
    Name = "vault1",
        Environment-Name = "consul-cluster"

  }
}

resource "aws_instance" "maniak_vault2" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.vault_sg]
  subnet_id              = var.public_subnet2
  key_name               = aws_key_pair.maniak_vault_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/vault-config.tpl",
    {
      vault_name    = "vault2.maniak.academy"
      VAULT_VERSION = "1.6.3"
      VAULT_URL     = "https://releases.hashicorp.com/vault"
      CONSUL_URL="https://releases.hashicorp.com/consul"
      CONSUL_VERSION ="1.9.3"
      local_ipv4    = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
    }
  )
  tags = {
    Name = "vault2",
        Environment-Name = "consul-cluster"

  }
}


resource "aws_instance" "maniak_vault3" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.vault_sg]
  subnet_id              = var.public_subnet3
  key_name               = aws_key_pair.maniak_vault_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/vault-config.tpl",
    {
      vault_name    = "vault3.maniak.academy"
      VAULT_VERSION = "1.6.3"
      VAULT_URL     = "https://releases.hashicorp.com/vault"
      local_ipv4    = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
           CONSUL_URL="https://releases.hashicorp.com/consul"
      CONSUL_VERSION ="1.9.3"
    }
  )
  tags = {
    Name = "vault3",
    Environment-Name = "consul-cluster"
  }
}


# resource "aws_lb_target_group_attachment" "vault_tg_attach" {
#   count            = var.instance_count
#   target_group_arn = var.lb_target_group_arn
#   target_id        = aws_instance.maniak_vault[count.index].id
#   port             = var.compute_tg_port
# }


resource "aws_route53_record" "vault1" {
  zone_id = var.host_zone_id
  name    = var.vault0_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_vault1.public_ip]
}

resource "aws_route53_record" "vault2" {
  zone_id = var.host_zone_id
  name    = var.vault1_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_vault2.public_ip]
}
resource "aws_route53_record" "vault3" {
  zone_id = var.host_zone_id
  name    = var.vault2_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_vault3.public_ip]
}