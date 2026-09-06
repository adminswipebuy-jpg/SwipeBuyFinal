# SwipeBuy V8.1 — Social Messaging & Communities 2.0

This milestone strengthens the communication layer with an integrated community detail experience.

## Added
- Community detail pages from the Connect/Communications hub.
- Join/leave state shown from the authenticated member document.
- Community post feed backed by Firestore subcollections.
- Member post composer for joined communities.
- Community metadata and participation surface.

## Architecture
- Posts live under `communities/{communityId}/posts`.
- Membership remains under `communities/{communityId}/members/{userId}` and `communityMembers`.
- Client writes only user-authored post content; production moderation/rate limits should remain backend-controlled.
