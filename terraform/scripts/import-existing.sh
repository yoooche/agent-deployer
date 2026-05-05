#!/bin/bash
# One-time script: import existing GCP resources into Terraform state.
# Run from repo root: ./terraform/scripts/import-existing.sh
#
# If a resource is already in state, that import will fail with
# "already managed" and is safe to ignore.
#
# Required:
#   PROJECT_ID, REGION, ZONE, VM_NAME, REPO_ID, SA_EMAIL, TF_VAR_ssh_pub_key
#
# Example:
#   PROJECT_ID=my-project REGION=asia-east1 ZONE=asia-east1-a \
#   VM_NAME=agent-vm REPO_ID=agent-artifact-registry \
#   SA_EMAIL=vm-deployer-sa@my-project.iam.gserviceaccount.com \
#   TF_VAR_ssh_pub_key="$(cat ~/.ssh/agent_vm.pub)" \
#   ./terraform/scripts/import-existing.sh

set -e

cd "$(dirname "$0")/.."

for name in PROJECT_ID REGION ZONE VM_NAME REPO_ID SA_EMAIL TF_VAR_ssh_pub_key; do
  if [ -z "${!name:-}" ]; then
    echo "Error: $name is required."
    exit 1
  fi
done

echo "Initializing Terraform..."
terraform init -backend-config="bucket=${PROJECT_ID}-tfstate"

import_resource() {
  if terraform import "$@" 2>/dev/null; then
    echo "  OK"
  else
    echo "  Skipped (may already be in state or does not exist)"
  fi
}

echo "1/4 Importing Artifact Registry repository..."
import_resource google_artifact_registry_repository.repo \
  "projects/${PROJECT_ID}/locations/${REGION}/repositories/${REPO_ID}"

echo "2/4 Importing Service Account..."
import_resource google_service_account.vm_sa \
  "projects/${PROJECT_ID}/serviceAccounts/${SA_EMAIL}"

echo "3/4 Importing IAM binding (ar_reader)..."
import_resource 'google_project_iam_member.ar_reader' \
  "${PROJECT_ID} roles/artifactregistry.reader serviceAccount:${SA_EMAIL}"

echo "4/4 Importing Compute Instance..."
import_resource google_compute_instance.vm \
  "projects/${PROJECT_ID}/zones/${ZONE}/instances/${VM_NAME}"

echo "Done. Run 'terraform plan' to verify state matches GCP."
