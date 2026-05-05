# Terraform：匯入既有資源

## 何時需要 import

資源已在 GCP 手動建立，或前次 apply 失敗只成功建立部分資源時，Terraform state 與實際不符，需要把既有資源匯入 state。

## import 是命令，不是設定

`terraform import` 是 CLI 指令，不寫在 `.tf` 檔中，在 terminal 執行一次即可。

## 執行順序

1. 先 `terraform init`（含 backend-config）
2. 再 `terraform import ...`

## 本專案常見 import 指令

```bash
# 設定變數（必要時）
export PROJECT_ID="your-agent-project"
export REGION="asia-east1"
export ZONE="asia-east1-a"
export VM_NAME="agent-vm"
export REPO_ID="agent-artifact-registry"
export SA_EMAIL="vm-deployer-sa@your-agent-project.iam.gserviceaccount.com"
export TF_VAR_ssh_pub_key="$(cat ~/.ssh/agent_vm.pub)"

# Artifact Registry
terraform import google_artifact_registry_repository.repo \
  "projects/${PROJECT_ID}/locations/${REGION}/repositories/${REPO_ID}"

# Service Account
terraform import google_service_account.vm_sa \
  "projects/${PROJECT_ID}/serviceAccounts/${SA_EMAIL}"

# IAM binding
terraform import 'google_project_iam_member.ar_reader' \
  "${PROJECT_ID} roles/artifactregistry.reader serviceAccount:${SA_EMAIL}"

# Compute Instance
terraform import google_compute_instance.vm \
  "projects/${PROJECT_ID}/zones/${ZONE}/instances/${VM_NAME}"
```

## 匯入腳本

可使用 `terraform/scripts/import-existing.sh` 一次匯入上述資源。

## 是否放在 CI/CD

- import 屬於一次性修正步驟，一般**不**放在 CI/CD
- 與 bootstrap 一樣，屬於環境建立／修復流程，而非每次部署
