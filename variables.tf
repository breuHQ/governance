variable "org_id" {
  default = "460100486399"
}

variable "billing_account" {
  default = "0175D5-703D28-5C6ADF"
}

variable "workspace_impersonated_user" {
  type      = string
  sensitive = true
}
