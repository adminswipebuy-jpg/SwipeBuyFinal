# SwipeBuy V1.8 — End-to-End Transaction Flow

This release adds the Flutter service layer that connects:
Video/listing → order → checkout session → payment verification → completion/review foundation.

## Added
- TransactionFlowService
- Customer order stream
- Checkout initiation through the V1.3 PaymentService
- Idempotency key convention
- Payment status checking
- Documentation of the end-to-end lifecycle

## Authoritative state
The backend remains the source of truth for:
- price and currency
- payment success
- order/payment status
- refunds
- platform fees
- provider earnings/payouts

## Production completion still required
- Wire Paystack, MTN MoMo, Stripe and PayPal provider adapters.
- Verify signed provider webhooks.
- Implement trusted order state transitions.
- Implement completed-order eligibility before reviews.
- Calculate fees and payouts server-side.
- Add refund/chargeback handling.
- Add notification triggers.
