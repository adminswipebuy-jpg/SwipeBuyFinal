# SwipeBuy V1.6 — Provider Profiles & Availability

Added:
- Provider profile service
- Business/provider bio and business type
- Contact phone and address fields
- GeoPoint location foundation
- Profile completeness flag
- Opening-hours storage foundation
- Services/pricing storage foundation

Production notes:
- Phone/email verification should be handled by Firebase Auth.
- Location should be validated and protected against arbitrary writes where appropriate.
- Public provider discovery should expose only approved public profile fields.
- Business verification/KYC should be server-controlled.
- Calendar conflicts and booking availability should be enforced transactionally on the backend.
- Do not use client-written earnings or payment state as financial truth.
