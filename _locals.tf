locals {
  # users
  users = {
    for filename in fileset(path.module, "users/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  # groups on google workspace
  gsuite_groups = {
    for filename in fileset(path.module, "groups/gsuite/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  # gsuite group memberships
  gsuite_group_members = flatten([
    for user, details in local.users : try(flatten([
      for group, role in details.gsuite.groups : { email : details.email, group : "${group}@breu.io", role : upper(role) }
    ]), [])
  ])

  # repositories on github
  repos = {
    for filename in fileset(path.module, "repos/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  # teams on github
  github_teams = {
    for filename in fileset(path.module, "groups/github/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  # team associations with repos on github
  github_team_repos = flatten([
    for repo, details in local.repos : try(flatten([
      for team, permission in details.teams : { repo : repo, team : team, permission : permission }
    ]), [])
  ])

  # team assoications with github users
  github_team_memberships = flatten([
    for user, details in local.users : flatten([
      for team, role in details.github.teams : { username : details.github.username, team : team, role : role }
    ])
  ])
}

# This is temporary to make me understand the final structure of different ELTs i am using above.
output "users" {
  value = local.users
}

output "repos" {
  value = local.repos
}

output "gsuite_groups" {
  value = local.gsuite_groups
}

output "gsuite_group_members" {
  value = local.gsuite_group_members
}

output "github_teams" {
  value = local.github_teams
}

output "github_team_repos" {
  value = local.github_team_repos
}

output "github_team_memberships" {
  value = local.github_team_memberships
}

# For importing we are going to need to inspect the ids, the following can be used.

/* data "github_team" "example" {
  slug = "admins"
}

output "github_admin" {
  value = data.github_team.example.id
} */
