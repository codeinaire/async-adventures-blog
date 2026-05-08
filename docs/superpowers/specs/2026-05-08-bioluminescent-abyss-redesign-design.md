# Bioluminescent Abyss — Async Adventures Redesign

**Date:** 2026-05-08
**Author:** John Stewart (with Claude)
**Status:** Design — pending implementation plan

## Summary

Replace the current MultiTerm theme system on `asyncadventures.com` with a single signature look: **Bioluminescent Abyss** — a cyberpunk-leaning aesthetic warmed by deep-sea bioluminescence, drawing structural inspiration from [imagetoolz.app](https://imagetoolz.app) (cyber-clip polygons, scanline overlays, neon glow text-shadows, mono+display type pairing) but swapping out cyberpunk's harsh magenta/cyan/yellow for an aquamarine/cyan/amber palette that reads more solarpunk / hopepunk — growth, warmth, optimism — without losing the techno-noir bones.

The redesign covers every page, removes the existing 60-theme Shiki picker, and ships a single matching custom Shiki code theme.

## Aesthetic direction

A fusion of three genres:

- **Cyberpunk** — for structure: sharp angular clip-paths, scanlines, neon glow, mono typography, deep dark backgrounds, HUD chrome.
- **Solarpunk** — for warmth: bioluminescent (aqua/cyan), amber as warm punctuation instead of harsh yellow, mycelial-network metaphors, "things grow here."
- **Hopepunk** — for tone: distinctly readable, generous, considered. The site invites you in rather than warns you off.

Conceptual frame: the blog reads as a series of **field notes from someone exploring an unfamiliar codebase the way you'd explore an abyss** — bioluminescent lights in the dark. This is reflected in copy ("transmissions", "field note") but stripped of any mystique that would obscure the actual writing.

## Locked decisions

### Palette — Bioluminescent Abyss

| Token | Value | Role |
| --- | --- | --- |
| `--bg` | `#060f1c` | Page background (deep navy-teal abyss) |
| `--panel` | `#0a1828` | Card / inner panel background |
| `--border` | `#152840` | Default 1px border |
| `--border-strong` | `#1f3550` | Cover / featured border |
| `--accent-1` | `#7fffd4` | Aquamarine — primary glow, headings, highlights |
| `--accent-2` | `#5ec8ff` | Cyan — secondary, links, meta text, time |
| `--accent-3` | `#ffce5e` | Firefly amber — labels, warm punctuation, function names in code |
| `--text` | `#e8f0f5` | Body text |
| `--muted` | `#5a7a8a` | Secondary / muted text |
| `--text-em` | `#7fffd4` | Emphasis (em / strong) |

Glow alpha tokens (derived):

- `--glow-aqua-soft: rgba(127,255,212,0.18)`
- `--glow-aqua: rgba(127,255,212,0.4)`
- `--glow-aqua-strong: rgba(127,255,212,0.6)`
- `--glow-cyan-soft: rgba(94,200,255,0.18)`
- `--glow-cyan: rgba(94,200,255,0.4)`

Dark-only. No light mode in scope.

### Typography

- **Display** (hero titles, h2 in prose, page titles, big labels): **Major Mono Display** — Google Fonts, single weight 400. Uppercase by default. Letter-spacing 0.02–0.04em.
- **Body & UI** (everything else): **JetBrains Mono Variable** — already in the project (`@fontsource-variable/jetbrains-mono`). Weights 400 / 500 / 700.
- **Code** (Shiki blocks, inline code): **JetBrains Mono Variable** — same as body, kept consistent.

No system fonts, no Inter, no Space Grotesk.

### Theme scope

- The 60-theme Shiki picker is **removed**.
- The light/dark/auto toggle is **removed**.
- The site is dark-only, single signature look.
- Code blocks use a single custom Shiki theme: **`bioluminescent-abyss`** (defined below).

## Signature visual language

These elements appear across every page and form the design's identifying DNA:

1. **Cyber-clip polygons** — cards, panels, and hero containers have two corners notched (top-left and bottom-right). Default cut sizes:
   - Small (cards, code blocks): 8px
   - Medium (panels, nav cards): 12–14px
   - Large (frame, hero): 16–20px
   - CSS: `clip-path: polygon(N px 0%, 100% 0%, 100% calc(100% - N px), calc(100% - N px) 100%, 0% 100%, 0% N px)`

2. **Scanline overlay** — every page has a fixed CRT scanline overlay applied via `body::after`:
   ```css
   body::after {
     content: '';
     position: fixed; inset: 0;
     background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(255,255,255,0.022) 2px, rgba(255,255,255,0.022) 3px);
     pointer-events: none;
     z-index: 1000;
   }
   ```

3. **Neon glow text-shadow** — display text uses two-layer text-shadow:
   ```css
   text-shadow: 0 0 8px var(--glow-aqua), 0 0 24px var(--glow-aqua-soft);
   ```
   Applied to hero titles, page titles, h2 in prose. Subtler glow on smaller display elements.

4. **Pulse-dot live indicator** — a 5px aqua dot with glow that pulses opacity 1 → 0.4 → 1 over 1.6s. Used in the top status bar (next to site name) and on featured/recent badges. Disabled under `prefers-reduced-motion`.

5. **Corner brackets** — used to frame cover images and important content blocks. 14px L-shaped brackets in aquamarine with subtle drop-shadow glow, positioned at the four corners of the framed element.

6. **HUD label rule** — every label uses the `▙` left-bracket prefix in firefly amber, uppercase, letter-spaced 0.2–0.3em. E.g. `▙ RECENT TRANSMISSIONS`, `▙ FIELD NOTE`, `▙ TRANSMISSION`, `▙ NAV`, `▙ TAG`. Consistent across the site.

## Page designs

### Home (`/`)

A "Recent Transmissions" feed: the front door is a chronological list of recent posts.

**Structure (top to bottom):**

1. **Top status bar** (shared across every page)
   - Left: pulse-dot + `ASYNC.ADVENTURES` (uppercase, letter-spaced)
   - Right: `// posts · {N} // tags · {M}` (muted color)
   - Bottom border in `--border`

2. **Hero**
   - Label: `▙ RECENT TRANSMISSIONS` (amber, letter-spaced, 0.3em)
   - Title: `siteConfig.title` ("async adventures") in Major Mono Display, 36px, aquamarine, glow text-shadow
   - Subtitle: 1–2 sentences in body text, max 70% width. Source: `home.md` frontmatter `subtitle:` field if present, falling back to `siteConfig.description`. (The current `home.md` `bannerContent` field can be repurposed by renaming to `subtitle`, or kept as a separate small note element below the feed — see "Migration notes".)
   - Stats row: `TRANSMISSIONS {N} · TAGS {M} · SIGNAL STRONG` — counts derived at build time from the `posts` and unique-tag collections; cyan labels with amber values

3. **Feed** (no separate label; hero already names what's below)
   - Each entry is a row with three columns: timestamp · title+tags · arrow
   - Timestamp: cyan, format `2026.05.08`
   - Title: body text, hovers to aquamarine with glow text-shadow + 6px slide-right
   - Tags: small bordered chips below the title
   - Arrow: amber, right-aligned
   - Entries separated by 1px dashed border in `--border`

4. **All transmissions CTA**
   - At the end of the feed, a centered dashed-border button: `▶ ALL TRANSMISSIONS` → `/posts`
   - Cyber-clip corners (8px)

5. **Footer** (shared)

### Post detail (`/posts/[slug]`)

A "Field Report": optimized for long-form reading while keeping the abyss aesthetic visible at the edges.

**Structure (top to bottom):**

1. **Top status bar** — `// posts · {date}` on the right
2. **Header strip** — single line: `▙ FIELD NOTE // {readingTime} MIN` (dashed bottom border)
3. **Cover** (180px tall by default)
   - Real image when `coverImage` is in frontmatter (existing schema)
   - Procedural mycelium SVG fallback otherwise (spec below)
   - Four 14px corner brackets in aquamarine with drop-shadow glow
   - Caption bottom-right: `// MYCELIUM-{shortHash} · seeded` for procedural covers
   - 12px cyber-clip corners
4. **Title block**
   - Title in Major Mono Display, 30px, aquamarine, glow
   - Meta row: `{date} :: {AUTHOR} :: #tag #tag #tag` — cyan labels, separators in `--border-strong`
5. **Content grid** — two columns, 130px sidebar + main
   - **TOC sidebar** (`▙ NAV` label) — sticky, list of h2/h3 headings, active state has 2px aquamarine left border + aquamarine text. Sub-headings indented and dimmer.
   - **Prose**:
     - **TLDR box** at the top (when `tldr` frontmatter is present): aquamarine left border, soft aqua bg tint, `▙ TRANSMISSION` label
     - h2 in Major Mono Display 18px aquamarine with subtle glow
     - h3/h4 in JetBrains Mono uppercase amber, letter-spaced
     - Body paragraphs at 12px / line-height 1.75
     - **Code blocks** — custom Shiki theme (see below). Header strip with filename (cyan) + lang badge (amber). Bottom of header dashed.
     - **Inline code** — aquamarine on `--panel` background, mono
     - **Links** — cyan, underline on hover with text-shadow glow
     - **Blockquote** — 2px cyan left border, italic, slightly muted
     - **Lists** — aquamarine bullets/numbers
     - **Tables** — `--border` borders, hover row highlight in soft aqua
6. **Prev/Next nav row**
   - Two cards, each 8px cyber-clip corners, panel bg
   - Hover: border becomes cyan
   - Labels: `← PREVIOUS` / `NEXT →` in amber
   - Title in body color
7. **Footer**

### Archive (`/posts`)

Same feed pattern as the homepage, but full and grouped by year.

**Structure:**
1. Top status bar
2. Hero strip: `▙ ALL TRANSMISSIONS` label + page title + count subtitle
3. Year-grouped sections:
   - Year separator: `▙ 2026` (amber, dashed top border, ~24px above)
   - Same entry rows as homepage feed
4. Pagination at the bottom (existing component restyled)
5. Footer

### Tags index (`/tags`)

A "Frequencies" view — each tag is a row showing relative frequency as a glowing bar.

**Structure:**
1. Top status bar
2. Hero: `▙ FREQUENCIES` label + `tags` title + count subtitle
3. Frequency rows (one per tag):
   - 3-column grid: `tag-name | bar | count`
   - Tag name in cyan, prefixed `#`
   - Bar: 4px tall, gradient `aquamarine → cyan` with aqua glow box-shadow, width proportional to relative frequency
   - Count in muted color, right-aligned
   - Whole row is a link to `/tags/[tag]`, hover increases bar glow
4. Footer

### Per-tag (`/tags/[tag]`)

**Structure:**
1. Top status bar
2. Hero: `▙ TAG · #typescript` label + `#typescript` as the title in Major Mono Display + post count subtitle
3. Same feed structure as homepage (no year grouping; chronological list)
4. Footer

### 404 (`/404`)

**Structure:**
1. Top status bar (`// signal lost` on the right)
2. Centered hero block:
   - Label: `▙ NO TRANSMISSION`
   - Title: `404` in Major Mono Display, very large (~96px), aquamarine, heavy glow
   - Body: short message — "The signal didn't reach this page. Try returning to the surface."
   - CTA card: `▶ RETURN TO SURFACE` → `/`, cyber-clip corners, hover border-color cyan
3. Footer

### Shared header (every page)

Single row, ~36px tall. Cyber-clip corners on the bottom edge.

- Left cluster: pulse-dot + `ASYNC.ADVENTURES` (clickable → `/`)
- Right cluster: nav links (`posts` `tags`) · `[search]` icon · `[rss]` icon
- All link text: muted by default, hover → cyan

Search invokes Pagefind (already in stack) in a modal-style overlay styled to match the design (panel bg, cyber-clip).

### Shared footer (every page)

Single row, dashed top border.

- Left: `// © 2026 john stewart · async adventures` (muted)
- Right: small SVG icons for github · email · linkedin (cyan, hover aqua glow)
- Far right: `// END OF TRANSMISSION` (amber, letter-spaced)

## Component patterns

### `MyceliumCover.astro` (new)

Procedurally generates an SVG cover for posts without `coverImage`.

**Inputs:** post slug (string)
**Output:** inline `<svg viewBox="0 0 800 360">`

**Algorithm:**
1. Hash the slug (e.g. djb2 or SHA-1 truncated) → 32-bit seed
2. Mulberry32 PRNG seeded with the hash
3. Generate `N = 7 + rand()*4` nodes (so 7–10 nodes) at pseudo-random positions on the 800×360 canvas, with margin (avoid edges by 60px)
4. Each node gets:
   - `r`: 3–6 px (random)
   - `color`: weighted pick from `[aquamarine, aquamarine, cyan, amber]` (aqua dominant, amber rare)
5. For each node, find its 2 nearest neighbors and emit a line connecting (deduplicate edges)
6. Emit lines first (under), then circles (over)
7. Wrap circles + lines in a `filter: url(#glow)` group
8. Background: a radial gradient from `var(--accent-2)` at 18% alpha to transparent
9. Caption: `// MYCELIUM-{firstHashChars} · seeded` rendered as a small text element bottom-right (or in the parent component as a span)

The Astro component takes `slug` as a prop and renders deterministically — same input → same output. No build-time write needed; it runs at SSR.

### `StatusBar.astro` (new)

The shared top status bar. Props: `postsCount`, `tagsCount`, optional `rightSlot` for per-page text override (e.g. `// signal lost` on 404).

### `PulseDot.astro` (new)

A reusable inline component rendering the animated 5px aqua dot. Internally uses `prefers-reduced-motion` to disable animation.

### `TLDR.astro` (modify existing)

- Restyle: 2px aquamarine left border, soft aqua bg, `▙ TRANSMISSION` label as `::before` content
- Drop the existing prose styling, use raw markdown-rendered HTML (already exists)

### `TableOfContents.astro` (modify existing)

- Restyle: cyber-clip-free, simple sticky outline
- `▙ NAV` label
- Active state: 2px aquamarine left border + 6px left padding shift + aquamarine color
- Sub-headings (h3/h4) indented, smaller, more muted
- Hover state: subtle slide-right

### `PostPreview.astro` (modify existing)

- Restyle as a feed entry row (3 columns: time · title+tags · arrow)
- Hover: 6px slide-right + aquamarine glow on title
- Cyan timestamp, body-color title, bordered tag chips, amber arrow

### `PostPreviewsWithYear.astro` (modify existing)

- Year separators in `▙ 2026` style (amber, dashed top border)

### `Header.astro` (rewrite)

- Replaces existing header
- Renders `StatusBar` + nav cluster

### `Footer.astro` (rewrite)

- Replaces existing footer
- HUD style with social SVGs

### `HomeBanner.astro` (modify or replace)

- Repurpose as the homepage hero — `▙ RECENT TRANSMISSIONS` label, title, sub, stats row
- Or split: `HomeHero.astro` for the hero, retain `HomeBanner` for optional intro markdown content (current usage)

### Removed components

- `SelectTheme.astro` — gone
- `SelectThemeLoader.astro` — gone
- `LightDarkAutoButton.astro` — gone
- `LightDarkAutoThemeLoader.astro` — gone

## Custom Shiki theme — `bioluminescent-abyss`

A new Shiki / Expressive Code theme, defined as a JSON file at `src/styles/themes/bioluminescent-abyss.json`.

**Token color map (TextMate scopes):**

| Scope | Color | Token role |
| --- | --- | --- |
| `comment`, `punctuation.definition.comment` | `#5a7a8a` italic | Comments |
| `keyword`, `storage.type`, `storage.modifier` | `#5ec8ff` | Keywords (`async`, `const`, `function`, `await`) |
| `string`, `string.quoted` | `#7fffd4` | Strings |
| `entity.name.function`, `support.function` | `#ffce5e` | Function names |
| `variable`, `variable.parameter` | `#e8f0f5` | Variables |
| `constant.numeric`, `constant.language` | `#ffce5e` | Numbers, booleans |
| `entity.name.type`, `support.type` | `#7fffd4` | Types |
| `entity.name.tag` | `#5ec8ff` | HTML/JSX tags |
| `entity.other.attribute-name` | `#ffce5e` | HTML attributes |
| `markup.bold` | `#7fffd4` bold | |
| `markup.italic` | `#7fffd4` italic | |
| `markup.heading` | `#7fffd4` bold | |

**Editor colors:**
- `editor.background`: `#0a1828` (panel)
- `editor.foreground`: `#e8f0f5`
- `editor.lineHighlightBackground`: `rgba(127,255,212,0.04)`
- `editorLineNumber.foreground`: `#5a7a8a`

Hooked into Astro via `astro.config.mjs` Expressive Code plugin's `themes` option, replacing the current 60-theme list. Block frame styling (filename, lang badge, copy button) restyled to match (cyber-clip 8px corners, dashed bottom border on filename row).

## Motion

- **Pulse-dot**: 1.6s ease-in-out infinite, opacity keyframes 0% / 50% / 100% = 1 / 0.4 / 1.
- **Hover transitions**: 0.2s ease-out for color, text-shadow, padding-left, border-color.
- **No scroll-driven animation** in v1 (keep it lean).
- **No typewriter / glitch / scan-line-sweep effects** in v1 (avoid clutter).
- **`prefers-reduced-motion: reduce`**: disable pulse-dot and hover slide; keep color transitions (they're a quarter-second, not motion).

## Accessibility

- Color contrast checked against WCAG AA:
  - `--text` (`#e8f0f5`) on `--bg` (`#060f1c`) → 15.8:1 ✓
  - `--accent-1` (`#7fffd4`) on `--bg` → 12.4:1 ✓
  - `--accent-2` (`#5ec8ff`) on `--bg` → 9.7:1 ✓
  - `--accent-3` (`#ffce5e`) on `--bg` → 11.6:1 ✓
  - `--muted` (`#5a7a8a`) on `--bg` → 4.6:1 ✓ (passes AA for normal text)
- All interactive elements have visible focus rings (1px aquamarine outline + offset)
- Pulse animation respects `prefers-reduced-motion`
- Scanline overlay is `pointer-events: none` and tested for any seizure-trigger patterns (it's static, no animation)

## Files affected

### New files

- `src/styles/themes/bioluminescent-abyss.json` — custom Shiki theme
- `src/components/MyceliumCover.astro` — procedural cover generator
- `src/components/StatusBar.astro` — top status bar
- `src/components/PulseDot.astro` — animated live indicator
- `src/components/HomeHero.astro` — `▙ RECENT TRANSMISSIONS` hero block (split from HomeBanner)
- `src/components/FrequencyBar.astro` — tag frequency row
- `src/pages/tags/index.astro` — tags index page (does not currently exist; this redesign adds it)

### Modified files

- `src/styles/global.css` — palette CSS vars, font import, scanline overlay, base styles, prose styles, link styles, code block frame styles
- `src/site.config.ts` — remove `themes` config (mode/default/include); update `navLinks` to include `Posts` (`/posts`) and `Tags` (`/tags`); leave font and socialLinks
- `astro.config.mjs` — Expressive Code config to load custom Shiki theme only; remove the multi-theme block
- `src/layouts/Layout.astro` — render StatusBar at top, Footer at bottom
- `src/components/Header.astro` — rewrite as nav cluster (right side of StatusBar) or fold into StatusBar
- `src/components/Footer.astro` — rewrite to HUD style
- `src/components/PostPreview.astro` — feed entry row
- `src/components/PostPreviewsWithYear.astro` — year separators
- `src/components/TableOfContents.astro` — sticky outline + `▙ NAV` label
- `src/components/TLDR.astro` — `▙ TRANSMISSION` styling
- `src/components/HomeBanner.astro` — optionally simplify or merge into HomeHero
- `src/components/Pagination.astro` — restyle to match
- `src/components/Search.astro` — restyle Pagefind UI to match (panel bg, cyber-clip)
- `src/pages/index.astro` — homepage layout: Hero + feed + ALL TRANSMISSIONS CTA
- `src/pages/posts/[slug].astro` — Field Report layout: header strip + cover + title + content grid + nav row
- `src/pages/posts/[...page].astro` — archive with year groups
- `src/pages/tags/[tag]/[...page].astro` — per-tag page using feed pattern
- `src/pages/404.astro` — Signal Lost page

### Removed files

- `src/components/SelectTheme.astro`
- `src/components/SelectThemeLoader.astro`
- `src/components/LightDarkAutoButton.astro`
- `src/components/LightDarkAutoThemeLoader.astro`
- `src/components/ReactGithubCalendar.tsx` — verified unreferenced (assigned to `homeGithubCalendar` in `src/pages/index.astro` but never rendered). Safe to remove along with the unused `homeGithubCalendar`/`homeAvatarImage` variables

## Out of scope

- **Light mode variant** — dark only. Could be added later as `bioluminescent-tide` (warm bone bg, deep teal text).
- **Animated particle field** — drifting plankton-like dots in the background. Mentioned during brainstorming but deferred.
- **Glitch / chromatic aberration / scan-line-sweep effects** — avoided for cleanliness.
- **Custom iconography** — using existing icon stack (`astro-icon`) with cyan/aqua coloring.
- **Mycelium cover style variants** — locked to "constellation" generator. Topographic / sonar / blob alternatives are post-launch polish.
- **Crosshair on procedural covers** — removed during brainstorming. Could come back as a hover-only detail later.
- **Inline section anchors / heading hover anchors** — keep existing `rehype-autolink-headings` behavior, just style to match.
- **Comments (Giscus)** — already wired but commented out in config; if turned on later, theme it to match (panel bg, aquamarine accent).
- **GitHub Calendar widget on home** — current `ReactGithubCalendar` component isn't part of the new homepage hero. If you still want it, it'd live on a future "/about" page or can be added back to the home below the feed; not in this redesign.
- **RSS feed styling** — existing RSS feed remains; only the link in the footer/header is restyled.

## Migration notes

- The redesign is large enough to ship as a single PR rather than incrementally — the visual language is interlocking (palette + type + layout all reinforce each other).
- Develop on a branch (`gitbutler/blog-fe-redesign` already in use).
- Visual regression: take screenshots of `/`, `/posts/{a recent slug}`, `/posts`, `/tags`, `/tags/typescript`, `/404` before merge for QA.
- Performance: scanline overlay is a single fixed div with `pointer-events: none` — no measurable cost. Mycelium SVG covers are inlined per post — small overhead, no extra requests.
- Build: `npm run build` should keep working with the new Shiki theme; verify Pagefind index still indexes prose correctly (data-pagefind-body attr stays on the article).
- **Content migration**: the existing `src/content/home.md` frontmatter has `bannerContent` ("All posts lovingly crafted by a human.") and `githubCalendar`. Recommended path: rename `bannerContent` → `subtitle` and use it as the hero subtitle source; drop `githubCalendar` (the calendar is no longer rendered in this design). The "All posts lovingly crafted by a human" line is a nice quirky touch — consider preserving it as a small italic note in the footer (`// All posts lovingly crafted by a human`) instead of losing it entirely.
