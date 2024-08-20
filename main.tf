resource "aws_instance" "web" {
  ami                    = var.specified_ami_by_marketplace ? data.aws_ami.marketplace_ami_details.id : var.automq_byoc_env_console_ami
  instance_type          = var.automq_byoc_ec2_instance_type
  subnet_id              = local.automq_byoc_env_console_public_subnet_id
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
    automqVendor   = "automq"
    automqEnvironmentID = var.automq_byoc_env_id
  }

  associate_public_ip_address = true

  # Initialize the AutoMQ BYOC console configuration
  user_data = templatefile("${path.module}/tpls/userdata.tpl", {
    aws_iam_instance_profile_arn_encoded = local.aws_iam_instance_profile_arn_encoded,
    automq_data_bucket                   = local.automq_data_bucket,
    automq_ops_bucket                    = local.automq_ops_bucket,
    instance_security_group_id           = aws_security_group.allow_all.id,
    instance_dns                         = aws_route53_zone.private.zone_id,
    instance_profile_arn                 = aws_iam_instance_profile.automq_byoc_instance_profile.arn,
    environment_id                       = var.automq_byoc_env_id
  })
}