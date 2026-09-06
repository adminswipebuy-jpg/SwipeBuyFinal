# SwipeBuy V3.0 — Maps, Routes & Navigation

## Added
- Google Maps route screen foundation.
- Courier and destination markers.
- Polyline rendering.
- Secure routing-backend client contract.
- Route duration and distance response model.
- Server-side routing proxy example.

## Production requirements
- Configure restricted Google Maps SDK keys for Android/iOS/web as appropriate.
- Keep server-side routing credentials in Secret Manager.
- Authenticate every route request and apply rate limits and quotas.
- Use Google Routes API (or an approved routing provider) through the backend.
- Refresh ETA only at sensible intervals and when courier movement warrants it.
- Do not expose continuous courier location outside an active delivery.
- Add route recalculation when the courier deviates from the route.
- Add navigation handoff/deep-linking only after validating the destination and user role.
- Cache route results where safe to reduce API cost.
- Monitor API usage and set billing alerts.
