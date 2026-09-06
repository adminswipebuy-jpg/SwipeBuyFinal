# SwipeBuy V9.8 — AI Agent Reviews, Trust & Safety 2.0

Adds a trust layer for the AI Agent Marketplace: community reviews, report flows, personal trust/caution signals, and a dedicated safety center. Reviews and reports are marked pending/open so moderation and trusted backend services can control public ratings, enforcement, and agent execution.

### Added
- `lib/services/ai_agent_trust_service.dart`
- `lib/pages/ai_agent_trust_page.dart`
- Profile navigation entry
- Marketplace card link to trust & reviews

### Backend notes
- Client submissions do not directly change aggregate ratings or agent safety status.
- Production should validate review eligibility, rate-limit reports, moderate content, and compute aggregate reputation server-side.
- Real-world agent actions remain confirmation-gated and backend-controlled.
