# SwipeBuy V5.8 — Multimodal AI

Adds the Vision AI layer on top of V5.7.

## Added
- Image upload from camera/gallery.
- Secure temporary upload to Firebase Storage.
- `analyzeSwipeBuyImage` Cloud Function contract.
- Image + natural-language prompt workflow.
- Structured AI result: summary, tags, suggestions, metadata.
- Vision AI entry point from the AI Actions screen.

## Production architecture
The mobile app does not contain an AI-provider secret. The Cloud Function should validate the caller, authorize the request, call the selected vision model/provider, apply safety policy, optionally search SwipeBuy data, and return structured results.

Sensitive actions such as purchases, wallet changes, bookings, and account changes must remain separately confirmed and server-authorized.

## Testing note
Flutter SDK is not installed in this environment, so an APK/build and `flutter analyze` were not run here.
