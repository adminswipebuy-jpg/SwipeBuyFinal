# SwipeBuy V9.0 — Advanced AI, Voice & Vision 2.0

Adds a unified AI 2.0 command center that combines:
- Natural-language cross-category discovery
- Voice input and action planning
- Vision AI entry point for photo-based discovery
- Smart result ranking using the existing universal AI service
- Explicit confirmation for sensitive actions
- Privacy/safety guidance for voice and temporary image processing

## Integration notes
The mobile client remains a secure orchestration layer. Actual model/provider secrets should remain server-side. Sensitive transactions should continue through trusted backend functions and payment providers. Vision analysis requires the existing `analyzeSwipeBuyImage` Cloud Function contract.

## Validation
This milestone is source-level/prototype integration. Flutter SDK and production backend validation are still required before release.
