# Wakeel AI — UI Design System

**Direction:** Bold corporate/legal — deep navy + muted brass gold, light-first (dark + high-contrast supported)
**Languages:** Arabic (RTL) / English (LTR), theme-provider driven

---

## 1. Principles

1. **Two brand colors, not five.** Navy is the brand. Gold is the *only* accent, reserved for one meaning: "AI touched this." Everything else is neutral. The current codebase fights itself with three competing hues (bark/ochre/teal) — don't repeat that.
2. **Navy = official, gold = AI.** Any place the product distinguishes human/legal-authoritative content from AI-generated content, encode it in color (navy vs. gold), not just a badge label. This is the single running visual idea of the whole system.
3. **Light-first.** Design and test in light mode first; dark and high-contrast are derived, not primary.
4. **Restraint over decoration.** One motion idea (not motion on every element), one accent color, one signature mark. Cut before you add.
5. **RTL is not an afterthought.** Every spacing/positioning value uses logical properties (start/end, not left/right) so Arabic and English are equally first-class, not a mirrored translation layer bolted on.

---

## 2. Color

### 2.1 Primitives

| Scale | 950 | 900 | 700 | 500 | 300 | 100 | 50 |
|---|---|---|---|---|---|---|---|
| **Navy** | `#0A1729` | `#101F3D` | `#1B3050` | `#3E5A82` | `#9FB2C9` | `#DDE4EC` | `#F1F4F8` |
| **Brass Gold** | — | `#7A5B2E` | `#9C7640` | `#B8935B` | `#D9C299` | `#F0E6D3` | `#F8F2E8` |
| **Neutral (paper/slate)** | `#14161B` | `#20232B` | `#4A505C` | `#7A818F` | `#C7CCD3` | `#E8EAED` | `#F8F7F3` |

### 2.2 Status (muted, desaturated — must not visually compete with brass gold)

| Status | fg | bg (tint, 8–12% opacity) |
|---|---|---|
| Success | `#2F6B4F` | `rgba(47,107,79,0.10)` |
| Warning | `#8A5A1E` | `rgba(138,90,30,0.10)` |
| Error | `#8C3229` | `rgba(140,50,41,0.10)` |
| Info | `#2E5480` | `rgba(46,84,128,0.10)` |

Note these are deliberately muted/brick-toned, not saturated red/green/amber — saturated status colors would visually compete with the brass accent and cheapen the "legal document" tone.

### 2.3 Semantic tokens

| Token | Light | Dark | High-contrast add-on | Usage |
|---|---|---|---|---|
| `--color-bg-page` | Neutral-50 `#F8F7F3` | Navy-950 `#0A1729` | — | App background |
| `--color-bg-card` | white `#FFFFFF` | Navy-900 `#101F3D` | — | Cards, panels, modals |
| `--color-bg-card-raised` | Neutral-100 `#E8EAED` | Navy-700 `#1B3050` | — | Hover/raised surfaces |
| `--color-bg-sidebar` | Navy-950 (dark in both modes — brand anchor) | Navy-950 | — | Sidebar, never switches to light |
| `--color-brand-primary` | Navy-900 | Neutral-100 | — | Primary buttons, active nav, headings |
| `--color-accent` | Brass-500 `#B8935B` | Brass-500 | Brass-700 (stronger) | AI markers, citation icons, AI-variant CTAs only |
| `--color-text-primary` | Navy-950 | Neutral-50 | — | Body text |
| `--color-text-secondary` | Neutral-700 `#4A505C` | Neutral-300 | Neutral-500-equivalent lighter/darker | Secondary/meta text |
| `--color-text-on-navy` | Neutral-50 | Neutral-50 | — | Text on sidebar / navy surfaces |
| `--color-border-default` | Neutral-200 `#E8EAED`-ish | Navy-700 | Stronger both directions | Hairlines, input borders |
| `--color-border-focus` | Brass-500 | Brass-500 | — | Focus ring only — the one place gold appears as an outline rather than a fill |

**Hard rule:** components reference `--color-*` semantic tokens only, never `--navy-500` etc. directly. This is the single biggest fix versus the current codebase, where components hardcode a primitive scale that was never wired into semantic tokens.

---

## 3. Typography

| Role | Family | Weights | Where |
|---|---|---|---|
| Display / heading (Latin) | Fraunces (or Lora as a safer fallback) | 500, 600 | Page titles, card titles, modal headers |
| Body / UI (Latin) | Public Sans | 400, 500, 600 | Everything else in Latin script |
| Arabic (all roles) | Cairo (or Almarai) | 400, 500, 700 | All Arabic text — one family across heading and body; Arabic display/serif faces don't hold up at UI sizes |
| Numeric / mono | IBM Plex Mono (kept) | 400, 500 | IDs, audit timestamps, currency figures only |

### Type scale

| Token | Size / line-height | Weight | Usage |
|---|---|---|---|
| `text-3xl` | 1.875rem / 1.2 | 600 (serif) | Page title |
| `text-2xl` | 1.5rem / 1.25 | 600 (serif) | Section header |
| `text-xl` | 1.25rem / 1.35 | 500 (serif) | Card title |
| `text-lg` | 1.125rem / 1.4 | 500 (sans) | Emphasized body |
| `text-base` | 1rem / 1.5 | 400 (sans) | Default body |
| `text-sm` | 0.875rem / 1.45 | 400–500 (sans) | UI labels, table cells |
| `text-xs` | 0.75rem / 1.4 | 500 (sans) | Meta, captions, badges |

**Arabic adjustment:** add ~10–15% extra line-height at every step (Arabic script needs more vertical breathing room), never italicize Arabic text, and avoid letter-spacing tricks (`tracking-wide`) on Arabic — they don't read the same way they do in Latin caps.

---

## 4. Spacing & Layout

8pt base grid (keep the existing scale, it's fine):

| Token | px |
|---|---|
| `--spacing-1` | 4 |
| `--spacing-2` | 8 |
| `--spacing-3` | 12 |
| `--spacing-4` | 16 |
| `--spacing-6` | 24 |
| `--spacing-8` | 32 |
| `--spacing-12` | 48 |
| `--spacing-16` | 64 |

**Structural constants:** sidebar `240px` (`264px` on `xl` breakpoint) — keep as-is. Topbar `64px` height. Main content `max-w-6xl` centered — keep for the sandbox-era pages, revisit per real page once table-heavy views (Employees, Audit Log) need full width.

---

## 5. Radius

| Token | px | Usage |
|---|---|---|
| `--radius-xs` | 4 | Checkboxes, small badges |
| `--radius-sm` | 6 | Buttons (sm), inputs |
| `--radius-md` | 8 | Buttons (default), popovers |
| `--radius-lg` | 12 | Cards |
| `--radius-xl` | 16 | Modals, large panels |
| `--radius-2xl` | 24 | Chat bubble container, pill-shaped chat input |
| `--radius-full` | 9999 | Avatars, FAB, badges |

A bold corporate/legal direction reads more credible with slightly *tighter* radii than a consumer-SaaS look — favor `sm`/`md` for most controls, reserve `xl`/`2xl` for a few soft, friendly moments (the AI chat surfaces specifically — this is one of the few places warmth is appropriate, since it's the "assistant" persona).

---

## 6. Elevation

Real shadow tokens (currently referenced as `--elevation-1..4` with no definitions — fix that):

| Token | Value (light) | Usage | Dark mode equivalent |
|---|---|---|---|
| `--shadow-sm` | `0 1px 2px rgba(16,31,61,0.06)` | Buttons, inputs at rest | Omit — use `--color-border-default` (1px border) instead; shadows barely read on dark backgrounds |
| `--shadow-md` | `0 4px 12px rgba(16,31,61,0.08)` | Cards, dropdowns | Border + very subtle glow (`0 0 0 1px navy-700`) |
| `--shadow-lg` | `0 12px 32px rgba(16,31,61,0.14)` | Modals, popovers, command palette | Same pattern, higher opacity border |

---

## 7. Iconography

- `lucide-react` (already a dependency) — keep. Consistent stroke width (1.5–2), no mixing icon sets.
- Sizes: `16px` inline with text, `20px` default UI (nav, buttons), `24px` standalone/empty-state icons.
- Icon color always follows text color context (`currentColor`) — never a hardcoded hex on an icon.

---

## 8. Motion

| Token | Duration | Easing | Usage |
|---|---|---|---|
| `--motion-fast` | 120ms | ease-out | Hover states, focus rings |
| `--motion-base` | 200ms | ease-in-out | Tab switches, accordion, dropdown open |
| `--motion-slow` | 300ms | spring (light, one place only) | Sidebar active-item highlight (`layoutId` shared-element animation) — the one deliberate signature motion moment |

Drop the current pattern of spring scale/tap animation on *every* button — keep motion to: the sidebar active-highlight, toast enter/exit, and modal/drawer enter/exit. Respect `prefers-reduced-motion` everywhere.

---

## 9. Signature element: the seal mark

The one memorable, brand-specific visual idea, used in exactly two places so it stays a signature rather than decoration:

1. **Logomark** — a minimal circular seal (navy ring, brass gold inner mark), replacing the current placeholder rotated-border circle in the sidebar header.
2. **Citation marker** — the same seal motif, reduced to a small icon, placed beside every AI citation (e.g. next to "Article 84 · Labor Law 12/2003" in the chat). This directly visualizes the product's core promise — every AI claim is stamped/verifiable — rather than being pure branding.

Don't reuse the seal mark anywhere else (no watermarks, no repeating pattern backgrounds) — its meaning depends on scarcity.

---

## 10. Component states (reference spec)

### Button

| Variant | Default | Hover | Active | Disabled |
|---|---|---|---|---|
| Primary | bg `--color-brand-primary`, text on-navy | +6% lighter | +12% darker | Neutral-200 bg, Neutral-500 text |
| Secondary | transparent, border `--color-border-default`, text primary | bg Neutral-100 | bg Neutral-200 | same disabled pattern |
| AI-accent | bg `--color-accent`, text on-navy | +6% lighter | +12% darker | same |
| Ghost | transparent, text secondary | bg Neutral-100 | bg Neutral-200 | same |
| Danger | bg status-error fg, text white | +8% darker | +14% darker | same |

Sizes unchanged from current scale (`xs/sm/md/lg/xl`, 28–56px height) — that ladder is fine, only the color/token references need fixing.

### Input

- Default: `--color-border-default` border, `--color-bg-card` background.
- Focus: border → `--color-border-focus` (brass gold), 2px outline offset 2px — this is the one place brass appears as a functional (not decorative) signal.
- Error: border → status-error fg, helper text in status-error fg below the field.

### Badge / status pill

- Solid background = status `bg` token (8–12% tint), text = matching `fg` token. Never a solid saturated fill — keep it a tint, consistent with the muted status palette in §2.2.
- "AI-generated" badge specifically uses `--color-accent` at a light tint, not any status color — reinforces the navy/gold distinction system-wide.

### Table

- Row hover: `--color-bg-card-raised`.
- Sortable header: text-secondary, brass-gold sort-direction arrow on active column only (another deliberate, narrow use of the accent).

---

## 11. Accessibility targets

- Text contrast ≥ 4.5:1 body, ≥ 3:1 large text (WCAG AA) in both light and dark; high-contrast mode pushes toward AAA on text/border pairs.
- Focus-visible ring on every interactive element, 2px, `--color-border-focus`, 2px offset — never removed, only restyled.
- Minimum hit target 40×40px for icon-only buttons (voice button, FAB, close icons).
- All icon-only controls carry an accessible name (`aria-label`) — check this explicitly for `VoiceButton`, FAB, and table sort headers.

---

## 12. Theming matrix summary

| Mode | Background | Sidebar | Accent behavior |
|---|---|---|---|
| Light (default) | Neutral-50 paper | Navy-950 (stays dark) | Brass gold at full saturation |
| Dark | Navy-950 | Navy-950 (same as light — sidebar never changes) | Brass gold, same hue, slightly reduced saturation to avoid glow |
| High-contrast (either mode) | unchanged | unchanged | Borders/text pushed to higher-contrast primitive steps; accent unchanged (already sufficiently distinct) |

Sidebar staying navy in both light and dark mode is intentional — it's the one constant brand anchor regardless of theme, similar to how the current file already keeps `--bg-sidebar` navy-toned in both modes.
