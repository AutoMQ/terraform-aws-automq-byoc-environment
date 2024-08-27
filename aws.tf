provider "aws" {
  region = var.cloud_provider_region
}

# Conditional creation of data bucket
module "automq_byoc_data_bucket_name" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  create_bucket = var.automq_byoc_data_bucket_name == "" ? true : false
  bucket        = "automq-data-${var.automq_byoc_env_id}"
  force_destroy = true

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

# Conditional creation of ops bucket
module "automq_byoc_ops_bucket_name" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  create_bucket = var.automq_byoc_ops_bucket_name == "" ? true : false
  bucket        = "automq-ops-${var.automq_byoc_env_id}"
  force_destroy = true

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

data "aws_availability_zones" "available_azs" {}

module "automq_byoc_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  count = var.create_new_vpc ? 1 : 0
  cidr = "10.0.0.0/16"
  name = "automq-byoc-vpc-${var.automq_byoc_env_id}"

  azs             = slice(data.aws_availability_zones.available_azs.names, 0, 3)
  public_subnets  = ["10.0.0.0/20"]
  private_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  count = var.create_new_vpc ? 1 : 0

  description = "Security group for VPC endpoint"
  vpc_id      = module.automq_byoc_vpc[0].vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "automq-byoc-endpoint-sg-${var.automq_byoc_env_id}"
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

resource "aws_vpc_endpoint" "ec2_endpoint" {
  count = var.create_new_vpc ? 1 : 0

  vpc_id            = module.automq_byoc_vpc[0].vpc_id
  service_name      = "com.amazonaws.${var.cloud_provider_region}.ec2"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg[0].id]
  subnet_ids        = module.automq_byoc_vpc[0].private_subnets

  private_dns_enabled = true

  tags = {
    Name = "automq-byoc-ec2-endpoint-${var.automq_byoc_env_id}"
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  count = var.create_new_vpc ? 1 : 0

  vpc_id            = module.automq_byoc_vpc[0].vpc_id
  service_name      = "com.amazonaws.${var.cloud_provider_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    module.automq_byoc_vpc[0].public_route_table_ids,
    module.automq_byoc_vpc[0].private_route_table_ids
  )

  tags = {
    Name = "automq-byoc-s3-endpoint-${var.automq_byoc_env_id}"
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

locals {
  automq_byoc_vpc_id                       = var.create_new_vpc ? module.automq_byoc_vpc[0].vpc_id : var.automq_byoc_vpc_id
  automq_byoc_env_console_public_subnet_id = var.create_new_vpc ? element(module.automq_byoc_vpc[0].public_subnets, 0) : var.automq_byoc_env_console_public_subnet_id
  automq_data_bucket                       = var.automq_byoc_data_bucket_name == "" ? module.automq_byoc_data_bucket_name.s3_bucket_id : "${var.automq_byoc_data_bucket_name}-${var.automq_byoc_env_id}"
  automq_ops_bucket                        = var.automq_byoc_ops_bucket_name == "" ? module.automq_byoc_ops_bucket_name.s3_bucket_id : "${var.automq_byoc_ops_bucket_name}-${var.automq_byoc_env_id}"
}

data "aws_vpc" "vpc_id" {
  id = local.automq_byoc_vpc_id
}

locals {
  ssm_parameter_path = "/aws/service/marketplace/prod-nl2cyzygb46fw/${var.automq_byoc_env_version}"
}

data "aws_ssm_parameter" "marketplace_ami" {
  name = local.ssm_parameter_path
}

data "aws_ami" "marketplace_ami_details" {
  most_recent = true

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.marketplace_ami.value]
  }
}

resource "aws_security_group" "automq_byoc_console_sg" {
  vpc_id = data.aws_vpc.vpc_id.id

  name = "automq-byoc-console-sg-${var.automq_byoc_env_id}"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.automq_byoc_env_console_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

resource "aws_iam_role" "automq_byoc_role" {
  name = "automq-byoc-service-role-${var.automq_byoc_env_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

resource "aws_iam_policy" "automq_byoc_policy" {
  name        = "automq-byoc-service-policy-${var.automq_byoc_env_id}"
  description = "Custom policy for automq_byoc service"

  policy = templatefile("${path.module}/tpls/automq_byoc_role_policy.json.tpl", {
    automq_data_bucket = local.automq_data_bucket
    automq_ops_bucket  = local.automq_ops_bucket
  })

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

resource "aws_iam_role_policy_attachment" "automq_byoc_role_attachment" {
  role       = aws_iam_role.automq_byoc_role.name
  policy_arn = aws_iam_policy.automq_byoc_policy.arn
}

resource "aws_iam_instance_profile" "automq_byoc_instance_profile" {
  name = "automq-byoc-instance-profile-${var.automq_byoc_env_id}"
  role = aws_iam_role.automq_byoc_role.name

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

resource "aws_route53_zone" "private_r53" {
  name = "${var.automq_byoc_env_id}.automq.private"

  vpc {
    vpc_id = local.automq_byoc_vpc_id
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

locals {
  aws_iam_instance_profile_arn_encoded = urlencode(aws_iam_instance_profile.automq_byoc_instance_profile.arn)
}

resource "aws_eip" "web_ip" {
  instance = aws_instance.automq_byoc_console.id

  tags = {
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }
}

locals {
  public_subnet_id = var.create_new_vpc ? module.automq_byoc_vpc[0].public_subnets[0] : var.automq_byoc_env_console_public_subnet_id
}

data "aws_subnet" "public_subnet_info" {
  id = local.public_subnet_id
}