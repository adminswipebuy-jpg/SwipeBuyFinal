# SwipeBuy V7.9 — Social Feed & Content Engagement 2.0

V7.9 strengthens the social feed with a unified engagement layer for saves, shares, views, and moderation signals.

## Added
- Persistent content saves with per-user state.
- Share events captured in a dedicated engagement stream.
- View events with optional watch duration metadata.
- In-feed “More” controls for Not interested and Report Content.
- Dedicated `content_engagement_events`, `content_saves`, and `content_reports` collections.

## Production notes
- Use trusted backend/Cloud Functions to aggregate counters, rank content, and fan out notifications.
- Keep report processing and moderation decisions server-controlled.
- Consider App Check, rate limits, abuse detection, and pagination before public launch.
