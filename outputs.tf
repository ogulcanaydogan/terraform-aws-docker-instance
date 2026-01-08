output "instance_ids" {
  description = "IDs of the created EC2 instances."
  value       = aws_instance.this[*].id
}

output "instance_public_ips" {
  description = "Public IPv4 addresses of the created EC2 instances."
  value       = aws_instance.this[*].public_ip
}

output "instance_private_ips" {
  description = "Private IPv4 addresses of the created EC2 instances."
  value       = aws_instance.this[*].private_ip
}

output "instance_public_dns" {
  description = "Public DNS names of the created EC2 instances."
  value       = aws_instance.this[*].public_dns
}

output "instance_private_dns" {
  description = "Private DNS names of the created EC2 instances."
  value       = aws_instance.this[*].private_dns
}

output "security_group_id" {
  description = "ID of the security group (null if using existing security groups)."
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_name" {
  description = "Name of the security group (null if using existing security groups)."
  value       = var.create_security_group ? aws_security_group.this[0].name : null
}

output "ami_id" {
  description = "AMI ID used for the instances."
  value       = local.ami_id
}

output "instance_arns" {
  description = "ARNs of the created EC2 instances."
  value       = aws_instance.this[*].arn
}
