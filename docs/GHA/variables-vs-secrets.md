# GitHub Actions：Variables vs Secrets

## 差異

| | Variables | Secrets |
|---|-----------|---------|
| 用途 | 非敏感設定 | 密鑰、token、私鑰 |
| 範例 | project_id、region | GCP_SA_KEY、SSH_PRIVATE_KEY |
| 顯示 | 在 logs 中以 `***` 遮蔽 | 完全不顯示 |

## 本專案 Variables

到 Repo → Settings → Secrets and variables → Actions → **Variables**：

| 變數 | 範例值 |
|------|--------|
| GCP_PROJECT_ID | your-agent-project |
| GCP_REGION | asia-east1 |
| GCP_ZONE | asia-east1-a |
| VM_NAME | agent-vm |
| VM_MACHINE_TYPE | e2-small |
| ARTIFACT_NAME | agent-artifact-registry |

## 本專案 Secrets

到 Repo → Settings → Secrets and variables → Actions → **Secrets**：

| Secret | 來源 |
|--------|------|
| GCP_SA_KEY | 服務帳號 JSON 檔案內容 |
| SSH_PUB_KEY | VM SSH public key 內容 |
| SSH_PRIVATE_KEY | VM SSH private key 內容 |
| Agent runtime token | 依 agent spec 定義，例如 `OPENCLAW_GATEWAY_TOKEN` |

## 判斷原則

- 密鑰、密碼、token → Secrets
- 專案 ID、region、機器名稱等 → Variables
