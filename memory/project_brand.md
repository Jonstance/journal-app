---
name: project-brand
description: Velvet Journal brand palette, assets, and design language — use when making any UI/visual changes
metadata:
  type: project
---

Brand colors (in colors.dart):
- `#5B2A4A` velvet (primary brand — deep plum)
- `#7A3A62` velvetLight (lighter plum, warmth variant)
- `#F4EFE6` cream (light background)
- `#1A0F15` dusk (dark background)
- `#2A1820` ink (primary text)
- Accents: amber `#F2B56B`, coral `#F28C6A`

Assets in `assets/images/`:
- `app-icon.png` — velvet bg + cream mark (launcher icon design)
- `mark.png` — dark (velvet) mark, use on light backgrounds
- `mark-cream.png` — cream mark, use on dark backgrounds
- `lockup-horizontal-light.png` / `lockup-horizontal-dark.png` — full wordmark lockups

Design specs (root dir, for reference):
- `First-run welcome.png` — onboarding page 0 design
- `Launch _ splash.png` — splash screen design (cream bg, velvet mark, "VELVET JOURNAL", "PRIVATE · ON DEVICE")
- `Writing surface.png` — editor header design

Key design decisions:
- Splash: cream `#F4EFE6` background + velvet mark centered + wordmark + "PRIVATE · ON DEVICE" tagline
- Onboarding page 0: left-aligned small mark, "Welcome to *Velvet.*" mixed-style headline, privacy subtext, "BEGIN WRITING →" CTA
- Editor header: `[mark] VELVET   JOURNAL` left + `△ ON DEVICE` right + thin divider

**Why:** Brand package provided by designer; all UI must match this language.
**How to apply:** Always use these colors and assets for any new UI surface. Check mark variant (dark vs cream) based on background.
