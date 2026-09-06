# SwipeBuy V13.1 — Advanced Content Moderation, AI Safety & Abuse Prevention 2.0

Adds a client-side safety control plane for submitting automated safety signals and requesting human safety review. Backend/admin systems must perform model inference, risk scoring, enforcement, takedowns, account restrictions, appeals and audit decisions.

## Added
- AI Safety & Abuse Prevention center
- Safety signal types: spam, scam/fraud, harassment, harmful content, abuse, copyright concern
- Target types: content, account, seller, professional, AI agent
- Backend-review safety signal requests
- Human safety review requests
- Profile integration

## Production requirements
- Connect `automated_safety_signals` and `safety_review_requests` to trusted Cloud Functions/backend workflows.
- Add authenticated Firestore/Functions authorization and rate limits.
- Keep moderation models, risk scoring, enforcement, appeals and audit logs server-side.
