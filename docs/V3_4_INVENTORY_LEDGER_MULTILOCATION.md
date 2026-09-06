# SwipeBuy V3.4 — Inventory Ledger + Multi-location

## Added
- Inventory movement ledger foundation.
- Movement types: restock, sale, cancellation, return, adjustment, transfer.
- Movement reference/note fields.
- Inventory location model.
- Merchant inventory locations page.
- Product inventory history page.

## Production requirements
- Ledger entries must be immutable and created by trusted backend functions.
- Stock balances should be derived/validated from ledger movements or maintained transactionally by the backend.
- Every sale, return, cancellation and transfer should reference an authoritative order/event.
- Prevent duplicate event processing with idempotency keys.
- Transfers should be two-sided transactions (source decrement + destination increment).
- Add warehouse/location-specific stock balances.
- Add low-stock notifications per location.
- Add audit logs and staff permissions.
- Never allow a client to fabricate stock increases or financial inventory movements.
