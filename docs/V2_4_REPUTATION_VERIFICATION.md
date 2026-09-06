# SwipeBuy V2.4 — Reputation + Verification

## Added
- Provider reputation service.
- Customer review submission foundation.
- Published provider review stream.
- Provider statistics display.
- Verification badge UI.
- Review status defaults to `pending`.

## Firestore model
`reviews/{reviewId}`
- providerId
- customerId
- orderId
- rating (1–5)
- text
- status (`pending` / `published` / `rejected`)
- createdAt

`provider_stats/{providerId}`
- providerId
- averageRating
- reviewCount
- optional ratingDistribution

## Production trust requirements
- Only allow a review after a completed/eligible order or booking, validated by trusted backend.
- Enforce one review per eligible transaction.
- Calculate averages and counts on trusted backend; never accept client-supplied provider_stats.
- Moderation, spam detection, abuse reports and appeal workflow are required.
- Verification badges must be issued only from trusted verification/KYC/business checks.
- Do not expose sensitive verification documents to clients.
