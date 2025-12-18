output "instance_public_ip" {
  description = "Public IPv4 addresses of the created EC2 instances."
  value = aws_instance.tfmyec2.*.public_ip
}

output "sec_gr_id" {
  description = "ID of the security group attached to the instances."
  value = aws_security_group.tf-sec-gr.id
}

output "instance_id" {
  description = "IDs of the created EC2 instances."
  value = aws_instance.tfmyec2.*.id
}
