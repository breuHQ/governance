# Introduction

Breu's identity and access management, as code. The aim of the project is to

- create user's across multiple SASS
- manage access level across multiple SASS

have a unified control of all resources and provide audit logs.

Currently it support

- Google Workspace
- Github

Work in progress

- Google Cloud

## Pre Requisites

You have the following developer tools installed on your computer

- [terraform](https://terraform.io)
- [gcloud](https://cloud.google.com/sdk/gcloud)
- [jq](https://stedolan.github.io/jq/)

## Getting Started

Before getting started, you need to obtain the service account credentials from `breu-seed` project and place the file with name `gsuite.json` at the root of the directory.

The project also assumes that you the admin on github. Get the `GITHUB_TOKEN` from github, and export it as environment varilable.

Then run,

```bash
terraform init
```

You should be able to run the project.

## Project Structure

### Users

Each user is represented as a file inside `users` folder. The structure of the `<user>.yaml` is as follows

```yaml
email: email@breu.io # email address
recovery_email: # recovery email
recovery_phone: # recovery phone
name:
  first_name: # first name
  last_name: # last name

googleworkspace_user: true # if this is a gsuite user. In some cases we might not want to add a user in google workspace

# Google Workspace
googleworkspace:
  groups:
    - name: team # name of the group
      role: member # role of the member
# Github
github:
  username: # github username
  teams:
    - name: team # name of the team on github
      role: member # role
```

### Groups

There are two types of groups currently.

1. Google Workspaces
2. Github
