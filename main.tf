resource "aws_launch_template" "Webservers_Nodes" {
  name          = "${var.env}-Webservers-app"
  image_id      = var.image_id
  instance_type = var.instance_type

  key_name = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }
  vpc_security_group_ids = [aws_security_group.amazon-linux.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Terraform   = "true"
      Environment = var.env
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Terraform   = "true"
      Environment = var.env
      Name        = "app"
    }
  }
  user_data           = base64encode(data.template_file.userdata.rendered)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "Webservers_Nodes" {
  name             = "${var.env}-Webserver-app"
  desired_capacity = 2
  max_size         = 2
  min_size         = 1
  termination_policies      = ["OldestInstance"]

  launch_template {
    id      = aws_launch_template.Webservers_Nodes.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = [aws_lb_target_group.Webserver.arn]

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
  //  health_check_grace_period = 300
  //  health_check_type         = "EC2"
}

resource "aws_security_group" "amazon-linux" {
  name        = "amazon-ec2-security-group"
  description = "Allow Custom TCP and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform"
  }
}

resource "aws_lb_target_group" "Webserver" {
  name     = "${var.env}-Webserver-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = 80
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = "200"  # has to be HTTP 200 or fails
  }

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}


resource "aws_lb" "this" {
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 600
  name                       = "${var.env}-app"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = var.subnet_ids

  tags = {
    Terraform         = "true"
    Environment       = var.env
  }
}

resource "aws_security_group" "lb" {
  name        = "${var.env}-app-lb"
  description = "ALB Security Groups"
  vpc_id      = var.vpc_id

  ingress {
    description = "Internal Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Internal Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Webserver.arn
  }
}