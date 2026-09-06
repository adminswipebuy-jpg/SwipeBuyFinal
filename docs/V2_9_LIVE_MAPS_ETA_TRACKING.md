# SwipeBuy V2.9 — Live Maps + ETA + Delivery Tracking

## Added
- Live courier-location data model using Firestore GeoPoint.
- Real-time order tracking stream.
- Courier location update foundation.
- ETA field support.
- Customer live-delivery tracking page.
- Distance/ETA architecture notes.

## Important production requirements
- Do not expose a courier's location before the delivery is active and consent/privacy rules allow it.
- Courier location writes must be backend-authorized and rate-limited.
- Verify courier-to-order assignment on every update.
- Use Google Maps Routes/Navigation or a trusted routing backend for road distance and ETA; the included distance helper is only a placeholder.
- Store only the minimum location history required; avoid indefinite tracking history.
- Add stale-location detection and accuracy/heading checks.
- Add customer map markers, route polyline, courier heading and ETA refresh.
- Keep Google Maps API keys restricted by platform/application.
- Never let clients alter financial fields or authoritative order status.
