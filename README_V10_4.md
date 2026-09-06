# SwipeBuy V10.4 — Global Merchant & Seller Operations 2.0

V10.4 adds a unified merchant operations control room for inventory, fulfillment, returns and team workflows.

## Included
- Merchant Operations page with Overview / Inventory / Fulfillment / Returns / Team tabs.
- Inventory visibility with low-stock signals and SKU readiness.
- Fulfillment task queue with backend-ready order workflow handoff.
- Returns operations surface tied to seller ownership.
- Merchant team invites with scoped role labels.
- Operations sync request flow.
- Home popup and Profile integration.

## Production architecture
Client writes are request-style operations. Inventory deductions, refund decisions, shipment state, permissions and financial settlement should be validated by trusted backend code and provider webhooks before becoming authoritative.

## Verification
Lightweight Dart delimiter/source checks were performed on new/modified Dart files. Flutter SDK is not installed in the current environment, so a full `flutter analyze` / `flutter build` was not run.
