---
project: "Outline"
version: 1
status: draft
created: 2026-06-16
context_type: greenfield
product_type: desktop
target_scale:
  users: small
  qps: "# TODO: qps — see Open Questions"
  data_volume: "# TODO: data_volume — see Open Questions"
timeline_budget:
  mvp_weeks: 2
  hard_deadline: null
  after_hours_only: true
---

## Vision & Problem Statement

Developers who write structured, recurring-format markdown notes daily have no lightweight desktop tool that covers their full workflow. Existing tools are either too heavy (Obsidian and its plugin ecosystem) or missing the key capability: a form-driven template system that prompts for input before inserting structured content.

The insight: templates in existing lightweight editors are static text — they don't know what inputs they need. Outline treats a template's frontmatter as a form definition, rendering a dynamic dialog on insertion. This turns repetitive note creation from manual boilerplate into a guided, structured action — and it's not available in any standalone lightweight editor today.

## User & Persona

**Primary persona:** A developer who writes structured markdown notes daily — project notes, meeting notes, research logs, task records. They maintain a library of note formats and reach for templates constantly. They want an editor that is light, stays out of the way, and handles their template workflow without requiring a plugin ecosystem or a heavyweight app.

Name: Developer (the user themselves is the primary persona; the app generalises to others in the same role)
Context: Works on Linux or Windows; stores notes as plain files on disk; values data ownership and simplicity.
Moment: Opening a new note and wanting to apply a template — currently either fighting a heavy app or typing boilerplate by hand.

## Success Criteria

### Primary
- A user can open Outline, browse a directory tree of markdown notes, open a note, edit it in a plain-text editor with syntax highlighting, and toggle to a rendered HTML preview. This flow working end-to-end = the product works.

### Secondary
- Templates with form-driven insertion work: a user can pick a template, fill in the form fields defined in its frontmatter, and have the rendered content inserted into a new note or at the cursor position in the current note.

### Guardrails
- The editor never mutates markdown automatically — no auto-formatting, no surprise transformations of the user's raw text.
- The app runs on both Linux and Windows with no platform-only behavior or shortcuts.

## User Stories

### US-01: User browses, edits, and previews a note

- **Given** a user opens Outline pointed at a directory containing markdown files
- **When** they select a note from the file tree and switch between edit and preview modes
- **Then** the editor shows the raw markdown with syntax highlighting, and the preview shows correctly rendered HTML

#### Acceptance Criteria
- File tree shows all markdown files and directories under the root
- Opening a note loads its content into the editor
- Edit mode shows raw markdown; preview mode shows rendered HTML
- Switching modes does not modify the file's content

### US-02: User applies a form-driven template

- **Given** a user has a templates directory containing at least one template file whose frontmatter defines one or more form fields, and a note is open in the editor
- **When** they trigger “use template”, select a template from the templates directory, fill in the form dialog that renders the declared field types, and confirm
- **Then** the template body with `{{field_name}}` placeholders replaced by the entered values is inserted at the cursor position in the current note (or created as a new note if triggered from the “new note from template” action)

#### Acceptance Criteria
- If the templates directory does not exist, the “use template” action is unavailable
- Templates without frontmatter form fields insert immediately — no dialog shown
- The form dialog renders each field in its declared type: text (single-line), text (multiline), number, date, select (dropdown)
- All `{{field_name}}` placeholders in the body are replaced; unmatched placeholders are left as-is (no silent data loss)
- Inserting at cursor does not modify content outside the inserted region
- Creating from template produces a new file containing only the rendered body (frontmatter form definition is stripped from the output)

## Functional Requirements

### File Navigation
- FR-001: User can browse notes and directories in a file tree. Priority: must-have
  > Socrates: Counter-argument considered: "OS file manager already handles browsing." Resolution: kept; an in-app file tree is table-stakes for a focused note-taking tool — switching to a file manager breaks the flow.
- FR-002: User can open a markdown note for reading/editing. Priority: must-have
- FR-005: User can create a new note. Priority: must-have
- FR-006: User can create a new directory. Priority: must-have
- FR-007: User can delete a note. Priority: must-have
- FR-008: User can delete a directory. Priority: must-have
  > Socrates: Counter-argument considered: "Deletion is dangerous; OS file manager handles it." Resolution: kept; CRUD without delete is incomplete. A confirmation dialog is required to prevent accidental data loss.

### Editor
- FR-003: User can edit a note in a plain-text editor with syntax highlighting. Priority: must-have
- FR-004: User can toggle between edit mode (plain text) and preview mode (rendered HTML). Priority: must-have
  > Socrates: Counter-argument raised: "Preview rendering can be complex to implement." Resolution: kept; preview is core to markdown editing. Complexity risk noted — use an existing markdown rendering library rather than building from scratch.
- FR-009: User can view frontmatter metadata in a note without it being mangled by the editor. Priority: must-have
  > Socrates: Counter-argument considered: "Treat frontmatter as plain text in v1." Resolution: kept; frontmatter is load-bearing for the template system — it must be parsed correctly.

### Templates
- FR-010: User can browse templates stored in a dedicated templates directory. Priority: must-have
- FR-011: User can create a new note from a template. Priority: must-have
- FR-012: User can insert a template at the cursor position in the currently open note. Priority: must-have
- FR-013: User can fill in a dynamic form when using a template that has a form definition in its frontmatter. Priority: must-have
- FR-014: Form field types supported: text (single-line), text (multiline), number, date, select (dropdown). Priority: must-have
  > Socrates: Counter-argument considered: "Start with text-only forms; the full field set is too broad for v1." Resolution: kept; the full field type set is the key differentiator of Outline. Cutting it would reduce the MVP to something any static template tool already does.

## Non-Functional Requirements

- Edit/preview mode switching is perceptible as instant: user-perceived latency < 200 ms.
- The app makes no network calls and transmits no data outside the local machine — no telemetry, no analytics, fully offline.

## Business Logic

Outline parses a template's frontmatter form definition and renders a dynamic input dialog, then substitutes the collected values into the template body before inserting it.

The rule's inputs are: a template file whose frontmatter declares one or more form fields (each with a type and label), and the values the user enters into the rendered dialog. The output is the template body with all field placeholders replaced by user-supplied values, inserted either as a new note or at the cursor position in the current note. The user encounters this rule every time they trigger "use template" — the form is the bridge between a static template file and a filled, structured note.

## Access Control

Single user; no auth; data lives on-device only. The app opens directly to the user's note library. Notes are plain markdown files on the filesystem. No accounts, no login, no roles.

## Non-Goals

- **No cloud sync or remote storage** — notes live on the local filesystem only; sync is out of scope for v1 and may never be in scope.
- **No collaboration or multi-user features** — single-user, single-machine tool.
- **No mobile app** — Linux and Windows desktop only; no iOS/Android target.
- **No plugin or extension system** — the feature set is fixed in v1; extensibility is not a design goal.
- **No version history or git integration** — the app does not track note history; users who want versioning use git externally.

## Open Questions

1. **What rendering library to use for markdown preview?** — Owner: user. Note: complexity risk flagged in FR-004 Socratic round; resolution deferred to tech-stack selection.
2. **What's the placeholder syntax for template form fields in the template body?** — Owner: user. By: before implementation planning. (e.g., `{{field_name}}` vs `<field_name>` vs custom syntax.)
3. **What are the ballpark `qps` and `data_volume` for `target_scale`?** — Owner: user. Note: for a local desktop app these may be N/A; confirm or provide ballparks so the PRD frontmatter is complete.
4. ~~Missing user story for the template insertion flow~~ — **Resolved: US-02 added above.**
