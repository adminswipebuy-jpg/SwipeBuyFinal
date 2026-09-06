# SwipeBuy V2.8 — Merchant + Courier Delivery

## Added
- Merchant delivery/order dashboard foundation.
- Courier assigned-jobs dashboard foundation.
- Courier assignment request marker.
- Delivery workflow state machine foundation.
- Delivery-focused status labels.

## Roles
### Merchant
Can view its own orders and request courier assignment for ready orders.

### Courier
Can view orders assigned to its courier account.

### Customer
Continues to use the V2.7 order tracking flow.

## Production hardening
- All order status transitions must move to trusted Cloud Functions/backend.
- Verify merchant ownership and courier role on every privileged operation.
- Never accept client-supplied price, payment state, courier identity or ETA.
- Courier assignment should use a transaction/claim mechanism to prevent double assignment.
- Integrate a real delivery/courier provider before production.
- Add ETA calculation, proof of pickup/delivery, customer notifications and support escalation.
- Live courier location requires explicit privacy/consent controls and retention limits.
- Add delivery fee/tax/currency calculation on the backend.
