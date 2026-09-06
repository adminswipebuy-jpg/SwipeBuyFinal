# SwipeBuy V7.7 — Social Graph & Following Pulse 2.0

V7.7 turns the existing Following area into a real cross-SwipeBuy pulse.

## Added
- Following Pulse screen for followed creators/providers.
- Combined posts/content and published marketplace listings.
- Newest-first ordering across followed sources.
- Creator profile handoff from pulse cards.
- Marketplace listing handoff for followed seller updates.
- Pull-to-refresh and refresh action.
- Backend-first read architecture using existing Firestore follows/content/listings collections.

## Production notes
- Real-time fan-out and large-scale ranking should move to backend aggregation/feeds as usage grows.
- Listing/product schemas must match the production marketplace model before release.
- Firestore composite indexes may be required for content/listing queries.
