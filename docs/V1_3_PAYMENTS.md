# SwipeBuy V1.3 — Secure Payment Architecture

## What this version adds
- Flutter `PaymentService` for secure callable-function checkout requests.
- `createCheckout` callable function.
- `verifyPayment` callable function.
- `payment_sessions` server-owned collection.
- Idempotency key support.
- Provider abstraction for Paystack, MTN MoMo, Stripe, and PayPal.
- Order transition to `payment_pending`.
- Client cannot directly declare a payment successful.

## Provider status
This is an architecture foundation, NOT live payment processing yet.

Before production:
1. Resolve listing price and currency on the trusted backend.
2. Add provider SDK/API calls in Cloud Functions.
3. Store secrets in Google Cloud/Firebase Secret Manager.
4. Implement signed webhook endpoints.
5. Verify provider transaction status server-side.
6. Make webhook handling idempotent.
7. Only the backend may change `paymentStatus` to `paid`.
8. Add platform fees, seller payout/escrow logic, refunds and chargebacks.
9. Add audit logs and rate limiting.
10. Test sandbox transactions before production.

## Providers
- Paystack: Ghana/Africa checkout architecture.
- MTN MoMo: Ghana mobile-money architecture.
- Stripe: international card/payment architecture.
- PayPal: international wallet/payment architecture.

No secret key is included in this project.
