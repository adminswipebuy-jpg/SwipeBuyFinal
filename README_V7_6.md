# SwipeBuy V7.6 — Checkout & Buyer Protection

V7.6 advances the marketplace into a buyer checkout flow.

## Added
- Secure Checkout page with delivery/pickup selection.
- Delivery address and coupon capture.
- Buyer Protection information surface.
- Backend-first `checkoutSessions` request contract.
- Marketplace product cards now open checkout with a Buy action.

## Important production boundary
The phone app only creates a checkout request. A trusted backend/payment provider must validate prices, apply coupons, authorize/verify payment, create/finalize the order, and update payment status. Never trust a client-side payment-success flag.

## Version
`7.6.0+52`
