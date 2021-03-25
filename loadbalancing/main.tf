# -- load balancing/main.tf --- 

resource "aws_lb" "vault-lb" {
  name            = "vault-loadbalancer"
  subnets         = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout    = 400

}

resource "aws_lb_target_group" "vault-tg" {
  name     = "vault-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_healthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
    path                = "/v1/sys/health"
    protocol            = "HTTPS"
  }
}

resource "aws_lb_listener" "vault_lb_listener" {
  load_balancer_arn = aws_lb.vault-lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault-tg.arn
  }
  certificate_arn = aws_acm_certificate_validation.maniak.certificate_arn
}

resource "aws_acm_certificate" "maniak" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

data "aws_route53_zone" "maniak" {
  name         = var.zone_name
  private_zone = false
}

resource "aws_route53_record" "vault-cert" {
  zone_id = var.host_zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.vault-lb.dns_name]
}

resource "aws_route53_record" "maniak" {
  for_each = {
    for dvo in aws_acm_certificate.maniak.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.maniak.zone_id
}

resource "aws_acm_certificate_validation" "maniak" {
  certificate_arn         = aws_acm_certificate.maniak.arn
  validation_record_fqdns = [for record in aws_route53_record.maniak : record.fqdn]
}

