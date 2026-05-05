# GCP VM：SSH 排查筆記

## 先分兩條路

| 狀況 | 代表什麼 |
|------|----------|
| **Cloud Shell** 裡 `gcloud compute ssh` 能進 VM | VM、`sshd`、防火牆與對外 IP 大致正常；問題多半在 **本機網路** 或 **本機 SSH 設定／金鑰** |
| **本機** `ssh` 逾時 | 常見：電信／公司／路由器 **擋出站 TCP 22**；可換手機熱點對照 |
| **本機** `Permission denied` | **使用者** 或 **私鑰** 與 VM metadata 不一致（本專案使用者為 `louis-agent`） |

重啟 VM **不會**自動修好「連錯 IP」或「家裡網路擋 22」這類問題。

## `gcloud compute ssh … --troubleshoot`

- 會用 **Network Intelligence** 做連線測試；若 **forward / return 皆 REACHABLE**，表示從 **Cloud Shell 當下的對外 IP** 到 VM 外部 IP，在 GCP 側量到的路徑是通的。
- 過程可能詢問是否啟用 `networkmanagement.googleapis.com`、`monitoring.googleapis.com` 等 API，允許即可跑完檢查。

## `gcloud compute ssh`（不加 `--troubleshoot`）

- 畫面上若出現 **Updating project ssh metadata**，代表 gcloud 把 **Cloud Shell 產生的公鑰** 寫進 **專案 metadata**，再用對應私鑰登入；**與你本機 `~/.ssh` 裡那把 key 無必然關係**。
- 本機要能登入，仍需 **對應 Terraform `ssh_pub_key` 的那把私鑰**，且 `HostName` 為 **目前** VM 對外 IP。

## 靜態 IP 套用後：本機還連舊 IP

若 VM 曾用 ephemeral IP，**第一次**把 `google_compute_address` 綁上後，對外 IP **可能從舊的變成靜態 IP**（見 [Terraform/static-external-ip.md](../Terraform/static-external-ip.md)）。

- 請把 **`~/.ssh/config` 裡 `Host` 的 `HostName`** 改成 Terraform output / Console 上看到的 **目前 IP**。
- OpenSSH 若提示：`This host key is known by the following other names/addresses: … 某舊 IP`，代表 **同一台機器、同一組 host key**，只是你以前用別的 IP連過；屬正常提示，接受指紋後會把新 IP 寫入 `known_hosts`。

## `known_hosts` 是什麼（你沒特別「用」也會有）

- 檔案通常在 **`~/.ssh/known_hosts`**，由 **OpenSSH 客戶端自動讀寫**，不是你手動開的程式。
- 第一次連某主機時會記下對方的 **host key**（伺服器身分）；之後再連會比對，避免連到被換過的中間機器。
- 只要用過 `ssh` / `scp` / 走 SSH 的 `git`，幾乎都會有這個檔案；平常不必編輯，除非出現 **REMOTE HOST IDENTIFICATION HAS CHANGED** 或想清掉已作廢的舊 IP 列。

## 本專案對照（Terraform）

- 防火牆：`target_tags = ["agent-ssh"]`，VM 帶同一 tag；`ssh_source_ranges` 預設為 `0.0.0.0/0` 時，不應因「來源 CIDR」挡掉一般家裡 IP。
- metadata：`ssh-keys = "louis-agent:${var.ssh_pub_key}"` → 登入帳號為 **`louis-agent`**。

## 仍要繞過本機擋 22 時

可評估 **IAP TCP 轉發**（`gcloud compute ssh --tunnel-through-iap` 等），需額外防火牆允許 IAP 位址範圍；細節以官方文件為準。
