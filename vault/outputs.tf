output "instance_port" {
  value = aws_lb_target_group_attachment.vault_tg_attach[0].port
}
output "instance" {
  value     = aws_instance.maniak_vault[*]
  sensitive = true
}