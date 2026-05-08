# Architecture

`agent-deployer` deploys agent runtimes. It does not own the application data model or product-specific workflows that agents may call.

## Current Shape

```text
GitHub Actions
  -> Terraform apply when infrastructure changes
  -> Docker build and push to Artifact Registry
  -> SSH to GCE VM
  -> docker run agent container

GCE VM
  -> long-running agent gateway or worker
  -> local persistent volume for agent config/state
  -> private localhost ports by default

Consumer application
  -> separate API, database, dashboard, and domain logic
  -> exposes tools or APIs for the agent to call
```

## Repository Boundary

This repo should contain reusable deployment material:

- Terraform modules and variables for shared infrastructure
- Docker runtime conventions
- GitHub Actions deployment flow
- Agent specs and examples
- Operational runbooks

This repo should not contain consumer app logic:

- family-care schemas
- medical, insurance, finance, or sensor workflows
- dashboard implementation
- domain RAG ingestion rules
- private documents or production data

## Deployment Units

The deployer should treat each agent as a runtime unit described by an agent spec:

- image source
- container name
- ports
- volumes
- environment variables and secrets
- health check
- persistence requirements
- supported channels
- operational notes

OpenClaw is the first runtime example. Hermes should be added as another spec, not by duplicating the whole deployment workflow.

## Direction

The next architecture step is to make the current OpenClaw-specific workflow consume an agent spec. Until then, OpenClaw remains the concrete implementation and the docs define the generic target shape.
