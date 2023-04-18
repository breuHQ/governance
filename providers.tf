provider "github" {
  owner = "breuHQ"
}


provider "googleworkspace" {
  customer_id             = "C00z5q9hc"
  credentials             = "./gsuite.json"
  impersonated_user_email = var.workspace_impersonated_user
  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/apps.groups.settings",
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.userschema",
  ]
}
