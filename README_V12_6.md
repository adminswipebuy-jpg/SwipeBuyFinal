# SwipeBuy V12.6 — Advanced Account Security, Device Trust & Anti-Takeover 2.0

Adds a backend-first security control plane for trusted devices, suspicious-session response and account recovery review.

## Added
- Device trust request workflow
- Trusted-device status stream
- Request sign-out of other sessions
- Account recovery review workflow
- Security notes emphasizing server-side enforcement
- Profile/identity entry point

## Production requirements
The client must not decide device trust, identity proof, session revocation, or recovery eligibility. Deploy these collections/actions behind authenticated backend rules/functions and add risk-based MFA/passkey/device attestation where appropriate.
