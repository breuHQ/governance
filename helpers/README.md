# Script Helper

A helper script is included to create the Seed Project and its Seed Service Account, grant the necessary roles to the Seed Service Account, and enable the necessary API's in the Seed Project. Run it as follows:

1. populate setup_seed_prj.env file with required creds.
1. execute the helper script as;

   ```bash
   ./helpers/setup.sh
   ```

1. this will generate the SA credentials.json for you, which you can use for project factory.

## In order to execute this script, you must have an account with the following list of permissions at minimum

resourcemanager.organizations.list
resourcemanager.projects.list
billing.accounts.list
iam.serviceAccounts.create
iam.serviceAccountKeys.create
resourcemanager.organizations.setIamPolicy
resourcemanager.projects.setIamPolicy
serviceusage.services.enable on the project
servicemanagement.services.bind on following services:
cloudresourcemanager.googleapis.com
cloudbilling.googleapis.com
iam.googleapis.com
admin.googleapis.com
appengine.googleapis.com
billing.accounts.getIamPolicy on a billing account.
billing.accounts.setIamPolicy on a billing account.
