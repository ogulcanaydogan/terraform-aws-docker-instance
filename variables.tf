variable "name" {
  description = "Name prefix for all resources created by this module."
  type        = string
  default     = "docker-instance"

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "name must be between 1 and 32 characters."
  }
}

variable "instance_type" {
  description = "EC2 instance type to launch for the Docker host."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*\\.[a-z0-9]+$", var.instance_type))
    error_message = "instance_type must be a valid EC2 instance type (e.g., t3.micro, m5.large)."
  }
}

variable "key_name" {
  description = "EC2 key pair name for SSH access. Set to null to disable SSH key."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "instance_count must be between 1 and 10."
  }
}

variable "hostname" {
  description = "Hostname assigned to the instance via user data."
  type        = string
  default     = "docker-host"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.hostname))
    error_message = "hostname must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "ingress_ports" {
  description = "List of TCP ports to allow for inbound traffic."
  type        = list(number)
  default     = [22, 80, 443]

  validation {
    condition     = alltrue([for p in var.ingress_ports : p >= 1 && p <= 65535])
    error_message = "All ports must be between 1 and 65535."
  }
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed for inbound traffic. Restrict this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.ingress_cidr_blocks) > 0
    error_message = "At least one CIDR block must be specified."
  }
}

variable "vpc_id" {
  description = "VPC ID where resources will be created. If null, uses default VPC."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance. If null, uses default subnet."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance."
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the instance."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 1000
    error_message = "root_volume_size must be between 8 and 1000 GB."
  }
}

variable "root_volume_type" {
  description = "Type of the root EBS volume (gp2, gp3, io1, io2)."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "root_volume_type must be one of: gp2, gp3, io1, io2."
  }
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root EBS volume."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring for the instance."
  type        = bool
  default     = false
}

variable "docker_compose_version" {
  description = "Docker Compose version to install (v2.x format, e.g., 2.24.0)."
  type        = string
  default     = "2.24.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.docker_compose_version))
    error_message = "docker_compose_version must be in semver format (e.g., 2.24.0)."
  }
}

variable "ami_id" {
  description = "Custom AMI ID. If null, uses latest Amazon Linux 2023."
  type        = string
  default     = null
}

variable "user_data_extra" {
  description = "Additional user data script to run after Docker installation."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "create_security_group" {
  description = "Whether to create a security group. Set to false to use existing security groups."
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "List of existing security group IDs to attach. Used when create_security_group is false."
  type        = list(string)
  default     = []
}
