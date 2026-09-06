# SwipeBuy V9.7 — AI Agent Marketplace & Task Marketplace 2.0

Adds a reusable AI-agent marketplace layer on top of the V9.6 action architecture.

## Included
- Browse published agents by category.
- Install an agent into a signed-in user's private installed-agent collection.
- Save agents into a private saved-agent collection.
- Publish reusable agent templates with title, description, category and steps.
- Marketplace metadata tracks installs, rating placeholders and timestamps.
- Real-world actions remain gated; this client does not claim that an installed agent can bypass confirmation or trusted backend processing.

## Firebase collections
- `ai_agent_marketplace`
- `users/{uid}/installed_agents/{agentId}`
- `users/{uid}/saved_agents/{agentId}`

Production follow-up should validate Firestore rules, add moderation/review flows, server-side counters and abuse controls before opening publishing broadly.
