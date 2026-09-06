# SwipeBuy V2.6 — AI Recommendations

## Added
- Personalized “For You” feed foundation.
- Category preference signal.
- Location relevance signal.
- Rating/quality signal.
- Views, saves and booking conversion signals.
- Recommendation click event tracking.
- Recommendation service and UI.

## Production AI architecture
The current Flutter implementation is a transparent ranking prototype, not a production ML model.

Recommended production pipeline:
1. Capture privacy-aware interaction events.
2. Validate and rate-limit event ingestion on the backend.
3. Build user/category/provider embeddings or feature vectors.
4. Candidate generation from followed providers, nearby providers, search results and popular listings.
5. Rank candidates using relevance, predicted engagement/conversion, freshness, trust and diversity.
6. Apply safety/fairness/business constraints.
7. Return a server-ranked feed to the app.
8. Continuously evaluate ranking quality with offline metrics and controlled experiments.

Do not expose private user features or sensitive data to providers. Do not use sensitive personal attributes for recommendation targeting.
