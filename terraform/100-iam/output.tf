output "cross_role_arn" {
  description = "ARN of the cross account role"
  value       = aws_iam_role.cross_role.arn
}