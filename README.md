# governance

Breu's IAM governance as code

New Mainterner must provide their **Personal Access Token** for GitHub in their own Local Environment

This can be done in the follwing way ->

- Set env variable by setting the token to .bashrc/.bash_profile

- example - `export GITHUB_TOKEN="${token_string}"`

Documentation can be found here - >

[OAuth / Personal Access Token](https://registry.terraform.io/providers/integrations/github/latest/docs#oauth--personal-access-token)

# To Create a New User

Create a <username>.yml inside users directory

run commands ->

- `terraform plan -out <plan_name>`
