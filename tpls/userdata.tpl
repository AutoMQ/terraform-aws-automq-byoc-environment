#cloud-config
bootcmd:
  - |
    if [ ! -f "/home/admin/config.properties" ]; then
      touch /home/admin/config.properties
      echo "cmp.provider.credential=vm-role://${aws_iam_instance_profile_arn_encoded}@aws" >> /home/admin/config.properties
      echo 'cmp.provider.databucket=${automq_data_bucket}' >> /home/admin/config.properties
      echo 'cmp.provider.opsBucket=${automq_ops_bucket}' >> /home/admin/config.properties
      echo 'cmp.provider.instanceSecurityGroup=${instance_security_group_id}' >> /home/admin/config.properties
      echo 'cmp.provider.instanceDNS=${instance_dns}' >> /home/admin/config.properties
      echo 'cmp.provider.instanceProfile=${instance_profile_arn}' >> /home/admin/config.properties
      echo 'cmp.environmentId=${environment_id}' >> /home/admin/config.properties
    fi