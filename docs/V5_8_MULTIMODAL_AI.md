# V5.8 Multimodal AI

SwipeBuy Vision AI lets a user choose an image from camera/gallery and add a natural-language instruction.

## Flow
1. User picks an image.
2. App uploads the temporary image to `ai_inputs/{uid}/...`.
3. App calls the trusted `analyzeSwipeBuyImage` callable with the image URL and prompt.
4. Backend authenticates the caller, fetches the image, invokes the selected vision model, applies safety/authorization checks, and returns structured JSON.
5. App renders a summary, tags, and suggested next searches/actions.
6. Temporary image is deleted by the client in the prototype; production may move cleanup/audit to the backend.

## Production requirements
Do not put model-provider API keys in the mobile app. The callable should rate-limit requests, validate file ownership and MIME/size, reject unauthorized access, log minimal audit data, and avoid performing purchases, wallet changes, bookings, or other sensitive actions without the existing confirmation/authorization flow.
