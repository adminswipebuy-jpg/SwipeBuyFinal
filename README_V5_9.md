# SwipeBuy V5.9 — Global Marketplace & Local Discovery

Adds a location-aware Nearby experience using Geolocator 14.0.3. Users can grant location permission, filter by category, discover published listings with stored latitude/longitude, sort by distance, and open route navigation.

## Production requirements
- Store real listing coordinates (`latitude`, `longitude`) only when the seller has permission to publish the location.
- Request location only when the user opens Nearby or enables a location feature.
- Use server-side geospatial querying for scale; this client currently fetches up to 100 published listings and filters by distance locally.
- Add privacy policy language and platform disclosure for location collection.

Dependency source: geolocator 14.0.3 on pub.dev.
