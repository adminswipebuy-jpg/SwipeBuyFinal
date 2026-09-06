# SwipeBuy V7.8 — Social Engagement 2.0

V7.8 deepens the social layer with richer story engagement and notification controls.

## Added
- Story reactions (❤️ 🔥 😂 👏) with per-user reaction state.
- Story replies stored separately for a scalable engagement model.
- Story viewer upgraded with reply composer and reaction controls.
- Notifications now support a one-tap Mark All as Read action.
- Stronger unread notification presentation.
- Backend-first Firestore collections: `storyReactions` and `storyReplies`.

## Production notes
- Notifications at scale should be delivered by trusted backend jobs / FCM rather than relying only on client writes.
- Story media should remain protected by Storage rules and moderation workflows.
- Reaction and reply fan-out/counts should be aggregated server-side as traffic grows.
