
output "mysubnet1-id" {
  value = aws_subnet.mysubnet1.id
}
output "mysubnet2-id" {
  value = aws_subnet.mysubnet2.id
}
output "mysubnet3-id" {
  value = aws_subnet.mysubnet3.id
}
output "mysubnet4-id" {
  value = aws_subnet.mysubnet4.id
}

output "pubSecGroupId" {
  value = aws_security_group.pub-secgroup.id
}


output "PrivDnsName" {
  value = aws_lb.private-lb.dns_name
}