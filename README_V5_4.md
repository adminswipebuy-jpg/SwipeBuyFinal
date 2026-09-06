# SwipeBuy V5.4

Smart Home + Personalization 2.0 adds a user preference center and a personalized For You ranking foundation.

## Included
- User interests stored in `user_preferences`
- Preferred location and nearby-content toggle
- Content language preference
- Personalized `For You` ranking using interests, locality, freshness and engagement/quality signals
- Impression events from the vertical feed
- Reset recommendations control
- Home and Profile shortcuts to personalization settings

## Production note
The client ranking is a foundation/demo implementation. A production-scale recommendation system should compute ranking server-side and apply experimentation, safety, diversity and anti-gaming controls.
