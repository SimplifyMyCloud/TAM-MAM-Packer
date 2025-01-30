# packer/frontend.pkr.hcl

source "amazon-ebs" "frontend" {
  ami_name      = "mam-frontend-us-west2-{{timestamp}}"
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
    Component   = "MAM Frontend"
  }
}

build {
  sources = ["source.amazon-ebs.frontend"]

  provisioner "file" {
    source      = "frontend-init.sh"
    destination = "/tmp/init.sh"
  }

  provisioner "file" {
    source      = "build"
    destination = "/tmp/build"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir /opt/mam-frontend",
      "sudo chmod +x /tmp/init.sh",
      "sudo mv /tmp/build /opt/mam-frontend/",
      "sudo /tmp/init.sh"
    ]
  }
}
