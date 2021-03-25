# -- load balancing/variables.tf --- 

variable "public_sg" {}
variable "public_subnets" {}
variable "vpc_id" {}
variable "tg_port" {}
variable "tg_protocol" {}
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "listener_port" {}
variable "listener_protocol" {}
variable "host_zone_id" {}
variable "domain_name" {}
variable "lb_record_name" {}
variable "zone_name" {}
