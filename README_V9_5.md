# SwipeBuy V9.5 — AI Proactive Assistant & Smart Alerts 3.0

Adds a user-scoped proactive alert layer for prices, jobs, property, deals, events and content.

## Included
- Proactive AI alert creation screen
- Alert types and cadence controls
- Pause/resume/delete controls
- User-scoped `users/{uid}/ai_proactive_alerts` collection
- Profile entry point
- Backend-first trigger/verification architecture

## Production note
This milestone stores alert preferences and provides the client control plane. A trusted backend/Cloud Functions worker should evaluate external or transactional conditions and send notifications; the client must not self-verify purchases, payments or other sensitive outcomes.

Version: `9.5.0+71`
