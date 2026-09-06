# SwipeBuy V4.8 — Rich Messaging + Community Media

V4.8 extends V4.7 with richer user communication and community content primitives.

## Messaging
- Image attachments stored in Firebase Storage.
- Message types (`text`, `image`, `video`, `voice`) in one schema.
- Read receipts via `readBy` and `status`.
- Per-message emoji reactions.
- Typing state on conversations.
- Message reporting and user blocking hooks.

## Communities
- Text/image/video posts.
- Polls with per-user votes.
- Reactions and reporting.
- Media uploads scoped to the creator.

## Production hardening still required
- Server-side notification fan-out and abuse throttling.
- Moderation queues and automated media scanning.
- True voice-recording UX and video transcoding/CDN pipeline.
- Pagination, offline sync, encryption strategy and full accessibility QA.
