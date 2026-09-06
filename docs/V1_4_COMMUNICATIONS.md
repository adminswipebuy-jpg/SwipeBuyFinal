# SwipeBuy V1.4 — Communications, Maps & Reviews

Added:
- NotificationService for per-user notifications.
- ChatService with Firestore chat/message streams.
- ReviewService with moderation-friendly pending reviews.
- Google Maps Flutter dependency foundation.

Production requirements:
- Deploy Firebase Cloud Functions to create notifications from trusted events.
- Add FCM device-token registration and server-side push sending.
- Add chat creation permissions and abuse/rate limiting.
- Configure Google Maps Android/iOS/web keys using restricted API keys.
- Never expose unrestricted server secrets.
- Reviews should only become public after backend validation that the order is completed and belongs to the reviewer.
