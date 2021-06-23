# governance
Breu's IAM governance as code

New Mainterner must provide their personal PAT into _config.tf

Documentation can be found here - > https://registry.terraform.io/providers/integrations/github/latest/docs#oauth--personal-access-token

#To Create a New User

1. Create a <username>.yml inside users directory

2. run commands -> 
  
terraform plan -out <name>.txt 
  
check for line -> Plan: # to add, # to change, # to destroy.

terraform apply "<name>.txt"

#To Destroy the User Created

1. Delete the <name>.yml file from user directory

2. run commands ->
  
terraform refresh
terraform init
terraform fmt
terraform validate
terraform plan -out <name>.txt
terraform apply "<name>.txt"

check for line Plan: # to add, # to change, # to destroy.


