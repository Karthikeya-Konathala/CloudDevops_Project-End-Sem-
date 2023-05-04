provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
tags = {
    Name = "example-instance"
  }
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.example.public_ip},' playbook.yml"
  }
}

data "template_file" "ansible_playbook" {
  template = file("playbook.yml.tpl")
  vars = {
    docker_image = "nginx:latest"
  }
}

resource "local_file" "playbook" {
  content  = data.template_file.ansible_playbook.rendered
  filename = "playbook.yml"
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
