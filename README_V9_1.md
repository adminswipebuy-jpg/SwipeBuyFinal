# SwipeBuy V9.1 — AI Automation & Personal Assistant 2.0

V9.1 adds a persistent automation layer for the AI assistant. Users can save repeatable routines, choose a schedule, pause/resume them, and delete them.

## Included
- AI Automation 2.0 page
- Firestore `ai_automations` data model
- Create / pause / resume / delete controls
- Profile entry point
- Backend-first execution contract: this client stores routines only; trusted backend scheduling/execution should perform real actions and notifications.

## Production note
Scheduler/worker execution is intentionally not claimed here. Connect Cloud Scheduler/Functions or another trusted backend worker before presenting automations as active real-world execution.
