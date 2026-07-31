# Kith — master build prompt

This is the consolidated spec for Kith, assembled after the fact. Kith was built
incrementally across many sessions; this is the single prompt that would rebuild it
in one shot. Paste it to a capable coding agent to recreate the app.

---

## The one-line mission

Build **Kith** — a personal app that helps someone stay genuinely close to the
people they love (never miss a birthday, never let a friend drift) *and* remember
the everyday things they mean to do. Named from "kith and kin": your close people.

Success is measured in **time-in-app going DOWN** and in real life getting warmer —
"you've been calling more lately" — never in engagement.

## Hard platform constraints (do not violate)

- **No backend, no accounts, no server-side anything.** All data lives on-device in
  `localStorage` (key `orbit-data`) with an IndexedDB mirror (`orbit-idb`) for the
  service worker. Nothing is ever transmitted.
- **The machine has no Node.js and no Python.** Ship as three static files —
  `index.html` (everything: HTML + CSS + vanilla JS, no build step, no framework),
  `manifest.json`, `sw.js` — plus a tiny **PowerShell** static server (`serve.ps1`,
  Windows `HttpListener`, port 8123) for local use, and `.bat` launchers.
- **Installable PWA**, hosted free on GitHub Pages. All paths relative (`./`) so it
  works at any URL path. Service worker is **network-first for HTML/JS/JSON** (so
  updates apply reliably online) and cache-first for icons; page auto-reloads on SW
  `controllerchange`; a visible version badge + "Force update" button in Settings.
- Offline-capable. Respects `prefers-reduced-motion` and light/dark themes.

## The core design principle (this governs everything)

**Overwhelm is the enemy. Never show the wall.** The user abandons apps because they
open them, see a long list, feel bad, and close them. So:

- The **Today** screen shows at most ~3–5 things ("Right now"), scored by urgency,
  blended across people-due AND tasks. Everything else folds behind ONE "Show
  everything" toggle, collapsed by default.
- A **Focus mode** shows one card at a time (Done / push to Tomorrow / Skip) for when
  even five feels like too much.
- Completing empties the screen — that emptiness is the reward ("✨ Clear.").

## Values & guardrails (what to NEVER build)

- **No addiction mechanics.** No streaks that shame, no engagement-bait notifications,
  no points/leaderboards, no infinite feeds, no variable-reward slot loops.
- Gamify the **outcome** (reaching a real person), never app usage.
- **No AI-written messages sent as the user** — people can tell; it destroys trust.
  Suggestions are *starters* the user edits, never autosends.
- **Privacy is structural**: local-only, code public, data never leaves the device.
- Don't reward opening the app; reward keeping people close.

## Feature spec

### People & relationships (the heart)
- Add a person: name, WhatsApp number, **cadence** (how often to stay in touch, e.g.
  every 7/14/30/90 days), optional birthday, "their people" (partner/kids/pets),
  free notes, a **message tone** (Warm / Respectful / Fun & quirky), and **talking
  points** ("bring up next time").
- Per-person **progress ring** = how far through the cadence cycle. Colour-coded:
  green on-track, amber due-soon, red overdue.
- **Health label** (Solid / Drifting / Reconnect) from consistency; recovers fast so
  one bad month isn't a guilt monument.
- **Log a touch** in one tap (with backdate option + optional note). WhatsApp button
  opens a **starter picker**: 3 rotating tone-matched openers (never the same twice)
  + the last note shown as context + editable box + "open blank". Nothing autosends.
- Bulk add (paste lines), Google Contacts CSV import, Android Contact Picker.

### Capture & tasks (the scheduler)
- One **capture box** on Today parses natural language: "call Amma tomorrow" (links
  Amma + dates it), "shoes on friday" (schedules + hides until Friday).
- **My day** to-do list: tap to complete, undone items roll over with a "from
  yesterday" tag, done items fade after a week. A to-do linked to a person counts as
  a touch when completed.
- **Plans**: dated intentions ("Movie with Rohan, Sat") with optional person link and
  one-tap "Add to Google Calendar" (template link, no OAuth).
- **Routines**: recurring life tasks (dentist every 6 months, health check yearly).

### Calendar (see it laid out)
- **Week view** (default): vertical 7-day agenda, each day listing its to-dos, plans,
  catch-ups due, birthdays, occasions, routines; today highlighted; tap any day
  (the "+", an empty day) to add a to-do or plan to it.
- **Month view** toggle: grid with coloured dots per kind + a day panel.

### Notes
- A standalone **Notes** tab: jot/keep anything not tied to a person — ideas, lists,
  gift thoughts. Card grid, optional title, pin-to-top, edit, delete-with-undo.

### Occasions
- Built-in Indian + global festivals with **web-verified dates 2026–2028** (Diwali,
  Holi, Ugadi, Raksha Bandhan, both Eids [moon-dependent ±1 day], Christmas, New
  Year), toggleable, plus custom occasions.
- **Wish queue** per occasion: opens each contact's WhatsApp with a personalised
  message, tracks who's been wished, counts it as a touch.

### Reminders that survive a closed browser
- In-app notifications while open + best-effort PWA periodic background sync.
- **Native Windows toast** (`orbit-notify.ps1`, WinRT via PowerShell) that reads the
  auto-backup JSON and fires every morning at 9:00 with real names ("Say hello to:
  Amma (10d over) · Rohan's birthday in 3 days"), browser fully closed. Registered
  via `setup-morning-toast.bat` (Windows scheduled task).

### Data safety
- **Auto-backup** (File System Access API): pick a file once, Kith rewrites it after
  every change. Export/import JSON. Version badge + Force update in Settings.

### Delight (joy, not addiction)
- Confetti burst on any completion (self-contained canvas, respects reduced-motion) +
  warm microcopy that never repeats.
- **Milestones** that fire once and celebrate the outcome: first touch, reconnecting
  after months apart, 10/25/50/100 catch-ups with someone.
- Easter egg: tap the logo to spin it; 7 taps for a hidden thank-you.
- Monthly review, weekly-wins dot strip, "on this day" resurfacing of past notes.

## Design system

- **Type**: DM Serif Display for headings/brand, DM Sans for everything else.
- **Palette**: warm off-white / near-black neutrals; accent blue `#2a78d6` (light) /
  `#3987e5` (dark); status greens/ambers/reds kept separate from the accent; per-kind
  calendar colours (catch-up blue, to-do green, plan magenta, birthday violet,
  occasion orange, routine aqua). Full light + dark themes, both deliberately styled.
- Clean, minimal, generous spacing, progress rings and soft cards. Nothing cluttered —
  every element earns its place.

## Data model (localStorage `orbit-data`)

```
{ version, people[], tasks[] (routines), plans[], todos[], notes[],
  occasions[] (with per-year done maps), settings{ birthdayLead, occasionLead,
  lastNotified, milestones, lastAutoBackup } }
```
Person: `{ id, name, phone, cadence, birthday, tone, circle, notes, topics[],
interactions[]{date,note}, snoozedUntil, createdAt }`. **Never rename the storage
keys** (`orbit-data`, `orbit-idb`, `orbit-backup`) even if rebranding — doing so wipes
user data.

## Verification (build discipline)

- Every change verified in **headless Edge** (`msedge --headless=new --dump-dom` /
  `--screenshot`, fresh `--user-data-dir` per run).
- A permanent `?selftest` hook runs ~44 machine-checkable assertions into a hidden
  div; `?demo` loads sample data; `?tab=`, `?showall`, `?focus`, `?review` deep-link
  states; a hidden `#jserror` div captures runtime errors. Ship only when selftest is
  green and there's no jserror.
- Bump the SW cache version + the visible APP_VERSION together on every release.
