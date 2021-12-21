
resource "aws_security_group" "instance_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_launch_template" "my_launch_template" {
  name_prefix            = "tf-lt"
  image_id               = data.aws_ami.linux_ami.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name               = var.key_pair

  tags = {
    Name        = "Bastion-Host"
    Environment = "Sandbox"
  }
}

resource "aws_autoscaling_group" "bar" {

  availability_zones = [for az in data.aws_availability_zones.azs.names : az]
  desired_capacity   = var.desired_size
  max_size           = var.max_size
  min_size           = var.min_size

  target_group_arns = [aws_lb_target_group.lb_tg.arn]

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
}

resource "aws_lb" "my_nlb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in data.aws_subnet_ids.default_subnets.ids : subnet]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "tf-example-lb-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = data.aws_vpc.default_vpc.id

  tags = {
    Name = "bastion-node"
  }
}

resource "aws_lb_listener" "bastion" {
  load_balancer_arn = aws_lb.my_nlb.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

