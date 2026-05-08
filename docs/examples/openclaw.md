# OpenClaw Example

OpenClaw is the current concrete runtime in this repo.

## Runtime

- Image source: `ghcr.io/openclaw/openclaw:latest`
- Local Dockerfile: [docker/Dockerfile](../../docker/Dockerfile)
- Container name: `openclaw-gateway`
- Gateway port: `18789`
- Control UI port: `18791`
- Persistent path on VM: `/home/louis-agent/.openclaw`

## Environment

Required:

- `OPENCLAW_GATEWAY_TOKEN`

Common:

- `NODE_ENV=production`
- `OPENCLAW_GATEWAY_BIND=lan`
- `OPENCLAW_GATEWAY_PORT=18789`
- `TERM=xterm-256color`

## Channels

OpenClaw can act as a shared gateway for multiple chat channels. For family or team use, configure allowlists per channel and avoid mixing unrelated trust boundaries in one runtime.

## Provider Notes

OpenClaw can use API-key providers and, when configured, ChatGPT/Codex OAuth-style providers. Treat OAuth tokens as sensitive runtime secrets and expect quota limits that differ from OpenAI API billing.

## Deployment Notes

The current workflow still contains OpenClaw-specific image names, container name, ports, environment variables, and volume paths. The generic target is to move these values into an agent spec.
