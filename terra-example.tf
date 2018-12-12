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
    command = "rm -f ${path.module}/cookbooks.tar.gz ; berks package ${path.module}/cookbooks.tar.gz --berksfile=Berksfile"
  }
}


provider "google" {
  credentials = "${file("/home/nickapos/.config/gcloud/legacy_credentials/nickapos@gmail.com/adc.json")}"
  region     = "europe-west2"
}

resource "google_compute_instance" "example" {
  project = "terraform-experiments"
  zone = "europe-west2-a"
  name = "tf-example"
  machine_type = "f1-micro"
  connection {
    type        = "ssh"
    agent       = true
    user        = "nickapos"
    port        = "22"
    timeout     = "5m"
    private_key = "${file("~/.ssh/google_compute_engine")}"
  }

  boot_disk {
    initialize_params {
      image="centos-7"
    }
  }

  network_interface {
   network = "default"
   access_config {
   }
 }


  provisioner "file" {
    source      = "${path.module}/cookbooks.tar.gz"
    destination = "/tmp/cookbooks.tar.gz"
  }
  provisioner "file" {
    content = "${data.template_file.vault-config.rendered}"
    destination = "/tmp/config.json"
  }

  provisioner "file" {
    content = "${data.template_file.dna.rendered}"
    destination = "/tmp/dna.json"
  }

  provisioner "remote-exec" {
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
