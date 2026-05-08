# GCP：如何知道要啟用哪些 API

## 為什麼會遇到 "API has not been used or is disabled"

GCP 專案預設不會啟用所有 API。使用某個服務時，必須先啟用對應的 API，否則會出現 `Error 403: ... API has not been used ... or is disabled`。

## 如何知道要啟用哪個 API

### 方法一：從錯誤訊息取得

錯誤裡會直接給出 API 名稱和啟用連結，例如：

```
Error 403: Identity and Access Management (IAM) API has not been used ...
Enable it by visiting https://console.developers.google.com/apis/api/iam.googleapis.com/overview?project=...
```

照連結前往並啟用即可。

### 方法二：查 Terraform Provider 文件

使用 Terraform 的 `google` provider 時，可到 [Google Provider 文件](https://registry.terraform.io/providers/hashicorp/google/latest/docs) 查每個 resource 對應的 API，例如：

- `google_artifact_registry_repository` → Artifact Registry API
- `google_service_account` → IAM API
- `google_project_iam_member` → Cloud Resource Manager API
- `google_compute_instance` → Compute Engine API

### 方法三：本專案常用 API 清單

| API | 用途 |
|-----|------|
| `compute.googleapis.com` | GCE VM |
| `iam.googleapis.com` | Service Account |
| `cloudresourcemanager.googleapis.com` | IAM binding、專案層級權限 |
| `artifactregistry.googleapis.com` | Artifact Registry |
| `storage.googleapis.com` / `storage-api.googleapis.com` | GCS（state bucket） |

## 一次性啟用常用 API

```bash
gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  artifactregistry.googleapis.com \
  storage.googleapis.com \
  storage-api.googleapis.com \
  --project=YOUR_PROJECT_ID
```

## 檢查專案已啟用的 API

```bash
gcloud services list --enabled --project=YOUR_PROJECT_ID
```

## 注意事項

- 啟用 API 後，建議等 1–2 分鐘再重試
- 使用新 GCP 服務時，多半需要先啟用相關 API
