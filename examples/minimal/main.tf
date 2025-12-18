terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "docker_instance" {
  source = "../.."

  key_name              = "KeyPair"
  instance_type         = "t3.micro"
  num_of_instance       = 1
  tag                   = "example-docker-instance"
  server-name           = "example-docker"
  docker-instance-ports = [22, 80, 8080]
}
