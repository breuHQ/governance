locals {
  users = {
    for f in fileset(path.module, "users/*.yml") :
    trimsuffix(basename(f), ".yml") => yamldecode(file(f))
  }

  repos = {
    for f in fileset(path.module, "repos/*.yml"):
    trimsuffix(basename(f), ".yml") => yamldecode(file(f))
  }
}

output "users" {
  value = local.users
}

output "repos" {
  value = local.repos
}
