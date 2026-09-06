# SwipeBuy V8.5 — Smart Recommendations & Discovery 2.0

This milestone adds a dedicated smart recommendations layer on top of the existing personalization and feed ranking foundations.

## Included
- Smart Recommendations page for personalized marketplace discovery.
- Ranking signals from user interests and preferred category/location.
- Quality/engagement signals from ratings, saves, bookings and views.
- Recommendation interaction telemetry in `recommendation_events`.
- Profile shortcut to Smart Recommendations.
- Version bumped to `8.5.0+61`.

## Production note
This is a client-side ranking foundation. For a world-class production launch, move ranking weights, eligibility, experimentation, abuse controls and recommendation decisions to trusted backend services.
