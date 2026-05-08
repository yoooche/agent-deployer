# Model Providers

Agent runtimes may support different model providers. This repo should record provider expectations at the deployment boundary, not application prompts or private credentials.

## Provider Types

| Provider type | Credential style | Billing style | Notes |
|---------------|------------------|---------------|-------|
| ChatGPT/Codex OAuth | OAuth token/session | ChatGPT Plus/Pro or Codex quota when supported | Used by some agent runtimes through an `openai-codex` or `codex` provider. Not the same as OpenAI API billing. |
| OpenAI API | `OPENAI_API_KEY` | OpenAI Platform API billing | Better for production predictability and service accounts. Separate from ChatGPT subscription. |
| OpenRouter | `OPENROUTER_API_KEY` | OpenRouter billing | Useful for model choice and cost routing. |
| Local model endpoint | base URL/token | host cost | Works with self-hosted vLLM, Ollama, or compatible OpenAI-style APIs. |

## Deployment Guidance

- Treat provider credentials as secrets.
- Record which provider a runtime expects in its agent spec.
- Do not assume ChatGPT Plus means OpenAI API credits.
- Do not bake provider tokens into Docker images.
- Prefer provider-neutral environment names in generic deployer code, and map them to agent-specific names at render time.

## Open Questions

- Which providers should be officially tested in CI?
- Should OAuth-based providers be treated as development-only or supported for production?
- Should each agent have isolated credentials, even when using the same model provider?
