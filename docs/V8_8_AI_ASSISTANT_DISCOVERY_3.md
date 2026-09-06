# SwipeBuy V8.8 — AI-Powered Personal Assistant & Discovery 3.0

## Added
- Dedicated AI Assistant workspace with a co-pilot style interface.
- Cross-platform natural language search using the existing Universal AI service.
- Lightweight intent detection for shopping, jobs, property, travel, education, sports, finance, services and general discovery.
- Contextual next-best-action suggestions such as compare, nearby, filters and save-search actions.
- Recent assistant history persisted in `ai_assistant_history`.
- Quick prompt examples for common SwipeBuy journeys.

## Production notes
- The assistant remains a routing/discovery foundation, not a general-purpose LLM.
- Sensitive actions such as purchases, bookings, withdrawals or other account changes must remain behind explicit confirmation and trusted backend authorization.
- The `ai_assistant_history` collection should be protected with production Firestore rules that restrict reads/writes to the authenticated owner and/or a trusted backend.
- For large-scale deployment, move discovery and ranking to server-side indexes and model services rather than client-side Firestore scans.
