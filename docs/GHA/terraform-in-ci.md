# GitHub Actions：在 CI 中執行 Terraform

## 重點

- Variables 未設定時，`${{ vars.GCP_PROJECT_ID }}` 等會是空字串
- 空字串會導致 `-backend-config="bucket=-tfstate"` 等錯誤
- 必須先在 GitHub 設定 Variables 和 Secrets

## Terraform 步驟範例

```yaml
- uses: google-github-actions/auth@v2
  with:
    credentials_json: ${{ secrets.GCP_SA_KEY }}

- uses: hashicorp/setup-terraform@v4
  with:
    terraform_wrapper: false

- name: Terraform init
  run: terraform init -backend-config="bucket=${{ vars.GCP_PROJECT_ID }}-tfstate"
  working-directory: terraform

- name: Terraform Apply
  run: terraform apply -auto-approve
  working-directory: terraform
```

## 傳遞變數給 Terraform

用 `env` 設定 `TF_VAR_*`：

```yaml
env:
  TF_VAR_project_id: ${{ vars.GCP_PROJECT_ID }}
  TF_VAR_ssh_pub_key: ${{ secrets.SSH_PUB_KEY }}
```

## Job 間傳遞 Terraform outputs

Terraform outputs 要寫入 `$GITHUB_OUTPUT`，才能在後續 job 使用：

```yaml
- name: Get Outputs
  id: outputs
  run: |
    echo "vm_external_ip=$(terraform output -raw vm_external_ip)" >> $GITHUB_OUTPUT
    echo "artifact_registry_url=$(terraform output -raw artifact_registry_url)" >> $GITHUB_OUTPUT
  working-directory: terraform
```

Job 的 `outputs` 要引用**正確的 step id**：

```yaml
outputs:
  vm_external_ip: ${{ steps.outputs.outputs.vm_external_ip }}
  artifact_registry_url: ${{ steps.outputs.outputs.artifact_registry_url }}
```

格式為：`steps.<step_id>.outputs.<output_name>`
