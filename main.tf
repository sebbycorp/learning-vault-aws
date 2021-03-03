# -- root/main.tf --


module "network" {
  source           = "./network"
  vpc_cidr         = local.vpc_cidr
  access_ip        = var.access_ip
  private_sn_count = 3
  public_sn_count  = 3
  max_subnets      = 20
  security_groups  = local.security_groups
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  db_subnet_group  = true
}


module "bastion" {
  source          = "./bastion"
  instance_count  = "1"
  bastion_sg      = module.network.bastion_sg
  public_subnets  = module.network.public_subnets
  instance_type   = "t2.micro"
  vol_size        = "10"
  key_name        = "bastion"
  public_key_path = "c:/Users/sebbycorp/.ssh/bastion.pub"
  # user_data_path  = "${path.root}/userdata.tpl"

}

module "consulserver" {
  source          = "./consulserver"
  instance_count  = "1"
  consul_sg       = module.network.consul_sg
  private_subnets = module.network.private_subnets
  public_subnets  = module.network.public_subnets

  instance_type   = "t2.micro"
  vol_size        = "10"
  key_name        = "consul"
  public_key_path = "C:/Users/sebbycorp/.ssh/consul.pub"
  host_zone_id    = var.host_zone_id
  consul0_name    = var.consul0_name
  extconsul0_name = var.extconsul0_name

}

module "vault" {
  source              = "./vault"
  instance_count      = "3"
  vault_sg            = module.network.vault_sg
  public_subnets      = module.network.public_subnets
  instance_type       = "t2.micro"
  vol_size            = "10"
  key_name            = "vault"
  public_key_path     = "C:/Users/sebbycorp/.ssh/vault.pub"
  lb_target_group_arn = module.loadbalancing.lb_target_group_arn
  compute_tg_port     = "8200"
  host_zone_id        = var.host_zone_id
  vault0_name         = var.vault0_name
  vault1_name         = var.vault1_name
  vault2_name         = var.vault2_name
}

module "loadbalancing" {
  source                 = "./loadbalancing"
  public_sg              = module.network.public_sg
  public_subnets         = module.network.public_subnets
  vpc_id                 = module.network.vpc_id
  tg_port                = "8200"
  tg_protocol            = "HTTPS"
  lb_healthy_threshold   = "2"
  lb_unhealthy_threshold = "2"
  lb_timeout             = "2"
  lb_interval            = "30"
  listener_protocol      = "HTTPS"
  listener_port          = "443"
  host_zone_id           = var.host_zone_id
  domain_name            = var.domain_name
  lb_record_name         = var.lb_record_name
  zone_name              = var.zone_name
}