# Remote state in S3 with native state locking (Terraform >= 1.10 — no separate
# DynamoDB lock table needed). The bucket is created once by ./bootstrap before
# this backend is initialised. Backend blocks cannot use variables, so the
# bucket name is hardcoded — change the account id if yours differs.
terraform {
  backend "s3" {
    bucket       = "ubuntu-retail-tfstate-773475891131"
    key          = "webapp/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
