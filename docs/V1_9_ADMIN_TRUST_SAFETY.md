# SwipeBuy V1.9 — Admin & Trust/Safety

Added:
- AdminService foundation
- Pending-listing moderation stream
- Report review stream
- Admin moderation callable functions
- Admin report-resolution callable function
- Admin audit-log collection foundation
- Documentation for trust and safety controls

Security:
- Privileged moderation functions require the Firebase Auth custom claim `admin=true`.
- Clients should not be trusted to grant themselves admin status.
- In production, moderation actions should write immutable audit records.
- User suspension, payout holds, refunds and financial actions should also be backend-controlled.
- Add rate limits, abuse detection, content moderation, identity/business verification and appeal workflows before broad launch.

The current Flutter AdminService methods are UI/service contracts; privileged production mutations should use the callable functions.
