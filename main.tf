locals {
  ami_id             = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id
  security_group_ids = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids

  common_tags = merge(var.tags, {
    Name      = var.name
    ManagedBy = "terraform"
  })
}

# Amazon Linux 2023 AMI (used if ami_id not provided)
data "aws_ami" "amazon_linux_2023" {
  count       = var.ami_id == null ? 1 : 0
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Security Group
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.name}-sg"
  description = "Security group for ${var.name} Docker instance"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow TCP port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# EC2 Instance
resource "aws_instance" "this" {
  count = var.instance_count

  ami                         = local.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = local.security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile        = var.iam_instance_profile
  monitoring                  = var.enable_monitoring

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/userdata.sh", {
    hostname               = var.hostname
    docker_compose_version = var.docker_compose_version
    user_data_extra        = var.user_data_extra
  })

  tags = merge(local.common_tags, {
    Name = var.instance_count > 1 ? "${var.name}-${count.index + 1}" : var.name
  })

  lifecycle {
    ignore_changes = [ami]
  }
}
