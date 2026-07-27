# AGENTS.md — Wakeel AI (Mobile)

Context for AI coding agents working in this repository. This repo is the
**Employee Mobile App** half of Wakeel AI (the HR Web Dashboard is a separate
Flutter/web or .NET-hosted frontend, not in this repo). Read this before
picking up a task; read `wakeel-ai-ui-design-system.md` before touching any
UI.

## What Wakeel AI is

Wakeel AI (وكيل, "agent/representative") is an AI-powered digital HR and
legal officer for Egyptian SMEs (10–100 employees) — a graduation project
(ITI) positioned as a real B2B SaaS product. It replaces the need for a
full-time HR manager (8–15k EGP/month) or per-consultation legal counsel
(500–2,000 EGP) for routine HR/labor-law work.

Two interfaces, one backend pipeline:
- **Employee Mobile App (this repo)** — employees ask HR/legal questions in
  natural Arabic or English, by text or voice, and get instant answers
  grounded in *their own* employment data + the company handbook + Egyptian
  labor law. E.g. "What's my leave balance?", "If I resign today, how much
  will I get?".
- **HR Web Dashboard (separate app)** — HR managers issue plain-language
  requests ("Generate a contract for Ahmed, Developer, 12,000 EGP") and get
  a ready-to-print, legally compliant PDF, plus analytics/audit logs.

Core pipeline (same for both apps): user input → RAG retrieves relevant
law/policy → agentic AI decides answer vs. calculate vs. generate-document →
tool executes (Calculator / Document Generator / Database Query) → grounded
answer, PDF, or verified figure is returned. **Nothing is answered from the
LLM's general knowledge alone** — every legal/numeric claim must be grounded
in retrieved law text or a deterministic calculator, because hallucinated
numbers/clauses in this domain carry real financial and legal risk.

## Backend (separate repo, but shapes what the mobile app calls/expects)

- **.NET 9 Web API**, PostgreSQL (employee records, accounts, audit logs),
  Qdrant (vector DB for RAG), Microsoft Semantic Kernel as the agent
  framework/orchestrator.
- **LLMs**: Claude Sonnet 4.6 (primary — reasoning, drafting, grounded Q&A),
  Claude Haiku 4.5 (secondary — intent classification, language detection,
  summarization). Both provided free by ITI for the project duration.
- **RAG knowledge base**: Egyptian Labor Law (Law No. 14 of 2025), Social
  Insurance Law, 2025 income tax brackets, each client company's own
  Employee Handbook (per-company indexed), past contract templates. Chunked
  by domain (leave, termination, gratuity, taxation, contracts), embedded
  with `text-embedding-3-small`.
- **Auth**: JWT, role-based (HR / Employee / Owner). The mobile app only
  ever operates as the **Employee** role — it must never assume access to
  other employees' data or HR-only endpoints.
- **Agent boundaries — hard constraints, not just backend concerns**: the
  system must never provide legal advice for court disputes (always show a
  "consult a lawyer" disclaimer for anything dispute-shaped), never touch
  government systems (Tax Authority, Social Insurance portal) in the MVP,
  never process full payroll (individual calculations/explanations only),
  never access data outside the requesting user's role. If a mobile screen
  ever surfaces something that reads like binding legal advice or
  cross-employee data, that's a bug against these constraints.
- **Observability/audit**: every AI interaction (who asked what, when, what
  action was taken) is logged server-side via Langfuse + an audit trail. The
  mobile app doesn't implement this, but should never fight it (e.g. don't
  build client-side-only flows that bypass the API for anything
  consequential).

## What the mobile app actually needs to do (from team scenarios)

- Text and voice Q&A grounded in the employee's own data + labor law
  (leave balance, end-of-service gratuity estimate, contract questions).
- Multimodal input: voice → text (speech-to-text) for the question, and
  vision/OCR to let an employee photograph a document (e.g. a medical
  certificate to support a leave request) instead of typing it.
- Every AI answer that cites a law article shows the citation using the
  seal-mark citation marker (see design system §9) — this is the product's
  core trust signal ("every AI claim is stamped/verifiable"), not
  decoration.
- Disclaimers direct users to a human lawyer for anything dispute-shaped —
  never let the UI imply the AI's answer is final legal counsel.

## Tech stack (this repo)

- **Flutter** (Dart ^3.12.2, Flutter 3.44.x), Material 3.
- **State management: Riverpod** (`flutter_riverpod`) — chosen over
  Provider/BLoC for compile-safe DI and cleaner async state (chat streams,
  RAG answers, dashboards). All app-wide state goes through providers in
  `lib/core/providers/`.
- **Navigation: go_router** — chosen for declarative routing and
  auth-guarded redirects (needed once HR/Employee-role routing exists).
- **HTTP: dio** — for the future API client layer (auth interceptor for JWT
  attach/refresh will live here).
- **Secrets/session: flutter_secure_storage** — for JWT storage once auth
  lands.
- **Fonts: google_fonts** (Fraunces, Public Sans, Cairo, IBM Plex Mono —
  fetched/cached at runtime, not bundled as assets).
- **Icons: lucide_icons_flutter** — Flutter port matching the design
  system's `lucide-react` icon language (§7), for visual consistency with
  the (separate) web dashboard if it also uses Lucide.
- **i18n: flutter_localizations + intl**, arb files in `lib/l10n/`
  (`app_en.arb` / `app_ar.arb`), generated via `flutter gen-l10n`
  (`l10n.yaml` config, `generate: true` in `pubspec.yaml`). Arabic drives
  RTL automatically through the standard localization delegates — no manual
  `Directionality` needed.

### Known environment workaround

`path_provider_android` >=2.3.0 depends on the `jni` pub package, whose
Android `build.gradle` calls a Kotlin-DSL-only `kotlin()` extension that
this project's Gradle/AGP/Kotlin setup can't resolve, breaking
`assembleDebug`/`assembleRelease` outright. Pinned via `dependency_overrides`
in `pubspec.yaml` to `path_provider_android: 2.2.17` (last pre-`jni`
release). Revisit/remove this override if upstream fixes it or if the
Android Gradle setup changes.

## Design system

`wakeel-ai-ui-design-system.md` (repo root) is the source of truth for all
UI work — read it before writing any widget. Summary of what's already
implemented in `lib/core/theme/`:

- `app_palette.dart` — raw primitive color scales (navy/brass/neutral/status).
  Never reference these directly from widgets.
- `app_colors.dart` — `AppColors` (`ThemeExtension`), the semantic token
  layer (`bgPage`, `bgCard`, `accent`, `borderFocus`, etc.) for
  light/dark/high-contrast. Always read colors via
  `Theme.of(context).extension<AppColors>()!`.
- `app_typography.dart` — the 7-step type scale (`text3xl`…`textXs`) plus
  `buildTextTheme()` for Material's `TextTheme` slots. Arabic gets Cairo
  end-to-end (heading + body) with ~12.5% extra line-height; Latin gets
  Fraunces (headings) / Public Sans (body). `AppTypography.mono()` for
  IDs/timestamps/currency only.
- `app_spacing.dart`, `app_radius.dart`, `app_motion.dart` — 8pt spacing,
  radius, and duration/curve tokens.
- `app_shadows.dart` — `AppShadows` (`ThemeExtension`); empty lists in dark
  mode by design (use a 1px `borderDefault` border instead — shadows don't
  read on navy).
- `app_button_styles.dart` — the 5 button variants (primary / secondary /
  ai-accent / ghost / danger) as `ButtonStyle` factories, since Flutter only
  ships 3 button widgets natively.
- `app_theme.dart` — `AppTheme.build({brightness, highContrast, isArabic})`,
  the only place `ThemeData` should be constructed.
- `core/widgets/seal_mark.dart`, `status_badge.dart`, `ai_badge.dart` — the
  signature seal mark (logomark + citation marker, used in exactly those two
  places per the design system — don't reuse it elsewhere), muted status
  pills, and the AI-generated badge.
- `core/providers/app_settings_providers.dart` — `themeModeProvider`,
  `highContrastProvider`, `localeProvider`.
- `features/shell/theme_showcase_screen.dart` — scaffolding-only screen
  exercising every token; not a product screen. Expect it to be replaced by
  real screens (auth, chat, leave requests, ...) as user stories land.

## Working conventions for this repo

- One feature = one folder under `lib/features/<feature>/`. Shared
  UI/tokens/infra stay under `lib/core/`.
- Never hardcode a color, font, spacing, or radius value in a widget —
  always go through the `App*` token classes above.
- The mobile app is Employee-role only; don't build HR-manager-only flows
  here (contract generation, company-wide analytics, etc.) — those belong
  to the HR Web Dashboard.
- Every AI-sourced answer/value in the UI should be visually distinguishable
  as AI-generated (gold accent / `AiBadge`) versus authoritative/human
  content (navy) — this is the one running visual idea of the whole
  product, not optional polish.
