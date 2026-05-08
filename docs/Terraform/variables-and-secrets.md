# Terraform：變數與機密

## 本機 vs CI 的變數來源

| 執行環境 | 變數來源 | 說明 |
|----------|----------|------|
| 本機 | `terraform.tfvars` | Terraform 自動讀取，方便反覆 plan/apply |
| GitHub Actions | `TF_VAR_*` 環境變數 | 從 GitHub Variables / Secrets 傳入 |

## terraform.tfvars 的用途

- 本機執行時提供變數值，不必每次輸入
- 被 `.gitignore` 排除，不會被 commit（含 project_id、ssh_pub_key 等）
- CI 中不會存在，因此 GHA 需從 GitHub Variables / Secrets 傳入

## TF_VAR_ 規則

環境變數 `TF_VAR_foo` 會對應到 Terraform 變數 `var.foo`。例如：

```
TF_VAR_project_id  → var.project_id
TF_VAR_ssh_pub_key → var.ssh_pub_key
```

## 變數 vs 機密

- 非敏感：用 Variables（專案 ID、region、機器型號等）
- 敏感：用 Secrets（SA key、SSH 私鑰、token）
