# agent-deployer

Reusable Terraform, Docker, and GitHub Actions scaffolding for deploying long-running agent runtimes on GCP.

This repository owns deployment infrastructure only. It should stay generic enough to deploy agents such as OpenClaw, Hermes, or future gateway/worker agents without absorbing the business logic of any one consumer application.

## What Belongs Here

- Agent runtime deployment patterns
- GCP VM, Artifact Registry, Terraform state, IAM, and SSH setup
- Docker image build/push/run conventions
- Agent runtime specs and examples
- Security, cost, and operations notes for hosted agents

## What Does Not Belong Here

- Domain schemas for a specific product
- Medical, finance, insurance, or family-care business logic
- User-facing dashboards
- Application-specific RAG pipelines
- Production secrets or local Terraform state

## Start Here

- [docs/README.md](docs/README.md) - documentation index
- [docs/architecture.md](docs/architecture.md) - repo boundary and deployment shape
- [docs/agent-spec.md](docs/agent-spec.md) - required contract for a deployable agent
- [docs/examples/openclaw.md](docs/examples/openclaw.md) - current OpenClaw runtime example
- [docs/examples/hermes.md](docs/examples/hermes.md) - planned Hermes runtime example
