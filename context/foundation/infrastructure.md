---
project: Outline
researched_at: 2026-06-16
recommended_platform: GitHub (Actions + Releases)
runner_up: GitLab (CI + Releases)
context_type: mvp
tech_stack:
  language: Dart
  framework: Flutter Desktop
  runtime: Native binary (Linux x64, Windows x64)
---

## Recommendation

**Distribute Outline binaries via GitHub Actions + GitHub Releases.**

Outline is a native desktop app, not a web service — "deployment" means building and distributing compiled binaries for Linux and Windows. GitHub is the strongest fit for this use case across all five agent-friendly criteria: it offers free CI with both Windows and Linux runners (essential for Flutter cross-platform builds), permanent release artifact hosting, a mature `gh` CLI for the full release lifecycle, and the only GA MCP server among the evaluated platforms — enabling an agent to manage releases programmatically. The platform was initially ranked #2 due to user preference for GitLab, but GitLab's lack of free-tier Windows runners makes it a blocker without a Windows development machine.

## Platform Comparison

The following platforms were evaluated as distribution infrastructure for a native Flutter desktop app (manual binary download, no code signing, cost-minimized at MVP). Criteria are adapted from the agent-friendly platform rubric: CLI-first maintenance, managed/SaaS operations, agent-readable docs, stable deployment API, and MCP/first-class integration.

| Platform | CLI-first | Managed/SaaS | Agent-readable docs | Stable release API | MCP / Integration | Total |
|---|---|---|---|---|---|---|
| **GitHub (Actions + Releases)** | ✅ Pass | ✅ Pass | ✅ Pass | ✅ Pass | ✅ Pass | **5/5** |
| **GitLab (CI + Releases)** | ⚠️ Partial | ✅ Pass | ⚠️ Partial | ⚠️ Partial | ❌ Fail | **2.5/5** |
| **Cloudflare R2 + Pages** | ⚠️ Partial | ⚠️ Partial | ✅ Pass | ⚠️ Partial | ❌ Fail | **2.5/5** |
| **Self-hosted (VPS + S3)** | ⚠️ Partial | ❌ Fail | ❌ Fail | ⚠️ Partial | ❌ Fail | **1.5/5** |

### Platform notes

- **GitHub (Actions + Releases)** — the only platform with a full 5/5 score. Free for public repos with **unlimited CI minutes** on both Windows and Linux runners (no shared runner minutes to ration). Permanent release artifact hosting with no storage cap for public repos. The `gh` CLI covers the full release lifecycle non-interactively: `gh release create`, `gh release upload`, `gh release download` all work with no flags beyond the required arguments. Official GitHub MCP Server (GA) enables agent-driven repo, issue, PR, Action, and release management. Docs are published as markdown on GitHub with `llms-full.txt` available for agent consumption.

- **GitLab (CI + Releases)** — scored #2. Fully managed SaaS with a stable Releases API. However: (a) **no Windows shared runners on the free tier** — a hard blocker for Flutter cross-platform builds without a Windows machine, (b) 400 CI minutes/month limit is tight for Flutter's ~15-minute builds, (c) 5GB storage cap, (d) no MCP server, (e) `glab` CLI is community-maintained, (f) docs are HTML-only with no `llms.txt`. Viable for Linux-only projects but not suitable for a dual-platform desktop app without a self-hosted Windows runner or a paid plan.

- **Cloudflare R2 + Pages** — excellent asset delivery (zero egress fees, global CDN) but requires a separate CI service and hand-building a release pipeline from scratch. More DIY effort with less agent-friendly tooling. Better suited as a supplement (e.g., mirror downloads) than a primary distribution channel.

- **Self-hosted (VPS + S3-compatible storage)** — maximum control but unacceptable ops burden for an MVP solo project. Requires server provisioning, backups, security patching, and a custom release pipeline. No agent-friendly docs or MCP integration. Ruled out as incompatible with "minimize cost" and "MVP speed" constraints.

### Shortlisted Platforms

#### 1. GitHub (Actions + Releases) (Recommended)

GitHub wins decisively because it's the only free-tier option that can **automatically build Flutter for both Linux and Windows**. GitHub Actions offers unlimited CI minutes for public repos on both Ubuntu and Windows runners — no rationing, no self-hosted runner setup, no paid upgrade. The `gh` CLI and GitHub MCP Server (GA) make the full release pipeline agent-operable: an agent can tag, build, create a release, upload assets, and verify success without a browser. Docs are available as markdown on GitHub with `llms-full.txt` for direct agent reading. The only cost is that the repo must be public to use the free tier.

#### 2. GitLab (CI + Releases)

A strong platform for Linux-only projects, but the lack of free Windows runners is a hard blocker for Outline. With a Windows machine you could self-host a runner, but without one, building Windows binaries on GitLab free tier is impossible. If you later set up a Windows self-hosted runner or upgrade to Premium, GitLab becomes viable again.

#### 3. Cloudflare R2 + Pages

Best-in-class global asset delivery at zero egress cost, but requires too much custom engineering (separate CI, custom release script, hand-built download page) for an MVP. Not recommended as the primary distribution channel.

## Anti-Bias Cross-Check: GitHub (Actions + Releases)

### Devil's Advocate — Weaknesses

1. **Free tier requires a public repository.** If you ever want the repo to be private, GitHub's free CI minutes drop to 2000 min/month, and you lose permanent release artifact storage. The project's current status is unclear — if it's meant to be private, the cost calculus changes.
2. **No built-in auto-update mechanism.** GitHub Releases is a file host. There's no update-check protocol, no delta updates, no installers. Every update is a full manual re-download. Adding auto-update later requires a custom update checker or adopting a framework like `flutter_app_updater`.
3. **Unsigned Windows binaries trigger SmartScreen warnings.** Without an EV code signing certificate ($200-500/year), Windows will flag the downloaded binary as "unverified publisher" and may block installation entirely depending on SmartScreen settings.
4. **GitHub Actions runner IPs change without notice.** If a future build step needs to access a restricted network, you can't whitelist by IP. This is a minor concern at MVP but becomes relevant with private package repositories or internal APIs.
5. **Vendor lock-in on CI workflows.** Your `.github/workflows/build.yml` is GitHub Actions-specific. Moving to another CI platform later requires a full rewrite. Acceptable for an MVP but worth noting.

### Pre-Mortem — How This Could Fail

> The team deployed Outline via GitHub Actions and Releases. Six months later, the decision turned out to be a complete disaster.
>
> The build pipeline was set up hastily — no caching, no conditional execution. Each CI run took 15-20 minutes, burning through the developer's patience. Since the repo was private (the team didn't want to open-source), they hit the 2000-minute cap quickly and started paying $4/user/month for GitHub Pro. The cost was small, but the frustration of slow, opaque builds mounted.
>
> Windows users couldn't install the app without seeing a SmartScreen warning. The "Windows protected your PC" dialog scared away most testers. A competing note-taking app with a signed installer and auto-update gained traction while Outline's adoption stalled.
>
> The release process was entirely manual — a developer had to trigger the workflow, wait, download artifacts, and run `gh release create`. No automation was ever built because "it's just an MVP." Two releases shipped with broken Linux bundles because the Ubuntu image version silently changed and dropped a required system library.
>
> The root mistake: treating "distribution" as a solved problem once the binaries were uploaded, when in fact the entire pipeline — CI reliability, caching, code signing, release automation — needed deliberate engineering that was deferred indefinitely.

### Unknown Unknowns

- **`subosito/flutter-action` installs Flutter from scratch on every run.** Even with caching enabled, the initial setup takes 2-5 minutes. Combined with Flutter's build time, your feedback loop is ~20 minutes per commit. This is fine for releases but painful for CI-on-every-push during development.
- **GitHub MCP Server requires a PAT with `repo` and `workflow` scopes.** The agent needs a valid, unexpired token. Token rotation is the agent's responsibility — an expired PAT silently breaks the release pipeline without clear error messaging from the MCP server.
- **GitHub API rate limits apply to release creation.** 5000 authenticated requests per hour is generous, but there's also a per-hour upload bandwidth limit. For rapid release iteration (push → build → tag → release) you may encounter throttling.
- **Download analytics are limited to total download counts.** You won't know how many users upgraded, which platform they're on, or which version — without adding telemetry, which the PRD explicitly forbids.
- **GitHub's release page does not auto-detect platform for download.** Users see both Linux and Windows binaries with generic file names. You'll want to add a simple `_Just the app, please_` download button or a small landing page to improve UX.

## Operational Story

How the chosen platform operates day to day for building and distributing Outline binaries.

- **Preview builds**: Not applicable (native desktop app, no preview URLs). For testing, CI can build debug binaries and attach them as workflow artifacts (available for 90 days) or publish to a "nightly" release tag.
- **Secrets**: GitHub Actions Secrets store tokens and keys. Set under Settings → Secrets and variables → Actions. Repository admins can read, write, and rotate secrets. Agent needs a PAT (fine-grained, scoped to `contents: write` and `workflows`) stored as a secret or in the agent's own credential store.
- **Rollback**: `gh release delete <tag>` followed by `gh release create <new-tag> <files> --title "vX.Y.Z" --notes "Rollback to stable"`. Rollback time: ~30 seconds. No data caveats — releases are immutable file uploads, so the old binary can be re-uploaded under a new tag.
- **Approval**: The release publish job should require manual approval (via `environment: release` with required reviewers in GitHub Actions). An agent may run build and test jobs unattended but must hand off the publish step for human verification.
- **Logs**: Pipeline logs are read-only via `gh run view --log <run-id>`, `gh run list`, or the GitHub web UI (Actions → Workflow run → Raw logs). The GitHub MCP Server's `listWorkflowRuns` and `getWorkflowRun` tools provide structured access for an agent.

## Risk Register

| Risk | Source | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| Free tier requires public repo | Devil's advocate | High | High (cost if private) | Keep repo public for MVP. If private later, accept $4/mo for GitHub Pro (2000 CI min/mo, 500MB release storage). Still cheaper than GitLab Premium |
| Slow CI without caching | Pre-mortem / Unknown unknowns | High | Medium (developer time) | Add `actions/cache` for `.dart_tool/`, `build/`, and Flutter SDK. Use `flutter build --release` with `--no-tree-shake-icons` to reduce memory. Expected build time: ~8-12 min with caching |
| Unsigned Windows SmartScreen | Pre-mortem | Medium (once Windows users appear) | Medium (user trust) | Deferred per interview ("just binaries"). When needed: acquire code signing cert ($200-500/yr) and add a signing step to the workflow |
| PAT expiry breaks agent automation | Unknown unknowns | Medium | High (release pipeline blocked) | Use fine-grained PATs with 1-year expiry. Set a calendar reminder. Or use GitHub App installation tokens (auto-rotated, no expiry) for agent auth |
| No auto-update mechanism | Devil's advocate | Medium (future need) | Medium (user adoption) | Deferred per interview ("manual download"). If auto-update is needed later, evaluate `flutter_app_updater` or `sparkle_flutter` — both can fetch from GitHub Releases |
| API rate limits on rapid releases | Unknown unknowns | Low | Low | Unlikely at MVP scale. If hit: batch release creation, or use a dedicated deploy token to increase effective rate limit |
| Release page UX — no platform detection | Unknown unknowns | Low | Low | Add a simple `README.md` badge/button: `[Download for Linux](...) [Download for Windows](...)`. Or use GitHub Pages for a minimal download landing page |

## Getting Started

These steps set up a GitHub Actions workflow that builds Outline for both Linux and Windows and publishes a release when a tag is pushed.

1. **Ensure the repository is public** on GitHub. Private repos work too but have CI minute and storage limits on the free plan.

2. **Create `.github/workflows/release.yml`** in the project root:

   ```yaml
   name: Build and Release

   on:
     push:
       tags:
         - 'v*'

   jobs:
     build-linux:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.44.0'
             channel: 'stable'
         - run: flutter pub get
         - run: flutter build linux --release
         - uses: actions/upload-artifact@v4
           with:
             name: outline-linux
             path: build/linux/x64/release/bundle/

     build-windows:
       runs-on: windows-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.44.0'
             channel: 'stable'
         - run: flutter pub get
         - run: flutter build windows --release
         - uses: actions/upload-artifact@v4
           with:
             name: outline-windows
             path: build/windows/x64/runner/Release/

     create-release:
       needs: [build-linux, build-windows]
       runs-on: ubuntu-latest
       permissions:
         contents: write
       steps:
         - uses: actions/download-artifact@v4
         - name: Package artifacts
           run: |
             tar czf outline-linux-x64.tar.gz outline-linux/
             zip -r outline-windows-x64.zip outline-windows/
         - name: Create Release
           env:
             GH_TOKEN: ${{ github.token }}
           run: |
             gh release create ${{ github.ref_name }} \
               outline-linux-x64.tar.gz \
               outline-windows-x64.zip \
               --title "Outline ${{ github.ref_name }}" \
               --generate-notes
   ```

3. **Push the workflow file and trigger a release:**

   ```bash
   git add .github/workflows/release.yml
   git commit -m "Add release workflow"
   git tag v0.1.0
   git push origin main --tags
   ```

4. **Verify the release** appears at `https://github.com/<owner>/outline/releases/tag/v0.1.0` with both platform binaries attached.

5. **For CI during development** (not releases), create a separate `ci.yml` workflow that runs tests and builds on every push without creating releases:

   ```yaml
   name: CI
   on: [push, pull_request]
   jobs:
     analyze:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.44.0'
         - run: flutter pub get
         - run: flutter analyze
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.44.0'
         - run: flutter pub get
         - run: flutter test
   ```

## Out of Scope

The following were not evaluated in this research:
- Docker image creation or containerization (not relevant for a native desktop app)
- CI/CD pipeline configuration beyond basic build and release workflows
- Web hosting or server-side deployment (Outline has no server component)
- Auto-update mechanisms (mechanics for checking, downloading, and applying updates within the app)
- Code signing and notarization (Windows Authenticode, Linux GPG)
- Package manager distribution (APT, Flatpak, Snap, AUR, Homebrew, winget)
- Production-scale architecture (multi-region, HA, DR)
- Download analytics or user telemetry
