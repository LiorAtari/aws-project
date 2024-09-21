resource "aws_iam_role" "EKS-SQS-SecretManager-Access" {
  name = "EKS-SQS-SecretManager-Access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:ms-sa",
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "EKS-SQS-SecretManager-Access" {
  name = "EKS-SQS-SecretManager-Access"
  role = aws_iam_role.EKS-SQS-SecretManager-Access.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "Statement1",
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:secretsmanager:eu-north-1:794038222022:secret:token-x0VBQa",
          "arn:aws:sqs:eu-north-1:794038222022:stadard_queue",
          "arn:aws:s3:::lioratari-bucket",
          "arn:aws:s3:::lioratari-bucket/*"
        ]
      }
    ]
  })
}
