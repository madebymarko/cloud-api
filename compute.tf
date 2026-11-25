locals {
  # Graviton families have a "g" after the generation number (t4g, m7g, c7gn).
  ami_arch = can(regex("^[a-z]+[0-9]+g", var.instance_type)) ? "arm64" : "amd64"
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/${local.ami_arch}/hvm/ebs-gp3/ami-id"
}
resource "aws_instance" "api" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.insecure_value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.api.id, aws_security_group.api_web.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.api.name

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/journal_api.sh.tftpl", {
    app_repo_url         = var.app_repo_url
    app_git_ref          = var.app_git_ref
    aws_region           = var.aws_region
    db_secret_arn        = aws_db_instance.main.master_user_secret[0].secret_arn
    db_host              = aws_db_instance.main.address
    db_name              = var.db_name
    app_port             = var.app_port
    openai_api_key_param = var.openai_api_key_param
    openai_base_url      = var.openai_base_url
    openai_model         = var.openai_model
  })
  user_data_replace_on_change = true

  depends_on = [aws_iam_role_policy.api]

  lifecycle {
    ignore_changes = [ami]
  }

  tags = { Name = "${local.name}-api" }
}
