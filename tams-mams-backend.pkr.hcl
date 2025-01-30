# packer/backend.pkr.hcl

source "amazon-ebs" "backend" {
  ami_name      = "mam-backend-smc-dev-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  ssh_username = "ubuntu"

  tags = {
    Environment = "smc-dev"
    Component   = "MAM Backend"
  }
}

build {
  sources = ["source.amazon-ebs.backend"]

  provisioner "file" {
    source      = "backend-init.sh"
    destination = "/tmp/init.sh"
  }

  provisioner "file" {
    source      = "mam-backend"
    destination = "/tmp/mam-backend"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir /opt/mam",
      "sudo chmod +x /tmp/init.sh",
      "sudo mv /tmp/mam-backend /opt/mam/",
      "sudo chmod +x /opt/mam/mam-backend",
      "sudo /tmp/init.sh"
    ]
  }
}
