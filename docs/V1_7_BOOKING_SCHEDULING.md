# SwipeBuy V1.7 — Booking & Scheduling

Added:
- BookingService for customer/provider booking streams.
- Booking request creation foundation.
- Booking cancellation.
- Cloud Function createBooking foundation.
- Firestore booking access controls.
- Booking status lifecycle foundation.

Production requirements:
- Enforce slot uniqueness with a Firestore transaction or equivalent trusted reservation mechanism.
- Validate provider working hours, holidays, staff availability, and timezone on the backend.
- Re-check listing/provider eligibility server-side.
- Connect confirmed bookings to payment sessions.
- Send notifications after request/accept/decline/cancel events.
- Add reschedule flow with server-side conflict checks.
- Store timestamps consistently and display in the user's/provider's timezone.
