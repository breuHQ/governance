
locals {
  # repositories on github
  repos = {
    for filename in fileset(path.module, "repos/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }

  # teams on github
  github_teams = {
    for filename in fileset(path.module, "groups/github/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }

  # team associations with repos on github
  github_team_repos = {
    for obj in flatten([
      for repo, details in local.repos : try(flatten([
        for team in details.teams : { repo : repo, team : team.name, permission : team.permission }
      ]), [])
    ]) : "${obj.repo}_${obj.team}" => obj
  }

  # team assoications with github users
  github_team_memberships = {
    for obj in flatten([
      for user, details in local.users : try(flatten([
        for team in details.github.teams : { username : details.github.username, team : team.name, role : team.role }
      ]), [])
    ]) : "${obj.team}_${obj.username}" => obj
  }
}

resource "github_repository" "repos" {
  for_each = local.repos

  name                        = each.value.name
  description                 = each.value.description
  has_downloads               = each.value.has_downloads
  has_issues                  = each.value.has_issues
  has_wiki                    = each.value.has_wiki
  has_projects                = each.value.has_projects
  topics                      = each.value.topics
  allow_merge_commit          = false
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
}

resource "github_team" "teams" {
  for_each = local.github_teams

  name                      = each.key
  description               = each.value.description
  create_default_maintainer = each.value.create_default_maintainer

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

resource "github_team_repository" "team_repos" {
  for_each = local.github_team_repos

  team_id    = github_team.teams[each.value.team].id
  repository = each.value.repo
  permission = each.value.permission

  lifecycle {
    ignore_changes = [etag]
  }
}

resource "github_team_membership" "team_memberships" {
  for_each = local.github_team_memberships

  team_id  = github_team.teams[each.value.team].id
  username = each.value.username
  role     = each.value.role
}
