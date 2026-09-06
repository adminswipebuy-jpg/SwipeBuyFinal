# SwipeBuy V4.6 — Messaging, Communities & Notifications

V4.6 strengthens the social network layer around the existing SwipeBuy feed.

## Added
- Unified Communications screen with Chats, Communities and Following Pulse tabs.
- Community discovery by category and member count.
- Community creation and join workflow.
- Profile shortcuts into Communities/Connections and Notifications.
- Search entry point for people, creators, communities and conversations.
- Reuses the existing real-time chat and notification services.

## Data model
- `communities/{communityId}`
- `communities/{communityId}/members/{userId}`
- `communityMembers/{userId_communityId}`

## Next
V4.7 should add rich messaging attachments, read receipts/presence, community posts, moderation/reporting, and push notification fan-out.
