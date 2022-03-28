terraform {
  required_version = ">= 1"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.1"
    }

    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "0.6.0"
    }
  }
}
