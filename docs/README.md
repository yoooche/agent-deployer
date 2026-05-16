# agent-deployer Docs

This directory documents how to deploy generic long-running agent runtimes. OpenClaw is the current concrete example, but the repo should stay useful for Hermes and other future agents.

## 目錄結構

```
docs/
├── architecture.md       # repo boundary and deployment shape
├── agent-spec.md         # generic contract for deployable agents
├── providers.md          # model provider and billing modes
├── costs.md              # cost drivers and MVP/production patterns
├── security.md           # hosted-agent security posture
├── operations.md         # deployment and recovery checklist
├── kumi-mvp-architecture.md # Kumi family-ops MVP boundaries and first loop
├── examples/
│   ├── openclaw.md       # current runtime example
│   └── hermes.md         # planned runtime example
├── GCP/
│   ├── required-apis.md      # 如何知道要啟用哪些 API
│   ├── iam-and-permissions.md   # IAM、授權、SA 權限
│   ├── bootstrap.md         # GCS state bucket 一次性建立
│   └── ssh-troubleshooting.md  # SSH 逾時／本機 vs Cloud Shell、known_hosts、靜態 IP 後改 HostName
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

## Start Here

1. Read [architecture.md](architecture.md) to understand what belongs in this repo.
2. Read [agent-spec.md](agent-spec.md) before adding a new agent runtime.
3. Use [operations.md](operations.md) when setting up or debugging a deployment.
4. Read [kumi-mvp-architecture.md](kumi-mvp-architecture.md) before changing Kumi service boundaries or renaming infrastructure.
5. Use [examples/openclaw.md](examples/openclaw.md) and [examples/hermes.md](examples/hermes.md) as runtime-specific references.

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
| SSH / port 22 逾時（curl 連 22 timeout） | 專案缺少允許 tcp:22 的防火牆；`main.tf` 已含 `google_compute_firewall` + VM `tags`，再執行 `terraform apply`；若 Cloud Shell 可連、本機逾時見 [GCP/ssh-troubleshooting.md](GCP/ssh-troubleshooting.md) |
| Cloud Shell 可 SSH、本機不行；或換靜態 IP後突然又可連 | [GCP/ssh-troubleshooting.md](GCP/ssh-troubleshooting.md)（本機擋 22、`HostName` 舊 IP、`known_hosts` 提示） |
