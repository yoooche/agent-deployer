# Kumi MVP Architecture

This document defines the first shippable shape for Kumi family operations. It is intentionally small. The goal is to prove one useful loop before adding Paperclip, creating a Spring Boot backend, renaming projects, rebuilding infrastructure, or making the system beautiful.

## MVP Rule

Make the ugly version work first.

After the MVP proves the loop, it is allowed to create a cleaner GCP project, rename repositories, and rebuild the GCE setup as a reward. Until then, naming cleanup is tracked as future work unless it blocks safety or the first real workflow.

## First Useful Loop

The MVP is successful when this works end to end:

```text
Family member asks in Telegram or LINE:
  "這週媽媽有哪些事情？"

OpenClaw receives the message.
OpenClaw calls a stable Kumi tool.
The tool checks Supabase family task data.
The bot replies with this week's tasks and clear ownership.
The tool call and important state changes are auditable.
```

This loop matters more than a clean repo name, a new GCP project, or a perfect dashboard.

## System Roles

```text
Telegram / LINE
  Human entry point for quick questions, approvals, reminders, and updates.

OpenClaw
  Conversation-facing agent runtime. It talks to people and routes requests.

Paperclip
  Phase 2 operating layer. It becomes useful when chat is no longer enough for
  task coordination, approvals, recurring work, and agent run history.

Supabase Postgres
  Kumi domain database. It stores family-care product data such as family
  members, appointments, care tasks, documents, and admin records.

Kumi tools
  Controlled API/tool layer that lets agents read or write Kumi data without
  receiving raw database credentials.

GCE VM
  First MVP host for OpenClaw. It may also host Paperclip later if Phase 2 needs
  an agent office and task panel.
```

## Phase Plan

### Phase 1: OpenClaw + Supabase Tools

This is the MVP critical path.

```text
Telegram / LINE
  -> OpenClaw
  -> Stable Kumi tool contract
  -> Supabase RPC / REST / Edge Functions
  -> Supabase Postgres
```

Use this phase to prove that a family-facing bot can reduce coordination load. Do not add Paperclip just because it is interesting.

Phase 1 success means:

- the bot can answer this week's family tasks
- the bot can create or complete a low-risk task
- tool calls are logged
- Supabase permissions do not expose sensitive data
- you and your sister can use the flow without opening a dashboard

### Phase 2: Paperclip As Operating Layer

Add Paperclip only when OpenClaw chat starts to feel insufficient.

Paperclip becomes justified when at least two of these are true:

- active family tasks exceed 30 items
- you and your sister need a dashboard to see open loops
- background routines run more than 10 times per week
- approvals become common enough to need a board
- it becomes hard to tell who did what
- there is more than one agent runtime
- Telegram or LINE threads become too messy to recover context
- a second company, such as the Shopee business, starts sharing the same operating model

Until then, Paperclip stays in the parking lot.

### Phase 3: Spring Boot Or Kumi API

Add a dedicated backend when Supabase tools are no longer enough.

The Spring Boot or `kumi-api` layer should replace the tool implementation, not the tool contract.

```text
OpenClaw
  -> Same stable Kumi tools
  -> Spring Boot Kumi API
  -> Supabase Postgres
```

This phase is for stronger auth, authorization, audit, validation, approval gates, document workflows, idempotency, and test coverage.

## Database Boundary

Paperclip Postgres and Supabase Postgres may coexist once Paperclip enters Phase 2.

They do not serve the same purpose.

| Database | Owner | Stores | Do not use it for |
| --- | --- | --- | --- |
| Paperclip Postgres | Paperclip | Agents, issues, runs, comments, approvals, heartbeats, budgets, activity logs | Family domain data or long-term app data |
| Supabase Postgres | Kumi | Family members, appointments, care notes, documents, financial/admin records | Paperclip internal state |

Paperclip is allowed to reference Supabase records by ID or link. It should not become the family data warehouse.

Supabase is allowed to expose controlled tools to agents. It should not store Paperclip's internal agent runtime state.

## Current Infrastructure

Current usable infrastructure:

- GCP project: `openclaw-louis-agent`
- VM: `openclaw-vm`
- Zone: `asia-east1-a`
- Machine type: `e2-small`
- Current OpenClaw ports:
  - `127.0.0.1:18789`
  - `127.0.0.1:18791`
- Current OpenClaw state path:
  - `/home/louis-agent/.openclaw`

Possible Phase 2 addition:

- Paperclip state path:
  - `/home/louis-agent/.paperclip`
- Paperclip port:
  - bind privately first, preferably localhost or Tailscale-only

The VM may host both OpenClaw and Paperclip after Phase 1 if Paperclip is justified. This is acceptable because the goal is product validation, not infrastructure elegance.

## Repository Boundary

Keep these concerns separate.

```text
agent-deployer
  GCE, Docker, Terraform, deployment docs, runtime specs.
  It may describe OpenClaw deployment now and Paperclip deployment later.
  It must not contain family-care business logic.

kumi-brain-sql
  Supabase schemas, migrations, RLS policies, seed data.
  It owns the Kumi domain data model.

kumi-tools or kumi-api
  Controlled tool/API layer.
  It mediates agent access to Supabase.

paperclip
  Upstream external project.
  Do not fork it into this repo for MVP.

openclaw
  External agent runtime.
  Use it as a deployed service, not as Kumi's source of truth.
```

## Access Pattern

Preferred MVP flow:

```text
Human
  -> Telegram / LINE
  -> OpenClaw
  -> Kumi tool contract
  -> Supabase
```

Possible Phase 2 review flow:

```text
Human
  -> Browser
  -> Paperclip panel
```

Telegram and LINE are the remote-work interface. Paperclip is the office only if Phase 2 needs an office.

## Tool Strategy

Agents should use tools with stable domain names, not raw SQL. The tool surface should stay stable while the implementation changes underneath it.

Good first tools:

- `list_weekly_family_tasks`
- `create_family_task`
- `mark_family_task_done`
- `list_upcoming_appointments`
- `record_care_note`
- `get_family_member_summary`

The agent-facing contract should look like business operations:

```json
{
  "name": "list_weekly_family_tasks",
  "description": "List family tasks due in a date range for the current actor's family.",
  "input": {
    "from": "2026-05-14",
    "to": "2026-05-21",
    "assignee": "optional"
  }
}
```

Avoid table-shaped tools such as `query_table`, `run_sql`, or `select_from_kumi_core`.

Avoid giving agents:

- raw `DATABASE_URL`
- Supabase `service_role` key
- arbitrary SQL execution
- unrestricted document export

Implementation path:

1. Phase 1: Supabase REST with strict RLS for read-only demo data.
2. Phase 1: Supabase RPC functions for domain-specific tools.
3. Phase 1 or 2: Supabase Edge Functions for validation, audit, and sensitive actions.
4. Phase 3: Spring Boot or another dedicated `kumi-api` service once the domain needs stronger boundaries.

The key rule: replace the implementation, not the tool names.

## Safety Rules

These are not cleanup preferences. These are MVP blockers.

- Do not store real medical, legal, financial, or identity documents in an anon-readable table.
- Do not expose Supabase service role keys to OpenClaw, Paperclip agents, browser code, or prompts.
- Do not add Paperclip to the MVP critical path unless it solves an observed coordination problem.
- Do not rely on agent memory as the source of truth for family records.
- Do not let agents perform high-risk write actions without human approval.
- Do not mix unrelated trust boundaries in one chat without allowlists.

Acceptable temporary ugliness:

- GCP project name is not final.
- VM name is not final.
- OpenClaw runs alone first.
- Paperclip is deferred to Phase 2.
- Tools are small and incomplete.
- UI is mostly Telegram/LINE plus Supabase-backed tools.

## Seven-Day MVP Checklist

1. Keep OpenClaw running as the Telegram or LINE-facing runtime.
2. Add a safe Supabase table for family tasks or appointments.
3. Remove or replace any anon read-all policy before using real family data.
4. Define the stable tool contract for `list_weekly_family_tasks`.
5. Implement `list_weekly_family_tasks` through Supabase RPC, REST, or Edge Functions.
6. Add a minimal audit log for tool calls.
7. Make the bot answer: `這週媽媽有哪些事情？`

Only after this works should cleanup projects begin.

## Post-MVP Cleanup Rewards

Once the first loop is working with real usage, these become allowed cleanup tasks:

- Create a clean GCP project name.
- Recreate GCE with clearer VM naming.
- Rename repositories.
- Add Tailscale or a private access layer if not already done.
- Add a dedicated `kumi-tools` or `kumi-api` repo.
- Add Paperclip if the Phase 2 threshold is reached.
- Add Spring Boot or another dedicated backend if Supabase tools become too weak.

Cleanup is earned by working software.

## Open Questions

- Should the first human-facing channel be Telegram only, or LINE for family adoption?
- Should Supabase own only domain records, or also lightweight conversation state?
- Should sensitive actions use passkeys/WebAuthn step-up auth in MVP or post-MVP?
- What exact threshold will trigger adding Paperclip?
- Which one weekly family report should the system send first?
