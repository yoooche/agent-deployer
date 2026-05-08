# Terraform：GCS Backend

## 為什麼用 -backend-config

`backend "gcs"` 區塊**不能使用變數**，因此無法寫成：

```hcl
backend "gcs" {
  bucket = var.project_id  # Error!
}
```

解法是使用 partial config，在 `terraform init` 時用 `-backend-config` 傳入 bucket 名稱。

## 本機 init

```bash
terraform init -backend-config="bucket=YOUR_PROJECT_ID-tfstate"
```

## GHA init

```yaml
- run: terraform init -backend-config="bucket=${{ vars.GCP_PROJECT_ID }}-tfstate"
  working-directory: terraform
```

## Bucket 名稱約定

必須與 bootstrap 建立的 bucket 一致：`{project_id}-tfstate`。
