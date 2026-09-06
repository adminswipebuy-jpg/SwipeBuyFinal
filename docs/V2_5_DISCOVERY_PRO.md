# SwipeBuy V2.5 — Advanced Discovery

## Added
- Advanced marketplace search foundation.
- Category and action-type filters.
- Location/radius filtering when listing GeoPoint data exists.
- Local relevance sorting by distance.
- Search fields across title, description, category, provider and location name.
- Dedicated Discovery Pro page.

## Important production scaling
The current implementation intentionally uses Firestore plus lightweight client filtering. At scale, move full-text search to Algolia, Typesense, Elasticsearch/OpenSearch or another dedicated search index.

For location discovery at global scale:
- Store normalized GeoPoint fields.
- Use a geospatial index/service rather than downloading large result sets.
- Respect user location permission and privacy.
- Do not expose precise provider/customer private locations unnecessarily.

For personalization:
- Keep ranking server-controlled.
- Combine relevance, freshness, location, category affinity, quality/trust and conversion signals.
- Add diversity/fairness constraints so the same providers do not monopolize discovery.
