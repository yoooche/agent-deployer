# GCP：Bootstrap（一次性建立 state bucket）

## 為什麼需要 bootstrap

Terraform 使用 GCS backend 時，需要一個已存在的 bucket 來存放 state。這個 bucket 無法由 Terraform 自己建立（類似「誰來建立建構工具」的問題），因此需要單獨的 bootstrap 步驟。

## 做法

### 方式一：用 Terraform bootstrap（建議）

專案內已有 `terraform/bootstrap/`，執行：

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

會建立 `{project_id}-tfstate` bucket。

### 方式二：用 gcloud 手動建立

```bash
gcloud storage buckets create gs://YOUR_PROJECT_ID-tfstate --location=asia-east1
```

## bucket 名稱唯一性

GCS bucket 名稱在整個 GCP 全域必須唯一，建議包含 project_id：

- `{project_id}-tfstate`，例如 `your-agent-project-tfstate`

## 執行位置

Bootstrap 只需在**本機**執行一次，之後 GHA 直接使用該 bucket。不需要在 CI/CD 中執行 bootstrap。
