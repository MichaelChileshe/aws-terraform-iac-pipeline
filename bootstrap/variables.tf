variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project_name" {
  type    = string
  default = "ubuntu-retail"
}
variable "github_owner" {
  description = "Your GitHub username or org (the part before the / in the repo URL)"
  type        = string
}
variable "github_repo" {
  description = "The repository name that will run the pipeline"
  type        = string
  default     = "aws-terraform-iac-pipeline"
}
