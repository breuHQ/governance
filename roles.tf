// work in progress

/*In this script, the "google_iam_member" resource is used to get the role of the 
user from Google Workspace. The member argument is used to specify the email address 
of the user. The "google_iam_binding" resource is used to assign the role to the 
user on GCP. The role argument is used to set the role that should be assigned to the 
user and the members argument is used to set the email address of the user.*/


# resource "google_iam_member" "user" {
#   role = "roles/viewer"
#   member = "user:${var.user_email}"
# }

# resource "google_iam_binding" "binding" {
#   role = "${google_iam_member.user.role}"
#   members = ["${google_iam_member.user.member}"]
# }
