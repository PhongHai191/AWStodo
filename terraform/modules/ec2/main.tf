# ── Bastion Host ──────────────────────────────────────────────────────────────
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
    Role = "bastion"
  }
}

# ── Web Server 1 (AZ1) ────────────────────────────────────────────────────────
resource "aws_instance" "web" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_app_subnet_ids[count.index]
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = var.key_name
  iam_instance_profile   = var.ec2_instance_profile

  associate_public_ip_address = false

  metadata_options {
    http_tokens = "required" 
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF
  )

  tags = {
    Name = "${var.project_name}-${var.environment}-web-${count.index + 1}"
    Role = "web"
  }
}

# ── ALB Target Group Attachments ──────────────────────────────────────────────
resource "aws_lb_target_group_attachment" "web" {
  count            = length(aws_instance.web)
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.web[count.index].id
  port             = 3000
}
