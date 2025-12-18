# Terraform AWS Docker Instance

This module provisions Amazon Linux 2 EC2 instances with Docker installed and a security group that opens the ports you specify.
It is intended as an example module rather than a production-ready deployment.

## Requirements

- Terraform `>= 1.3.0`
- AWS provider `~> 4.0`
- AWS credentials with permissions to create EC2 instances and security groups.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "docker_instance" {
  source = "ogulcanaydogan/docker-instance/aws"
  # A semver tag such as v1.0.0 is recommended once published to the registry.

  key_name              = "KeyPair"
  instance_type         = "t3.micro"
  num_of_instance       = 1
  tag                   = "example-docker-instance"
  server-name           = "example-docker"
  docker-instance-ports = [22, 80, 8080]
}
```

## Inputs

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `docker-instance-ports` | List of TCP ports to allow for inbound traffic to the instance security group. | `list(number)` | `[22, 80, 8080]` |
| `instance_type` | EC2 instance type to launch for the Docker host. | `string` | `"t2.micro"` |
| `key_name` | Existing EC2 key pair name used to allow SSH access. | `string` | `"KeyPair"` |
| `num_of_instance` | Number of EC2 instances to create. | `number` | `1` |
| `server-name` | Hostname assigned to the instance via user data. | `string` | `"docker-instance"` |
| `tag` | Name tag applied to created resources. | `string` | `"Docker-Instance"` |

## Outputs

| Name | Description |
| --- | --- |
| `instance_id` | IDs of the created EC2 instances. |
| `instance_public_ip` | Public IPv4 addresses of the created EC2 instances. |
| `sec_gr_id` | ID of the security group attached to the instances. |

## Examples

See [`examples/minimal`](examples/minimal) for a minimal configuration that uses this module.

## Notes

- The module fetches the latest Amazon Linux 2 AMI that matches the filters in `main.tf`.
- Docker and Docker Compose are installed via user data on instance boot.
