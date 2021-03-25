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

resource "aws_instance" "maniak_consul1" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.consul_sg]
  subnet_id              = var.public_subnet1
  key_name               = aws_key_pair.maniak_consult_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/consul.tpl",
    {
      consul_name    = "consul1.maniak.academy"
      CONSUL_VERSION = "1.9.3"
      CONSUL_URL     = "https://releases.hashicorp.com/consul"
      local_ipv4     = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

    }
  )
  tags = {
    Name = "consul1",
    Environment-Name = "consul-cluster"
  }
}

resource "aws_instance" "maniak_consul2" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.consul_sg]
  subnet_id              = var.public_subnet1
  key_name               = aws_key_pair.maniak_consult_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/consul.tpl",
    {
      consul_name    = "consul2.maniak.academy"
      CONSUL_VERSION = "1.9.3"
      CONSUL_URL     = "https://releases.hashicorp.com/consul"
      local_ipv4     = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

    }
  )
  tags = {
    Name = "consul2",
    Environment-Name = "consul-cluster"
  }
}

resource "aws_instance" "maniak_consul3" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.consul_sg]
  subnet_id              = var.public_subnet2
  key_name               = aws_key_pair.maniak_consult_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/consul.tpl",
    {
      consul_name    = "consul3.maniak.academy"
      CONSUL_VERSION = "1.9.3"
      CONSUL_URL     = "https://releases.hashicorp.com/consul"
      local_ipv4     = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

    }
  )
  tags = {
    Name = "consul3",
    Environment-Name = "consul-cluster"
  }
}

resource "aws_instance" "maniak_consul4" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.consul_sg]
  subnet_id              = var.public_subnet3
  key_name               = aws_key_pair.maniak_consult_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/consul.tpl",
    {
      consul_name    = "consul4.maniak.academy"
      CONSUL_VERSION = "1.9.3"
      CONSUL_URL     = "https://releases.hashicorp.com/consul"
      local_ipv4     = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

    }
  )
  tags = {
    Name = "consul4",
    Environment-Name = "consul-cluster"
  }
}


resource "aws_instance" "maniak_consul5" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [var.consul_sg]
  subnet_id              = var.public_subnet3
  key_name               = aws_key_pair.maniak_consult_auth.id
  root_block_device {
    volume_size = var.vol_size
  }
  user_data = templatefile("${path.module}/consul.tpl",
    {
      consul_name    = "consul5.maniak.academy"
      CONSUL_VERSION = "1.9.3"
      CONSUL_URL     = "https://releases.hashicorp.com/consul"
      local_ipv4     = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

    }
  )
  tags = {
    Name = "consul5",
    Environment-Name = "consul-cluster"
  }
}



resource "aws_route53_record" "consul1" {
  zone_id = var.host_zone_id
  name    = var.consul1_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul1.private_ip]
}


resource "aws_route53_record" "consul2" {
  zone_id = var.host_zone_id
  name    = var.consul2_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul2.private_ip]
}

resource "aws_route53_record" "consul3" {
  zone_id = var.host_zone_id
  name    = var.consul3_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul3.private_ip]
}

resource "aws_route53_record" "consul4" {
  zone_id = var.host_zone_id
  name    = var.consul4_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul4.private_ip]
}
resource "aws_route53_record" "consul5" {
  zone_id = var.host_zone_id
  name    = var.consul5_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul5.private_ip]
}




resource "aws_route53_record" "extconsult1" {
  zone_id = var.host_zone_id
  name    = var.extconsul1_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul1.public_ip]
}


resource "aws_route53_record" "extconsul2" {
  zone_id = var.host_zone_id
  name    = var.extconsul2_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul2.public_ip]
}

resource "aws_route53_record" "extconsul3" {
  zone_id = var.host_zone_id
  name    = var.extconsul3_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul3.public_ip]
}

resource "aws_route53_record" "extconsul4" {
  zone_id = var.host_zone_id
  name    = var.extconsul4_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul4.public_ip]
}
resource "aws_route53_record" "extconsul5" {
  zone_id = var.host_zone_id
  name    = var.extconsul5_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maniak_consul5.public_ip]
}



