# Docker：Artifact Registry

## 本專案流程

1. **GHA**：build 映像 → push 到 GCP Artifact Registry
2. **VM**：`gcloud auth configure-docker` → `docker pull` → `docker run`

## VM 需具備的條件

- 已安裝 Docker
- 已安裝 **Docker**（`docker.io` 即可；若無 `docker-compose-plugin` 可用 `docker run` 替代 compose）
- 已安裝 gcloud（或透過 VM metadata 取得 ADC）
- VM 使用的 SA 具備 `roles/artifactregistry.reader`

## Port 對應

每個 agent 的 port 應記錄在 [agent-spec.md](../agent-spec.md)。目前 OpenClaw 範例使用兩個 port：
- **18789**：WebSocket
- **18791**：HTTP Control UI（需 token）。SSH tunnel 時兩個都要轉發：
  `-L 18789:127.0.0.1:18789 -L 18791:127.0.0.1:18791`

## 映像 URL 格式

```
{region}-docker.pkg.dev/{project_id}/{repository_id}/{image}:{tag}
```

例如：`asia-east1-docker.pkg.dev/your-agent-project/agent-artifact-registry/openclaw:latest`

## 常見錯誤

| 錯誤 | 原因 | 解法 |
|------|------|------|
| permission denied | VM SA 無 Artifact Registry 讀取權 | 授權 `roles/artifactregistry.reader` |
| unauthorized | Docker 未設定 gcloud cred helper | 在 VM 上執行 `gcloud auth configure-docker REGION-docker.pkg.dev` |
| unknown shorthand flag: 'f' in -f | VM 未安裝 Docker Compose plugin | `sudo apt-get install -y docker-compose-plugin`，或改用 standalone `docker-compose` |
| docker: command not found（非互動式 SSH） | PATH 過短或 docker 未安裝 | 先 `apt-get install -y docker.io`，再用 \`DOCKER=\$(which docker)\` 取得路徑 |
| /usr/bin/docker: No such file or directory | VM 上 docker 未安裝或路徑不同 | 在 deploy 步驟開頭執行 `apt-get install -y docker.io` |
| Unable to locate package docker-compose-plugin | Debian 預設 repo 無此 package | 改用 `docker run` 取代 `docker compose`，或加入 Docker 官方 APT 源 |
