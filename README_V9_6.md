# SwipeBuy V9.6 — AI Real-World Actions 3.0

Adds a controlled action orchestration layer that lets users stage real-world SwipeBuy actions without the client claiming they were completed.

## Included
- AI Real-World Actions screen
- Intent-based action staging for checkout, booking, job application, message drafts, saves and discovery
- Explicit user confirmation for sensitive actions
- User-scoped `ai_action_requests` collection
- Action history with staged/confirmed/cancelled states
- Profile entry point

## Production note
A trusted backend/Cloud Functions worker should execute confirmed actions and verify transaction outcomes. The client only creates/stages requests and records user confirmation; it must not mark payments, bookings, messages or submissions as completed.

Version: `9.6.0+72`
