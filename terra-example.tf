variable "access_key" {}
variable "secret_key" {}
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "eu-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-00846a67"
  instance_type = "t2.micro"
  key_name= "ec2-keys"
}
