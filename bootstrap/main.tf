# Bootstrap: run ONCE, locally, with local state. It creates the two things the
# main configuration and the pipeline need to exist first:
#   1. the S3 bucket that holds the main config's remote state
#   2. the GitHub OIDC provider + IAM role the pipeline assumes (keyless auth)
# Chicken-and-egg: this can't itself use the remote backend, because it's what
# creates the backend. Its own state stays local and is git-ignored.

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# ---------------- Remote state bucket ----------------
resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------- GitHub OIDC provider ----------------
# Fetch GitHub's current OIDC certificate so the thumbprint is never hardcoded/stale.
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# ---------------- IAM role the pipeline assumes ----------------
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-terraform"

  # Trust policy: only tokens from THIS GitHub repo, with the sts.amazonaws.com
  # audience, may assume the role. Scoping the `sub` to the repo is the
  # security-critical line — without it, any GitHub repo could assume it.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:*"
        }
      }
    }]
  })
}

# Permissions Terraform needs to manage the webapp stack + read/write its state.
# Broad-by-service for the lab; least-privilege is the documented next step.
resource "aws_iam_role_policy" "github_actions" {
  name = "terraform-permissions"
  role = aws_iam_role.github_actions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ManageInfra"
        Effect   = "Allow"
        Action   = ["ec2:*", "s3:*"]
        Resource = "*"
      }
    ]
  })
}
