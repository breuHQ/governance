locals {
  users = {
    for filename in fileset(path.module, "users/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  repos = {
    for filename in fileset(path.module, "repos/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  gsuite_groups = {
    for filename in fileset(path.module, "groups/gsuite/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  github_teams = {
    for filename in fileset(path.module, "groups/github/*.yml") :
    trimsuffix(basename(filename), ".yml") => yamldecode(file(filename))
  }

  github_team_repos = flatten(
    [
      for repo, value in local.repos : flatten( # this flatten should be in try()
        [
          for team, permission in value.teams : { repo : repo, team : team, permission : permission }
        ]
      )
    ]
  )

  github_team_memberships = flatten(
    [
      for user, value in local.users: flatten( # this flatten should be in in try()
        [
          for team, role in value.github.teams : { username: value.github.username, team: team, role: role }
        ]
      )
    ]
  )
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
