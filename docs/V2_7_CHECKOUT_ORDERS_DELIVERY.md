# SwipeBuy V2.7 — Checkout + Orders + Delivery

## Added
- Cart item model.
- Cart-to-order checkout foundation.
- Delivery vs pickup selection.
- Customer delivery address field.
- Customer order history.
- Real-time order tracking page.
- Delivery lifecycle labels.

## Order lifecycle
pending → payment_pending → confirmed → preparing → ready → picked_up → out_for_delivery → delivered

Cancellation/refund states are also recognized.

## Critical production requirements
- The client must not be authoritative for price, fees, taxes, inventory, delivery cost, payment state or order status.
- Replace direct client order creation with the existing trusted Cloud Function checkout/order flow before production.
- Payment must be verified by provider webhook/server verification.
- Inventory and stock must be reserved transactionally.
- Delivery quotes, driver assignment, ETA and location must be server-controlled.
- Add merchant preparation timers, courier workflows, proof of delivery and customer support.
- Use proper address/location privacy controls.
- Currency conversion and tax rules must be backend-controlled by jurisdiction.
