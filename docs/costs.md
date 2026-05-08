# Costs

This repo should optimize for a low fixed-cost MVP while keeping a clean path to production hardening.

## Main Cost Drivers

- Always-on VM for the agent gateway
- Artifact Registry storage and egress
- Database tier used by the consumer application
- Object storage for documents and artifacts
- LLM quota or API usage
- OCR, embedding, and scheduled batch jobs
- Logs, backups, and retention

## Low-Cost MVP Pattern

```text
Agent runtime       GCP Compute Engine small VM
Consumer Java API   Cloud Run
Database/RAG        Supabase Postgres + pgvector
Files               Supabase Storage or GCS
LLM                 ChatGPT/Codex OAuth first, API billing later if needed
```

This keeps the agent long-running while allowing the Java API to scale to zero or low usage.

## Production Pattern

```text
Agent runtime       GCP Compute Engine or managed container runtime
Consumer Java API   Cloud Run
Database/RAG        Cloud SQL PostgreSQL + pgvector or managed Postgres
Files               GCS
Secrets             Secret Manager
Logs/Audit          Cloud Logging
```

This usually costs more but improves control, backups, IAM, and auditability.

## Cost Rules

- Keep agent VM size small until real load proves otherwise.
- Avoid Cloud SQL in the first prototype unless governance requirements demand it.
- Track LLM usage separately from infrastructure cost.
- Add budgets and alerts before inviting non-developer users.
- Record any paid service upgrade in this file with the reason and revisit date.
