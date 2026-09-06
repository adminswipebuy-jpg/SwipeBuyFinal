# SwipeBuy V5.5 — Smart Alerts & Personalization

Adds a smart-alert inbox, user-controlled alert settings integration, unread/read state, mark-all-read, and personalized category ordering based on saved interests.

## Production notes
- Smart alerts should be created by trusted backend functions for events such as price changes, new jobs, property matches, followed-creator posts, LIVE starts, sports/news events, and order status changes.
- Client code only reads and acknowledges alerts.
- Push delivery continues through Firebase Cloud Messaging using registered device tokens.
- Firestore indexes may be required for compound queries on `smart_alerts(userId, read, createdAt)`.
