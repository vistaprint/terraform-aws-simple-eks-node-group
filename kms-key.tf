data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ebs_encryption_key" {
  description             = "Encryption Key for EBS volumes"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "auto-ebs-2",
    "Statement": [
        {
            "Sid": "Allow access through EBS for all principals in the account that are authorized to use EBS",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:CreateGrant",
                "kms:DescribeKey"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": data.aws_caller_identity.current.account_id,
                    "kms:ViaService": "ec2.eu-west-1.amazonaws.com"
                }
            }
        },
        {
                  "Sid": "Allow administration of the key",
                  "Effect": "Allow",
                  "Principal": {
                    "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                  },
                  "Action": [
                      "kms:Create*",
                      "kms:Describe*",
                      "kms:Enable*",
                      "kms:List*",
                      "kms:Put*",
                      "kms:Update*",
                      "kms:Revoke*",
                      "kms:Disable*",
                      "kms:Get*",
                      "kms:Delete*",
                      "kms:ScheduleKeyDeletion",
                      "kms:CancelKeyDeletion"
                  ],
                  "Resource": "*"
              },
        {
            "Sid": "Allow direct access to key metadata to the account",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": [
                "kms:Describe*",
                "kms:Get*",
                "kms:List*",
                "kms:RevokeGrant"
            ],
            "Resource": "*"
        }
    ]
  })
}