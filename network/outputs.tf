# -- network/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.maniak_vpc.id
}
output "public_sg" {
  value = aws_security_group.maniak_sg["public"].id
}
output "bastion_sg" {
  value = aws_security_group.maniak_sg["bastion"].id
}
# output "public_subnets" {
#   value = aws_subnet.maniak_public_subnet.*.id
# }
output "consul_sg" {
  value = aws_security_group.maniak_sg["consul"].id
}
output "vault_sg" {
  value = aws_security_group.maniak_sg["vault"].id
}
# output "private_subnets" {
#   value = aws_subnet.maniak_private_subnet.*.id
# }
output "public_subnet1" {
  value = aws_subnet.maniak_public_subnet1.id
}
output "public_subnet2" {
  value = aws_subnet.maniak_public_subnet2.id
}
output "public_subnet3" {
  value = aws_subnet.maniak_public_subnet3.id
}