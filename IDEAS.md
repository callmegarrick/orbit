# Orbit — boundary-pushing ideas ledger

The goal isn't more features. It's: Garrick consistently keeps up with people and never misses a birthday.
Every idea gets an honest verdict against the real constraints: no Node/Python, no server, WhatsApp auto-send impossible, habit psychology > features.

## ✅ Built

### 1. Native Windows toasts with the browser closed (iteration 1, 2026-07-11)
The "web apps can't notify when closed" wall only exists *inside* the browser. Orbit's auto-backup already writes all data to a JSON file — so `orbit-notify.ps1` reads that file directly and fires a **native Windows toast** (WinRT, zero installs) with actual names: "Say hello to: Amma (10d over) · Rohan's birthday in 3 days". Clicking it opens the app. `setup-morning-toast.bat` registers it daily at 9:00.
**Why it matters:** this was the one broken promise in the original spec — reminders you can't miss, with nothing running. Now it exists.
**Dependency:** turn on auto-backup in Settings (file must be named orbit-backup*.json in the Orbit folder, Documents, OneDrive, Downloads, or Desktop). Without it, a generic morning nudge still fires.
**Verified:** live-tested against synthetic data — overdue math, birthday window, occasion window, snooze-skip and disabled-skip all correct.

## ✅ Built (continued)

### 2. Conversation fuel (iteration 2, 2026-07-11)
The hard part of reconnecting isn't remembering *to* call — it's the blank "what do I say" moment. Now: the last note ("asked about her job interview") shows on focus cards and people cards right where you read before tapping WhatsApp, and after every ✓ Done the toast offers "📝 add note" so capturing takes 3 seconds while fresh.
**Honest limitation:** I deliberately did NOT auto-inject notes into the WhatsApp prefill text — machine-mangled "personal" messages read as fake. The note is fuel for *your* words, not a replacement.

### 3. Monthly review ritual (iteration 3, 2026-07-11)
First 5 days of each month, the Today view offers a 2-minute review (also always at People → ☾ Review): total touches + most-consistent star, **missed birthdays with a one-tap belated-wishes button**, people who slipped through with zero touches — each with WhatsApp / log / **Relax** (if a cadence keeps failing, it's the wrong cadence; bump it to one you'll actually keep). Test hook: `?review`.

## 🔨 Next up
(nothing above the bar — loop stopped 2026-07-11 after 3 iterations; parked ideas below need Garrick's call)

## 🅿 Parked (honest reasons)

- **AI-drafted personal messages** (Claude API): genuinely powerful — drafts a personal message from your notes+occasion. Needs an API key and costs money per message. Parked until Garrick says he wants it; then it's ~an hour of work.
- **Phone access**: the PWA would work on Android/iPhone but needs hosting (GitHub Pages) — data wouldn't sync between devices without a backend. Export/import works as a manual bridge. Parked: laptop-first is fine for building the habit.
- **Voice logging** ("I called Amma") via Web Speech API: cool demo, slower than clicking ✓ Done. Parked as gimmick.

## ❌ Rejected (so we stop re-litigating)

- **WhatsApp true auto-send** — requires WhatsApp Business API (a business account, approval, per-message fees) or ToS-violating automation that gets numbers banned. The one-tap prefilled queue is the honest ceiling. **Final.**
- **Cloud sync / multi-device backend** — a server means accounts, hosting, security, cost; destroys the "your data never leaves your laptop" property. **Out of scope by design.**
- **Streak counters** — one broken streak and the app becomes a monument to failure. Weekly-wins dots (already shipped) reward without punishing. **Final.**
