# SwipeBuy V1.1 — Live Firestore Listings

This version keeps the polished vertical marketplace UI while connecting listings to Firebase Cloud Firestore.

## What changed
- Public feed listens to `listings` with `status == published`.
- If no published records exist yet, the app shows the built-in demo marketplace cards.
- Create Listing now writes a `pending_review` document owned by the signed-in user.
- Added category-aware action labels/icons.
- Added a reusable MarketplaceService for listings and job applications.

## Important
New listings are intentionally `pending_review` and will not appear publicly until an admin/backend changes the status to `published`. This matches the security-first design.

## Firebase console
Create test data only through the app after Email/Password authentication is enabled. Do not switch Firestore rules to public/test access.
