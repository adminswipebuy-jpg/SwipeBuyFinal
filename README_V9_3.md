# SwipeBuy V9.3 — AI Memory & Personal Context 2.0

Added a user-controlled AI memory layer for personalization.

## Highlights
- Save preference/context memories with categories.
- Pause or delete memories at any time.
- User-scoped Firestore storage under `users/{uid}/ai_memory`.
- Designed for future personalization and AI-agent context injection.
- Sensitive actions remain confirmation-gated and backend-controlled.

## Important
This is a source milestone. Flutter/Dart compilation and Firebase Rules validation require a configured Flutter/Firebase development environment. The memory collection should be protected with rules that only allow the owning authenticated user to read/write their own documents.
