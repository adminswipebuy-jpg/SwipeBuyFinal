# SwipeBuy V2.1 — Social Layer

Added a Firestore-backed social foundation for the marketplace:
- Follow/unfollow providers
- Like/unlike listings
- Save/unsave listings
- Share-event recording
- Comments with a bottom-sheet UI
- Reusable Follow button and social action rail

Collections: `follows`, `likes`, `saves`, `comments`, `listing_events`.

Production hardening still required: server-side rate limits, trusted counters, moderation/spam controls, abuse reporting, self-follow prevention, notifications, and a scalable denormalized Following feed.
