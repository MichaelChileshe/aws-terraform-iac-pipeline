output "state_bucket" {
  description = "S3 bucket holding the main configuration's remote state"
  value       = aws_s3_bucket.tfstate.bucket
}
output "github_actions_role_arn" {
  description = "ARN of the role the GitHub Actions pipeline assumes — put this in the workflow"
  value       = aws_iam_role.github_actions.arn
}
