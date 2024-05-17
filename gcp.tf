locals {
  gcp_folders = {
    for folder in yamldecode(file("gcp/folders.yaml")).folders :
    folder.name => try(
      { parent : "folders/${folder.parent}" },
      { parent : "organizations/${var.org_id}" },
    )
  }

  gcp_folder_ids = {
    for name, folder in local.gcp_folders :
    name => folder.parent
  }

  gcp_projects = {
    for filename in fileset(path.module, "gcp/projects/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }

  gcp_project_buckets = {
    for name, project in local.gcp_projects :
    name => {
      name : "${name}-tfstate",
      location : project.default_region,
    } if try(project.create_state_bucket, false) == true
  }
}

resource "google_folder" "folders" {
  for_each     = local.gcp_folders
  display_name = each.key
  parent       = each.value.parent
}


module "projects" {
  source  = "terraform-google-modules/project-factory/google"
  version = "14.1.0"

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
  labels                  = each.value.labels
}

resource "google_storage_bucket" "state" {
  for_each = local.gcp_project_buckets
  name     = each.value.name
  location = each.value.location
  project  = each.key

  versioning {
    enabled = true
  }

  depends_on = [
    module.projects
  ]
}

output "project_state_backets" {
  value = {
    for name, bucket in google_storage_bucket.state :
    name => bucket.self_link
  }
}

output "folder_ids" {
  value = {
    for name, folder in google_folder.folders :
    name => folder.folder_id
  }
}
