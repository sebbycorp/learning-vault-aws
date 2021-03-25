output "lb_target_group_arn" {
  value = aws_lb_target_group.vault-tg.arn
}
output "lb_endpoint" {
  value = aws_lb.vault-lb.dns_name
}
