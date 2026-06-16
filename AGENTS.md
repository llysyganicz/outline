# Repository Guidelines

Outline is a Flutter Desktop note-taking app for Linux and Windows that stores notes as markdown files with frontmatter metadata and supports templates. Built with Flutter 3.44 (stable) and Dart SDK ^3.12.2.

## Hard rules

- Never add native platform dependencies without first updating `pubspec.yaml` and running `flutter pub get`.
- Keep `lib/main.dart` as the app entry point only; place new screens, widgets, and logic in separate files under `lib/`.
- Do not commit generated files from `build/`, `.dart_tool/`, or `coverage/` (already gitignored).

## Project Structure

- `lib/` — Dart source code (currently `main.dart` only; grows as features land).
- `linux/` and `windows/` — platform runner code (Flutter-generated; rarely modified).
- `context/` — project planning docs (PRD, shape notes, tech-stack, change plans) — agent-only, not shipped.
- `test/` — test directory (not yet created; add alongside source files per testing guidelines).
- `pubspec.yaml` — project manifest (dependencies, scripts, metadata).
- `analysis_options.yaml` — linting config (extends `package:flutter_lints/flutter.yaml`).

## Build, Test, and Development Commands

- `flutter pub get` — install dependencies.
- `flutter run -d linux` — launch desktop app (Linux).
- `flutter run -d windows` — launch desktop app (Windows).
- `flutter test` — run all tests.
- `flutter analyze` — static analysis (lints the whole project).
- `flutter build linux --release` — Linux release binary.
- `flutter build windows --release` — Windows release binary.

## Coding Style & Naming Conventions

- Theming: prefer `ColorScheme.fromSeed` and `Material3` (as in `@lib/main.dart`).
- Linting enforced via `flutter analyze` (config in `@analysis_options.yaml`).

## Testing Guidelines

- Place test files in `test/` mirroring `lib/` layout (e.g. `lib/editor/editor.dart` → `test/editor/editor_test.dart`).

## Commit & Pull Request Guidelines

- The repository uses [Jujutsu (jj)](https://github.com/jj-vcs/jj) as its version control system.
- Change descriptions use imperative mood (via `jj describe`), matching the project's imperative convention.
- Squash related changes before pushing (`jj squash`).
- Push to remote with `jj git push`, then open a pull request from the jj branch.
