# SwipeBuy V9.2 — AI Agents & Multi-Step Tasks 2.0

V9.2 adds an AI-agent planning layer. Users can describe a goal, SwipeBuy can break it into a multi-step plan, save the plan to Firestore, and request trusted backend execution.

## Included
- AI Agents 2.0 page
- Goal-to-plan intent detection for shopping, jobs, property, travel and general discovery
- Four-step plan templates with action labels
- Agent task persistence in `ai_agent_runs`
- Queue/cancel controls
- Explicit sensitive-action confirmation flag
- Profile and main app entry points

## Production boundary
The Flutter client does **not** claim to execute purchases, bookings, transfers, publishing or other real-world actions. `requestExecution()` only marks a saved task as queued. A trusted backend worker must validate permissions, perform each step, enforce confirmations, and write authoritative execution results.
