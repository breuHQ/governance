
locals {
  # users
  users = {
    for filename in fileset(path.module, "users/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }

  googleworkspace_users = {
    for user, details in local.users : user => details if try(details.googleworkspace_user)
  }

  # groups on google workspace
  googleworkspace_groups = {
    for filename in fileset(path.module, "groups/google/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }

  # googleworkspace group memberships
  googleworkspace_group_members = {
    for obj in flatten([
      for user, details in local.users : try(flatten([
        for group in details.googleworkspace.groups : { user : user, email : details.email, group : group.name, role : upper(group.role) }
      ]), [])
    ]) : "${obj.group}_${obj.user}" => obj
  }
}

resource "googleworkspace_user" "users" {
  for_each       = local.googleworkspace_users
  primary_email  = each.value.email
  recovery_email = each.value.recovery_email
  recovery_phone = each.value.recovery_phone
  

  name {
    given_name  = each.value.name.first_name
    family_name = each.value.name.last_name
  }
  
  aliases = try(each.value.googleworkspace.aliases, [])



}
output "duplicate_users" {
  value = [for user in googleworkspace_user.users : 
            user.primary_email if length([for user_inner in googleworkspace_user.users : 
            user_inner.primary_email if user_inner.primary_email == user.primary_email]) > 1]
}

resource "googleworkspace_group" "groups" {
  for_each = local.googleworkspace_groups

  email       = "${each.key}@breu.io"
  name        = each.value.name
  description = each.value.description
}

resource "googleworkspace_group_member" "group_member" {
  for_each = local.googleworkspace_group_members

  # group = "${each.value.group}@breu.io"
  group_id = googleworkspace_group.groups[each.value.group].id
  email    = each.value.email
  role     = each.value.role
}
