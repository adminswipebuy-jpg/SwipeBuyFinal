# SwipeBuy V5.6 — AI Assistant + Universal Discovery

Adds the first in-app "Ask SwipeBuy" experience. The assistant is a platform-wide discovery layer that routes user intent to supported SwipeBuy data collections such as listings, jobs, properties, content, professionals and travel listings.

## What this release does
- Adds an Ask SwipeBuy screen with natural-language search examples.
- Adds an intent router for shopping, jobs, property, sports, finance, education, services and travel.
- Searches multiple Firestore collections and merges/deduplicates results.
- Provides action labels such as Buy/View/Apply/Learn/Hire/Book.
- Adds a Home shortcut with a sparkle icon.

## Production path
This is the **assistant shell and discovery router**, not a general-purpose LLM. For a production AI experience, add a trusted backend function that calls the selected model provider, then passes structured tool requests into SwipeBuy search, recommendation, payments, bookings and other authorized actions. Never put a provider API secret in the mobile app.
