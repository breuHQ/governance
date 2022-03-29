# module "project-factory" {

#   name                = "breu-growth"
#   random_project_id   = true
#   org_id              = "460100486399"
#   usage_bucket_name   = "breu-growth-usage-report-bucket"
#   usage_bucket_prefix = "usage/breu-growth"
#   billing_account     = "0175D5-703D28-5C6ADF"
# }

locals {
  gcp_folders = {
    for folder in yamldecode(file("gcp/folders.yaml")).folders :
    folder.name => try({ parent : "folders/${folder.parent}" }, { parent : "organizations/${var.org_id}" })
  }

  gcp_projects = {
    for filename in fileset(path.module, "gcp/projects/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }
}

resource "google_folder" "folders" {
  for_each     = local.gcp_folders
  display_name = each.key
  parent       = each.value.parent
}


module "projects" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 12.0.0"

  for_each                = local.gcp_projects
  project_id              = each.key
  folder_id               = each.value.folder_id
  random_project_id       = each.value.random_project_id
  name                    = each.value.name
  org_id                  = var.org_id
  billing_account         = try(each.value.billing_account, var.billing_account)
  domain                  = each.value.domain
  activate_apis           = each.value.activate_apis
  default_service_account = "delete"
}
