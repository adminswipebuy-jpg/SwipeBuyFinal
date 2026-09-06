# SwipeBuy V4.1 — Content Feed Engine

This release turns the home experience into a reusable multi-vertical content feed.

## Added
- Shared `ContentItem` model for news, sports, finance, crypto, investment, property, jobs, education, fitness, lifestyle and future verticals.
- `content_items` Firestore collection contract with `published` status and `createdAt` ordering.
- Vertical swipe feed with rich action cards and per-content engagement events.
- Demo fallback content so the app remains usable before ingestion pipelines are connected.
- Event logging to `content_events` for likes, saves, shares, comment opens and primary actions.

## Next target
Connect authorized content providers and media storage, then move ranking from demo/chronological fallback to server-controlled personalization using watch time, completion, follows, saves, searches and conversions.
