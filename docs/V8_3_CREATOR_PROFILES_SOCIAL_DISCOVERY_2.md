# SwipeBuy V8.3 — Creator Profiles & Social Discovery 2.0

## Added
- Creator discovery surface with search and topic/category filters.
- Creator cards with follower counts, bio, verification state and follow action.
- Direct navigation into the existing creator profile and published content experience.
- Discover-creators entry point from Connections and My Profile.
- Firestore-backed discovery foundation that ranks matching creators by follower count.

## Production note
Creator eligibility and privacy should be enforced by server-side rules/queries. A client-side creatorMode/profileMode flag is only a discovery hint, not a security boundary.
