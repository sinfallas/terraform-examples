terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "Región de AWS donde se desplegará la infraestructura"
  default = "us-west-1"
}

variable "rnombre" {
  type        = string
  description = "Nombre del runner"
}

variable "url" {
  type        = string
  description = "URL del repositorio"
}

variable "rtag" {
  type        = string
  description = "Tag del runner"
}

variable "rtoken" {
  type        = string
  description = "Token del repositorio"
}

variable "ubuntupass" {
  type        = string
  description = "Clave de usuario ubuntu"
}

variable "gitlabpass" {
  type        = string
  description = "Clave de usuario gitlab-runner"
}

variable "aws_vpc" {
  type        = string
  description = "id vpc"
}

variable "aws_subnet" {
  type        = string
  description = "id subnet"
}

variable "nombreinstancia" {
  type        = string
  description = "nombre instancia"
}

variable "nombregruposeguridad" {
  type        = string
  description = "nombre gruposeguridad"
}

variable "instancetype" {
  type        = string
  description = "tipo instancia"
}

variable "pemname" {
  type        = string
  description = "nombre pem"
}

variable "diskspace" {
  type        = string
  description = "espacio en disco"
}

data "aws_vpc" "existing_vpc" {
  id = var.aws_vpc
}

data "aws_subnet" "existing_subnet" {
  id = var.aws_subnet
}

data "aws_ami" "ubuntu_2604" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "docker_sg" {
  name        = var.nombregruposeguridad
  description = "Allow traffic"
  vpc_id      = data.aws_vpc.existing_vpc.id
  
  ingress {
    description = "entrada de ejemplo"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.1/32"]
  }

  egress {
    description      = "Permitir todo el trafico de salida (IPv4 e IPv6)"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "docker_server" {
  ami           = data.aws_ami.ubuntu_2604.id
  instance_type = var.instancetype
  key_name      = var.pemname
  subnet_id = data.aws_subnet.existing_subnet.id
  
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  
  root_block_device {
    volume_type = "gp3"
    volume_size = var.diskspace
  }
    
  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -x
              export DEBIAN_FRONTEND=noninteractive
              add-apt-repository ppa:sinfallas/stuff -y
              apt update
              apt -y install precicd
              inicio -i instalar
              echo "ubuntu:${var.ubuntupass}" | chpasswd
              echo "gitlab-runner:${var.gitlabpass}" | chpasswd
              inicio -g register '${var.rnombre}' '${var.url}' '${var.rtoken}' '${var.rtag}'
              EOF

  tags = {
    Name = var.nombreinstancia
  }
}

output "instance_public_ip" {
  value       = aws_instance.docker_server.public_ip
  description = "La IP pública de la instancia."
}

output "instance_private_ip" {
  value       = aws_instance.docker_server.private_ip
  description = "La IP privada de la instancia."
}
