data "template_file" "dna" {
  template = "${file("chef-execution.json.tpl")}"
  vars {
    version = "0.11.4"
    address = "0.0.0.0"
    recipe = "hashicorp-vault::default"
  }
}
data "template_file" "vault-config" {
  template = "${file("config.json.tpl")}"
  vars {
    address = "0.0.0.0"
  }
}

# Package the cookbooks into a single file for easy uploading
resource "null_resource" "berks_package" {
  # asuming this is run from a cookbook/terraform directory
  provisioner "local-exec" {
    command = "rm -f ${path.module}/cookbooks.tar.gz ; berks package ${path.module}/cookbooks.tar.gz --berksfile=../Berksfile"
  }
}


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


  provisioner "file" {
    connection {
      type = "ssh"
      user = "centos"
      agent = "true"
      private_key = "${file("/home/nickapos/.ssh/ec2-keys.pem")}"
    }
    source      = "${path.module}/cookbooks.tar.gz"
    destination = "/tmp/cookbooks.tar.gz"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "centos"
      agent = "true"
      private_key = "${file("/home/nickapos/.ssh/ec2-keys.pem")}"
    }
    content = "${data.template_file.vault-config.rendered}"
    destination = "/tmp/config.json"
  }

  provisioner "file" {
    connection {
      type = "ssh"
      user = "centos"
      agent = "true"
      private_key = "${file("/home/nickapos/.ssh/ec2-keys.pem")}"
    }
    content = "${data.template_file.dna.rendered}"
    destination = "/tmp/dna.json"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "centos"
      agent = "true"
      private_key = "${file("/home/nickapos/.ssh/ec2-keys.pem")}"
    }
    inline = [
      "curl -LO https://www.chef.io/chef/install.sh && sudo bash ./install.sh",
      "sudo chef-solo --recipe-url /tmp/cookbooks.tar.gz -j /tmp/dna.json",
      "echo 'Creating vault data dir' && sudo mkdir /opt/vault-data && sudo chown vault:vault /opt/vault-data",
      "sudo mv /tmp/config.json /etc/vault/vault.json",
      "sudo systemctl restart vault"


    ]
  }
  depends_on = ["null_resource.berks_package"]
}
output "hostname" {
  value = "${aws_instance.example.public_dns}"
}
output "address" {
  value = "${aws_instance.example.public_ip}"
}
