output "access_key" {
  value = aws_iam_access_key.github_actions_key.id
}

output "secret_key" {
  value = aws_iam_access_key.github_actions_key.secret
}