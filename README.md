# PrepPilot — BCS & Government Job Preparation Tracker

PrepPilot is a local-first study planner for BCS Preliminary and other government recruitment exams. It combines study timing, task planning, editable syllabus tracking, spaced-revision scheduling, mock-test records, progress analytics, browser notifications, and JSON backup/restore in one responsive interface.

> **Current delivery status:** this is a functional local-mode starter, not yet a fully production-integrated cloud application. See `PROJECT_STATUS.md` for the implemented and unverified parts. No cloud sync or authentication is claimed in the current UI.

## Stack

- React + TypeScript + Vite
- Recharts for study-time charts; Lucide React icons
- IndexedDB persistence through `idb`, with a localStorage fallback if IndexedDB is unavailable
- Optional Supabase schema starter in `supabase/migrations/`
- PWA manifest and a basic cache-first/offline fallback service worker

## Requirements

- Node.js 20.19+ or 22.12+
- npm 10+

## Run locally

```bash
npm install
cp .env.example .env.local
npm run dev
```

Vite prints a local URL, usually `http://localhost:5173`. The app works in local-only mode without `.env.local` credentials. Your records are stored in the current browser profile; use Settings → Export backup to save a JSON copy before clearing browser data or switching devices.

## Scripts

```bash
npm run typecheck  # TypeScript checks
npm test           # automated domain-calculation tests
npm run build      # production build
npm run preview    # preview the production build
```

## Local persistence and offline use

The app stores the whole local workspace in IndexedDB. If IndexedDB is unavailable, the persistence helper attempts localStorage. This is per-browser/per-device storage; clearing site data can remove it. Export a JSON backup regularly. The service worker is registered for production builds and caches the app shell for an offline fallback. A first visit still needs a network connection to load the deployed app and its bundled assets.

## Features currently available

- Dashboard metrics calculated from stored sessions, tasks, revisions, and topics (empty states are shown when there is no data)
- Stopwatch study sessions with timestamp-based elapsed-time calculation and restoration after refresh
- Task create/edit/delete, status updates, priority, schedule, and start-session action
- Editable syllabus topic list, status/difficulty/priority, topic-linked study sessions, and revision creation
- Revision outcomes (Easy, Difficult, Forgotten) with documented interval behavior in the UI logic; easy defaults to 7 days, difficult to 3 days, forgotten to 1 day
- Manual mock-test result entry with correctness, unanswered counts, negative marking, accuracy, and score history
- Weekly study-time charts, subject distribution, goal and completion metrics, data export/import
- Dark/light themes, daily/weekly goals, Pomodoro preference, timezone preference, browser notification permission flow
- Project owner footer with Rubel and clearly nonfunctional placeholder social labels (replace with real URLs before public release)

## Supabase setup (not connected to the app yet)

1. Create a Supabase project.
2. Copy `.env.example` to `.env.local` and set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` using your project's public URL and anon key.
3. Apply `supabase/migrations/202610170001_initial_schema.sql` in the Supabase SQL editor or through the Supabase CLI.
4. Configure Auth → URL Configuration with your local and production callback URLs. Enable Google provider and configure OAuth credentials in both Google Cloud and Supabase if you want Google sign-in.
5. Before enabling cloud access, implement and test the client auth/session flows, data repository adapters, conflict-safe sync queue, and RLS integration tests. The current frontend deliberately does not imply cloud sync merely because variables exist.

Never put a Supabase service-role key in frontend environment variables. The `VITE_` prefix exposes values to browser code; only the anon key belongs there.

## Deployment

### Vercel

1. Push the project to GitHub.
2. Import it into Vercel.
3. Build command: `npm run build`; output directory: `dist`.
4. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` only if/when the app's cloud integration is implemented and tested.
5. Deploy over HTTPS. Verify PWA installability and offline behavior on the target browser after deployment.

### Netlify

Use `npm run build` and publish `dist`. Add a single-page-app redirect (`/* /index.html 200`) if deep routes are added in future. HTTPS is required for service workers outside localhost.

## Notifications caveat

In-app notifications are local records. Browser permission can be requested by a user action, but the current version does not schedule exact-time reminders, implement push subscriptions, or deliver notifications reliably while the app is closed. Reliable closed-app notifications require a backend scheduler, push subscription storage, and service-worker push handlers.

## Data backup and restore

Settings → Export backup downloads all local state as JSON. Restore validates the basic structure and asks before replacing current data. Keep backups private because they may contain personal study notes. Never import a backup you do not trust.

## Owner footer

The footer is centrally rendered in the shared application shell. The current social references are plain placeholder labels, not actual links. Before publishing, edit `src/config.ts` and replace the placeholder profile image and WhatsApp/Facebook/LinkedIn example URLs with real, owner-approved details. Do not publish invented contact information.


## Deploy on GitHub Pages

This repository includes a GitHub Actions workflow at `.github/workflows/deploy.yml`.
It builds the Vite app and publishes `dist/` to GitHub Pages automatically whenever
you push to the `main` branch.

1. Create a GitHub repository (for example, `PrepPilot`) and upload/push all files
   from this project. Keep `package.json`, `package-lock.json`, `src/`, `public/`,
   `index.html`, and `.github/` at the repository root.
2. In GitHub, open **Settings → Pages**.
3. Under **Build and deployment → Source**, choose **GitHub Actions**.
4. Open the **Actions** tab and wait for **Deploy PrepPilot to GitHub Pages** to finish.
5. Your site URL will be shown in the workflow deployment summary and in **Settings → Pages**.

The Vite base path is automatically set from the GitHub repository name during the
Actions build, so a project site such as `https://USERNAME.github.io/PrepPilot/`
can load its assets correctly.

### Supabase configuration

If you use the cloud sync features, add the required Supabase values as GitHub
repository Actions secrets/variables and wire them into the build workflow as
`VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` if the application expects them.
Do not commit private service-role keys. Local browser storage features can work
without cloud credentials, but cloud sync requires a valid Supabase project setup.
