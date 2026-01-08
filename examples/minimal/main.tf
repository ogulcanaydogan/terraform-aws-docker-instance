terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "docker_instance" {
  source = "../.."

  name          = "example-docker"
  instance_type = "t3.micro"
  key_name      = "my-keypair" # Replace with your key pair name

  ingress_ports = [22, 80, 443]

  tags = {
    Environment = "example"
  }
}

output "instance_public_ip" {
  value = module.docker_instance.instance_public_ips
}

output "instance_id" {
  value = module.docker_instance.instance_ids
}
