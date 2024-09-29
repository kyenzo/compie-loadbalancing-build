# Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = "{\"username\":\"dbuser\",\"password\":\"dbpassword\"}"
}

# Secret Policy to Allow Read-Only Access
resource "aws_secretsmanager_secret_policy" "db_secret_policy" {
  secret_arn = aws_secretsmanager_secret.db_secret.arn

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowReadOnlyAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.secrets_manager_account_id}:root"
      },
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
