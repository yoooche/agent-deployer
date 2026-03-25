# agent-deployer 部署筆記

本目錄整理 Terraform、GCP、GitHub Actions、Docker 的實務經驗、常見錯誤與最佳作法。

## 目錄結構

```
docs/
├── GCP/
│   ├── required-apis.md      # 如何知道要啟用哪些 API
│   ├── iam-and-permissions.md   # IAM、授權、SA 權限
│   └── bootstrap.md         # GCS state bucket 一次性建立
├── Terraform/
│   ├── variables-and-secrets.md  # 變數來源、tfvars vs GitHub
│   ├── backend-gcs.md       # GCS backend、partial config
│   ├── import-existing.md   # 匯入既有資源
│   └── static-external-ip.md # 靜態外部 IP、與 CI 分工
├── GHA/
│   ├── variables-vs-secrets.md   # Variables 與 Secrets 差別
│   └── terraform-in-ci.md   # Terraform 在 CI 的執行方式
├── Docker/
│   └── artifact-registry.md # Artifact Registry push/pull
└── README.md                # 本檔
```

## 快速對照：常見錯誤與對應文件

| 錯誤或問題 | 參考文件 |
|------------|----------|
| API has not been used or is disabled | [GCP/required-apis.md](GCP/required-apis.md) |
| 403 permission denied on bucket | [GCP/iam-and-permissions.md](GCP/iam-and-permissions.md) |
| The caller does not have permission (IAM) | [GCP/iam-and-permissions.md](GCP/iam-and-permissions.md)（需 `projectIamAdmin`） |
| Required 'compute.zones.get' permission | [GCP/iam-and-permissions.md](GCP/iam-and-permissions.md)（需 `compute.viewer`） |
| Required 'compute.instances.create' permission | [GCP/iam-and-permissions.md](GCP/iam-and-permissions.md)（需 `compute.instanceAdmin.v1`） |
| bucket doesn't exist（terraform init） | [GCP/bootstrap.md](GCP/bootstrap.md) |
| backend 不能使用變數 | [Terraform/backend-gcs.md](Terraform/backend-gcs.md) |
| terraform.tfvars 在 GHA 無效 | [Terraform/variables-and-secrets.md](Terraform/variables-and-secrets.md) |
| 409 resource already exists | [Terraform/import-existing.md](Terraform/import-existing.md) |
| vars 空字串、bucket=-tfstate | [GHA/variables-vs-secrets.md](GHA/variables-vs-secrets.md) |
| job outputs 取不到值 | [GHA/terraform-in-ci.md](GHA/terraform-in-ci.md) |
| docker pull permission denied | [Docker/artifact-registry.md](Docker/artifact-registry.md) |
| unknown shorthand flag: 'f' in -f（docker compose） | [Docker/artifact-registry.md](Docker/artifact-registry.md)（需安裝 docker-compose-plugin） |
| docker: command not found（deploy via SSH） | [Docker/artifact-registry.md](Docker/artifact-registry.md)（SSH 非互動式時 PATH 過短） |
| SSH / port 22 逾時（curl 連 22 timeout） | 專案缺少允許 tcp:22 的防火牆；`main.tf` 已含 `google_compute_firewall` + VM `tags`，再執行 `terraform apply` |
