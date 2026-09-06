# SwipeBuy V2.0 — Global Discovery & Intelligence Foundation

Added:
- DiscoveryService for published feed, category and location filtering.
- Listing view/action event tracking foundation.
- SearchService foundation.
- Global discovery architecture documentation.
- Personalized ranking event vocabulary.

Recommended production ranking signals:
- watch/view completion
- saves/favorites
- shares
- booking/order conversion
- search relevance
- category affinity
- location relevance
- provider quality/trust
- freshness
- diversity/fairness constraints

Important:
- Firestore is not a full-text search engine; production search should use a dedicated index.
- Ranking should run server-side or through a controlled recommendation service.
- Event ingestion needs rate limiting and abuse protection.
- Do not expose private customer behavior data.
- Personalized recommendations require privacy controls and clear data governance.
