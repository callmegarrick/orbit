# Orbit — improvement backlog

Goal: Garrick consistently keeps up with friends & family and never misses a birthday.
Priorities: lower friction to act · make the daily 10-second check-in stick · data safety.

## Done
- [x] v1: dashboard, rings, health labels, calendar, occasions (verified 2026–28 dates), WhatsApp one-tap, export/import, PWA + offline SW, PowerShell server, 9am Windows reminder script
- [x] Iteration 1 (2026-07-11): **Bulk quick-add** — paste "Name, phone, cadence, birthday" lines, one per person; flexible parsing (weekly/every 2 weeks/30, 14 Sep / 11/02/1999). Added permanent `?selftest` hook (10 assertions) for automated verification.
- [x] Iteration 2 (2026-07-11): **Auto-backup to a real file** — File System Access API; pick a file once (Settings → Backup), Orbit rewrites it 1.5s after every change. Handle persisted in IndexedDB; on restart, permission re-granted with one click via toast ("Resume"). Survives browser-data wipe.
- [x] Iteration 3 (2026-07-11): **Backdated logging** — "▾" next to every ✓ Done button opens Today / Yesterday / 2 days ago / date-picker + optional note; "+ Add past touch" in history modal; future dates clamped to today.
- [x] Iteration 4 (2026-07-11): **Weekly wins on hero** — 7-day touch-dot strip (today outlined, filled = ≥1 touch that day) + encouraging copy that scales with the count (0 → nudge, 6+ → 🔥). Reward framing, not guilt.
- [x] Iteration 5 (2026-07-11): **Google Contacts CSV import** — proper quoted-CSV parser, header mapping (old Name/Given Name + new First/Last formats), Google `--MM-DD` year-unknown birthdays, `:::` multi-value phones; preview modal with per-person tick, dupe auto-skip, one cadence applied to all. Selftest now 13 assertions.
- [x] Iteration 6 (2026-07-11): **Final polish** — "turns N" ages on focus cards, birthday rows, and calendar (0004 sentinel year excluded); manifest shortcuts (Who's due today? / People / Calendar); SW cache bumped to orbit-v2 so installed apps refresh. Selftest 15 assertions.

## Next
(empty — improvement loop stopped 2026-07-11 after 6 iterations; remaining ideas below were judged marginal. Restart anytime with /loop.)

## Ideas if the loop restarts
- **Monthly review view** — "who slipped through the cracks last month" retrospective.

## Roadmap loop (started 2026-07-20, per the product vision doc)
- [x] Stage 02 **Plans** (2026-07-20): dated intentions with optional person link ("Movie with Rohan, Sat" / "Decathlon sale, 25th"). Today section (7-day window, overdue flagged), calendar dots (magenta) + "+ Plan on this day" from day panel, done-with-person counts as a touch (undoable), one-tap Google Calendar template links (no OAuth), included in in-app digest, SW alert mirror, and orbit-notify.ps1 morning toast. SW v4. Selftest 19 assertions.

- [x] Stage 03 **Memory** (2026-07-21): "Their people" field per person (partner/kids/pets — shown in a recap block at the top of the person modal along with the last 3 noted moments, i.e. the pre-call recap card); "on this day" hero line resurfacing noted conversations from ~6 and ~12 months back (±2 days) with a follow-up nudge. SW v5. Selftest 20 assertions.

- [x] **My day** (2026-07-21, Garrick's request): lightweight daily to-do space on the Today tab — inline quick-add (Enter to add, stays focused for rapid entry), tap-to-complete, undone items roll over with a "from yesterday" tag, done items fade out after 7 days, delete with undo. Deliberately minimal: no projects/priorities/tags — it's a day list, not a task manager. SW v6. Selftest 21 assertions.

- [x] **Message tones & starter picker** (2026-07-22, prompted by real feedback — Lena spotted the identical canned template): per-person tone (Warm / Respectful / Fun & quirky). WhatsApp button now opens a picker with 3 rotating tone-matched starters (shuffle for more), the last note shown as context, an editable box, and "open chat blank." Nothing auto-sends. Kills the "same generic line every time" tell. SW v7. Selftest 26 assertions. Verified both tones live in browser.

- [x] **Talking points + device-safe templates** (2026-07-22): per-person "bring up next time" topics — jot from the message picker (inline add + remove chips) or the person editor; they resurface in the picker and on the Today focus card every time until ticked off. Also replaced em-dashes with plain punctuation in all WhatsApp-bound templates (older-Android compatibility; the reported � was a paste artifact — source emoji verified valid UTF-8). SW v8. Selftest 28 assertions.

## Anti-overwhelm rebuild (started 2026-07-22 — "one engine: intentions"; law: never show the wall)
- [x] Iteration 1 (2026-07-22): **Smart capture** — the My day box now parses natural input: "call Amma tomorrow" → linked to Amma, dated tomorrow; "gym on friday" / "shoes on the 25th" → future-dated and HIDDEN until that day (a "N scheduled later" counter is the only trace). Completing a person-linked intention logs a touch (and un-completing removes it). Toast confirms what was understood. Selftest 34 assertions. SW v9.

- [x] Iteration 2 (2026-07-22): **The capped Today** — one "Right now" section: up to 3 person cards + top-scored items (occasions today/tomorrow > overdue plans > overdue routines > today's intentions) capped at ~5 total, "N more waiting quietly" hint, capture box always beneath. EVERYTHING else (My day full list incl. scheduled, Plans, Birthdays, Occasions, Routines, Everyone else, Snoozed) folds behind one "Show everything (N)" toggle, collapsed by default. Earned "✨ Clear." state when empty. Test hook `?showall`. SW v10.

- [x] Iteration 3 (2026-07-22): **Focus mode** — "▶ Focus" on Right now opens one card at a time over the capped items (people, todos, plans, routines, occasion queues): ✓ Done / → Tomorrow (snoozes person, re-dates todo/plan) / Skip / 💬 Message; ends on the "✨ Clear." celebration. Esc exits. Test hook `?focus`. SW v11.

- [x] Iteration 4 (2026-07-23): **Pick from contacts** — Android Contact Picker API (`navigator.contacts.select`). "📇 Pick from your contacts" button in the add-person form (single) and "📇 From contacts" in Quick add (bulk, fills the paste box). Feature-detected via `hasContactPicker`; buttons hidden entirely on desktop/iOS where the API doesn't exist (verified: absent from rendered DOM on desktop, no error). Cuts the biggest setup friction on phone. SW v12.

- [x] **Week view / scheduler** (2026-07-23, Garrick's request "see my whole week laid out"): Calendar tab now defaults to a vertical 7-day agenda (Mon-start), each day listing its to-dos, plans, catch-ups due, birthdays, occasions, routines; today highlighted; per-day "+" adds a plan on that day; ←/→ week nav + "This week". Week/Month toggle keeps the month grid one tap away. Todos now also appear in the month grid (green). SW v13. Selftest 37 assertions. This is the planning surface distinct from the capped daily "do" screen — opt-in, so it doesn't reintroduce the wall.

## Boundary-pushing loop (started 2026-07-11)
See [IDEAS.md](IDEAS.md) — brainstorm ledger with verdicts. Iteration 1 shipped `orbit-notify.ps1` + `setup-morning-toast.bat`: native Windows toasts with real names, browser fully closed.

## Parked (marginal / needs justification)
- Contact photos (manual upload only; no API without server)
- Multi-device sync (needs a backend — out of scope by design)
- Streak counters (risk: breaking a streak demotivates — prefer weekly wins framing)

## Verification recipe (for each iteration)
Headless Edge, fresh profile per run:
`msedge --headless=new --disable-gpu --user-data-dir=%TEMP%\fresh-N --virtual-time-budget=8000 --dump-dom "http://localhost:8123/?demo&tab=<id>&selftest"`
Check: no `id="jserror"` div, all `PASS` in `id="selftest"` div, expected UI strings present. Screenshots via `--screenshot=`.
