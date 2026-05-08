# Hermes Example

Hermes is a planned runtime target. It should be added as a second agent spec rather than by copying the OpenClaw workflow.

## Expected Runtime Data

To add Hermes, document:

- Dockerfile or upstream image
- container name
- config and memory paths
- required ports
- required secrets
- model provider configuration
- persistence and backup requirements
- health check
- supported messaging channels

## Provider Notes

Hermes supports provider-based model configuration. If using Codex OAuth or ChatGPT subscription-backed quota, record the setup as a provider option and keep it separate from OpenAI API-key billing.

## Persistence Notes

Hermes emphasizes memory, skills, and learning loops. Its persistent volume should be treated as important runtime state. Backups matter more than for a stateless gateway.

## Collaboration With OpenClaw

OpenClaw and Hermes should coordinate through shared application APIs or a routing layer, not by directly modifying each other's private state.

Recommended split:

- OpenClaw: messaging gateway and user-facing channel access
- Hermes: background summaries, learning workflows, scheduled analysis
- Consumer API: source of truth, permissions, audit, and domain logic
