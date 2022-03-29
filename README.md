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

Each user is represented as a file inside `users` folder. The structure of the `${user}.yaml` is as follows

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

- Google Workspaces
- Github

#### Google Workspaces

Like `users`, each file in `groups/google` represent one group. The structure of the `${group}.yaml` is as follow. The filename will represent `${name}@breu.io`.

```yaml
name: Name
description: Description
```

#### Github

Like `users` and `github`, each file in `groups/github` represent a team in github. The structure of `${team}.yaml` is as follows

```yaml
description: Description
create_default_maintainer: false
privacy: secret # or public
```

### Repositories

We control the access of github via terraform aswell.

```yaml
name: infra
description: IaC for Breu. Setsup Breu as a startup incubator.
has_downloads: true
has_issues: true
has_wiki: false
has_projects: false
topics:
  - infra
  - internal
  - breu

teams:
  - name: admins
    permission: admin
```

### Google Cloud

Each `folder` in GCP represents a cost center, e.g. `breu` is the main `breu` const center. Then under breu, we will have multiple cost centers as well, like `growth`, `hr`, `rnd` etc. Each project is then created under a cost center.

There is a single `folders.yaml` right now, and each entry represent a single folder.
