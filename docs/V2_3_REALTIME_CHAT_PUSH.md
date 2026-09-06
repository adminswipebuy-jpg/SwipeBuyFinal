# SwipeBuy V2.3 — Realtime Chat + Push Foundation

## Added
- Real-time Firestore conversations and messages.
- Deterministic two-user conversation IDs.
- Message read state.
- Reusable chat page.
- Firebase Cloud Messaging permission/token registration.
- Token refresh handling.
- Notification event helper for trusted backend use.
- Secure conversation/message rules.

## Important production notes
- FCM/APNs delivery should be triggered by trusted Cloud Functions/backend, not directly by clients.
- iOS requires APNs capability/configuration and Firebase Messaging setup.
- Android notification channels and app behavior should be configured.
- The client should never be trusted to generate financial/order/payment notifications.
- Add server-side rate limits, abuse detection, blocked-user logic, attachments moderation, and message reporting.
- For large-scale chat, consider message pagination and denormalized conversation summaries.
- Never put FCM server credentials in the Flutter app.
