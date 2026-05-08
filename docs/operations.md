# Operations

## First Deployment Checklist

1. Create or select a GCP project.
2. Enable required APIs.
3. Create the Terraform state bucket with `terraform/bootstrap`.
4. Create the CI service account and grant required roles.
5. Configure GitHub Variables and Secrets.
6. Run the deployment workflow manually.
7. SSH to the VM and confirm the container is running.
8. Confirm the gateway/control ports are only reachable as intended.

## GitHub Configuration

Required repository variables:

- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCP_ZONE`
- `VM_NAME`
- `VM_MACHINE_TYPE`
- `ARTIFACT_NAME`

Required repository secrets:

- `GCP_SA_KEY`
- `SSH_PUB_KEY`
- `SSH_PRIVATE_KEY`
- agent-specific runtime tokens

## Common Commands

```bash
terraform init -backend-config="bucket=YOUR_PROJECT_ID-tfstate"
terraform plan
terraform apply
```

```bash
gcloud compute ssh louis-agent@VM_NAME --zone=ZONE --project=PROJECT_ID
```

```bash
sudo docker ps
sudo docker logs --tail=200 CONTAINER_NAME
```

## When Deployment Fails

- Terraform init fails: check state bucket and `GCP_PROJECT_ID`.
- Terraform apply fails: check CI service account roles and enabled APIs.
- Docker push fails: check Artifact Registry role and Docker auth.
- SSH fails: check VM IP, metadata SSH key, firewall, and source network.
- Container exits: inspect logs and required environment variables.

## Restart Packet

When pausing work on this repo, update:

- [README.md](../README.md) if the repo purpose changed
- [agent-spec.md](agent-spec.md) if runtime requirements changed
- [costs.md](costs.md) if billing assumptions changed
- [security.md](security.md) if exposure or secret handling changed
