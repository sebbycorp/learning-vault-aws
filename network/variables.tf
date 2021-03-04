# -- network/variables --

variable "vpc_cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(any)

}

variable "private_cidrs" {
  type = list(any)
}
variable "public_sn_count" {
  type = number
}
variable "private_sn_count" {
  type = number
}
variable "max_subnets" {
  type = number

}
variable "access_ip" {
  type = string
}
variable "security_groups" {}


variable "public_subnet1" {
  type = string
}
variable "public_subnet3" {
  type = string
}
variable "public_subnet2" {
  type = string
}

variable "availability_zone1" {
  description = "aws region (default is us-east-1)"
  default     = "us-east-1a"
}
variable "availability_zone2" {
  description = "aws region (default is us-east-1b)"
  default     = "us-east-1b"
}
variable "availability_zone3" {
  description = "aws region (default is us-east-1c)"
  default     = "us-east-1c"
}

