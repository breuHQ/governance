![Diagram](https://user-images.githubusercontent.com/42113685/130909934-a1905156-b373-4b43-802f-10f3ad873e3c.png)

## Overview Of The Key Components

### Project Build Squad

These are the Developers, Teams, Admins and Maintainers which can overlap

### User File

Sample File Example -

```JSON

email: john_doe@company.com
recovery_email: john.doe@email.com
name:
  first_name: John
  last_name: Doe

gsuite_user: true

# Google Workspace
gsuite:
  groups:
    - name: team
      role: member
# Github
github:
  username: john
  teams:
    - name: Project A
 role: member

```

### GIT

The New User File is stored, maintained and reviewed in Git after running

```
terraform plan -out <plan_name>

```

### Terraform Apply

```
terraform apply <plan_name>
```
