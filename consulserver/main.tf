# --- consul/main.tf  --- #

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "random_id" "maniak_consul_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "maniak_consult_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "maniak_consul" {
  count                  = var.instance_count
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.consul_sg]
  subnet_id              = var.public_subnets[count.index]
  key_name               = aws_key_pair.maniak_consult_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/consul.tpl",
    {
      consul_name    = "c${count.index}.maniak.academy"
      CONSUL_VERSION = "1.9.3"
      CONSUL_URL     = "https://releases.hashicorp.com/consul"
      local_ipv4     = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

    }
  )
  tags = {
    Name = "consul-${random_id.maniak_consul_id[count.index].dec}"

  }
}


resource "aws_route53_record" "consul0" {
  zone_id = var.host_zone_id
  name    = var.consul0_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul[0].private_ip]
}

resource "aws_route53_record" "externalconsult" {
  zone_id = var.host_zone_id
  name    = var.extconsul0_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul[0].public_ip]
}
