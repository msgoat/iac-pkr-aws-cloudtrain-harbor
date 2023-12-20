packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  ami_name = "CloudTrain-Harbor-${var.revision}-${legacy_isotime("20060102")}-${var.ami_architecture}-gp3"
  fully_qualified_version = "${var.revision}.${var.changelist}.${var.sha1}"
}

source "amazon-ebs" "harbor" {
  ami_name      = local.ami_name
  instance_type = var.ec2_instance_type
  region        = var.region_name
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      architecture        = "${var.ami_architecture}"
      name                = "al2023-ami-*"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["137112412989"] # Amazon
  }
  ssh_username = "ec2-user"
  launch_block_device_mappings {
    device_name = "/dev/xvda"
    encrypted = true
    volume_type = "gp3"
    volume_size = 8
    delete_on_termination = true
  }
  tags = {
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Department    = "Automotive Academy"
    Extra         = "<no value>"
    Maintainer    = "Michael Theis (msg)"
    OS_Version    = "Amazon Linux 2023"
    Organization  = "msg systems ag"
    Project       = "CloudTrain"
    Release       = "Latest"
    Name          = local.ami_name
    Version       = local.fully_qualified_version
  }
}

build {
  sources = ["source.amazon-ebs.harbor"]

  provisioner "file" {
    sources = [
      "./resources/harbor.yml",
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    env = {
      AMI_ARCHITECTURE = var.ami_architecture
      HARBOR_VERSION = var.harbor_version
    }
    scripts = [
      "./scripts/00_init.sh",
      "./scripts/01_install_docker.sh",
      "./scripts/02_install_awscli2.sh",
      "./scripts/04_install_harbor.sh",
    ]
  }

}

variable region_name {
  description = "AWS region name"
  type        = string
  default     = "eu-west-1"
}

variable revision {
  description = "Revision number (major.minor.path) of the AMI"
  type        = string
}

variable changelist {
  description = "Branch name"
  type        = string
  default     = "local"
}

variable sha1 {
  description = "Short commit hash of code base"
  type        = string
  default     = "12345678"
}

variable ami_architecture {
  description = "Processor architecture of the AMI, allowed values are `x86_64` or `arm64`"
  type        = string
  # default     = "arm64"
  default     = "x86_64"
}

variable ec2_instance_type {
  description = "EC2 instance type name"
  type        = string
  # default     = "t4g.small"
  default     = "t3.small"
}

variable harbor_version {
  description = "Harbor version number"
  type        = string
  default     = "v2.10.0"
}
