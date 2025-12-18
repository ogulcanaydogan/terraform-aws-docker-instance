variable "instance_type" {
  type = string
  description = "EC2 instance type to launch for the Docker host."
  default = "t2.micro"
}

variable "key_name" {
  type = string
  description = "Existing EC2 key pair name used to allow SSH access."
  default = "KeyPair"
}

variable "num_of_instance" {
  type = number
  description = "Number of EC2 instances to create."
  default = 1
}

variable "tag" {
  type = string
  description = "Name tag applied to created resources."
  default = "Docker-Instance"
}

variable "server-name" {
  type = string
  description = "Hostname assigned to the instance via user data."
  default = "docker-instance"
}

variable "docker-instance-ports" {
  type = list(number)
  description = "List of TCP ports to allow for inbound traffic to the instance security group."
  default = [22, 80, 8080]
}
