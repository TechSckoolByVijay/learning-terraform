locals {
  project_name = "capstone"

  hub_name  = "${local.project_name}-hub"
  dev_name  = "${local.project_name}-dev"
  prod_name = "${local.project_name}-prod"

  common_tags = {
    ManagedBy  = "Terraform"
    CostCenter = "100001"
    Project    = local.project_name
  }


  hub_router_subnet  = cidrsubnet(var.hub_address_space, 8, 1)
  hub_bastion_subnet = cidrsubnet(var.hub_address_space, 10, 2)
} 