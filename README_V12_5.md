# SwipeBuy V12.5 — Fraud Prevention, Risk Scoring & Marketplace Security 2.0

Added a backend-first security control plane for marketplace, payments, seller/professional accounts and transactions.

Features:
- User-facing security center
- Backend risk-profile status display
- Account security review requests
- Transaction/order fraud reports
- Protection-layer explanations
- Explicitly keeps risk scoring, payment holds, approvals, restrictions and enforcement server-side

## Production requirements
Connect `risk_profiles`, `risk_review_requests`, and `risk_transaction_reports` to trusted backend/Cloud Functions logic. Never calculate authoritative fraud scores or grant payment approval from the mobile client.
