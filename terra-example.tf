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
}
resource "aws_key_pair" "access" {
  key_name   = "access-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMmzGTmPORmgBzfCRAIovee7xN002ibY71RUwDoS0uX/Qo+E+ni3zrX/HfggXEIjMiWvyQaKJP/Un5gicXp7nmRKBQqvPViIPNPWN4Gh2kv7ISQR0hNsla5qzjK1WngkpfGq03obET6oKMu0RrrYswGex0cyO+9MHbIjsORYydqj4Lt+plIa6+48nVsixm6neWgoW0OEzfpcMhSCMovjXuCa2JzUEBuunQ1v9UcVcppPPtTTPdLtm0qXERGi4FVSWg3RYdgfn3/PkpIbTBgYYz+RuUpXudlT9pbsuPgAJ5X/QpCNJeLMgzW7wWMbJBMzdi1RXfzPjj5KGgJWxfTQmf nickapos@nickapos-TECRA-A11"
}
