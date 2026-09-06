# SwipeBuy V11.4 — Creator Courses, Learning & Certification 2.0

Adds a structured learning control plane: course discovery, enrollment requests, learner progress, certificate requests, and creator publishing guidance.

Version: 11.4.0+90

## Architecture
- Client requests enrollment/progress/certificate actions.
- Trusted backend services should validate payments, content entitlements, completion criteria and certificate issuance.
- Course catalog lives in `learning_courses`; enrollments in `learning_enrollments`.
