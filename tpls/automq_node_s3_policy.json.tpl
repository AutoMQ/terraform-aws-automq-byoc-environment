{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
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
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${automq_data_bucket}",
                "arn:aws:s3:::${automq_ops_bucket}"
            ],
            "Effect": "Allow"
        }
    ]
}