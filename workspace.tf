locals {
  # users
  users = {
    for filename in fileset(path.module, "users/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }

  googleworkspace_users = {
    for user, details in local.users :
    user => details if try(details.googleworkspace_user)
  }

  # groups on google workspace
  googleworkspace_groups = {
    for filename in fileset(path.module, "groups/google/*.yaml") :
    trimsuffix(basename(filename), ".yaml") => yamldecode(file(filename))
  }

  # googleworkspace group memberships
  googleworkspace_group_members = {
    for obj in flatten([
      for user, details in local.users :
      try( // Sometimes, flatten will fail if details.googleworkspace.groups is null therefore we need to try
        flatten([
          for group in details.googleworkspace.groups : {
            user : user,
            email : details.email,
            group : group.name,
            role : upper(group.role)
        }]),
        [],
      )
    ]) : "${obj.group}_${obj.user}" => obj
  }
}

resource "googleworkspace_user" "users" {
  for_each = local.googleworkspace_users

  primary_email  = each.value.email
  recovery_email = each.value.recovery_email
  recovery_phone = each.value.recovery_phone
  name {
    given_name  = each.value.name.first_name
    family_name = each.value.name.last_name
  }

  aliases   = try(each.value.googleworkspace.aliases, [])
  suspended = try(each.value.googleworkspace.suspended, false)

  lifecycle {
    ignore_changes = [
      etag,
      last_login_time,
    ]
  }
}

resource "googleworkspace_group" "groups" {
  for_each = local.googleworkspace_groups

  email       = "${each.key}@breu.io"
  name        = each.value.name
  description = each.value.description
  aliases     = try(each.value.aliases, [])
}

resource "googleworkspace_group_member" "group_member" {
  for_each = local.googleworkspace_group_members

  group_id = googleworkspace_group.groups[each.value.group].id
  email    = each.value.email
  role     = each.value.role
}

resource "googleworkspace_group_settings" "group_settings" {
  for_each = local.googleworkspace_groups

  email                   = googleworkspace_group.groups[each.key].email
  allow_external_members  = false
  who_can_contact_owner   = "ALL_MEMBERS_CAN_CONTACT"
  who_can_leave_group     = "NONE_CAN_LEAVE"
  who_can_join            = "INVITED_CAN_JOIN"
  who_can_view_membership = "ALL_MEMBERS_CAN_VIEW"
  who_can_view_group      = "ALL_MEMBERS_CAN_VIEW"
  who_can_post_message    = each.value.public ? "ANYONE_CAN_POST" : "ALL_MEMBERS_CAN_POST"
}
