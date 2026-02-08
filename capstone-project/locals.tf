locals {
  hub_prefix  = "${var.project_name}-hub"
  dev_prefix  = "${var.project_name}-dev"
  prod_prefix = "${var.project_name}-prod"
  nva_ip      = "10.0.1.4"

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}