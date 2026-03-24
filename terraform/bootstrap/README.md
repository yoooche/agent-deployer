# Terraform Bootstrap

Creates the GCS bucket used by the main Terraform config for remote state.

## When to run

**Once**, before your first `terraform init` in the main config. Run locally only.

## Prerequisites

- `gcloud` CLI installed and authenticated
- `terraform` CLI installed

## Steps

```bash
# From this directory (terraform/bootstrap/)
terraform init
terraform plan    # Review: will create 1 bucket
terraform apply   # Create the bucket
```

## Bucket name

The bucket is named `{project_id}-tfstate` (e.g. `my-project-tfstate`) for global uniqueness.

## After bootstrap

Once the bucket exists, run the main Terraform (from `terraform/`):

```bash
cd ..   # to terraform/
terraform init -backend-config="bucket=YOUR_PROJECT_ID-tfstate"
terraform plan
terraform apply
```

Use your GCP project ID (e.g. `openclaw-louis-agent-tfstate`).
