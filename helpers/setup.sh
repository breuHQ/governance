#!/bin/bash

# This script is derived from he helper scripts of the repository https://github.com/terraform-google-modules/terraform-google-project-factory

set -e
set -u

# Source input variables
. ./setup.env

# Set Locals
SA_ID="$SA_NAME@$SEED_PROJECT.iam.gserviceaccount.com"

# Organization ID
echo "Verifying organization..."
CHECK_ORG_ID="$(gcloud organizations list --format="value(ID)" --filter="$ORG_ID")"

if [[ $CHECK_ORG_ID == "" ]];
then
    echo "The organization id provided does not exist. Exiting."
    exit 1;
fi

# Project Folder
if [[ $FOLDER_ID == "" ]]; then
    echo "Skipping project folder verification... (input variable not passed in env file)"
    FOLDER_ID=""
else
    echo "Verifying project folder..."
    FOLDER_ID="$(gcloud resource-manager folders list --format="value(ID)" --organization="$ORG_ID" --filter="$FOLDER_ID")"

    if [[ $FOLDER_ID == "" ]]; then
        echo "The project folder does not exist. Exiting."
        exit 1;
    fi
fi

# Seed Project
echo "Verifying project..."
CHECK_SEED_PROJECT="$(gcloud projects list --format="value(projectId)" --filter="$SEED_PROJECT")"

if [[ $CHECK_SEED_PROJECT == "" ]];
then
    echo "The Seed Project does not exist. Creating..."
    gcloud projects create $SEED_PROJECT
    echo "Verifying project creation..."
    CHECK_CREATED_PROJECT="$(gcloud projects list --format="value(projectId)" --filter="$SEED_PROJECT")"
    if [[ $CHECK_CREATED_PROJECT == "${SEED_PROJECT}" ]];
    then
        echo "Seed Project created"
    else
        echo "Error in creating the project .. Exiting."
        exit 1;
    fi
else
    echo "The Seed Project already exists. Will not be created."
fi

# Billing account
if [ "x$BILLING_ACCOUNT" != "x"  ]; then
    echo "Verifying billing account..."
    CHECK_BILLING_ACCOUNT="$(gcloud beta billing accounts list --format="value(ACCOUNT_ID)" --filter="$BILLING_ACCOUNT")"

    if [[ $CHECK_BILLING_ACCOUNT == "" ]];
    then
        echo "The billing account does not exist. Exiting."
        exit 1;
    fi
else
    echo "Skipping billing account verification... (parameter not passed)"
fi

# Seed Service Account creation
# Check Seed service account
echo "Checking if Seed Service Account exists..."
CHECK_SA="$(gcloud iam service-accounts list --format="value(NAME)" --filter="${SA_NAME}" --project=${SEED_PROJECT})"

if [[ $CHECK_SA == "" ]];
then
    echo "The Seed Service Account '$SA_NAME' does not exist. Creating..."
    gcloud iam service-accounts \
    --project "${SEED_PROJECT}" create ${SA_NAME} \
    --display-name ${SA_NAME}
else
    echo "The Seed Service Account '$SA_NAME' already exists. Will not be created."
fi

echo "Downloading key to $KEY_FILE..."
gcloud iam service-accounts keys create "${KEY_FILE}" \
--iam-account "${SA_ID}" \
--user-output-enabled false

if [[ $FOLDER_ID == "" ]]; then
    echo "Skipping grant roles on project folder... (parameter not passed)"
else
    echo "Applying permissions for folder $FOLDER_ID..."
    # Grant roles/resourcemanager.folderViewer to the Seed Service Account on the folder
    echo "Adding role roles/resourcemanager.folderViewer..."
    gcloud resource-manager folders add-iam-policy-binding \
    "${FOLDER_ID}" \
    --member="serviceAccount:${SA_ID}" \
    --role="roles/resourcemanager.folderViewer" \
    --user-output-enabled false
fi

echo "Applying permissions for org $ORG_ID and project $SEED_PROJECT..."
# Grant roles/resourcemanager.organizationViewer to the Seed Service Account on the organization
gcloud organizations add-iam-policy-binding "${ORG_ID}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/resourcemanager.organizationViewer" \
--user-output-enabled false

# Grant roles/resourcemanager.projectCreator to the service account on the organization
echo "Adding role roles/resourcemanager.projectCreator..."
gcloud organizations add-iam-policy-binding "${ORG_ID}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/resourcemanager.projectCreator" \
--user-output-enabled false

# Grant roles/billing.user to the service account on the organization
echo "Adding role roles/billing.user..."
gcloud organizations add-iam-policy-binding "${ORG_ID}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/billing.user" \
--user-output-enabled false

# Grant roles/compute.xpnAdmin to the service account on the organization
echo "Adding role roles/compute.xpnAdmin..."
gcloud organizations add-iam-policy-binding \
"${ORG_ID}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/compute.xpnAdmin" \
--user-output-enabled false

# Grant roles/compute.networkAdmin to the service account on the organization
echo "Adding role roles/compute.networkAdmin..."
gcloud organizations add-iam-policy-binding "${ORG_ID}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/compute.networkAdmin" \
--user-output-enabled false

# Grant roles/iam.serviceAccountAdmin to the service account on the organization
echo "Adding role roles/iam.serviceAccountAdmin..."
gcloud organizations add-iam-policy-binding "${ORG_ID}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/iam.serviceAccountAdmin" \
--user-output-enabled false

# Grant roles/compute.instanceAdmin.v1 to the service account on the project
echo "Adding role roles/compute.instanceAdmin.v1..."
gcloud projects add-iam-policy-binding "${SEED_PROJECT}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/compute.instanceAdmin.v1" \
--user-output-enabled false

# Grant roles/storage.admin to the service account on the project
echo "Adding role roles/storage.admin..."
gcloud projects add-iam-policy-binding "${SEED_PROJECT}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/storage.admin" \
--user-output-enabled false

# Grant roles/resourcemanager.projectIamAdmin to the Seed Service Account on the Seed Project
echo "Adding role roles/resourcemanager.projectIamAdmin..."
gcloud projects add-iam-policy-binding "${SEED_PROJECT}" \
--member="serviceAccount:${SA_ID}" \
--role="roles/resourcemanager.projectIamAdmin" \
--user-output-enabled false

# enable the billing account
if [[ ${CHECK_BILLING_ACCOUNT:-} != "" ]]; then
    echo "Enabling the billing account..."
    gcloud beta billing accounts get-iam-policy "$BILLING_ACCOUNT" > policy-tmp-$$.yml
    unamestr=$(uname)
    if [ "$unamestr" = 'Darwin' ] || [ "$unamestr" = 'Linux' ]; then
        sed -i.bak -e "/^etag:.*/i \\
- members:\\
\ \ - serviceAccount:${SA_ID}\\
\ \ role: roles/billing.user" policy-tmp-$$.yml && rm policy-tmp-$$.yml.bak
        gcloud beta billing accounts set-iam-policy "$BILLING_ACCOUNT" policy-tmp-$$.yml
    else
        echo "Could not set roles/billing.user on service account $SERVICE_ACCOUNT.\
        Please perform this manually."
    fi
    rm -f policy-tmp-$$.yml
fi

# Enable billing for the seed project
echo "Linking Billing account '${BILLING_ACCOUNT}' with project '${SEED_PROJECT}'"
gcloud beta billing projects link ${SEED_PROJECT} --billing-account=${BILLING_ACCOUNT}

# Enable required API's
echo "Enabling APIs..."
sleep 5s

gcloud services enable \
cloudresourcemanager.googleapis.com \
--project "${SEED_PROJECT}"

echo "cloudresourcemanager.googleapis.com enabled.."

gcloud services enable \
cloudbilling.googleapis.com \
--project "${SEED_PROJECT}"

echo "cloudbilling.googleapis.com enabled.."

gcloud services enable \
billingbudgets.googleapis.com \
--project "${SEED_PROJECT}"

echo "billingbudgets.googleapis.com enabled.."

gcloud services enable \
iam.googleapis.com \
--project "${SEED_PROJECT}"

echo "iam.googleapis.com enabled.."

gcloud services enable \
admin.googleapis.com \
--project "${SEED_PROJECT}"

echo "admin.googleapis.com enabled.."

gcloud services enable \
appengine.googleapis.com \
--project "${SEED_PROJECT}"

echo "appengine.googleapis.com enabled.."

gcloud services enable \
storage-api.googleapis.com \
--project "${SEED_PROJECT}"

echo "storage-api.googleapis.com enabled.."


gcloud services enable \
firebase.googleapis.com \
--project "${SEED_PROJECT}"

echo "firebase.googleapis.com enabled.."

gcloud services enable \
dns.googleapis.com \
--project "${SEED_PROJECT}"

echo "dns.googleapis.com enabled.."

# Create a GCS Bucket for Terraform State
if [ "x$TF_BUCKET_NAME" != "x"  ]; then

    CHECK_BUCKET="$(gsutil ls -b -p $SEED_PROJECT gs://${TF_BUCKET_NAME}  2>/dev/null || echo '')"
    if [[ $CHECK_BUCKET == "" ]]; then
        echo "Creating GCS Bucket for Terraform state"
        gsutil mb -p $SEED_PROJECT "gs://${TF_BUCKET_NAME}"
    else
        echo "Bucket already exists. Will not be created."
    fi
else
    echo "TF_BUCKET_NAME variable not set in input variables file. Exiting..."
    exit 1;
fi

echo "All done."
