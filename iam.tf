data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "EC2CanAssumeThisRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  openai_param_arn = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.openai_api_key_param}"
}


resource "aws_iam_role" "api" {
  name               = "${local.name}-api-role"
  description        = "Role for the API EC2 instance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "api_permissions" {
  statement {
    sid = "ReadOnlyTheDbSecret"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [aws_db_instance.main.master_user_secret[0].secret_arn]
  }

  statement {
    sid       = "ReadOnlyTheOpenAiKey"
    actions   = ["ssm:GetParameter"]
    resources = [local.openai_param_arn]
  }

}
resource "aws_iam_role_policy" "api" {
  name   = "${local.name}-api-read-db-secret"
  role   = aws_iam_role.api.id
  policy = data.aws_iam_policy_document.api_permissions.json
}

resource "aws_iam_instance_profile" "api" {
  name = "${local.name}-api-profile"
  role = aws_iam_role.api.name
}
