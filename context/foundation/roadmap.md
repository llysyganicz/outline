---
project: "Outline"
version: 1
status: draft
created: 2026-06-16
updated: 2026-06-17
prd_version: 1
main_goal: speed
top_blocker: decisions
---

# Roadmap: Outline

> Derived from `context/foundation/prd.md` (v1) + auto-researched codebase baseline.
> Edit-in-place; archive when superseded.
> Slices below are listed in dependency order. The "At a glance" table is the index.

## Vision recap

Developers who write structured markdown notes daily lack a lightweight desktop tool that covers their full workflow. Outline sits between too-heavy apps (Obsidian and its plugin ecosystem) and too-dumb ones (static template tools): it renders a template's frontmatter as a dynamic input dialog at insertion time, turning repetitive note creation into a guided, structured action that no standalone lightweight editor currently offers. The app targets Linux and Windows and stores all data as plain markdown files on disk — no cloud, no accounts, no plugins.

## North star

**S-01: browse-edit-preview** — the first end-to-end slice that, if shipped, proves the core product premise works: the user can open Outline, browse a directory of notes, open one, edit it with syntax highlighting, and toggle to a rendered HTML preview.

> "North star" here means the smallest end-to-end user-visible slice whose successful delivery would prove the core product hypothesis — placed as early as its Prerequisites allow, because everything else only matters if this one works. Per the primary Success Criterion: "This flow working end-to-end = the product works."

## At a glance

| ID | Change ID | Outcome (user can …) | Prerequisites | PRD refs | Status |
|---|---|---|---|---|---|
| S-01 | browse-edit-preview | browse a markdown directory tree, open and edit a note with syntax highlighting, and toggle to HTML preview | — | US-01, FR-001, FR-002, FR-003, FR-004, FR-009, FR-010 | done |
| S-02 | file-management | create new notes and directories, and delete them with a confirmation dialog | S-01 | FR-005, FR-006, FR-007, FR-008 | proposed |
| S-03 | create-from-template | create a new note from a template file located in the templates directory; if the templates directory does not exist, no templates are available | S-01 | FR-011 | proposed |
| S-04 | form-driven-template-insertion | insert a template at the cursor position by filling in a dynamic form dialog with typed fields (text, multiline, number, date, select) | S-01, S-03 | FR-012, FR-013, FR-014 | blocked |
| S-05 | structured-logging | configure a file-based logging mechanism to replace debugPrint calls so errors and diagnostics are persisted to disk for post-mortem debugging | S-01 | (infra) | proposed |

## Baseline

What's already in place as of 2026-06-16 (auto-researched + user-confirmed).
Foundations below assume these are present and do NOT re-scaffold them.

- **Frontend:** partial — `lib/main.dart`: MaterialApp + Material3 theme + empty `EditorScreen` widget; no feature code yet
- **Backend / API:** absent — local desktop app; no backend needed by design
- **Data:** absent — no filesystem I/O, no note or frontmatter parsing implemented
- **Auth:** absent — not needed; single-user, no-auth per PRD
- **Deploy / infra:** present — `.github/workflows/ci.yml` (analyze on push/PR) + `release.yml` (builds Linux+Windows binaries, publishes GitHub Release on tag push)
- **Observability:** absent — default Flutter debug output only; no logging library

## Foundations

None. The Flutter scaffold is already in place (partial — `lib/main.dart` shell exists). No cross-cutting prerequisites need their own foundation before vertical work can start: no auth, no DB, no special infrastructure. All technical elements (filesystem I/O, markdown parsing, frontmatter parsing, form engine) are introduced inline within the first slice that needs them, per the progressive disclosure principle.

## Slices

### S-01: Browse, edit, and preview a note

- **Outcome:** user can open Outline pointed at a directory, browse all markdown files in a file tree, select and open a note, edit it in a plain-text editor with syntax highlighting, and toggle between edit mode and rendered HTML preview without modifying the file's content
- **Change ID:** browse-edit-preview
- **PRD refs:** US-01, FR-001, FR-002, FR-003, FR-004, FR-009, FR-010
- **Prerequisites:** —
- **Parallel with:** —
- **Blockers:** —
- **Unknowns:**
  - ~~What markdown rendering library to use?~~ **Resolved: `flutter_markdown_plus`** (official successor to the discontinued `flutter_markdown`; v1.0.7, Flutter 3.44 compatible, 334k downloads/month, drop-in API).
  - FR-010 coverage note: the templates directory is visible in the regular file tree — no separate template browser UI is needed. Convention: if a templates directory exists under the root, its files are available as templates; if it doesn't exist, there are no templates. `/10x-plan` decides the directory name convention (e.g., `_templates/`).
- **Risk:** This is the north star — nothing else is meaningful until this works. The main implementation risk is edit/preview latency: the NFR requires < 200ms mode switch; must be verified end-to-end before the slice is closed.
- **Status:** done

---

### S-02: File management — create and delete notes and directories

- **Outcome:** user can create a new blank note, create a new directory, delete a note with a confirmation dialog, and delete a directory with a confirmation dialog
- **Change ID:** file-management
- **PRD refs:** FR-005, FR-006, FR-007, FR-008
- **Prerequisites:** S-01
- **Parallel with:** S-03
- **Blockers:** —
- **Unknowns:** —
- **Risk:** Deletion is irreversible; the confirmation dialog is load-bearing (noted in FR-008 Socratic round). Risk is low if the dialog gate is implemented correctly and tested before merge.
- **Status:** proposed

---

### S-03: Create note from template

- **Outcome:** user can select a template file from the templates directory visible in the file tree and create a new note pre-populated with the template's body content (static content only, no form); if the templates directory does not exist, no templates are available
- **Change ID:** create-from-template
- **PRD refs:** FR-011
- **Prerequisites:** S-01
- **Parallel with:** S-02
- **Blockers:** —
- **Unknowns:** —
- **Risk:** The templates directory name/convention must be settled during `/10x-plan` (e.g., `_templates/` under the root); a wrong convention here would require renaming in S-04, but the decision is low-stakes and reversible.
- **Status:** proposed

---

### S-04: Form-driven template insertion

- **Outcome:** user can insert a template at the cursor position in the currently open note by triggering a dynamic form dialog — the dialog renders typed input fields (text single-line, text multiline, number, date, select/dropdown) defined in the template's frontmatter, substitutes the entered values into the template body replacing `{{field_name}}` placeholders, and inserts the result at the cursor
- **Change ID:** form-driven-template-insertion
- **PRD refs:** FR-012, FR-013, FR-014
- **Prerequisites:** S-01, S-03
- **Parallel with:** —
- **Blockers:** —
- **Unknowns:** —
- **Risk:** This is the product's key differentiator — the form dialog renders dynamically from the template's frontmatter. The riskiest assumption (the assumption whose failure would invalidate this slice) is that Flutter's widget system can render a fully dynamic form from a parsed frontmatter schema at runtime; a one-field proof-of-concept early in implementation de-risks the rest of the field types. Placeholder syntax settled: `{{field_name}}`.
- **Status:** proposed

### S-05: Structured logging to file

- **Outcome:** all debugPrint/error catch blocks replaced with a logger that writes to a rotating log file on disk, so users and developers can diagnose issues post-mortem without a debug console
- **Change ID:** structured-logging
- **PRD refs:** (infra — not user-facing, but supports observability)
- **Prerequisites:** S-01
- **Parallel with:** S-02, S-03
- **Blockers:** —
- **Unknowns:** —
- **Risk:** Low — replacing debugPrint calls is mechanical; choosing a logging library and log directory convention are the only decisions.
- **Status:** proposed

---

## Backlog Handoff

| Roadmap ID | Change ID | Suggested issue title | Ready for `/10x-plan` | Notes |
|---|---|---|---|---|
| S-01 | browse-edit-preview | Set up note browser, syntax-highlighted editor, and HTML preview toggle | yes | Run `/10x-plan browse-edit-preview`; use `flutter_markdown_plus` for preview |
| S-02 | file-management | Create and delete notes and directories with confirmation dialog | no | After S-01 lands; can run in parallel with S-03 |
| S-03 | create-from-template | Create new note from a static template file in the templates directory | no | After S-01 lands; can run in parallel with S-02 |
| S-04 | form-driven-template-insertion | Form-driven template insertion at cursor (dynamic dialog, typed fields, `{{field_name}}` substitution) | no | After S-01 + S-03 land |
| S-05 | structured-logging | Add file-based logging to replace debugPrint calls; errors and diagnostics persisted to disk | no | After S-01 lands; cross-cutting concern |

## Open Roadmap Questions

~~1. Placeholder syntax for template form fields~~ — **Resolved: `{{field_name}}`.**

~~2. Markdown rendering library for HTML preview~~ — **Resolved: `flutter_markdown_plus`** (official successor to the discontinued `flutter_markdown`; v1.0.7, Flutter ≥3.27.1, 334k downloads/month, drop-in API).

~~3. `qps` / `data_volume` in PRD frontmatter~~ — **Closed: N/A.** These are web-service metrics (requests per second, database volume). A local desktop app has no server and no request queue; file I/O runs at OS speed. No action needed.

~~4. User story US-02 for the template insertion flow~~ — **Resolved: US-02 added to `prd.md`.**

## Parked

- **Cloud sync or remote storage** — Why parked: PRD §Non-Goals; out of scope for v1 and possibly forever.
- **Collaboration or multi-user features** — Why parked: PRD §Non-Goals; single-user, single-machine tool.
- **Mobile app (iOS/Android)** — Why parked: PRD §Non-Goals; Linux and Windows desktop only.
- **Plugin or extension system** — Why parked: PRD §Non-Goals; fixed feature set in v1; extensibility is not a design goal.
- **Version history or git integration** — Why parked: PRD §Non-Goals; users who want versioning use git externally.

## Done

- **S-01: browse a markdown directory tree, open and edit a note with syntax highlighting, and toggle to HTML preview** — Archived 2026-06-17 → `context/archive/2026-06-16-browse-edit-preview/`. Lesson: —.
