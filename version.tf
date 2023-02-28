terraform {
  required_version = ">= 1"

  backend "gcs" {
    bucket = "breu-tfstate"
    prefix = "governance"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.18.0"
    }

    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "0.7.0"
    }
  }
}
