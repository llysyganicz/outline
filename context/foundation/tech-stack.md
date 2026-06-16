---
starter_id: flutter
package_manager: pub
project_name: outline
hints:
  language_family: dart
  team_size: solo
  deployment_target: self-host
  ci_provider: github-actions
  ci_default_flow: manual-promotion
  bootstrapper_confidence: verified
  path_taken: standard
  quality_override: false
  self_check_answers: null
  has_auth: false
  has_payments: false
  has_realtime: false
  has_ai: false
  has_background_jobs: false
---

## Why this stack

A solo developer building a lightweight desktop markdown editor targeting Linux and Windows in a 2-week after-hours sprint needs a typed, cross-platform UI toolkit with verified scaffolding and strong conventions. Flutter is the recommended default for `(desktop, dart)` and clears all four agent-friendly quality gates: typed (Dart's type system + null safety), convention-based (Flutter's consistent widget-tree layout and project structure), well-represented in training data, and comprehensively documented. The verified bootstrapper confidence means scaffolding will be smooth with no manual-step surprises. No technology-forcing features are in scope — no auth, payments, realtime, AI, or background jobs — keeping the stack clean and minimal. Desktop support targets Linux and Windows explicitly; the PRD non-goals rule out mobile. Deployment is self-host (distribute the built binary directly, e.g., via GitHub Releases); CI runs on GitHub Actions with manual promotion (required-reviewer gate on the publish job) so releases are gate-controlled before distribution. The user intends to scaffold in-place into the current directory rather than a new subdirectory — communicate this to `/10x-bootstrapper` at run time.
