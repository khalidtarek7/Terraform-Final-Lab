output "proxy1-id" {
  value = aws_instance.proxy-1.id
}
output "proxy2-id" {
  value = aws_instance.proxy-2.id
}

output "private-ec2-1" {
  value = aws_instance.private-ec2-1.id
}
output "private-ec2-2" {
  value = aws_instance.private-ec2-2.id
}