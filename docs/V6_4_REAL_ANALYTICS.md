# SwipeBuy V6.4 — Real Analytics + Dashboards

Adds an analytics service and dashboard for views, watch time, engagement, shares, saves, orders, sales and conversion indicators.

## Production notes
- Event data should be written by trusted services where practical.
- Aggregate analytics should eventually be materialized server-side for large datasets.
- Do not expose sensitive payment-provider secrets to the mobile app.
- Compile and test with the Flutter SDK before release.
