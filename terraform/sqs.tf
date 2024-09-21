resource "aws_sqs_queue" "standard_queue" {
  name = "stadard_queue"
  visibility_timeout_seconds = 120
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Policy1726829647771",
  "Statement": [
    {
      "Sid": "Stmt1726829643160",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::794038222022:role/EKS-SQS-SecretManager-Access"
      },
      "Action": "sqs:*",
      "Resource": "arn:aws:sqs:eu-north-1:794038222022:stadard_queue"
    }
  ]
}
POLICY
}