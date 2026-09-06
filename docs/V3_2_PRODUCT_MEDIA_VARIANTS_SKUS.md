# SwipeBuy V3.2 — Product Media, Variants & SKUs

## Added
- Product detail page.
- Product image/media display foundation.
- Variant selection foundation.
- Merchant variant management.
- SKU field and per-variant stock/price.
- Product media collection compatibility with the existing catalog model.

## Production requirements
- Use Firebase Storage only after billing is enabled and Storage rules are reviewed.
- Validate image/video MIME types, dimensions, duration and file size server-side.
- Generate thumbnails and optimized media; never rely only on client validation.
- Enforce unique SKUs per merchant on the backend.
- Variant price and stock must be server-authoritative.
- Reserve inventory transactionally when an order is created/paid.
- Prevent negative stock and concurrent overselling.
- Add bulk SKU import/export, barcode support and low-stock alerts.
- Add proper image galleries, video previews and CDN/cache strategy.
