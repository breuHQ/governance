# governance
Breu's IAM governance as code

New Mainterner must provide their Personal Access Token for GitHub

This can be done in the follwing way -->

1. Set env variable by setting the token to .bashrc/.bash_profile

example - export GITHUB_TOKEN="${token_string}"

Documentation can be found here - > https://registry.terraform.io/providers/integrations/github/latest/docs#oauth--personal-access-token

#To Create a New User

1. Create a <username>.yml inside users directory

2. run commands -> 

terraform plan -out <plan_name> 
  
check for line -> Plan: # to add, # to change, # to destroy.
  
terraform apply "<plan_name>"

#To Destroy the User Created

1. Delete the <name>.yml file from user directory

2. run commands ->
  
terraform refresh

terraform init

terraform fmt

terraform validate

terraform plan -out <plan_name>
  
terraform apply "<plan_name>"

check for line Plan: # to add, # to change, # to destroy.
