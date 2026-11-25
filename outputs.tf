output "vpc_id" {
  value = aws_vpc.main.id
}

output "selected_azs" {
  value = local.azs
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "api_security_group_ids" {
  value = [aws_security_group.api.id, aws_security_group.api_web.id]
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "admin_ssh_cidrs" {
  value = var.admin_ssh_cidrs

}

output "db_endpoint" {
  value = aws_db_instance.main.address
}

output "db_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "api_instance_id" {
  value = aws_instance.api.id
}

output "api_public_ip" {
  value = aws_instance.api.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_instance.api.public_ip}"
}

output "api_url" {
  description = "Public HTTPS endpoint (trusted certificate)"
  value       = "https://${aws_cloudfront_distribution.api.domain_name}"
}

output "api_docs_url" {
  description = "FastAPI Swagger UI"
  value       = "https://${aws_cloudfront_distribution.api.domain_name}/docs"
}
