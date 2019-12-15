resource "aws_lb_target_group" "public" {
  name     = "${var.name}-tg-public"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = merge({Name = "${var.name}-tg-public"}, var.tags)
}

resource "aws_lb_target_group_attachment" "public" {
  count = length(var.target_ids)

  target_group_arn = aws_lb_target_group.public.arn
  target_id        = var.target_ids[count.index]
  port             = 80
}

resource "aws_lb" "public" {
  name               = "${var.name}-lb-public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups_ids
  subnets            = var.subnet_ids

tags = merge({Name = "${var.name}-lb-public"}, var.tags)
}

resource "aws_lb_listener" "public_redirect" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_acm_certificate" "cert" {
  domain = var.certificate_domain
}

resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}