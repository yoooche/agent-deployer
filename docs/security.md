# Security

Hosted agents can bridge private chat channels, shell commands, documents, and application APIs. Default posture should be conservative.

## Defaults

- Bind control and gateway ports to `127.0.0.1`.
- Require SSH tunnel or explicit reverse proxy configuration for remote access.
- Restrict SSH source ranges for production.
- Store secrets in GitHub Secrets or a cloud secret manager.
- Keep persistent agent state outside containers.
- Use separate credentials per agent runtime.
- Log tool calls that touch sensitive systems.

## Sensitive Data

Agents should not be the source of truth for medical, insurance, finance, or identity data. Consumer applications should expose controlled APIs with:

- authentication
- authorization
- audit logs
- source citations for document answers
- read-only tools by default
- human approval for write actions

## Channel Access

When an agent is connected to messaging platforms:

- use allowlists for user IDs or channel IDs
- treat group chats as higher risk than direct chats
- avoid sending full raw documents unless explicitly requested and authorized
- separate family/work/personal contexts when trust boundaries differ

## Deployment Checks

Before using a deployment with real users:

- verify ports are not publicly exposed unintentionally
- verify secrets are not printed in logs
- verify persistent volumes survive container replacement
- verify token rotation path
- verify rollback path
