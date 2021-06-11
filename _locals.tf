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

  github_team_memberships = flatten([for repo, value in local.repos :
    flatten([for team, permission in value.teams :
      {repo: repo, team: team, permission: permission}])
  ])
}

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

output "memberships" {
  value = local.github_team_memberships
}

/* data "github_team" "example" {
  slug = "admins"
}

output "github_admin" {
  value = data.github_team.example.id
} */
