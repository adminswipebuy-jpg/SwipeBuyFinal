# SwipeBuy V1 Secure

This release adds a security foundation for the global SwipeBuy marketplace.

## Included

- Firebase Authentication service wrapper.
- Firestore Security Rules with default deny.
- Cloud Storage Security Rules with authenticated ownership and upload limits.
- Server-controlled admin claims pattern.
- Client protection against direct wallet/transaction writes.
- Order/application/report authorization boundaries.
- Firebase App Check initialization.
- Server-side Cloud Function foundation for order creation.
- Account re-authentication before destructive account deletion.
- No payment-provider secret keys in Flutter.
- Firebase configuration is generated with FlutterFire instead of being fabricated.

Firebase recommends Authentication + Firestore Security Rules for client access, App Check for helping ensure requests originate from your app, and locked/default-deny rules as the production baseline.

## Required setup

1. Install Firebase CLI and FlutterFire CLI.
2. Run:
   `firebase login`
   `dart pub global activate flutterfire_cli`
   `flutterfire configure`
3. This generates `lib/firebase_options.dart`.
4. Enable Firebase Authentication providers you actually support.
5. Deploy:
   `firebase deploy --only firestore:rules,storage`
6. From `functions/`, install dependencies and deploy the Cloud Functions.
7. In Firebase Console > App Check, register Android, Apple, and Web apps.
8. Replace the web reCAPTCHA site key in `lib/main.dart`.
9. Monitor App Check metrics before enabling enforcement.
10. Set admin custom claims only from trusted server/admin tooling.

## Important production security rules

### Payments
Never put Stripe, PayPal, Paystack, or other secret keys in Flutter. The client can request a payment session; a trusted backend must calculate/validate the amount, create the provider transaction, receive the webhook, verify the transaction, and then update the order/payment state.

### Wallet
Wallet balances are server-owned. The Flutter app must not write `wallets/*` balances or `transactions/*`. Every credit/debit should have an auditable transaction record and idempotency protection.

### Videos
The included Storage rules are a foundation, not a full content-delivery architecture. For public feeds, use a controlled publishing pipeline, moderation, file validation, quotas, and preferably signed/controlled delivery URLs rather than exposing unrestricted originals.

### Admin
Do not let clients assign themselves `admin`. Use Firebase Auth custom claims set by trusted server-side code. Keep administrative tools behind strong authentication and least privilege.

### Rate limiting and abuse
Security Rules authorize access but are not a complete abuse-prevention system. Add server-side rate limits, App Check enforcement, moderation queues, anomaly detection, and monitoring before public launch.

### Data privacy
Collect only data needed for the feature. Protect private profile fields, application documents, payment metadata, and location data. Provide account deletion and a clear privacy policy.

## Security test checklist

- Unauthenticated reads/writes are denied where expected.
- A user cannot read another user's private data.
- A user cannot change their role/admin status.
- A user cannot write wallet balances.
- A user cannot mark an order as paid from the client.
- A user cannot modify another user's listing.
- Storage rejects oversized/non-approved uploads.
- Admin-only moderation actions fail for normal users.
- App Check is registered for every production platform.
- Firebase Emulator Suite tests are added before production deployment.
