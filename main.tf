resource "github_repository" "repos" {
  for_each = local.repos

  name          = each.value.name
  description   = each.value.description
  has_downloads = each.value.has_downloads
  has_issues    = each.value.has_issues
  has_wiki      = each.value.has_wiki
  has_projects  = each.value.has_projects
}

resource "gsuite_user" "users" {
  for_each = local.users

  primary_email = each.value.email
  recovery_email = each.value.recovery_email

  name = {
    given_name = each.value.name.first_name
    family_name = each.value.name.last_name
  }

  aliases = each.value.gsuite.aliases
}
