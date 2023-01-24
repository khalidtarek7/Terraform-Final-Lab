resource "aws_instance" "proxy-1" {
 ami           = var.proxy1-ami
 instance_type = var.proxy1-instance-type
 associate_public_ip_address = true
 subnet_id = var.mysubnet1-id
 vpc_security_group_ids = [var.pubSecGroupId]
 key_name = "khalid"
 tags = {
    Name = "proxy1"
  }
 provisioner "local-exec" {
  when = create
   command = "echo public_ip1  ${self.public_ip} >> ./public_ip.txt"
 }
 connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("./ec2/khalid.pem")
      host = self.public_ip
    }

 provisioner "remote-exec" {
    inline = var.provisionerData
    
  }
}

resource "aws_instance" "proxy-2" {
 ami           = var.proxy2-ami
  instance_type = var.proxy2-instance-type
  associate_public_ip_address = true
  subnet_id = var.mysubnet2-id
  vpc_security_group_ids = [var.pubSecGroupId]
  key_name = "khalid"
  tags = {
    Name = "proxy2"
  }
  provisioner "local-exec" {
    when = create
   command = "echo public_ip2  ${self.public_ip} >> ./public_ip.txt"
 }
 connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("./ec2/khalid.pem")
      host = self.public_ip
    }

 provisioner "remote-exec" {
    inline = var.provisionerData
  }
}

resource "aws_instance" "private-ec2-1" {
 ami           = var.priv-ec2-1-ami
  instance_type = var.priv-ec2-1-instance-type
  associate_public_ip_address = false
  subnet_id = var.mysubnet3-id
  vpc_security_group_ids = [var.pubSecGroupId]
  tags = {
    Name = "apache1"
  }
  
  user_data = <<EOF
#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
apt-get update -y
apt-get install apache2 -y
EOF

}

resource "aws_instance" "private-ec2-2" {
 ami           = var.private-ec2-2-ami
  instance_type = var.priv-ec2-2-instance-type
  associate_public_ip_address = false
  subnet_id = var.mysubnet4-id
  vpc_security_group_ids = [var.pubSecGroupId]
  tags = {
    Name = "apache2"
  }
  
  user_data = <<EOF
#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
apt-get update -y
apt-get install apache2 -y
EOF
}

