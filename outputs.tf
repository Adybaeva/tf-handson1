output "vpc_id" {
  value = aws_vpc.batch-14-vpc.id
}
output "puclic_1a_subnet_id" {
  value = aws_subnet.puclic-subnet-1a.id
}

output "public-1a-ip" {
  value = aws_instance.public-1a-ec2.public_ip
}

output "puclic-1b-ip" {
  value = aws_instance.public-1b-ec2.public_ip
}