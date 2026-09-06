# SwipeBuy V3.1 — Storefronts, Catalog & Inventory

## Added
- Business storefront page.
- Catalog item model.
- Product price, currency and stock fields.
- Product variants field foundation.
- Merchant catalog management page.
- Active/inactive product control.

## Production requirements
- Store inventory in a server-authoritative model.
- Validate price, currency, stock and variant selections on the backend.
- Reserve/decrement stock transactionally during checkout.
- Prevent overselling under concurrent orders.
- Never trust client-supplied totals.
- Add image/video media upload after Storage billing is available.
- Add SKU/barcode support, low-stock alerts, bulk editing and product import.
- Add merchant-specific tax, delivery and fulfillment rules.
- Keep catalog reads scoped to public/active products.
