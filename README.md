# terraform-aws-docker-instance

Terraform module that provisions EC2 instances with Docker and Docker Compose pre-installed. Uses Amazon Linux 2023 with configurable security groups, EBS volumes, and networking options.

## Features

- **Docker & Docker Compose v2** pre-installed and ready to use
- **Amazon Linux 2023** with latest security patches
- **Configurable security groups** with customizable ingress CIDR blocks
- **EBS encryption** enabled by default
- **VPC/subnet selection** for custom networking
- **IAM instance profile** support for AWS service access
- **Detailed monitoring** option for CloudWatch
- **Custom user data** support for additional setup

## Requirements

- Terraform `>= 1.5.0`
- AWS provider `>= 5.0`
- AWS credentials with permissions to create EC2 instances, security groups, and read AMIs

## Usage

### Basic Example

```hcl
module "docker_instance" {
  source = "ogulcanaydogan/docker-instance/aws"

  name     = "my-docker-host"
  key_name = "my-keypair"

  tags = {
    Environment = "development"
  }
}
```

### Production Example with VPC and Restricted Access

```hcl
module "docker_instance" {
  source = "ogulcanaydogan/docker-instance/aws"

  name          = "prod-docker-host"
  instance_type = "t3.medium"
  key_name      = "prod-keypair"

  # Network configuration
  vpc_id    = "vpc-12345678"
  subnet_id = "subnet-12345678"

  # Security - restrict SSH to your IP
  ingress_ports       = [22, 80, 443]
  ingress_cidr_blocks = ["10.0.0.0/8", "YOUR_IP/32"]

  # Storage
  root_volume_size      = 50
  root_volume_type      = "gp3"
  root_volume_encrypted = true

  # IAM role for AWS service access
  iam_instance_profile = "my-instance-profile"

  # Monitoring
  enable_monitoring = true

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

### Multiple Instances

```hcl
module "docker_workers" {
  source = "ogulcanaydogan/docker-instance/aws"

  name           = "docker-worker"
  instance_count = 3
  instance_type  = "t3.small"
  key_name       = "my-keypair"

  tags = {
    Role = "worker"
  }
}
```

### With Custom User Data

```hcl
module "docker_instance" {
  source = "ogulcanaydogan/docker-instance/aws"

  name     = "custom-docker-host"
  key_name = "my-keypair"

  user_data_extra = <<-EOF
    # Pull and run a container
    docker pull nginx:latest
    docker run -d -p 80:80 nginx:latest
  EOF
}
```

### Using Existing Security Groups

```hcl
module "docker_instance" {
  source = "ogulcanaydogan/docker-instance/aws"

  name     = "docker-host"
  key_name = "my-keypair"

  create_security_group = false
  security_group_ids    = ["sg-12345678", "sg-87654321"]
}
```

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| None | All variables have defaults | - |

### Instance Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name` | Name prefix for all resources | `string` | `"docker-instance"` |
| `instance_type` | EC2 instance type | `string` | `"t3.micro"` |
| `instance_count` | Number of instances to create | `number` | `1` |
| `key_name` | EC2 key pair name for SSH | `string` | `null` |
| `hostname` | Hostname for the instance | `string` | `"docker-host"` |
| `ami_id` | Custom AMI ID (uses Amazon Linux 2023 if null) | `string` | `null` |

### Networking

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `vpc_id` | VPC ID (uses default VPC if null) | `string` | `null` |
| `subnet_id` | Subnet ID (uses default subnet if null) | `string` | `null` |
| `associate_public_ip` | Associate public IP address | `bool` | `true` |

### Security

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_security_group` | Create a new security group | `bool` | `true` |
| `security_group_ids` | Existing security group IDs | `list(string)` | `[]` |
| `ingress_ports` | TCP ports to allow inbound | `list(number)` | `[22, 80, 443]` |
| `ingress_cidr_blocks` | CIDR blocks for inbound traffic | `list(string)` | `["0.0.0.0/0"]` |

### Storage

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `root_volume_size` | Root EBS volume size in GB | `number` | `20` |
| `root_volume_type` | Root EBS volume type | `string` | `"gp3"` |
| `root_volume_encrypted` | Encrypt root volume | `bool` | `true` |

### Docker

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `docker_compose_version` | Docker Compose version to install | `string` | `"2.24.0"` |
| `user_data_extra` | Additional user data script | `string` | `""` |

### Other

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `iam_instance_profile` | IAM instance profile name | `string` | `null` |
| `enable_monitoring` | Enable detailed CloudWatch monitoring | `bool` | `false` |
| `tags` | Additional tags for resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_ids` | IDs of the created EC2 instances |
| `instance_public_ips` | Public IPv4 addresses |
| `instance_private_ips` | Private IPv4 addresses |
| `instance_public_dns` | Public DNS names |
| `instance_private_dns` | Private DNS names |
| `instance_arns` | ARNs of the instances |
| `security_group_id` | ID of the created security group |
| `security_group_name` | Name of the created security group |
| `ami_id` | AMI ID used for instances |

## Security Considerations

- **Restrict `ingress_cidr_blocks`** in production - avoid `0.0.0.0/0` for SSH access
- **Use IAM instance profiles** instead of hardcoded credentials for AWS access
- **Enable EBS encryption** (enabled by default) for data at rest protection
- **Review security group rules** regularly and remove unused ports
- **Use private subnets** with NAT gateway for production workloads

## Connecting to Your Instance

```bash
# SSH into the instance
ssh -i ~/.ssh/your-key.pem ec2-user@<instance_public_ip>

# Check Docker status
sudo systemctl status docker

# Run a container
docker run hello-world

# Use Docker Compose
docker compose version
```

## Troubleshooting

Check the user data log for Docker installation issues:

```bash
sudo cat /var/log/userdata.log
```

## Examples

See [`examples/minimal`](examples/minimal) for a minimal configuration.

## Notes

- The module uses Amazon Linux 2023 by default (configurable via `ami_id`)
- Docker and Docker Compose v2 are installed via user data on first boot
- Instance AMI changes are ignored in lifecycle to prevent accidental recreation
