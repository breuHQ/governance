/*
 * Please see `./_locals.tf` for reading data from different files
 * The following iterate over each resource type (user, repo, group, team)
 */

resource "gsuite_user" "users" {
  for_each = local.users

  primary_email  = each.value.email
  recovery_email = each.value.recovery_email

  name = {
    given_name  = each.value.name.first_name
    family_name = each.value.name.last_name
  }

  aliases = try(each.value.gsuite.aliases, [])
}

resource "gsuite_group" "groups" {
  for_each = local.gsuite_groups

  email       = "${each.key}@breu.io"
  name        = each.value.name
  description = each.value.description
}

resource "gsuite_group_member" "group_member" {
  for_each = local.gsuite_group_members

  group = "${each.value.group}@breu.io"
  email = each.value.email
  role  = each.value.role
}

resource "github_repository" "repos" {
  for_each = local.repos

  name          = each.value.name
  description   = each.value.description
  has_downloads = each.value.has_downloads
  has_issues    = each.value.has_issues
  has_wiki      = each.value.has_wiki
  has_projects  = each.value.has_projects
}

resource "github_team" "teams" {
  for_each = local.github_teams

  name                      = each.key
  description               = each.value.description
  create_default_maintainer = each.value.create_default_maintainer
}

resource "github_team_repository" "team_repos" {
  for_each = local.github_team_repos

  team_id    = github_team.teams[each.value.team].id
  repository = each.value.repo
  permission = each.value.permission
}

resource "github_team_membership" "team_memberships" {
  for_each = local.github_team_memberships

  team_id  = github_team.teams[each.value.team].id
  username = each.value.username
  role     = each.value.role
}
