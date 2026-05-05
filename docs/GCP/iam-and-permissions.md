# GCP：IAM 與權限

## 授權方向

```
資源（Bucket、Project 等）
    ↑
    │ 授權（IAM binding）
    │
主體（Service Account、User） ← 被允許對資源執行指定動作
```

你在資源的 IAM 設定中將主體加入並指定 role，等於「授權該主體存取該資源」。

## 常見情境

### 1. CI/CD 用的 Service Account 需有權限

GHA 用的 `GCP_SA_KEY` 對應的 SA 需要：

| 用途 | 角色或權限 |
|------|------------|
| Terraform state (GCS) | `roles/storage.objectAdmin` on bucket，或 `roles/storage.admin` |
| 建立 VM（instances.create, disks.create, subnetworks.use 等） | `roles/compute.instanceAdmin.v1` |
| 保留靜態外部 IP（`google_compute_address`） | `roles/compute.networkAdmin` |
| 建立/更新 VPC 防火牆（`google_compute_firewall`） | `roles/compute.networkAdmin` |
| 讀取 zone/region 資訊（`compute.zones.get`） | `roles/compute.viewer` |
| 建立 Service Account | `roles/iam.serviceAccountAdmin` |
| 將 SA 掛到 VM 上（`iam.serviceAccounts.actAs`） | `roles/iam.serviceAccountUser` |
| 建立 Artifact Registry | `roles/artifactregistry.admin` |
| IAM binding（`google_project_iam_member`） | `roles/resourcemanager.projectIamAdmin`（專案層級） |

> **錯誤** `The caller does not have permission` 當讀寫 IAM policy 時，代表 SA 缺少 `resourcemanager.projects.setIamPolicy`，需授予 `roles/resourcemanager.projectIamAdmin`。

> **錯誤** `Required 'compute.instances.create' permission` 等，代表需 `roles/compute.instanceAdmin.v1` 與 `roles/compute.viewer`。

### 2. 授予 SA 存取 GCS Bucket

```bash
gsutil iam ch serviceAccount:SA_EMAIL:objectAdmin gs://BUCKET_NAME
```

### 3. VM 上的 SA 需存取 Artifact Registry

VM 使用的 SA 要有 `roles/artifactregistry.reader`，才能 `docker pull`。在 Terraform 中用 `google_project_iam_member` 綁定即可。

## 一次性授予 CI SA 全部所需權限

使用專案內腳本（依 `terraform/main.tf` 自動列出所需權限）：

```bash
./scripts/grant-ci-permissions.sh
```

或手動執行，需授予的 role 清單：

| Role | 用途 |
|------|------|
| `roles/storage.objectAdmin` | GCS state bucket 讀寫 |
| `roles/compute.instanceAdmin.v1` | 建立 VM、disk、使用 subnet、setMetadata、setServiceAccount |
| `roles/compute.viewer` | compute.zones.get 等讀取 |
| `roles/iam.serviceAccountAdmin` | 建立 Service Account |
| `roles/iam.serviceAccountUser` | 將 SA 掛到 VM（actAs） |
| `roles/artifactregistry.admin` | 建立 Artifact Registry |
| `roles/resourcemanager.projectIamAdmin` | IAM binding |

腳本也會啟用：`compute`, `iam`, `cloudresourcemanager`, `artifactregistry`, `storage`, `storage-api`。

## 最小權限原則

- 避免使用 Owner，依實際需求選擇較小範圍的 role
- CI 用 SA 與 VM 用 SA 可分開設定
- 參考：[GCP IAM Roles](https://cloud.google.com/iam/docs/understanding-roles)
