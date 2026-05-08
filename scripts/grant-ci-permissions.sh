#!/bin/bash
# 一次性授予 CI SA 執行 Terraform 所需的全部權限。
# 對應 terraform/main.tf 建立的資源：Artifact Registry、Service Account、IAM、VM。
#
# 用法：
#   PROJECT_ID=your-project-id \
#   SA_EMAIL=ci-terraform@your-project-id.iam.gserviceaccount.com \
#   ./scripts/grant-ci-permissions.sh

set -e

if [ -z "${PROJECT_ID:-}" ] || [ -z "${SA_EMAIL:-}" ]; then
  echo "Error: PROJECT_ID and SA_EMAIL are required."
  echo "Example:"
  echo "  PROJECT_ID=your-project-id SA_EMAIL=ci-terraform@your-project-id.iam.gserviceaccount.com ./scripts/grant-ci-permissions.sh"
  exit 1
fi

echo "Project: $PROJECT_ID"
echo "Service Account: $SA_EMAIL"
echo ""

echo "1. 啟用所需 API..."
gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  artifactregistry.googleapis.com \
  storage.googleapis.com \
  storage-api.googleapis.com \
  --project="$PROJECT_ID"

echo ""
echo "2. 授予專案層級權限..."

for ROLE in \
  roles/storage.objectAdmin \
  roles/compute.instanceAdmin.v1 \
  roles/compute.networkAdmin \
  roles/compute.viewer \
  roles/iam.serviceAccountAdmin \
  roles/iam.serviceAccountUser \
  roles/artifactregistry.admin \
  roles/resourcemanager.projectIamAdmin; do
  echo "  - $ROLE"
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SA_EMAIL" \
    --role="$ROLE" \
    --quiet 2>/dev/null || true
done

echo ""
echo "3. 授予 GCS state bucket 權限..."
gsutil iam ch "serviceAccount:${SA_EMAIL}:objectAdmin" "gs://${PROJECT_ID}-tfstate" 2>/dev/null || {
  echo "  (bucket 可能不存在，請先執行 bootstrap)"
}

echo ""
echo "完成。可重新執行 GHA workflow。"
