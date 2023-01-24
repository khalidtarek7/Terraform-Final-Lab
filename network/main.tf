#-----------------VPC & Subnets---------------------
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "mysubnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet-cidr1
  availability_zone = var.Az1
  tags = {
    Name = "public subnet 1"
  }

}
resource "aws_subnet" "mysubnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet-cidr2
  availability_zone = var.Az2
  tags = {
    Name = "public subnet 2"
  }
}
resource "aws_subnet" "mysubnet3" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet-cidr3
  availability_zone = var.Az1
  tags = {
    Name = "private subnet 1"
  }
}
resource "aws_subnet" "mysubnet4" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet-cidr4
  availability_zone = var.Az2
  tags = {
    Name = "private subnet 2"
  }
}
#----------------Routetables-----------------------
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "public route table"
  }
}
resource "aws_route" "igw-route" {
  route_table_id            = aws_route_table.pub-route.id
  destination_cidr_block    = var.destination_cidr
  gateway_id = aws_internet_gateway.internet-gw.id
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.pub-route.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.pub-route.id
}

resource "aws_route_table" "priv-route" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "private route table"
  }
}
resource "aws_route" "natgw-route" {
  route_table_id            = aws_route_table.priv-route.id
  destination_cidr_block    = var.destination_cidr
  gateway_id = aws_nat_gateway.nat-gw.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.mysubnet3.id
  route_table_id = aws_route_table.priv-route.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.mysubnet4.id
  route_table_id = aws_route_table.priv-route.id
}

#--------------------------Internet Gateway----------------------------------------

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "khalid igw"
  }
}

#----------------------------Nat Gateway-------------------------------------

resource "aws_eip" "eip" {
    vpc = true
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.mysubnet1.id

  tags = {
    Name = "khalid ngw"
  }

  depends_on = [aws_internet_gateway.internet-gw]
}

#-------------------------------Security Groups--------------------------------


resource "aws_security_group" "pub-secgroup" {
  name        = "pub-sec-group"
  description = "Allow HTTP traffic from anywhere"
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "public-secgroup"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#----------------------LoadBalancers--------------------
resource "aws_lb" "public-lb" {
  name               = "pub-lb"
  internal           = false
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pub-secgroup.id]
  subnets            = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]
  tags = {
    Name = "public-lb"
  }
}
resource "aws_lb_target_group" "pub-targetGroup" {
  name     = "pub-targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
  tags = {
    Name = "public-targetgroup"
  }
}
resource "aws_lb_target_group_attachment" "attach-proxy1" {
  target_group_arn = aws_lb_target_group.pub-targetGroup.arn
  target_id        = var.proxy1Id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-proxy2" {
  target_group_arn = aws_lb_target_group.pub-targetGroup.arn
  target_id        = var.proxy2Id
  port             = 80
}
resource "aws_lb_listener" "pub-listener" {
  load_balancer_arn = aws_lb.public-lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pub-targetGroup.arn
  }
}


resource "aws_lb" "private-lb" {
  name               = "priv-lb"
  internal           = true
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pub-secgroup.id]
  subnets            = [aws_subnet.mysubnet3.id, aws_subnet.mysubnet4.id]
  tags = {
    Name = "private-lb"
  }
}
resource "aws_lb_target_group" "priv-targetGroup" {
  name     = "priv-targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
  tags = {
    Name = "private-targetgroup"
  }
}
resource "aws_lb_target_group_attachment" "attach-priv1" {
  target_group_arn = aws_lb_target_group.priv-targetGroup.arn
  target_id        = var.privInstance1Id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-priv2" {
  target_group_arn = aws_lb_target_group.priv-targetGroup.arn
  target_id        = var.privInstance2Id
  port             = 80
}
resource "aws_lb_listener" "priv-listener" {
  load_balancer_arn = aws_lb.private-lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.priv-targetGroup.arn
  }
}

