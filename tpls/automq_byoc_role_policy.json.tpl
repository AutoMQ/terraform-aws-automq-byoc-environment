{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": "autoscaling.amazonaws.com"
        }
      }
    },
    {
      "Sid": "EC2InstanceProfileManagement",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "iam:PassedToService": "ec2.amazonaws.com*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "pricing:GetProducts",
        "cloudwatch:PutMetricData",
        "ec2:DescribeImages",
        "ec2:CreateLaunchTemplate",
        "ec2:CreateLaunchTemplateVersion",
        "ec2:ModifyLaunchTemplate",
        "ec2:RebootInstances",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "ec2:CreateKeyPair",
        "ec2:CreateTags",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeVolumes",
        "ec2:DescribeSubnets",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeVpcs",
        "ec2:DescribeTags",
        "ec2:DeleteKeyPair",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DeleteLaunchTemplate",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAddresses",
        "ec2:AssociateAddress",
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DeleteAutoScalingGroup",
        "autoscaling:AttachInstances",
        "autoscaling:DetachInstances",
        "autoscaling:ResumeProcesses",
        "autoscaling:SuspendProcesses",
        "route53:CreateHostedZone",
        "route53:GetHostedZone",
        "route53:ChangeResourceRecordSets",
        "route53:ListHostedZonesByName",
        "route53:ListResourceRecordSets",
        "route53:DeleteHostedZone",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeleteLoadBalancer"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetLifecycleConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:ListBucket"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetLifecycleConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${automq_data_bucket}",
        "arn:aws:s3:::${automq_ops_bucket}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:AbortMultipartUpload",
        "s3:PutObjectTagging",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::${automq_data_bucket}/*",
        "arn:aws:s3:::${automq_ops_bucket}/*"
      ]
    }
  ]
}