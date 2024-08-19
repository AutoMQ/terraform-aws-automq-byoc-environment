# main.tf

provider "aws" {
  region = var.cloud_provider_region
}

data "aws_vpc" "selected" {
  id = var.automq_byoc_vpc_id
}

# Obtain the specified version of ami id through the cloud market
locals {
  ssm_parameter_path = "/aws/service/marketplace/prod-nl2cyzygb46fw/${var.automq_byoc_env_version}"
}

data "aws_ssm_parameter" "marketplace_ami" {
  name = local.ssm_parameter_path
}

data "aws_ami" "marketplace_ami_details" {
  most_recent = true

  filter {
    name = "image-id"
    values = [data.aws_ssm_parameter.marketplace_ami.value]
  }
}

resource "aws_security_group" "allow_all" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [var.automq_byoc_env_console_cidr]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM role
resource "aws_iam_role" "automq_byoc_role" {
  name = "automq-byoc-service-role-${var.automq_byoc_env_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Create an IAM policy
resource "aws_iam_policy" "automq_byoc_policy" {
  name        = "automq-byoc-service-policy-${var.automq_byoc_env_id}"
  description = "Custom policy for automq_byoc service"

  policy = file("${path.module}/automq_byoc_policy.json")
}

# Attach strategies to roles
resource "aws_iam_role_policy_attachment" "automq_byoc_role_attachment" {
  role       = aws_iam_role.automq_byoc_role.name
  policy_arn = aws_iam_policy.automq_byoc_policy.arn
}

# Create an instance profile and bind a role
resource "aws_iam_instance_profile" "automq_byoc_instance_profile" {
  name = "automq-byoc-instance-profile-${var.automq_byoc_env_id}"
  role = aws_iam_role.automq_byoc_role.name
}

# Create an EC2 instance and bind an instance profile
resource "aws_instance" "web" {
  ami           = var.specified_ami_by_marketplace ? data.aws_ami.marketplace_ami_details.id : var.automq_byoc_env_console_ami
  instance_type = var.automq_byoc_ec2_instance_type
  subnet_id     = var.automq_byoc_env_console_public_subnet_id
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  iam_instance_profile = aws_iam_instance_profile.automq_byoc_instance_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "automq-byoc-console-${var.automq_byoc_env_id}"
  }

  user_data = <<-EOF
              #cloud-config
              bootcmd:
                - |
                  if [ ! -f "/home/admin/config.properties" ]; then
                    touch /home/admin/config.properties
                    echo "cmp.provider.credential=vm-role://${local.aws_iam_instance_profile_arn_encoded}@aws" >> /home/admin/config.properties
                    echo 'cmp.provider.databucket=${var.automq_byoc_data_bucket_name}' >> /home/admin/config.properties
                    echo 'cmp.provider.opsBucket=${var.automq_byoc_ops_bucket_name}' >> /home/admin/config.properties
                    echo 'cmp.provider.instanceSecurityGroup=${aws_security_group.allow_all.id}' >> /home/admin/config.properties
                    echo 'cmp.provider.instanceDNS=${aws_route53_zone.private.zone_id}' >> /home/admin/config.properties
                    echo 'cmp.provider.instanceProfile=${aws_iam_instance_profile.automq_byoc_instance_profile.arn}' >> /home/admin/config.properties
                    echo 'cmp.environmentId=${var.automq_byoc_env_id}' >> /home/admin/config.properties
                  fi
              EOF
}

# Create a Route53 private zone and bind it to the current VPC
resource "aws_route53_zone" "private" {
  name = "${var.automq_byoc_env_id}.automq.private"

  vpc {
    vpc_id = var.automq_byoc_vpc_id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "web_ip" {
  instance = aws_instance.web.id
}

# URL encoding instance_profile
locals {
  aws_iam_instance_profile_arn_encoded = urlencode(aws_iam_instance_profile.automq_byoc_instance_profile.arn)
}