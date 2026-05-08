# Agent Spec

Every deployable agent should be described by a small runtime spec. The spec is the contract between agent-specific runtime needs and generic infrastructure.

## Required Fields

```yaml
agent:
  id: openclaw
  displayName: OpenClaw
  image:
    dockerfile: docker/openclaw/Dockerfile
    repositoryName: openclaw
  runtime:
    containerName: openclaw-gateway
    user: louis-agent
    ports:
      - host: 127.0.0.1:18789
        container: 18789
        purpose: websocket
      - host: 127.0.0.1:18791
        container: 18791
        purpose: control-ui
    volumes:
      - host: /home/louis-agent/.openclaw
        container: /home/node/.openclaw
        purpose: config-and-state
    environment:
      static:
        NODE_ENV: production
        TERM: xterm-256color
      secrets:
        - OPENCLAW_GATEWAY_TOKEN
      optional:
        OPENCLAW_GATEWAY_BIND: lan
        OPENCLAW_GATEWAY_PORT: "18789"
  healthcheck:
    type: http
    url: http://127.0.0.1:18791
  channels:
    - telegram
    - line
    - wechat
  persistence:
    required: true
    backup: manual
```

## Design Rules

- The spec names runtime requirements; Terraform should stay mostly agent-neutral.
- Default port bindings should use `127.0.0.1` unless the operator explicitly exposes a public service.
- Secrets must come from GitHub Secrets or a cloud secret manager.
- Persistent state must live outside the container.
- Agent tool access should be read-only by default.
- Write actions should support human approval when the agent touches sensitive systems.

## Future Shape

The deployment workflow can evolve from hard-coded OpenClaw commands to a matrix:

```yaml
strategy:
  matrix:
    agent: [openclaw, hermes]
```

Each matrix entry would load the matching spec and render a `docker run` command or compose file.
