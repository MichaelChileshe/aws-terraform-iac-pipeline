# Architecture

## Layers
- **Source of truth:** Terraform code in this repo. Nothing is created by hand.
- **State:** an S3 bucket (encrypted, versioned) holding remote state, with
  Terraform 1.10 native S3 locking (`use_lockfile = true`) so concurrent applies
  can't corrupt it.
- **Module:** `modules/webapp` defines the whole stack (VPC, subnet, IGW, route
  table, security group, EC2 web server, private S3 assets bucket). The root
  config calls it once; a second environment would call it again with different
  inputs.
- **Pipeline:** GitHub Actions authenticates to AWS via OIDC (no stored keys),
  then runs fmt/validate/tflint/checkov/plan on PRs and apply on merge to main.

## The bootstrap chicken-and-egg
Remote state needs a bucket, and OIDC needs an IAM role — both must exist before
the main config or the pipeline can run. `bootstrap/` creates them with **local**
state (it can't use a backend that doesn't exist yet). It's applied once, by hand.

## What gets deployed
| Resource | Purpose |
|---|---|
| VPC + public subnet + IGW + route table | Network for the web server |
| Security group | HTTP from anywhere, SSH from the admin CIDR |
| EC2 (Amazon Linux 2023) | Web server; IMDSv2 required, encrypted root volume |
| S3 bucket (private, versioned, encrypted) | Application assets |

## Region
us-east-1 throughout.
