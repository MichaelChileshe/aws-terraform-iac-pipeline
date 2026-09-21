# Look up the latest Amazon Linux 2023 AMI at plan time, so the code never
# pins a stale image id.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# All the infrastructure lives in one reusable module, so a second environment
# is a second `module` block with different inputs — not a copy-paste of the code.
module "webapp" {
  source = "./modules/webapp"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  instance_type      = var.instance_type
  ami_id             = data.aws_ami.al2023.id
  admin_cidr         = var.admin_cidr
}
