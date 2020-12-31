
/*data "aws_kms_key" "alias" {
  key_id = "alias/cbg_ebs"
} */

// Create the Launch configuration so that the ASG can use it to launch EC2 instances

resource "aws_launch_configuration" "asg_config" {
  name_prefix   = "CBG-App-Config-"
  image_id = var.image_id
  instance_type = var.asg_instance_type
  key_name = "CableBuilderGo1"
  iam_instance_profile = var.iam_instance_profile
  user_data = templatefile("./compute/template/tomcat_server_build.tmpl", { rds_address = var.rds_address, aws_region = var.aws_region })
  security_groups = [var.app_sg_id]
  
  root_block_device {
    volume_type           = var.asg_vol_type
    volume_size           = var.asg_vol_size
    delete_on_termination = true
    encrypted = true
    //kms_key_id            = data.aws_kms_key.alias.id
  }
  
  // If the launch_configuration is modified:
  // --> Create New resources before destroying the old resources
  lifecycle {
    create_before_destroy = true
  }
}

// create a target group for your ASG

resource "aws_lb_target_group" "asg_tg" {
  name_prefix = "cbgASG"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  stickiness {
  cookie_duration = 86400
  enabled         = true
  type            = "lb_cookie"
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "cbg_asg" {
  name = "cablebuildergo-asg"
  launch_configuration = aws_launch_configuration.asg_config.id
  vpc_zone_identifier = var.app_subnet_id[*]
  health_check_grace_period = 300 // Time after instance comes into service before checking health.
  min_size = var.asg_min_size
  max_size = var.asg_max_size
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.asg_tg.arn]
 
  tag { 
    key = "Name"
    value = "CBG-Application-Server"
    
    propagate_at_launch = true
  }
 
  lifecycle {
  create_before_destroy = true
  }
}


## Creating ELB
resource "aws_lb" "cbg_elb" {
  name = "cablebuildergo"
  internal           = false
  load_balancer_type = "application"
  security_groups = [var.elb_sg_id]
  subnets  = var.elb_subnet_id[*]
   
  //enable_deletion_protection = true
  
 /* access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  } */
 } 

# 
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.cbg_elb.arn // Amazon Resource Name (ARN) of the load balancer
  port = 80
  protocol = "HTTP"
  
 /* port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4" 
  */

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
  listener_arn = aws_lb_listener.front_end.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }
      
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
