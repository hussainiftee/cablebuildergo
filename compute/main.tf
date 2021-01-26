# -----
# --- Copmpute Main Module, to build ELB, ASG to manage application ec2 instance
# ----- 


/* In future we could use to encrypt with KMS CMK.
data "aws_kms_key" "alias" {
  key_id = "alias/cbg_ebs"
} */

data "aws_acm_certificate" "my_certificate" {
  domain = var.acm_domain_name
}

// Create the Launch configuration so that the ASG can use it to launch EC2 instances

resource "aws_launch_configuration" "asg_config" {
  name_prefix          = "CBG-App-Config-"
  image_id             = var.image_id
  instance_type        = var.asg_instance_type
  key_name             = var.ec2_key_name
  iam_instance_profile = var.iam_instance_profile
  user_data            = templatefile("./compute/tomcat_server_build.tmpl", { rds_address = var.rds_address, aws_region = var.aws_region })
  security_groups      = [var.app_sg_id]

  root_block_device {
    volume_type           = var.asg_vol_type
    volume_size           = var.asg_vol_size
    delete_on_termination = true
    encrypted             = true
    //kms_key_id            = data.aws_kms_key.alias.id
  }

  // --> Create New resources before destroying the old resources
  lifecycle {
    create_before_destroy = true
  }
}

# create a Target Group for your ASG

resource "aws_lb_target_group" "asg_tg" {
  name_prefix = "cbgASG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  stickiness {
    cookie_duration = 86400
    enabled         = true
    type            = "lb_cookie"
  }
}

# Creating AutoScaling Group

resource "aws_autoscaling_group" "cbg_asg" {
  name                      = "cablebuildergo-asg"
  launch_configuration      = aws_launch_configuration.asg_config.id
  vpc_zone_identifier       = var.app_subnet_id[*]
  health_check_grace_period = 300 // Time after instance comes into service before checking health.
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_size
  max_size                  = var.asg_max_size
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.asg_tg.arn]

  tag {
    key                 = "Name"
    value               = var.ec2_name_tag
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.tag_proj_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.tag_env
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


## Creating ELB

resource "aws_lb" "cbg_elb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.elb_sg_id]
  subnets            = var.elb_subnet_id[*]

  enable_deletion_protection = true

  tags = {
    Project     = var.tag_proj_name
    Environment = var.tag_env
  }

  /* Modify the belwo variables if you want to enable the ELB logging
 access_logs {
    enabled = true
  } */
}


# HTTP Listener to redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cbg_elb.arn // Amazon Resource Name (ARN) of the load balancer
    port              = 80
    protocol          = "HTTP"
  

  // By default, return a simple 404 page
  default_action {
    type = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.cbg_elb.arn // Amazon Resource Name (ARN) of the load balancer
  //port              = 80
  //protocol          = "HTTP"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.my_certificate.arn
  

  // By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
  
}


resource "aws_lb_listener_rule" "asg_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# ----- End.  