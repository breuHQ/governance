// work in progress

// Using terraform we are assigning roles of users in gcp based on their role in google workspace
resource "null_resource" "assign_roles" {
  provisioner "local-exec" {
    command = <<EOF
    export ROLE=$(gcloud beta admin roles list | grep ${var.workspace_role} | awk '{print $1}')
    gcloud projects add-iam-policy-binding ${var.project_id} --member user:${var.email} --role projects/${var.project_id}/roles/$ROLE
    EOF
  }
}

variable "workspace_role" {
  description = "The role of the user in Google Workspace"
  type        = string
}

variable "email" {
  description = "The email of the user"
  type        = string
}

variable "project_id" {
  description = "The GCP project id"
  type        = string
}
