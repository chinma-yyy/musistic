output "iam_role_arn" {
  value = aws_iam_role.ec2_secrets_role.arn
}


output "policy_name" {
  value = aws_iam_instance_profile.ec2.name
}
