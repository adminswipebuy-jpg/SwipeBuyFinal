# SwipeBuy V6.0 — Global Map + Nearby Intelligence

Adds a first-class map experience on top of the V5.9 location-aware marketplace.

## Included
- Interactive Google Map screen.
- Current-location marker and location recentering.
- Category filters for Food, Hotels, Jobs, Property, Services, Beauty, Entertainment, Shopping and Events.
- Nearby markers sourced from published Firestore listings that contain coordinates.
- Radius selector (5 / 10 / 25 / 50 km).
- Marker detail sheet with category, distance and action placeholders.
- Map shortcut from the Home screen.
- "Ask SwipeBuy" map search affordance for the future AI-powered nearby query workflow.

## Production requirements
- Supply a production Google Maps API key via the Android/iOS platform configuration.
- Restrict the key by app/package and platform APIs.
- Use server-side geospatial indexing/querying at scale; the current client reuses V5.9 local filtering.
- Obtain explicit location permission only when needed.
- Do not expose private user coordinates to other users; publish only approved business/listing locations.
- Connect the detail-sheet actions to the real product, booking, job, property and service flows.
- Replace the read-only map search affordance with the secure AI action gateway when V5.7/V5.8 multimodal assistant infrastructure is connected.
