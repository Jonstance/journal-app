# Velvet Journal — Logo Package

Locked variant: **C2 · Bold Nib**
Generated: 2026-05-28

## Files

```
svg/
  mark.svg                    Primary mark — velvet on transparent
  mark-cream.svg              For dark backgrounds
  mark-ink.svg                Mono / single-color ink
  app-icon.svg                iOS-style squircle, cream bg + velvet mark (1024)
  app-icon-velvet.svg         Squircle, velvet bg + cream mark
  app-icon-dusk.svg           Squircle, dusk bg + cream mark
  favicon.svg                 32px squircle favicon — light
  favicon-dark.svg            32px squircle favicon — dark
  lockup-horizontal.svg       Mark · rule · "VELVET JOURNAL" + tagline (600×160)
  lockup-horizontal-dark.svg  Same, on dusk background
  lockup-stacked.svg          Centered mark above wordmark (360×360)
  lockup-stacked-velvet.svg   Same, on velvet background
  monogram.svg                Mark with breathing room (320×320)

png/
  mark/                       Velvet on transparent · 16, 32, 64, 128, 256, 512, 1024
  mark-cream/                 Cream on transparent · same sizes
  app-icon-1024.png           Full-size iOS / Android icon
  app-icon-512.png            Play Store / general purpose
  app-icon-192.png            PWA
  favicon-32.png
  favicon-16.png

palette.css                   CSS custom properties
palette.json                  Same, as JSON
```

## Mark geometry

ViewBox `0 0 100 100`. The mark is a single compound path with
`fill-rule="evenodd"` — the breather hole and slit are punched cleanly
so the mark works on any background.

```
d="M 14 16 L 50 86 L 86 16 L 68 16 L 50 52 L 32 16 Z
   M 53 58 A 3 3 0 1 1 47 58 A 3 3 0 1 1 53 58 Z
   M 48.5 64 L 51.5 64 L 51.5 80 L 48.5 80 Z"
```

## Clear space

Reserve **0.4× mark height** as clear space on all sides. Inside that
margin, no other element should encroach.

## Minimum sizes

- Digital mark: **16px** (use favicon-16.png — the mark holds at this size thanks to the bold weight; below 16px substitute a solid V without the slit).
- Print: **8mm tall** at 300dpi.

## Color

| Token  | Hex       | Role                       |
|--------|-----------|----------------------------|
| Ink    | #2A1820   | Body text on cream         |
| Velvet | #5B2A4A   | Primary brand              |
| Rose   | #7A3B5C   | Secondary accent           |
| Cream  | #F4EFE6   | Light surface              |
| Dusk   | #1A0F15   | Dark surface               |

## Type

- **Wordmark:** IBM Plex Mono, weight 500, letter-spacing 0.22em, uppercase.
- **Supporting:** Cormorant Garamond, italic, for taglines and editorial moments.

The lockup SVGs reference IBM Plex Mono by name — install the font, or
open the SVG in a vector editor and convert the text to outlines before
distributing to environments without the font available.

— Velvet Journal · 2026
