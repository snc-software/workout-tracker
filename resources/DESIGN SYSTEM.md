# Raspberry / Sky Design System (SwiftUI)

Reference spec for on-brand, accessible SwiftUI components. Pair this file with an Asset Catalog ( `Colors.xcassets` ) holding the actual color sets — this doc explains intent and usage rules; the asset catalog holds the exact values with built-in light/dark variants.

## Principles

* Every color must be defined as a **color set** in the asset catalog with both **Any Appearance** (light) and **Dark** variants filled in — never hardcode a raw scale value (e.g. `raspberry700`) directly in a view; reference the semantic color (e.g. `primaryBrand`) instead.
* Semantic status colors (success/warning/error/info) always ship as a **background / border / foreground** triad, never a single flat color. This is what gives toasts, alerts, and status pills their outlined, layered look.
* Primary brand color shifts tone between modes: `raspberry700` in light mode,  `raspberry400` in dark mode. This isn't a bug — a saturated 700 raspberry loses contrast on near-black backgrounds, so dark mode intentionally uses a lighter tint from the same scale.

## Color

Full scales (50–900/950) live in the asset catalog under `Raspberry/` , `Sky/` , and `Neutral/` color sets. Base/brand reference points:

| Role | Light mode | Dark mode | Asset name |
|---|---|---|---|
| Primary | `#C2185B` (raspberry700) | `#EC407A` (raspberry400) | `primaryBrand` |
| Primary hover/pressed | `#AD1457` (raspberry800) | `#F06292` (raspberry300) | `primaryBrandPressed` |
| Accent | `#0EA5E9` (sky500) | `#38BDF8` (sky400) | `accent` |
| Background | `#F8FAFC` | `#020617` | `appBackground` |
| Surface | `#FFFFFF` | `#0F172A` | `surface` |
| Text primary | `#0F172A` | `#F8FAFC` | `textPrimary` |
| Text secondary | `#475569` | `#94A3B8` | `textSecondary` |
| Border | `#E2E8F0` | `#334155` | `border` |

### Semantic status (success / warning / error / info)

Each has a light and dark variant, each with `Background` , `Border` , `Foreground` color sets (e.g. `successBackground` , `successBorder` , `successForeground` ). Use for toasts, inline alerts, badges/pills, and form validation states. Never mix a light-mode background with a dark-mode foreground or vice versa — all three should come from the same mode.

## Typography

| Role | Font | Weights | License |
|---|---|---|---|
| Heading | JetBrains Mono | Medium (500) / SemiBold (600) / Bold (700) | SIL OFL — free, commercial use |
| Body | Manrope | Regular (400) / Medium (500) / Bold (700) | SIL OFL — free, commercial use |

Both are self-hosted ( `.ttf` files bundled in the app target and registered in `Info.plist` ). JetBrains Mono is monospaced and runs wider than a proportional face — apply tight tracking at large heading sizes (H1/H2) to avoid overly loose type.

## Icons

**Iconoir** — MIT licensed, 1, 000+ icons on a 24×24 grid, rounded/friendly style. Use via the official Swift package:

* Package: [`iconoir-icons/iconoir-swift`](https://github.com/iconoir-icons/iconoir-swift)
* Docs: [iconoir.com/docs/introduction](https://iconoir.com/docs/introduction)

Tint icons with the mode-aware semantic colors ( `primaryBrand` , `accent` , `textSecondary` ), not raw scale values, for the same light/dark reasons as everything else.

## Component patterns established so far

* **Buttons**: solid fill using `primaryBrand` / `primaryBrandPressed` on interaction states.
* **Toasts**: `background` + 1pt `border` + `foreground` from the relevant semantic status triad, rounded corners (~8pt).
* **Status pills**: same triad as toasts, pill/capsule shape, compact padding.
* **Subtle backgrounds** (e.g. selected nav item, highlighted card): `primarySubtleBg` or `accentSubtleBg` rather than a full-strength brand color.

## For Claude Code

When generating a new SwiftUI component for this app:
1. Reference `Colors.xcassets` for exact color sets — don't invent or approximate hex values; if a needed color set doesn't exist yet, add it with both light and dark appearance slots filled in from the tables above.
2. Always support both light and dark variants using the asset catalog's built-in appearance switching.
3. For any status/feedback UI (toast, badge, alert, form error), use the full background/border/foreground triad, matched to the current mode.
4. Headings use the heading font token; body copy, labels, and UI chrome use the body font token.
5. Icons come from `iconoir-swift`; tint via mode-aware semantic colors, not raw scale values.
