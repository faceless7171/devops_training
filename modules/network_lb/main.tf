resource "aws_lb_target_group" "main" {
  name     = "${var.name}-tg"
  port     = var.target_port
  protocol = "TCP"
  vpc_id   = var.vpc_id

  tags = merge({Name = "${var.name}-tg"}, var.tags)
}

resource "aws_lb_target_group_attachment" "all" {
  count = length(var.target_ids)

  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.target_ids[count.index]
  port             = var.target_port
}

resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  tags = merge({Name = var.name}, var.tags)
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}