# SwipeBuy V1.2 — Media + Transaction Foundation

## What is now wired
1. Create Listing can select a phone video.
2. Video uploads to `users/{uid}/videos/...` in Firebase Storage.
3. The listing is created as `pending_review`.
4. The listing stores a `videoUrl` after upload.
5. Marketplace action buttons create pending orders.
6. Jobs create applications with `status: submitted`.

## Important security boundary
The Flutter app never marks an order as paid. The order begins as:
- `status: pending`
- `paymentStatus: unpaid`

Real payment must be initiated and verified by a trusted backend/webhook using the selected provider. Do not put Paystack, MTN MoMo, Stripe, PayPal or other secret keys in Flutter.

## Phone-only setup
From Firebase Console, publish the updated Storage Rules from `storage.rules` if you are managing rules manually.

A computer will still be needed later for full Flutter builds, release signing, Play App Signing fingerprints, and production deployment.
