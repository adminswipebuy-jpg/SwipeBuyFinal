# SwipeBuy V8.2 — Stories & Social Content 2.0

## Added
- Story composer with camera/gallery image selection.
- Caption, category, and audience/privacy controls.
- Firebase Storage image upload through existing MediaService.
- Firestore story publishing with 24-hour expiry and privacy metadata.
- Quick create buttons from Stories.
- Story cards show category metadata.

## Production note
Audience filtering must be enforced in Firestore security rules/server queries before production; the UI privacy selector is not a security boundary by itself.
