# -------------------Network----------------

module "network" {
  source = "./network"
  vpc-cidr = "10.0.0.0/16"
  subnet-cidr1 = "10.0.0.0/24"
  subnet-cidr2 = "10.0.2.0/24"
  subnet-cidr3 = "10.0.1.0/24"
  subnet-cidr4 = "10.0.3.0/24"
  destination_cidr = "0.0.0.0/0"
  Az1 = "us-east-1a"
  Az2 = "us-east-1b"
  proxy1Id = module.ec2.proxy1-id
  proxy2Id = module.ec2.proxy2-id
  privInstance1Id = module.ec2.private-ec2-1
  privInstance2Id = module.ec2.private-ec2-2
  
}


#-------------------EC2-------------------

module "ec2" {
  source = "./ec2"
  proxy1-ami = "ami-00874d747dde814fa"
  proxy1-instance-type = "t2.micro"
  proxy2-ami = "ami-00874d747dde814fa"
  proxy2-instance-type = "t2.micro"
  priv-ec2-1-ami = "ami-00874d747dde814fa"
  priv-ec2-1-instance-type = "t2.micro"
  private-ec2-2-ami = "ami-00874d747dde814fa"
  priv-ec2-2-instance-type = "t2.micro"
  mysubnet1-id = module.network.mysubnet1-id
  mysubnet2-id = module.network.mysubnet2-id
  mysubnet3-id = module.network.mysubnet3-id
  mysubnet4-id = module.network.mysubnet4-id
  pubSecGroupId = module.network.pubSecGroupId
  provisionerData = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${module.network.PrivDnsName}; \n  } \n}' > default",
      "sudo mv default /etc/nginx/sites-enabled/default",
      "sudo systemctl stop nginx",
      "sudo systemctl start nginx"
  ]

}


