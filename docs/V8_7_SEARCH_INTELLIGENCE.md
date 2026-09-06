# SwipeBuy V8.7 — Global Search Intelligence & Discovery 3.0

## Added
- Cross-category search across marketplace listings, jobs, property, professionals and content.
- Search modes for All, Marketplace, Jobs, Property, Services and Content.
- Token-aware relevance scoring with title/category/query boosts.
- Smart query suggestions such as near-me, deals, prices and jobs variants.
- Search analytics event foundation in `search_events`.
- Dedicated Search Intelligence screen available from the main search screen and profile.

## Production notes
- Firestore filtering is a lightweight client foundation; a production global search should move to a server-side/full-text index such as OpenSearch, Typesense or Algolia.
- Search analytics should be protected by server-side rules and/or a trusted backend before launch.
