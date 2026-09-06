# SwipeBuy V10.2 — International Commerce, Multi-Currency Pricing & FX 2.0

Adds an international commerce layer on top of V10.1 payments:

- preferred display currency
- local/seller currency visibility
- clearly-labeled estimated FX preference
- backend/provider FX quote request contract
- recent FX quote request history
- profile access from Identity/Profile

## Production note
The client does not calculate or guarantee live FX rates. A trusted backend/payment/FX provider should return the final quote, including rate, fees, timestamp, expiry and provider reference before payment authorization.
