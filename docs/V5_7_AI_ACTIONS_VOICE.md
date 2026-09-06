# SwipeBuy V5.7 — AI Actions + Voice

## Added
- Device speech-to-text using `speech_to_text`.
- AI action planning UI with explicit confirmation.
- Secure Cloud Functions callable contract: `executeSwipeBuyAiAction`.
- Home shortcut to the AI Actions screen.

## Security model
The mobile client only proposes actions. It must not directly change balances, confirm purchases, issue refunds, or perform other sensitive state changes. The Cloud Function should authenticate the caller, authorize the requested action, validate parameters, enforce idempotency, and require any additional provider confirmation before changing money or orders.

## Production backend contract
Callable name: `executeSwipeBuyAiAction`

Request:
```json
{
  "action": "search_and_prepare_purchase",
  "parameters": {"query": "Find a phone under GHS 4000"}
}
```

Response:
```json
{"status":"accepted","message":"Action accepted; awaiting next confirmation step."}
```

## Voice permissions
Android requests `RECORD_AUDIO`. iOS/macOS will also need Speech Recognition and Microphone usage descriptions before shipping those targets.

The speech plugin is currently `speech_to_text 7.4.0`, a stable release compatible with Dart 3.3.
