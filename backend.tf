terraform {
  backend "s3" {
    bucket         = "khalid-s3"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}