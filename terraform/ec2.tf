data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# quick and dirty user_data just to prove the health check works out
# of the box - replace this with your actual deploy/bootstrap script
# (or better, bake a custom AMI with Packer and skip user_data almost
# entirely). Ubuntu's cloud-init runs this as root automatically on
# first boot, same as Amazon Linux.
locals {
  app_user_data = <<-EOT
    #!/bin/bash
    set -e
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y python3
    mkdir -p /opt/app
    cat > /opt/app/server.py << 'PYEOF'
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/health":
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"ok")
            else:
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"hello from ${var.project_name}")

    HTTPServer(("0.0.0.0", ${var.app_port}), Handler).serve_forever()
    PYEOF
    nohup python3 /opt/app/server.py > /var/log/app.log 2>&1 &
  EOT
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name != "" ? var.key_pair_name : null
  # heads up: SSH in as "ubuntu", not "ec2-user" like on Amazon Linux

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(local.app_user_data)

  metadata_options {
    http_tokens = "required" # IMDSv2 only, no reason to allow v1
  }

  block_device_mappings {
    device_name = data.aws_ami.ubuntu.root_device_name # /dev/sda1 on Ubuntu, not xvda
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  name_prefix         = "${var.project_name}-asg-"
  vpc_zone_identifier = aws_subnet.private[*].id
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity

  health_check_type         = "ELB"
  health_check_grace_period = 60

  target_group_arns = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# scale on CPU - nothing fancy, bump this later if you need
# request-count based scaling instead
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.project_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
