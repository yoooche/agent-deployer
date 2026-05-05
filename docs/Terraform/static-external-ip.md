# Terraform：靜態外部 IP

## 目的

`google_compute_address` 在專案區域內保留一顆 **靜態外部 IP**，並綁在 GCE VM 上。之後僅更新映像、不重建 VM 時，**公網 IP 不變**；也比純 ephemeral IP 更利於冪等與 SSH 設定。

## 本專案實作

- Resource：`google_compute_address.vm_public`，名稱 `{vm_name}-ip`
- VM `access_config.nat_ip` 指向該 address
- Output `vm_external_ip` 為該靜態 IP

## 第一次套用後

若 VM 先前使用 ephemeral IP，**第一次** `terraform apply` 會建立保留位址並改綁 VM，對外 IP **可能會變一次**；之後在不再刪除該 `google_compute_address` 的前提下，同一顆 IP 會持續使用。IP 變更後請同步本機 **`~/.ssh/config` 的 `HostName`**，否則本機仍連舊位址會逾時或異常；排查說明見 [GCP/ssh-troubleshooting.md](../GCP/ssh-troubleshooting.md)。

## CI 權限

建立保留 IP 需要 `compute.addresses.create` 等權限，CI SA 需 **`roles/compute.networkAdmin`**（已列入 `scripts/grant-ci-permissions.sh`）。

## 與 workflow 分工

- 僅變更 `terraform/**` 或手動 `workflow_dispatch` 時會跑 `terraform apply`
- 僅變更 Docker / 其他檔案時只跑 build + deploy，並用 `gcloud compute instances describe` 取得目前 VM IP（與靜態 IP一致）
