resource "aws_lb" "this" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id

  tags = {
    Name                                           = "${var.project}-alb"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${var.project}-lb-target-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    healthy_threshold   = 2
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name                                           = "${var.project}-web-tg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

resource "aws_lb_target_group" "api" {
  name     = "${var.project}-lb-target-api"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    healthy_threshold   = 2
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name                                           = "${var.project}-api-tg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.this.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.api.arn
    type             = "forward"
  }
}
