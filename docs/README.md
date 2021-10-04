# governance

Breu's IAM governance as code


# Terraform Setup

Create service account credentials for running terraform locally. Then

```
export GOOGLE_CREDENTIALS=<PATH TO SERVICE ACCOUNT JSON CREDS>
gcloud auth activate-service-account --key-file $GOOGLE_CREDENTIALS
terraform init

```

# GitHub Setup

**Personal Access Token** for GitHub in their own Local Environment

This can be done in the follwing way ->

  - Set env variable by setting the token to .bashrc/.bash_profile
  - example - `export GITHUB_TOKEN="${token_string}"`

Documentation can be found here - >

[OAuth / Personal Access Token](https://registry.terraform.io/providers/integrations/github/latest/docs#oauth--personal-access-token)

# To Create a New User

Create a <username>.yml inside users directory

run commands -> 

  - `terraform plan -out <plan_name>`
  
**check for line -> Plan: # to add, # to change, # to destroy**
  
  - `terraform apply "<plan_name>"`
