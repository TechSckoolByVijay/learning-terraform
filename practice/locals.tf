locals {
  company = "KidDevOps"
  project = "Alpha-Project"
  env     = "Dev"

  base_name = "${local.company}-${local.project}-${local.env}"
}