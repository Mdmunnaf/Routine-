# PrepPilot — Project Status

Last updated: 2026-10-17

## Implemented in this delivery

- Responsive single-page React/TypeScript application shell with sidebar navigation and dark/light themes.
- Local IndexedDB persistence with a localStorage fallback.
- Dashboard calculations and empty states for actual local records.
- Timestamp-based focus timer; active session ID and session records persist across reloads.
- Planner task create/edit/delete, status, priority, schedule, and start-from-task action.
- Editable syllabus topics, topic status, difficulty and priority; timer-to-topic association.
- Revision queue and outcome-based follow-up scheduling.
- Manual mock-test result tracking, negative-mark calculation, and history.
- Analytics charts based on recorded sessions and basic productivity metrics.
- In-app notification list UI, browser notification permission request, JSON export/restore.
- Reusable `ProjectOwnerFooter` in the shared app shell with a local placeholder image and explicitly fake example URLs.
- PWA manifest, basic service-worker cache/offline fallback, environment example, README, and Supabase schema starter.

## Not implemented or not verified

- **No test/build result is claimed.** Package installation timed out in this execution environment, so dependencies were not installed and TypeScript checks, automated tests, and production build could not be run.
- Supabase Auth, Google OAuth, cloud CRUD, synchronization queue, conflict resolution, and cloud sync status are not wired into the frontend.
- Supabase migration is a schema starter and has not been applied or tested against a live project. RLS policies require review and security testing before production use.
- No full BCS syllabus seed data is included; users add and edit their own topics. This avoids presenting an unverified syllabus as official.
- The timer UI supports start/pause/resume/finish/cancel but does not yet implement separate break tracking or a live Pomodoro cycle. The Pomodoro setting is saved as a preference only.
- Planner recurrence generation, overlap detection, workload warnings, calendar/week visual view, and automatic revision-task generation are not implemented.
- MCQ questions and per-question attempts are not implemented; tests are entered manually as aggregate results.
- Notification delivery while the app is closed is not implemented; no push scheduler or push subscription flow exists.
- Owner social links are clickable example URLs and the profile image is a local placeholder; replace both in `src/config.ts` before public release.
- PWA behavior has not been tested on target devices/browsers; the service worker caches the shell only.
- Data import validates basic state shape, but exhaustive schema validation and migration/version handling are still needed.

## Recommended next steps

1. Run `npm install`, fix any dependency/type errors, then run `npm run typecheck` and `npm run build`.
2. Add automated unit tests for timer elapsed calculations, score calculations, revision intervals, date boundaries, and restore validation.
3. Wire Supabase authentication and typed repository methods, then test RLS using two separate test users.
4. Implement sync queue/outbox, conflict strategy, retry handling, and offline/online integration tests before exposing cloud sync.
5. Add separate break tracking, Pomodoro cycle, planner recurrence and overlap checks, MCQ question attempts, and push notifications only with appropriate backend infrastructure.
6. Replace footer placeholders only after the owner provides approved assets and URLs.
