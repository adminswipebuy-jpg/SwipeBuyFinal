# SwipeBuy V5.1 — Payments, Wallet & Transaction Ledger

## Added
- User wallet screen with available and pending balances.
- Deposit request flow for Mobile Money provider handoff.
- Withdrawal request flow.
- Wallet transaction history model.
- Backend-first payment architecture for checkout and creator payouts.
- `cloud_functions` dependency for trusted payment callables.

## Security model
The client only creates requests. It never writes a successful balance, finalized payment, creator earning, or completed payout. Trusted backend functions/payment providers must verify provider callbacks, enforce idempotency, calculate fees, update the ledger atomically, and create immutable transaction records.

## Suggested backend collections
- wallets/{uid}
- wallets/{uid}/transactions/{transactionId}
- wallet_deposit_requests/{requestId}
- wallet_withdrawal_requests/{requestId}
- payment_sessions/{sessionId}
- payout_requests/{requestId}

## Production requirements
- Use a licensed payment provider and official APIs for Mobile Money/cards.
- Verify webhooks server-side and make callbacks idempotent.
- Add KYC/identity checks where legally required.
- Keep a double-entry style ledger for money movement.
- Never trust balances supplied by the mobile client.
