# Bioluminescent Abyss Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 60-theme MultiTerm Shiki picker on `asyncadventures.com` with a single dark "Bioluminescent Abyss" look — palette + typography + custom Shiki theme + page redesigns + procedural mycelium covers — all per the spec at `docs/superpowers/specs/2026-05-08-bioluminescent-abyss-redesign-design.md`.

**Architecture:** Foundation-first. Palette + type + base styles → Custom Shiki theme → Site config + Layout chrome (status bar, header, footer, layout) → Procedural cover component → Restyled content components (TLDR, TOC, PostPreview, etc.) → Page redesigns (home, post detail, archive, tags index, per-tag, 404) → Cleanup of removed theme infrastructure. Single PR via the existing `blog-fe-redesign` GitButler virtual branch.

**Tech Stack:** Astro 5, Tailwind v4 (`@tailwindcss/vite`), JetBrains Mono Variable (already vendored via `@fontsource-variable/jetbrains-mono`), Major Mono Display (Google Fonts via `@import` in CSS), Expressive Code (Shiki) with a custom theme, Pagefind (already integrated), Astro Icon, GitButler CLI for commits.

**Reference:** All design tokens, page layouts, and component specs live in `docs/superpowers/specs/2026-05-08-bioluminescent-abyss-redesign-design.md`. Refer back to that document whenever a section here says "per spec." This plan provides the executable code; the spec provides the authoritative design intent.

**Commit workflow (GitButler):** This repo uses GitButler. Plain `git commit` is blocked on the workspace branch. Each task ends with:

```bash
but stage <each-modified-file> blog-fe-redesign
but commit blog-fe-redesign --only -m "<message>"
```

For **deleted files**, run `but stage` against the path you removed — GitButler tracks the deletion as a hunk. If `but stage <deleted-path>` errors, fall back to running `but stage` interactively (`but stage --branch blog-fe-redesign`) and select the deletion hunks from the TUI.

**Verification pattern:** Most tasks verify with `npm run build` (proves Astro compiles) plus `npm run dev` and a manual visit to a specific URL. The procedural cover task adds a determinism check script.

---

## Task 1: Foundation — replace `global.css` with Bioluminescent Abyss base styles

**Files:**
- Modify: `src/styles/global.css` (full rewrite — current 413 lines → replacement below)

The current `global.css` couples Tailwind theme variables to dynamic per-Shiki-theme variables (`--theme-foreground`, `--theme-background`, etc.). Strip that coupling and bake in the Bioluminescent Abyss palette directly.

- [ ] **Step 1: Read the existing file** so the rewrite preserves any prose styling that's still relevant

```bash
cat src/styles/global.css | wc -l
# ~413 lines — most of it is prose styles for ::after heading anchors, expressive-code overrides, etc. The rewrite below preserves the prose features but rebuilds them on the new palette.
```

- [ ] **Step 2: Replace the whole file** with the following content

```css
/* src/styles/global.css */
@import 'tailwindcss';
@import url('https://fonts.googleapis.com/css2?family=Major+Mono+Display&display=swap');

/* ---------- Local fonts ---------- */
@font-face {
  font-family: 'JetBrains Mono Variable';
  font-style: normal;
  font-display: swap;
  font-weight: 100 800;
  src: url(@fontsource-variable/jetbrains-mono/files/jetbrains-mono-latin-wght-normal.woff2)
    format('woff2-variations');
  unicode-range:
    U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308,
    U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}

/* ---------- Bioluminescent Abyss palette ---------- */
:root {
  --bg: #060f1c;
  --panel: #0a1828;
  --border: #152840;
  --border-strong: #1f3550;
  --accent-1: #7fffd4;        /* aquamarine */
  --accent-2: #5ec8ff;        /* cyan */
  --accent-3: #ffce5e;        /* firefly amber */
  --text: #e8f0f5;
  --muted: #5a7a8a;

  --glow-aqua-soft: rgba(127, 255, 212, 0.18);
  --glow-aqua: rgba(127, 255, 212, 0.4);
  --glow-aqua-strong: rgba(127, 255, 212, 0.6);
  --glow-cyan-soft: rgba(94, 200, 255, 0.18);
  --glow-cyan: rgba(94, 200, 255, 0.4);

  --font-display: 'Major Mono Display', 'JetBrains Mono Variable', monospace;
  --font-body: 'JetBrains Mono Variable', 'Courier New', monospace;
}

/* ---------- Tailwind theme bridge ---------- */
@theme {
  --color-bg: var(--bg);
  --color-panel: var(--panel);
  --color-border: var(--border);
  --color-border-strong: var(--border-strong);
  --color-accent-1: var(--accent-1);
  --color-accent-2: var(--accent-2);
  --color-accent-3: var(--accent-3);
  --color-text: var(--text);
  --color-muted: var(--muted);
  --default-font-family: var(--font-body);
}

/* ---------- View transitions ---------- */
header { view-transition-name: none; }
@view-transition { navigation: auto; }

/* ---------- Base body ---------- */
html, body {
  background-color: var(--bg);
  color: var(--text);
  font-family: var(--font-body);
}
body {
  font-size-adjust: ex-height 0.53;
  font-display: block;
  position: relative;
}

/* Scanline overlay — fixed, decorative, always on top */
body::after {
  content: '';
  position: fixed;
  inset: 0;
  background: repeating-linear-gradient(
    0deg,
    transparent,
    transparent 2px,
    rgba(255, 255, 255, 0.022) 2px,
    rgba(255, 255, 255, 0.022) 3px
  );
  pointer-events: none;
  z-index: 1000;
}

/* Reduced-motion: keep scanline (it's static), kill animations */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0s !important;
    transition-duration: 0s !important;
  }
}

/* ---------- Typography helpers ---------- */
.font-display {
  font-family: var(--font-display);
  letter-spacing: 0.02em;
  text-transform: lowercase;
}

.glow {
  text-shadow:
    0 0 8px var(--glow-aqua),
    0 0 24px var(--glow-aqua-soft);
}
.glow-soft {
  text-shadow: 0 0 6px var(--glow-aqua-soft);
}

.hud-label {
  color: var(--accent-3);
  font-size: 0.625rem;
  letter-spacing: 0.28em;
  text-transform: uppercase;
}
.hud-label::before {
  content: '▙ ';
  color: var(--accent-3);
}

/* ---------- Cyber-clip utilities ---------- */
.clip-sm  { clip-path: polygon(8px 0%,  100% 0%, 100% calc(100% - 8px),  calc(100% - 8px)  100%, 0% 100%, 0% 8px); }
.clip-md  { clip-path: polygon(12px 0%, 100% 0%, 100% calc(100% - 12px), calc(100% - 12px) 100%, 0% 100%, 0% 12px); }
.clip-lg  { clip-path: polygon(16px 0%, 100% 0%, 100% calc(100% - 16px), calc(100% - 16px) 100%, 0% 100%, 0% 16px); }
.clip-xl  { clip-path: polygon(20px 0%, 100% 0%, 100% calc(100% - 20px), calc(100% - 20px) 100%, 0% 100%, 0% 20px); }

/* ---------- Pulse animation ---------- */
@keyframes pulse-dot {
  0%, 100% { opacity: 1; }
  50%      { opacity: 0.4; }
}

/* ---------- Focus rings ---------- */
input:focus-visible,
textarea:focus-visible,
select:focus-visible,
button:focus-visible,
a:focus-visible,
input:active,
textarea:active,
select:active,
button:active {
  outline: 1px solid var(--accent-1);
  outline-offset: 2px;
}

button { cursor: pointer; }

/* ---------- Article images ---------- */
article img {
  display: block;
  max-width: 100%;
  border: 1px solid var(--border);
  margin: 1rem auto;
}
article img[pixelated='true'] {
  image-rendering: pixelated;
}

/* ---------- Prose styles ---------- */
.prose {
  font-size: 0.95rem;
  line-height: 1.75;
  color: var(--text);
}

.prose p { margin: 0.65rem 0; }

.prose a {
  color: var(--accent-2);
  text-decoration: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 3px;
  transition: text-shadow 0.2s ease-out, color 0.2s ease-out;
}
.prose a:hover {
  color: var(--accent-1);
  text-shadow: 0 0 6px var(--glow-aqua);
}

.prose strong, .prose b { color: var(--accent-1); font-weight: 700; }
.prose em, .prose i { color: var(--accent-1); font-style: italic; }

.prose h1, .prose h2 {
  font-family: var(--font-display);
  color: var(--accent-1);
  text-shadow: 0 0 6px var(--glow-aqua-soft);
  letter-spacing: 0.02em;
  margin: 1.5rem 0 0.5rem;
  font-weight: 400;
}
.prose h1 { font-size: 1.75rem; line-height: 1.15; }
.prose h2 { font-size: 1.25rem; line-height: 1.2; }

.prose h3, .prose h4, .prose h5, .prose h6 {
  font-family: var(--font-body);
  color: var(--accent-3);
  text-transform: uppercase;
  letter-spacing: 0.18em;
  font-size: 0.85rem;
  margin: 1.25rem 0 0.4rem;
  font-weight: 700;
}

.prose h1 .heading-anchor,
.prose h2 .heading-anchor,
.prose h3 .heading-anchor,
.prose h4 .heading-anchor,
.prose h5 .heading-anchor,
.prose h6 .heading-anchor {
  display: inline-flex;
  margin-left: 0.5rem;
  opacity: 0;
  color: var(--accent-2);
  transition: opacity 0.2s ease-out;
  vertical-align: middle;
}
.prose h1:hover .heading-anchor,
.prose h2:hover .heading-anchor,
.prose h3:hover .heading-anchor,
.prose h4:hover .heading-anchor,
.prose h5:hover .heading-anchor,
.prose h6:hover .heading-anchor { opacity: 1; }

.prose ul, .prose ol { padding-left: 1.4rem; margin: 0.6rem 0; }
.prose li { margin: 0.25rem 0; }
.prose ul > li::marker { color: var(--accent-1); }
.prose ol > li::marker { color: var(--accent-1); }

.prose blockquote {
  border-left: 2px solid var(--accent-2);
  padding: 0.25rem 0 0.25rem 1rem;
  margin: 1rem 0;
  font-style: italic;
  color: var(--text);
  opacity: 0.85;
}

.prose code:not(.expressive-code code) {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--accent-1);
  background: var(--panel);
  padding: 1px 6px;
  border: 1px solid var(--border);
}

.prose table {
  width: 100%;
  border-collapse: collapse;
  margin: 1rem 0;
  font-size: 0.85rem;
}
.prose table th,
.prose table td {
  border: 1px solid var(--border);
  padding: 0.4rem 0.6rem;
  text-align: left;
}
.prose table thead {
  background: rgba(127, 255, 212, 0.04);
  color: var(--accent-1);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  font-size: 0.75rem;
}
.prose table tbody tr:hover { background: rgba(127, 255, 212, 0.03); }

.prose hr {
  border: none;
  border-top: 1px dashed var(--border);
  margin: 1.5rem 0;
}

/* ---------- Expressive Code overrides (frame chrome) ---------- */
.prose div.expressive-code {
  margin: 1.25rem 0;
}
.prose div.expressive-code figure {
  border: 1px solid var(--border);
  background: var(--panel);
  border-radius: 0;
  clip-path: polygon(8px 0%, 100% 0%, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0% 100%, 0% 8px);
  box-shadow: none !important;
}
.prose div.expressive-code figure figcaption {
  background: transparent !important;
  border: none !important;
  border-bottom: 1px dashed var(--border) !important;
  padding: 0 !important;
}
.prose div.expressive-code figure figcaption span.title {
  color: var(--accent-2) !important;
  background: transparent !important;
  border: none !important;
  font-family: var(--font-body) !important;
  font-size: 0.7rem !important;
  letter-spacing: 0.18em !important;
  text-transform: uppercase !important;
  padding: 0.4rem 0.85rem !important;
  width: 100% !important;
}
.prose div.expressive-code figure pre {
  background: transparent !important;
  border: none !important;
  border-radius: 0 !important;
  scrollbar-width: thin;
}

/* hide katex-html (used as a11y shadow) */
.katex-html { display: none; }
```

- [ ] **Step 3: Verify Tailwind v4 build**

```bash
npm run build
```

Expected: Build completes. Some pages may render broken because the Layout still references the old `var(--theme-*)` system — that's fine for now; it'll be fixed in Task 7. The CSS itself must compile without errors.

If you see `The 'class' utility uses unknown utility` or theme errors, double-check the `@theme {}` block.

- [ ] **Step 4: Commit**

```bash
but stage src/styles/global.css blog-fe-redesign
but commit blog-fe-redesign --only -m "global.css: bioluminescent abyss palette, fonts, scanline, prose styles"
```

---

## Task 2: Custom Shiki theme + Expressive Code config

**Files:**
- Create: `src/styles/themes/bioluminescent-abyss.json` (custom Shiki theme JSON)
- Modify: `astro.config.mjs` (replace `themes: siteConfig.themes.include` with the single custom theme)

- [ ] **Step 1: Create the Shiki theme directory and file**

```bash
mkdir -p src/styles/themes
```

Then create `src/styles/themes/bioluminescent-abyss.json`:

```json
{
  "name": "bioluminescent-abyss",
  "type": "dark",
  "displayName": "Bioluminescent Abyss",
  "colors": {
    "editor.foreground": "#e8f0f5",
    "editor.background": "#0a1828",
    "editor.lineHighlightBackground": "#7fffd40a",
    "editor.selectionBackground": "#5ec8ff33",
    "editorLineNumber.foreground": "#5a7a8a",
    "editorLineNumber.activeForeground": "#7fffd4",
    "editorCursor.foreground": "#7fffd4",
    "terminal.ansiBlack": "#060f1c",
    "terminal.ansiRed": "#ff5e7a",
    "terminal.ansiGreen": "#7fffd4",
    "terminal.ansiYellow": "#ffce5e",
    "terminal.ansiBlue": "#5ec8ff",
    "terminal.ansiMagenta": "#e85aff",
    "terminal.ansiCyan": "#5ec8ff",
    "terminal.ansiWhite": "#e8f0f5"
  },
  "tokenColors": [
    { "scope": ["comment", "punctuation.definition.comment"],
      "settings": { "foreground": "#5a7a8a", "fontStyle": "italic" } },
    { "scope": ["keyword", "storage.type", "storage.modifier", "keyword.control", "keyword.operator.expression"],
      "settings": { "foreground": "#5ec8ff" } },
    { "scope": ["string", "string.quoted", "string.template"],
      "settings": { "foreground": "#7fffd4" } },
    { "scope": ["punctuation.definition.string"],
      "settings": { "foreground": "#7fffd4" } },
    { "scope": ["entity.name.function", "support.function", "meta.function-call entity.name.function", "variable.function"],
      "settings": { "foreground": "#ffce5e" } },
    { "scope": ["constant.numeric", "constant.language", "constant.character"],
      "settings": { "foreground": "#ffce5e" } },
    { "scope": ["variable", "meta.definition.variable variable.other"],
      "settings": { "foreground": "#e8f0f5" } },
    { "scope": ["variable.parameter"],
      "settings": { "foreground": "#e8f0f5" } },
    { "scope": ["entity.name.type", "entity.name.class", "support.type", "support.class"],
      "settings": { "foreground": "#7fffd4" } },
    { "scope": ["entity.name.tag"],
      "settings": { "foreground": "#5ec8ff" } },
    { "scope": ["entity.other.attribute-name"],
      "settings": { "foreground": "#ffce5e" } },
    { "scope": ["punctuation"],
      "settings": { "foreground": "#5a7a8a" } },
    { "scope": ["keyword.operator"],
      "settings": { "foreground": "#5ec8ff" } },
    { "scope": ["markup.bold"],
      "settings": { "foreground": "#7fffd4", "fontStyle": "bold" } },
    { "scope": ["markup.italic"],
      "settings": { "foreground": "#7fffd4", "fontStyle": "italic" } },
    { "scope": ["markup.heading"],
      "settings": { "foreground": "#7fffd4", "fontStyle": "bold" } },
    { "scope": ["markup.inserted"],
      "settings": { "foreground": "#7fffd4" } },
    { "scope": ["markup.deleted"],
      "settings": { "foreground": "#ff5e7a" } }
  ]
}
```

- [ ] **Step 2: Update `astro.config.mjs`** — replace the `expressiveCode` block

In `astro.config.mjs`, find the `expressiveCode({...})` call (lines ~75–83) and replace it. Also add an import for the JSON theme at the top.

Replace lines 1–10 (the existing imports up to and including `pluginLineNumbers`) with:

```javascript
// @ts-check
import { defineConfig } from 'astro/config'
import tailwindcss from '@tailwindcss/vite'
import sitemap from '@astrojs/sitemap'
import mdx from '@astrojs/mdx'
import rehypeSlug from 'rehype-slug'
import rehypeAutolinkHeadings from 'rehype-autolink-headings'
import expressiveCode from 'astro-expressive-code'
import siteConfig from './src/site.config'
import { pluginLineNumbers } from '@expressive-code/plugin-line-numbers'
import bioluminescentAbyss from './src/styles/themes/bioluminescent-abyss.json' with { type: 'json' }
```

Then find this block (lines ~75–83):

```javascript
    expressiveCode({
      themes: siteConfig.themes.include,
      useDarkModeMediaQuery: false,
      defaultProps: {
        showLineNumbers: false,
        wrap: false,
      },
      plugins: [pluginLineNumbers()],
    }),
```

Replace with:

```javascript
    expressiveCode({
      themes: [bioluminescentAbyss],
      useDarkModeMediaQuery: false,
      defaultProps: {
        showLineNumbers: false,
        wrap: false,
      },
      styleOverrides: {
        borderRadius: '0',
        codeBackground: 'var(--panel)',
        frames: {
          frameBoxShadowCssValue: 'none',
          editorTabBarBorderColor: 'var(--border)',
          editorTabBarBackground: 'transparent',
          editorActiveTabBackground: 'transparent',
          editorActiveTabIndicatorTopColor: 'var(--accent-1)',
          editorActiveTabIndicatorBottomColor: 'transparent',
          terminalBackground: 'var(--panel)',
          terminalTitlebarBackground: 'transparent',
          terminalTitlebarBorderBottomColor: 'var(--border)',
        },
      },
      plugins: [pluginLineNumbers()],
    }),
```

- [ ] **Step 3: Build and verify the Shiki theme is picked up**

```bash
npm run build
```

Expected: Build completes. The Astro/Expressive Code build logs should mention `bioluminescent-abyss` as the loaded theme.

If you see "themes is not iterable" or similar, check the JSON import syntax: it requires `with { type: 'json' }` for ESM JSON imports under Node 20+.

- [ ] **Step 4: Commit**

```bash
but stage src/styles/themes/bioluminescent-abyss.json blog-fe-redesign
but stage astro.config.mjs blog-fe-redesign
but commit blog-fe-redesign --only -m "shiki: custom bioluminescent-abyss theme + expressive-code config"
```

---

## Task 3: Site config — drop themes, update navLinks, types

**Files:**
- Modify: `src/site.config.ts`
- Modify: `src/types.ts`

The current config carries 60 Shiki theme names and a complex `themes.mode` switch. Strip it.

- [ ] **Step 1: Update `src/site.config.ts`**

Replace the file contents with:

```typescript
import type { SiteConfig } from '@types'

const config: SiteConfig = {
  site: 'https://asyncadventures.com',
  title: 'Async Adventures',
  description: 'Adventures in the world of software development',
  author: 'John Stewart',
  tags: [
    'Express.js', 'REST API', 'GraphQL', 'MongoDB', 'PostgreSQL', 'Docker',
    'AWS', 'GCP', 'Vercel', 'Firebase', 'Supabase', 'Prisma', 'Next.js',
    'React', 'TypeScript', 'JavaScript', 'HTML', 'CSS', 'SASS', 'SCSS',
    'Code Review', 'Git', 'DevOps', 'CI/CD', 'Unit Testing',
    'Integration Testing', 'Test-Driven Development', 'Agile Development',
    'Microservices', 'Serverless', 'Cloud Computing', 'Database Design',
    'API Development', 'Performance Optimization', 'Code Quality',
    'Clean Code', 'Developer Tools', 'Open Source', 'Tech Stack',
    'Software Engineer Career', 'Programming Tutorial',
    'Coding Best Practices', 'Asynchronous Programming', 'Async/Await',
    'Promises', 'Event Loop', 'Concurrency',
  ],
  socialCardAvatarImage: '',
  font: 'JetBrains Mono Variable',
  pageSize: 10,
  navLinks: [
    { name: 'Posts', url: '/posts' },
    { name: 'Tags', url: '/tags' },
  ],
  socialLinks: {
    github: 'https://github.com/codeinaire',
    email: 'john@asyncadventures.com',
    linkedin: 'https://www.linkedin.com/in/hi-im-john-stewart/',
  },
}

export default config
```

- [ ] **Step 2: Update `src/types.ts`** — remove `themes` from `SiteConfig`

Open `src/types.ts`, find the `SiteConfig` interface, and remove the `themes` property entirely. Keep everything else. Example:

```typescript
// Find this section in types.ts:
export interface SiteConfig {
  site: string
  title: string
  description: string
  author: string
  tags: string[]
  socialCardAvatarImage: string
  font: string
  pageSize: number
  navLinks: NavLink[]
  themes: ThemesConfig   // <-- REMOVE THIS LINE
  socialLinks: SocialLinks
  giscus?: GiscusConfig
}
```

Also remove the `ThemesConfig` interface and any related types (`ThemeMode`, etc.) if they're declared in this file and no longer referenced.

If `ThemesConfig` is exported and imported elsewhere, do a grep to find references:

```bash
grep -rn "ThemesConfig\|themes\.mode\|themes\.include\|themes\.default" src/ --include="*.astro" --include="*.ts" --include="*.tsx"
```

For each non-deleted reference, the corresponding code will be removed in later tasks (Layout in Task 7, Header in Task 5, etc.). The grep is just situational awareness.

- [ ] **Step 3: Verify TypeScript compiles**

```bash
npm run astro check 2>&1 | head -50
```

Expected: Errors will show `Property 'themes' does not exist` from `Layout.astro`, `Header.astro`, etc. Those are EXPECTED — those files get rewritten in later tasks. Note the count.

- [ ] **Step 4: Commit**

```bash
but stage src/site.config.ts blog-fe-redesign
but stage src/types.ts blog-fe-redesign
but commit blog-fe-redesign --only -m "config: drop multi-theme system, add posts/tags navLinks"
```

---

## Task 4: PulseDot + StatusBar components

**Files:**
- Create: `src/components/PulseDot.astro`
- Create: `src/components/StatusBar.astro`

- [ ] **Step 1: Create `PulseDot.astro`**

```astro
---
// src/components/PulseDot.astro
interface Props {
  size?: number
  class?: string
}
const { size = 5, class: extraClass = '' } = Astro.props
---
<span
  class={`pulse-dot inline-block align-middle ${extraClass}`}
  style={`width:${size}px;height:${size}px`}
  aria-hidden="true"
></span>

<style>
  .pulse-dot {
    background: var(--accent-1);
    box-shadow: 0 0 6px var(--glow-aqua-strong);
    animation: pulse-dot 1.6s ease-in-out infinite;
  }
</style>
```

(`@keyframes pulse-dot` is already defined in `global.css`.)

- [ ] **Step 2: Create `StatusBar.astro`**

```astro
---
// src/components/StatusBar.astro
import PulseDot from './PulseDot.astro'
import siteConfig from '../site.config'

---

<div class="status-bar">
  <a href="/" class="brand">
    <PulseDot />
    <span class="site-name">{siteConfig.title.toUpperCase().replace(/\s+/g, '.')}</span>
  </a>
  <div class="right">
    <slot name="right" />
  </div>
</div>

<style>
  .status-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.625rem 1.125rem;
    border-bottom: 1px solid var(--border);
    color: var(--muted);
    font-size: 0.6rem;
    letter-spacing: 0.18em;
    text-transform: uppercase;
  }
  .brand {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    color: var(--text);
    text-decoration: none;
  }
  .brand .site-name {
    color: var(--text);
    transition: color 0.2s ease-out;
  }
  .brand:hover .site-name { color: var(--accent-1); }
  .right { color: var(--muted); }
  .right :global(span.amber) { color: var(--accent-3); }
</style>
```

- [ ] **Step 3: Verify build**

```bash
npm run build 2>&1 | tail -20
```

Expected: Build still has errors from Layout/Header pending later tasks. The two new components themselves should compile (no errors mentioning `PulseDot.astro` or `StatusBar.astro`).

- [ ] **Step 4: Commit**

```bash
but stage src/components/PulseDot.astro blog-fe-redesign
but stage src/components/StatusBar.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "components: PulseDot + StatusBar"
```

---

## Task 5: Header rewrite

**Files:**
- Modify: `src/components/Header.astro` (full rewrite)

Replace the existing 76-line file with a tight nav + StatusBar wrapper.

- [ ] **Step 1: Rewrite `src/components/Header.astro`**

```astro
---
// src/components/Header.astro
import siteConfig from '../site.config'
import StatusBar from './StatusBar.astro'
import Search from './Search.astro'
import { getCollection } from 'astro:content'

const posts = await getCollection('posts')
const postCount = posts.length
const tagSet = new Set<string>()
for (const p of posts) {
  for (const t of (p.data.tags ?? []) as string[]) tagSet.add(t.toLowerCase())
}
const tagCount = tagSet.size
---

<header>
  <StatusBar>
    <span slot="right" class="status-right">
      <span class="muted">// posts · {postCount}</span>
      <span class="sep">//</span>
      <span class="muted">tags · {tagCount}</span>
    </span>
  </StatusBar>
  <nav class="nav-row" aria-label="Primary">
    <ul class="nav-links">
      {siteConfig.navLinks.map((link) => (
        <li><a href={link.url}>{link.name.toLowerCase()}</a></li>
      ))}
    </ul>
    <div class="nav-actions">
      <Search />
      <a href="/rss.xml" aria-label="RSS feed" class="rss-link">rss</a>
    </div>
  </nav>
</header>

<style>
  header { grid-area: header; margin-bottom: 1.5rem; }
  .status-right { display: inline-flex; gap: 0.5rem; align-items: center; }
  .status-right .muted { color: var(--muted); }
  .status-right .sep { color: var(--border-strong); }

  .nav-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.5rem 1.125rem;
    border-bottom: 1px dashed var(--border);
    font-size: 0.75rem;
    letter-spacing: 0.18em;
    text-transform: uppercase;
  }
  .nav-links {
    display: flex;
    gap: 1.25rem;
    list-style: none;
    padding: 0;
    margin: 0;
  }
  .nav-links a {
    color: var(--muted);
    text-decoration: none;
    transition: color 0.2s ease-out;
  }
  .nav-links a:hover { color: var(--accent-2); }

  .nav-actions {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  .rss-link {
    color: var(--muted);
    text-decoration: none;
    transition: color 0.2s ease-out;
  }
  .rss-link:hover { color: var(--accent-3); }
</style>
```

Note: `Search.astro` will be restyled later (Task 12) but its current API still works as a slot. The `getCollection` call here is the live source for the StatusBar's post/tag counts.

- [ ] **Step 2: Verify the new Header compiles in isolation**

```bash
npm run astro check 2>&1 | grep -i "Header.astro" | head -20
```

Expected: no errors referencing `Header.astro`. (Errors elsewhere remain, fixed in later tasks.)

- [ ] **Step 3: Commit**

```bash
but stage src/components/Header.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "header: rewrite — StatusBar + minimal nav row, drop theme picker"
```

---

## Task 6: Footer rewrite

**Files:**
- Modify: `src/components/Footer.astro` (full rewrite)

- [ ] **Step 1: Rewrite `src/components/Footer.astro`**

```astro
---
// src/components/Footer.astro
import siteConfig from '../site.config'

const year = new Date().getFullYear()
const social = siteConfig.socialLinks
---

<footer>
  <div class="left">
    <span class="muted">// © {year} {siteConfig.author.toLowerCase()} · {siteConfig.title.toLowerCase()}</span>
    <span class="quirky">// All posts lovingly crafted by a human</span>
  </div>
  <div class="right">
    {social.github && (
      <a href={social.github} target="_blank" rel="noopener noreferrer" aria-label="GitHub" class="social-link">github</a>
    )}
    {social.email && (
      <a href={`mailto:${social.email}`} aria-label="Email" class="social-link">email</a>
    )}
    {social.linkedin && (
      <a href={social.linkedin} target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" class="social-link">linkedin</a>
    )}
    <span class="amber">// END OF TRANSMISSION</span>
  </div>
</footer>

<style>
  footer {
    grid-area: footer;
    margin-top: 3rem;
    padding: 1rem 1.125rem;
    border-top: 1px dashed var(--border);
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    font-size: 0.7rem;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    flex-wrap: wrap;
    gap: 1rem;
  }
  .left { display: flex; flex-direction: column; gap: 0.4rem; color: var(--muted); }
  .left .quirky { color: var(--muted); font-style: italic; opacity: 0.7; text-transform: none; letter-spacing: 0; font-size: 0.7rem; }
  .right { display: flex; gap: 1rem; align-items: center; flex-wrap: wrap; }
  .social-link {
    color: var(--accent-2);
    text-decoration: none;
    transition: color 0.2s ease-out, text-shadow 0.2s ease-out;
  }
  .social-link:hover {
    color: var(--accent-1);
    text-shadow: 0 0 8px var(--glow-aqua);
  }
  .amber { color: var(--accent-3); }
</style>
```

- [ ] **Step 2: Verify**

```bash
npm run astro check 2>&1 | grep -i "Footer.astro"
```

Expected: no errors referencing `Footer.astro`.

- [ ] **Step 3: Commit**

```bash
but stage src/components/Footer.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "footer: rewrite — HUD strip with socials and end-of-transmission tag"
```

---

## Task 7: Layout.astro rewrite

**Files:**
- Modify: `src/layouts/Layout.astro` (full rewrite)

This unblocks every page. The current 168-line file resolves Shiki themes, generates per-theme CSS, and renders a TagsSidebar. Strip all of that.

- [ ] **Step 1: Replace `src/layouts/Layout.astro`**

```astro
---
// src/layouts/Layout.astro
import '/src/styles/global.css'
import Header from '@components/Header.astro'
import Footer from '@components/Footer.astro'
import siteConfig from '../site.config'

interface Props {
  title?: string
  description?: string
  tags?: string[]
  author?: string
}

const { title, description, tags, author } = Astro.props
const pageUrl = new URL(Astro.url.pathname, Astro.site).href.replace(/\/$/, '')
const pageType = Astro.url.pathname.startsWith('/posts') ? 'article' : 'website'
const pageTitle = title ? `${title} - ${siteConfig.title}` : siteConfig.title
const pageDescription = description || siteConfig.description
const pageAuthor = author || siteConfig.author
const pageImage =
  pageType === 'article'
    ? Astro.url.origin +
      Astro.url.pathname.replace(/\/posts\//, '/social-cards/') + '.png'
    : `${Astro.url.origin}/social-cards/__default.png`
const pageKeywords = [
  ...new Set(siteConfig.tags.concat(tags || []).map((w) => w.toLowerCase())),
].join(', ')
---

<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <meta name="generator" content={Astro.generator} />
    <meta name="theme-color" content="#060f1c" />
    <meta name="title" content={pageTitle} />
    <meta name="description" content={pageDescription} />
    <meta name="author" content={pageAuthor} />
    <meta property="og:title" content={pageTitle} />
    <meta property="og:description" content={pageDescription} />
    <meta property="og:url" content={pageUrl} />
    <meta property="og:type" content={pageType} />
    {pageImage && <meta property="og:image" content={pageImage} />}
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content={pageTitle} />
    <meta name="twitter:description" content={pageDescription} />
    {pageImage && <meta name="twitter:image" content={pageImage} />}
    <meta name="keywords" content={pageKeywords} />
    <link rel="canonical" href={pageUrl} />
    <link rel="sitemap" href="/sitemap-index.xml" />
    <link
      rel="alternate"
      type="application/rss+xml"
      title={siteConfig.title}
      href={new URL('rss.xml', Astro.site)}
    />
    <title>{pageTitle}</title>
  </head>
  <body>
    <div class="page">
      <Header />
      <main>
        <slot />
      </main>
      <Footer />
    </div>
  </body>
</html>

<style is:global>
  .page {
    min-height: 100vh;
    margin: 0 auto;
    padding: 1.25rem 1rem;
    max-width: 880px;
    display: grid;
    grid-template-columns: 1fr;
    grid-template-areas: 'header' 'main' 'footer';
  }
  main { grid-area: main; min-width: 0; }

  @media (min-width: 768px) {
    .page { padding: 2rem 1.5rem; }
  }
</style>
```

Notes on what was removed:
- All `themes`/`resolveThemeColorStyles` resolution code → no longer needed (single Shiki theme baked into Expressive Code).
- `LightDarkAutoThemeLoader` and `SelectThemeLoader` → never rendered (those components get deleted in Task 18).
- `TagsSidebar` and the 2-column main → gone. Tags get a dedicated index page now.
- The `getTagCounts` / `getAllPostTags` calls → no longer needed at layout level. The Header makes its own count calls; the tags index page makes its own.
- Per-page sidebar slot (`<slot name="sidebar" />`) → gone. Pages that need a sidebar (post detail's TOC) implement their own grid.

- [ ] **Step 2: Build the site**

```bash
npm run build 2>&1 | tail -30
```

Expected: Build will fail on the actual page files (`src/pages/index.astro`, `src/pages/posts/[slug].astro`, etc.) because they still reference `siteConfig.themes`, `homeAvatarImage`, the sidebar slot, etc. Note the failures — they're checklisted in the next tasks.

The Layout.astro itself must compile without error. If it errors, fix.

- [ ] **Step 3: Commit**

```bash
but stage src/layouts/Layout.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "layout: rewrite — drop theme machinery and tags sidebar, add abyss meta theme-color"
```

---

## Task 8: MyceliumCover component + determinism check

**Files:**
- Create: `src/components/MyceliumCover.astro`
- Create: `scripts/verify-mycelium.mjs` (one-off determinism verification)

The component generates a deterministic SVG cover from a post slug. Same slug → identical SVG output. Used as fallback when a post has no `coverImage`.

- [ ] **Step 1: Create `src/components/MyceliumCover.astro`**

```astro
---
// src/components/MyceliumCover.astro
//
// Deterministic procedural cover generator. Given a post slug, produces an
// SVG showing a small "mycelium" of nodes connected by lines, sized 800x360.
// Same slug always produces the exact same SVG.
//
interface Props {
  slug: string
  caption?: boolean        // default true: shows "// MYCELIUM-XXXX · seeded" caption
}
const { slug, caption = true } = Astro.props

// djb2 hash → 32-bit unsigned int
function hashSlug(s: string): number {
  let h = 5381
  for (let i = 0; i < s.length; i++) {
    h = ((h << 5) + h + s.charCodeAt(i)) | 0
  }
  return h >>> 0
}

// mulberry32 PRNG — deterministic, uniform-ish, returns 0..1
function mkPrng(seed: number) {
  let s = seed >>> 0
  return () => {
    s = (s + 0x6D2B79F5) | 0
    let t = s
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

const seed = hashSlug(slug)
const rand = mkPrng(seed)

// 7..10 nodes, with margin 60..(W-60), 50..(H-50)
const W = 800, H = 360, MARGIN_X = 60, MARGIN_Y = 50
const nodeCount = 7 + Math.floor(rand() * 4) // 7,8,9,10
type Node = { x: number; y: number; r: number; color: string }
const palette: string[] = [
  '#7fffd4', '#7fffd4', '#7fffd4', // aqua dominant
  '#5ec8ff', '#5ec8ff',            // cyan secondary
  '#ffce5e',                        // amber rare
]
const nodes: Node[] = []
for (let i = 0; i < nodeCount; i++) {
  nodes.push({
    x: MARGIN_X + rand() * (W - 2 * MARGIN_X),
    y: MARGIN_Y + rand() * (H - 2 * MARGIN_Y),
    r: 3 + rand() * 3.5,
    color: palette[Math.floor(rand() * palette.length)],
  })
}

// For each node, find its 2 nearest neighbors and emit edges (deduplicated)
type Edge = { a: number; b: number }
const edges: Edge[] = []
const seen = new Set<string>()
for (let i = 0; i < nodes.length; i++) {
  const dists = nodes
    .map((n, j) => ({ j, d: (n.x - nodes[i].x) ** 2 + (n.y - nodes[i].y) ** 2 }))
    .filter((e) => e.j !== i)
    .sort((a, b) => a.d - b.d)
    .slice(0, 2)
  for (const { j } of dists) {
    const key = i < j ? `${i}-${j}` : `${j}-${i}`
    if (!seen.has(key)) {
      seen.add(key)
      edges.push({ a: Math.min(i, j), b: Math.max(i, j) })
    }
  }
}

// Caption suffix: first 4 hex chars of the seed
const seedHex = seed.toString(16).padStart(8, '0').slice(0, 4).toUpperCase()
---

<svg viewBox="0 0 800 360" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" role="img" aria-label="Procedural cover">
  <defs>
    <radialGradient id={`bg-${seedHex}`} cx="60%" cy="40%" r="60%">
      <stop offset="0%" stop-color="#5ec8ff" stop-opacity="0.18" />
      <stop offset="100%" stop-color="#060f1c" stop-opacity="0" />
    </radialGradient>
    <filter id={`glow-${seedHex}`}>
      <feGaussianBlur stdDeviation="2" result="b" />
      <feMerge>
        <feMergeNode in="b" />
        <feMergeNode in="SourceGraphic" />
      </feMerge>
    </filter>
  </defs>
  <rect width="800" height="360" fill={`url(#bg-${seedHex})`} />
  <g stroke="#5ec8ff" stroke-width="0.8" opacity="0.45" filter={`url(#glow-${seedHex})`}>
    {edges.map((e) => (
      <line x1={nodes[e.a].x} y1={nodes[e.a].y} x2={nodes[e.b].x} y2={nodes[e.b].y} />
    ))}
  </g>
  <g filter={`url(#glow-${seedHex})`}>
    {nodes.map((n) => (
      <circle cx={n.x} cy={n.y} r={n.r} fill={n.color} />
    ))}
  </g>
  {caption && (
    <text x="780" y="346" text-anchor="end" font-family="JetBrains Mono Variable, monospace"
          font-size="10" fill="#5ec8ff" opacity="0.7" letter-spacing="2">
      // MYCELIUM-{seedHex} · SEEDED
    </text>
  )}
</svg>

<style>
  svg { display: block; width: 100%; height: 100%; }
</style>
```

- [ ] **Step 2: Create `scripts/verify-mycelium.mjs`** — one-off determinism check

```javascript
// scripts/verify-mycelium.mjs
//
// Standalone determinism check for the mycelium cover generator. Reproduces
// the same hash + PRNG used by src/components/MyceliumCover.astro, generates
// nodes for a fixed set of slugs twice, and asserts identical output.
//
// Run: node scripts/verify-mycelium.mjs

function hashSlug(s) {
  let h = 5381
  for (let i = 0; i < s.length; i++) h = ((h << 5) + h + s.charCodeAt(i)) | 0
  return h >>> 0
}
function mkPrng(seed) {
  let s = seed >>> 0
  return () => {
    s = (s + 0x6D2B79F5) | 0
    let t = s
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}
function genNodes(slug) {
  const W = 800, H = 360, MARGIN_X = 60, MARGIN_Y = 50
  const seed = hashSlug(slug)
  const rand = mkPrng(seed)
  const nodeCount = 7 + Math.floor(rand() * 4)
  const palette = ['#7fffd4','#7fffd4','#7fffd4','#5ec8ff','#5ec8ff','#ffce5e']
  const nodes = []
  for (let i = 0; i < nodeCount; i++) {
    nodes.push({
      x: MARGIN_X + rand() * (W - 2 * MARGIN_X),
      y: MARGIN_Y + rand() * (H - 2 * MARGIN_Y),
      r: 3 + rand() * 3.5,
      color: palette[Math.floor(rand() * palette.length)],
    })
  }
  return { seed, nodes }
}

const slugs = [
  '20260317-automating-subagent-workflow',
  '20260319-the-state-machine',
  '20260330-iterating-on-agentic-codeflow',
  '20260430-dungeon-crawler',
  'test-slug',
]

let ok = true
for (const slug of slugs) {
  const a = JSON.stringify(genNodes(slug))
  const b = JSON.stringify(genNodes(slug))
  if (a !== b) {
    console.error(`FAIL: non-deterministic for slug "${slug}"`)
    ok = false
  } else {
    console.log(`PASS: deterministic for "${slug}" — seed=${genNodes(slug).seed.toString(16)}, ${JSON.parse(a).nodes.length} nodes`)
  }
}

const allDifferent = new Set(slugs.map((s) => genNodes(s).seed)).size === slugs.length
if (!allDifferent) {
  console.error('FAIL: at least two slugs produced the same seed (collision)')
  ok = false
} else {
  console.log('PASS: all slugs produced distinct seeds')
}

process.exit(ok ? 0 : 1)
```

- [ ] **Step 3: Run the determinism check**

```bash
node scripts/verify-mycelium.mjs
```

Expected output:
```
PASS: deterministic for "20260317-automating-subagent-workflow" — seed=..., N nodes
PASS: deterministic for "20260319-the-state-machine" — ...
PASS: deterministic for "20260330-iterating-on-agentic-codeflow" — ...
PASS: deterministic for "20260430-dungeon-crawler" — ...
PASS: deterministic for "test-slug" — ...
PASS: all slugs produced distinct seeds
```

If any FAIL line appears, the algorithm has drifted from the component's implementation — copy the algorithm exactly from `MyceliumCover.astro` into the script (or vice versa).

- [ ] **Step 4: Build to verify the Astro component compiles**

```bash
npm run build 2>&1 | grep -i "MyceliumCover" | head -10
```

Expected: no errors referencing `MyceliumCover.astro`. (Page-level errors persist until later tasks.)

- [ ] **Step 5: Commit**

```bash
but stage src/components/MyceliumCover.astro blog-fe-redesign
but stage scripts/verify-mycelium.mjs blog-fe-redesign
but commit blog-fe-redesign --only -m "components: MyceliumCover — deterministic procedural svg cover + verify script"
```

---

## Task 9: TLDR component restyle

**Files:**
- Modify: `src/components/TLDR.astro`

The current TLDR uses a regex-based markdown-to-html converter and a Tailwind-styled box. Restyle the box to match the spec — `▙ TRANSMISSION` label, aquamarine left border, soft aqua bg.

- [ ] **Step 1: Replace `src/components/TLDR.astro`**

```astro
---
// src/components/TLDR.astro
interface Props {
  content: string
}
const { content } = Astro.props

function markdownToHtml(markdown: string): string {
  return markdown
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/^- (.*$)/gim, '<li>$1</li>')
    .replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')
    .replace(/\n\n/g, '</p><p>')
    .replace(/^(.*)$/gm, '<p>$1</p>')
    .replace(/<p><\/p>/g, '')
    .replace(/<p><ul>/g, '<ul>')
    .replace(/<\/ul><\/p>/g, '</ul>')
}

const htmlContent = markdownToHtml(content)
---

<aside class="tldr">
  <div class="label">▙ TRANSMISSION</div>
  <div class="body" set:html={htmlContent} />
</aside>

<style>
  .tldr {
    background: rgba(127, 255, 212, 0.05);
    border-left: 2px solid var(--accent-1);
    padding: 0.75rem 1rem;
    margin: 0 0 1.25rem;
    color: var(--text);
  }
  .label {
    color: var(--accent-1);
    font-size: 0.625rem;
    letter-spacing: 0.28em;
    text-transform: uppercase;
    margin-bottom: 0.5rem;
  }
  .body { font-size: 0.95rem; line-height: 1.65; }
  .body :global(p) { margin: 0.4rem 0; }
  .body :global(p:first-child) { margin-top: 0; }
  .body :global(p:last-child) { margin-bottom: 0; }
  .body :global(strong) { color: var(--accent-1); font-weight: 700; }
  .body :global(em) { color: var(--accent-1); font-style: italic; }
  .body :global(ul) { padding-left: 1.2rem; margin: 0.4rem 0; }
  .body :global(li) { margin: 0.2rem 0; }
  .body :global(li::marker) { color: var(--accent-1); }
</style>
```

- [ ] **Step 2: Verify**

```bash
npm run astro check 2>&1 | grep -i "TLDR.astro" | head -5
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
but stage src/components/TLDR.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "tldr: restyle as transmission box"
```

---

## Task 10: TableOfContents restyle

**Files:**
- Modify: `src/components/TableOfContents.astro`
- Read & possibly modify: `src/components/TableOfContentsHeading.astro`

Current TOC is a 98-line heading-tree component. Replace with a clean sticky outline matching the spec — `▙ NAV` label, active state with 2px aqua left border.

- [ ] **Step 1: Read the current files** to understand the existing data model

```bash
cat src/components/TableOfContents.astro
cat src/components/TableOfContentsHeading.astro
```

The component is given `headings` (Astro markdown headings), filters to depths 2/3, and recursively renders the tree.

- [ ] **Step 2: Replace `src/components/TableOfContents.astro`**

```astro
---
// src/components/TableOfContents.astro
import type { MarkdownHeading } from 'astro'

interface Props {
  headings: MarkdownHeading[]
}
const { headings } = Astro.props
const filtered = headings.filter((h) => h.depth >= 2 && h.depth <= 3)
---

{filtered.length > 0 && (
  <nav class="toc" aria-label="Table of contents">
    <div class="label">▙ NAV</div>
    <ul>
      {filtered.map((h) => (
        <li class={h.depth === 2 ? 'h2' : 'h3'}>
          <a href={`#${h.slug}`}>{h.text}</a>
        </li>
      ))}
    </ul>
  </nav>
)}

<style>
  .toc {
    border-left: 1px solid var(--border);
    padding: 0 0 0 0.75rem;
    font-size: 0.7rem;
    position: sticky;
    top: 1.25rem;
    align-self: flex-start;
    max-height: calc(100vh - 2.5rem);
    overflow-y: auto;
    scrollbar-width: thin;
  }
  .label {
    color: var(--accent-3);
    letter-spacing: 0.2em;
    margin-bottom: 0.75rem;
    font-size: 0.625rem;
    text-transform: uppercase;
  }
  ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }
  li {
    padding: 0.2rem 0;
    line-height: 1.4;
  }
  li.h3 {
    padding-left: 0.85rem;
    font-size: 0.65rem;
    opacity: 0.78;
  }
  li a {
    color: var(--muted);
    text-decoration: none;
    transition: color 0.2s ease-out, padding-left 0.2s ease-out, border-color 0.2s ease-out;
    display: block;
  }
  li a:hover {
    color: var(--text);
    padding-left: 0.25rem;
  }
  li a.active {
    color: var(--accent-1);
    padding-left: 0.4rem;
    border-left: 2px solid var(--accent-1);
    margin-left: -0.85rem;
  }
</style>

<script>
  // Highlight the TOC item closest to the top of the viewport
  const links = document.querySelectorAll<HTMLAnchorElement>('.toc a')
  const headingMap = new Map<string, HTMLAnchorElement>()
  for (const link of links) {
    const id = link.getAttribute('href')?.slice(1)
    if (id) headingMap.set(id, link)
  }

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        const id = entry.target.id
        const link = headingMap.get(id)
        if (!link) continue
        if (entry.isIntersecting) {
          links.forEach((l) => l.classList.remove('active'))
          link.classList.add('active')
        }
      }
    },
    { rootMargin: '0px 0px -75% 0px', threshold: 0 },
  )

  for (const id of headingMap.keys()) {
    const el = document.getElementById(id)
    if (el) observer.observe(el)
  }
</script>
```

- [ ] **Step 3: Delete `src/components/TableOfContentsHeading.astro`** (no longer used by the new flat TOC)

```bash
rm src/components/TableOfContentsHeading.astro
```

If the file is imported anywhere else, the TypeScript check will catch it. Run:

```bash
grep -rn "TableOfContentsHeading" src/ 2>&1 | head -5
```

Expected: no results (or only the just-deleted file showing in editor cache). If the new TableOfContents.astro still has an import for it, remove that line.

- [ ] **Step 4: Build and verify**

```bash
npm run astro check 2>&1 | grep -E "TableOfContents" | head -10
```

Expected: no errors referencing the TOC files.

- [ ] **Step 5: Commit**

```bash
but stage src/components/TableOfContents.astro blog-fe-redesign
but stage src/components/TableOfContentsHeading.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "toc: flat sticky outline with intersection-observer active state, drop nested heading component"
```

---

## Task 11: PostPreview + PostPreviewsWithYear restyle

**Files:**
- Modify: `src/components/PostPreview.astro`
- Modify: `src/components/PostPreviewsWithYear.astro`

`PostPreview` becomes a feed-entry row (timestamp · title+tags · arrow). `PostPreviewsWithYear` adds year separators in the `▙ 2026` style.

- [ ] **Step 1: Replace `src/components/PostPreview.astro`**

```astro
---
// src/components/PostPreview.astro
import type { CollectionEntry } from 'astro:content'
import { dateString } from '@utils'

interface Props {
  post: CollectionEntry<'posts'>
}
const { post } = Astro.props
const { title, published, tags } = post.data
---

<a href={`/posts/${post.id}`} class="entry">
  <time class="time" datetime={published.toISOString()}>{dateString(published)}</time>
  <div class="middle">
    <div class="title">{title}</div>
    {tags && tags.length > 0 && (
      <div class="tags">
        {tags.slice(0, 3).map((t: string) => (
          <span class="tag">#{t.toLowerCase()}</span>
        ))}
      </div>
    )}
  </div>
  <span class="arrow">→</span>
</a>

<style>
  .entry {
    display: grid;
    grid-template-columns: 110px 1fr auto;
    gap: 1.125rem;
    padding: 0.75rem 0;
    border-bottom: 1px dashed rgba(21, 40, 64, 0.7);
    align-items: baseline;
    color: var(--text);
    text-decoration: none;
    transition: padding-left 0.2s ease-out;
  }
  .entry:hover { padding-left: 0.4rem; }
  .entry:hover .title {
    color: var(--accent-1);
    text-shadow: 0 0 6px var(--glow-aqua);
  }
  .time {
    color: var(--accent-2);
    font-size: 0.7rem;
    letter-spacing: 0.05em;
    white-space: nowrap;
  }
  .middle { min-width: 0; }
  .title {
    color: var(--text);
    font-size: 0.875rem;
    transition: color 0.2s ease-out, text-shadow 0.2s ease-out;
    line-height: 1.4;
  }
  .tags {
    margin-top: 0.25rem;
    display: flex;
    gap: 0.3rem;
    flex-wrap: wrap;
  }
  .tag {
    display: inline-block;
    padding: 1px 7px;
    border: 1px solid var(--border);
    color: var(--accent-2);
    font-size: 0.625rem;
    letter-spacing: 0.08em;
  }
  .arrow {
    color: var(--accent-3);
    font-size: 0.875rem;
  }

  @media (max-width: 640px) {
    .entry { grid-template-columns: 1fr auto; }
    .time { grid-column: 1 / -1; font-size: 0.65rem; opacity: 0.85; }
  }
</style>
```

- [ ] **Step 2: Replace `src/components/PostPreviewsWithYear.astro`**

```astro
---
// src/components/PostPreviewsWithYear.astro
import type { CollectionEntry } from 'astro:content'
import PostPreview from './PostPreview.astro'

interface Props {
  posts: CollectionEntry<'posts'>[]
}
const { posts } = Astro.props

// Group posts by year, preserving the order of the input array (assumed
// sorted descending by date).
const groups: { year: number; posts: CollectionEntry<'posts'>[] }[] = []
for (const p of posts) {
  const y = p.data.published.getFullYear()
  const last = groups[groups.length - 1]
  if (last && last.year === y) last.posts.push(p)
  else groups.push({ year: y, posts: [p] })
}
---

<div class="year-feed">
  {groups.map((g) => (
    <section class="year-block">
      <h2 class="year-label">▙ {g.year}</h2>
      {g.posts.map((p) => <PostPreview post={p} />)}
    </section>
  ))}
</div>

<style>
  .year-block { margin-top: 2rem; }
  .year-block:first-child { margin-top: 0; }
  .year-label {
    color: var(--accent-3);
    font-size: 0.7rem;
    letter-spacing: 0.28em;
    text-transform: uppercase;
    border-top: 1px dashed var(--border);
    padding-top: 1rem;
    margin: 0 0 0.75rem;
    font-family: var(--font-body);
    font-weight: 400;
  }
</style>
```

- [ ] **Step 3: Verify**

```bash
npm run astro check 2>&1 | grep -E "PostPreview|PostPreviewsWithYear" | head -10
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
but stage src/components/PostPreview.astro blog-fe-redesign
but stage src/components/PostPreviewsWithYear.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "post-preview: feed entry row + year separator restyle"
```

---

## Task 12: Pagination + Search restyle

**Files:**
- Modify: `src/components/Pagination.astro`
- Modify: `src/components/Search.astro`

- [ ] **Step 1: Read existing pagination**

```bash
cat src/components/Pagination.astro
```

The current pagination accepts props for `nextLink` / `nextText` / `prevLink` / `prevText`. Keep the API.

- [ ] **Step 2: Replace `src/components/Pagination.astro`**

```astro
---
// src/components/Pagination.astro
interface Props {
  prevLink?: string
  prevText?: string
  nextLink?: string
  nextText?: string
}
const { prevLink, prevText, nextLink, nextText } = Astro.props
---

{(prevLink || nextLink) && (
  <nav class="pagination" aria-label="Pagination">
    <div class="slot">
      {prevLink && (
        <a href={prevLink} class="page-link prev">
          <span class="label">← previous</span>
          <span class="text">{prevText ?? 'older'}</span>
        </a>
      )}
    </div>
    <div class="slot right">
      {nextLink && (
        <a href={nextLink} class="page-link next">
          <span class="label">next →</span>
          <span class="text">{nextText ?? 'newer'}</span>
        </a>
      )}
    </div>
  </nav>
)}

<style>
  .pagination {
    margin-top: 2rem;
    padding-top: 1rem;
    border-top: 1px dashed var(--border);
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
  }
  .slot.right { text-align: right; }
  .page-link {
    display: inline-block;
    padding: 0.5rem 0.85rem;
    background: rgba(10, 24, 40, 0.5);
    border: 1px solid var(--border);
    text-decoration: none;
    color: var(--text);
    clip-path: polygon(8px 0%, 100% 0%, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0% 100%, 0% 8px);
    transition: border-color 0.2s ease-out;
  }
  .page-link:hover { border-color: var(--accent-2); }
  .page-link .label {
    display: block;
    color: var(--accent-3);
    font-size: 0.625rem;
    letter-spacing: 0.25em;
    text-transform: uppercase;
  }
  .page-link .text {
    display: block;
    margin-top: 0.25rem;
    font-size: 0.85rem;
    color: var(--text);
  }
</style>
```

- [ ] **Step 3: Read the current Search component**

```bash
cat src/components/Search.astro | head -50
```

Search renders Pagefind's UI in a modal. Keep the modal mechanics; restyle the button trigger and the modal chrome.

- [ ] **Step 4: Update `src/components/Search.astro`** — adjust ONLY the styles, leave the script logic alone

Open `src/components/Search.astro`. Find the `<style>` block (or inline classes) and replace any color/font references that touched the old `--theme-*` system with the new tokens. Specifically:

- Replace `text-accent` → `color: var(--accent-2)`
- Replace `bg-background` → `background: var(--bg)`
- Replace `text-foreground` → `color: var(--text)`
- Replace `border-accent` → `border-color: var(--accent-2)`
- Replace `bg-foreground/X` (any opacity) → `background: var(--panel)` or a `rgba(127,255,212,0.X)` glow tint as appropriate

Wrap any panel/modal containers with the cyber-clip util:

```html
<!-- Where the current Search renders the modal panel, add: -->
<div class="search-modal clip-md">
  <!-- existing search panel content -->
</div>
```

Add this CSS in the component's `<style>` block (or replace the existing block):

```css
.search-trigger {
  background: transparent;
  color: var(--muted);
  border: none;
  font-size: 0.75rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  cursor: pointer;
  transition: color 0.2s ease-out;
}
.search-trigger:hover { color: var(--accent-2); }

.search-modal {
  background: var(--panel);
  border: 1px solid var(--border-strong);
  color: var(--text);
}
.search-modal :global(.pagefind-ui__search-input) {
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--text);
  font-family: var(--font-body);
}
.search-modal :global(.pagefind-ui__result-link) {
  color: var(--accent-1);
  text-decoration: none;
}
.search-modal :global(.pagefind-ui__result-link:hover) {
  text-shadow: 0 0 6px var(--glow-aqua);
}
.search-modal :global(.pagefind-ui__result-excerpt) { color: var(--muted); }
```

If the existing template uses a `<button>` with classes for the trigger, change the class to `search-trigger` and the visible text to `search`.

- [ ] **Step 5: Verify**

```bash
npm run astro check 2>&1 | grep -iE "Pagination|Search" | head -10
```

Expected: no errors.

- [ ] **Step 6: Commit**

```bash
but stage src/components/Pagination.astro blog-fe-redesign
but stage src/components/Search.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "components: pagination cards + pagefind search restyle"
```

---

## Task 13: Homepage — HomeHero + index.astro

**Files:**
- Create: `src/components/HomeHero.astro`
- Modify: `src/pages/index.astro` (replaces existing 38-line file)
- Modify: `src/components/HomeBanner.astro` (slim down)

- [ ] **Step 1: Create `src/components/HomeHero.astro`**

```astro
---
// src/components/HomeHero.astro
import siteConfig from '../site.config'

interface Props {
  postCount: number
  tagCount: number
  subtitle?: string
}
const { postCount, tagCount, subtitle } = Astro.props
const sub = subtitle || siteConfig.description
---

<section class="hero">
  <div class="label">▙ RECENT TRANSMISSIONS</div>
  <h1 class="title">{siteConfig.title.toLowerCase()}</h1>
  {sub && <p class="sub">{sub}</p>}
  <div class="stats">
    <span><span class="k">TRANSMISSIONS</span><span class="v">{postCount}</span></span>
    <span><span class="k">TAGS</span><span class="v">{tagCount}</span></span>
    <span><span class="k">SIGNAL</span><span class="v">STRONG</span></span>
  </div>
</section>

<style>
  .hero {
    padding: 2rem 0 1.5rem;
    border-bottom: 1px solid var(--border);
    margin-bottom: 1.25rem;
  }
  .label {
    color: var(--accent-3);
    font-size: 0.625rem;
    letter-spacing: 0.3em;
    text-transform: uppercase;
  }
  .title {
    font-family: var(--font-display);
    font-size: 2.25rem;
    line-height: 1.05;
    letter-spacing: 0.04em;
    color: var(--accent-1);
    text-shadow: 0 0 10px var(--glow-aqua), 0 0 28px var(--glow-aqua-soft);
    margin: 0.6rem 0 0.4rem;
    font-weight: 400;
  }
  .sub {
    color: var(--text);
    opacity: 0.8;
    font-size: 0.85rem;
    max-width: 70%;
    line-height: 1.6;
    margin: 0;
  }
  .stats {
    display: flex;
    gap: 2rem;
    margin-top: 1.4rem;
    color: var(--accent-2);
    font-size: 0.625rem;
    letter-spacing: 0.22em;
    flex-wrap: wrap;
  }
  .stats .k { color: var(--accent-2); }
  .stats .v { color: var(--accent-3); margin-left: 0.4rem; }

  @media (max-width: 640px) {
    .title { font-size: 1.75rem; }
    .sub { max-width: 100%; }
  }
</style>
```

- [ ] **Step 2: Replace `src/pages/index.astro`**

```astro
---
// src/pages/index.astro
import Layout from '@layouts/Layout.astro'
import { getSortedPosts } from '@utils'
import { getCollection, render } from 'astro:content'
import PostPreview from '@components/PostPreview.astro'
import HomeHero from '@components/HomeHero.astro'
import siteConfig from '../site.config'

const home = await getCollection('home')
const homeEntry = home[0]
const subtitle =
  (homeEntry?.data as { subtitle?: string } | undefined)?.subtitle ??
  siteConfig.description

const sortedPosts = await getSortedPosts()
const recentPosts = sortedPosts.slice(0, siteConfig.pageSize)

// All-time counts for the hero
const tagSet = new Set<string>()
for (const p of sortedPosts) {
  for (const t of (p.data.tags ?? []) as string[]) tagSet.add(t.toLowerCase())
}
---

<Layout>
  <HomeHero postCount={sortedPosts.length} tagCount={tagSet.size} subtitle={subtitle} />
  <section class="feed">
    {recentPosts.map((post) => <PostPreview post={post} />)}
  </section>
  <a href="/posts" class="all-link">▶ ALL TRANSMISSIONS</a>
</Layout>

<style>
  .feed { margin-bottom: 1rem; }
  .all-link {
    display: block;
    text-align: center;
    color: var(--accent-3);
    font-size: 0.7rem;
    letter-spacing: 0.3em;
    text-transform: uppercase;
    padding: 0.85rem 1rem;
    margin-top: 1rem;
    border: 1px dashed var(--border);
    text-decoration: none;
    clip-path: polygon(8px 0%, 100% 0%, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0% 100%, 0% 8px);
    transition: border-color 0.2s ease-out, color 0.2s ease-out;
  }
  .all-link:hover { border-color: var(--accent-3); color: var(--text); }
</style>
```

- [ ] **Step 3: Slim `src/components/HomeBanner.astro`** to a no-op stub (keeping the file present for any third-party reference, marked deprecated). Or delete it. Simpler: delete.

Verify nothing else imports it:

```bash
grep -rn "HomeBanner" src/ 2>&1 | head -5
```

Expected: only `index.astro` (which no longer imports it after Step 2). If clean, delete:

```bash
rm src/components/HomeBanner.astro
```

- [ ] **Step 4: Build the site and visit the homepage**

```bash
npm run build 2>&1 | tail -20
npm run dev &
sleep 3
curl -s http://localhost:4321/ | grep -E "RECENT TRANSMISSIONS|async adventures" | head -5
kill %1
```

Expected: `RECENT TRANSMISSIONS` and `async adventures` appear in the rendered HTML.

(Some pages — post detail, archive, etc. — will still error at this point. That's expected; they're handled in Tasks 14+. The homepage itself must render.)

- [ ] **Step 5: Commit**

```bash
but stage src/components/HomeHero.astro blog-fe-redesign
but stage src/components/HomeBanner.astro blog-fe-redesign
but stage src/pages/index.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "home: HomeHero + recent transmissions feed, drop HomeBanner"
```

---

## Task 14: Post detail — `[slug].astro` rewrite

**Files:**
- Modify: `src/pages/posts/[slug].astro` (full rewrite)

The new post detail uses StatusBar (from Layout) + a Field Note header strip + cover (real image OR MyceliumCover) + title block + 2-column content grid (TOC + prose) + Pagination as prev/next.

- [ ] **Step 1: Rewrite `src/pages/posts/[slug].astro`**

```astro
---
// src/pages/posts/[slug].astro
import type { GetStaticPaths } from 'astro'
import Layout from '@layouts/Layout.astro'
import { dateString, getSortedPosts } from '@utils'
import { getCollection, render } from 'astro:content'
import TableOfContents from '@components/TableOfContents.astro'
import TLDR from '@components/TLDR.astro'
import MyceliumCover from '@components/MyceliumCover.astro'
import { Image } from 'astro:assets'

export const getStaticPaths = (async () => {
  const posts = await getSortedPosts()
  return posts.map((post, index) => {
    const validPrev = index > 0
    const validNext = index < posts.length - 1
    return {
      params: { slug: post.id },
      props: {
        post,
        prev: validPrev ? posts[index - 1] : undefined,
        next: validNext ? posts[index + 1] : undefined,
      },
    }
  })
}) satisfies GetStaticPaths

const { post, prev, next } = Astro.props
const postData = post.data
const { headings, Content: PostContent, remarkPluginFrontmatter } = await render(post)
const readingTime: string =
  (remarkPluginFrontmatter as { minutesRead?: string } | undefined)?.minutesRead ?? '?'
const readingMin = parseInt(String(readingTime).match(/\d+/)?.[0] ?? '?', 10) || readingTime
---

<Layout
  title={postData.title}
  description={postData.description}
  author={postData.author}
  tags={postData.tags as string[] | undefined}
>
  <article data-pagefind-body>
    <div class="header-strip">
      <span class="label">▙ FIELD NOTE&nbsp;<span class="sep">//</span> <span class="value">{readingMin} MIN</span></span>
    </div>

    <div class="cover-wrap clip-md">
      <span class="corner tl"></span><span class="corner tr"></span>
      <span class="corner bl"></span><span class="corner br"></span>
      {postData.coverImage ? (
        <Image src={postData.coverImage.src} alt={postData.coverImage.alt} class="cover-img" />
      ) : (
        <MyceliumCover slug={post.id} />
      )}
    </div>

    <div class="title-block">
      <h1 class="title">{postData.title.toLowerCase()}</h1>
      <div class="meta-row">
        <span>{dateString(postData.published)}</span>
        <span class="sep">::</span>
        <span class="author">{(postData.author ?? 'JOHN STEWART').toUpperCase()}</span>
        {postData.tags && postData.tags.length > 0 && (
          <>
            <span class="sep">::</span>
            {(postData.tags as string[]).slice(0, 5).map((t) => (
              <span class="tag">#{t.toLowerCase()}</span>
            ))}
          </>
        )}
      </div>
    </div>

    <div class="content-grid">
      {headings.length > 0 ? <TableOfContents headings={headings} /> : <div />}
      <div class="prose">
        {postData.tldr && <TLDR content={postData.tldr} />}
        <PostContent />
      </div>
    </div>
  </article>

  {(prev || next) && (
    <nav class="prev-next" aria-label="Adjacent posts">
      {prev && (
        <a href={`/posts/${prev.id}`} class="nav-card">
          <span class="nav-label">← PREVIOUS</span>
          <span class="nav-title">{prev.data.title.toLowerCase()}</span>
        </a>
      )}
      <span />
      {next && (
        <a href={`/posts/${next.id}`} class="nav-card next">
          <span class="nav-label">NEXT →</span>
          <span class="nav-title">{next.data.title.toLowerCase()}</span>
        </a>
      )}
    </nav>
  )}
</Layout>

<style>
  article { margin: 0; padding: 0; }

  .header-strip {
    padding: 1rem 0 0.6rem;
    border-bottom: 1px dashed var(--border);
    margin-bottom: 1rem;
  }
  .label {
    color: var(--accent-3);
    font-size: 0.7rem;
    letter-spacing: 0.3em;
    text-transform: uppercase;
  }
  .label .sep { color: var(--border-strong); padding: 0 0.5rem; }
  .label .value { color: var(--text); }

  .cover-wrap {
    height: 200px;
    position: relative;
    overflow: hidden;
    background: var(--panel);
    border: 1px solid var(--border-strong);
    margin-bottom: 1rem;
  }
  .cover-wrap :global(svg),
  .cover-wrap :global(img) {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  .corner {
    position: absolute;
    width: 14px; height: 14px;
    border: 2px solid var(--accent-1);
    z-index: 2;
    filter: drop-shadow(0 0 4px var(--glow-aqua-strong));
  }
  .corner.tl { top: 6px; left: 6px; border-right: none; border-bottom: none; }
  .corner.tr { top: 6px; right: 6px; border-left: none; border-bottom: none; }
  .corner.bl { bottom: 6px; left: 6px; border-right: none; border-top: none; }
  .corner.br { bottom: 6px; right: 6px; border-left: none; border-top: none; }

  .title-block { margin: 1.25rem 0 1rem; }
  .title {
    font-family: var(--font-display);
    font-size: 2rem;
    line-height: 1.1;
    letter-spacing: 0.02em;
    color: var(--accent-1);
    text-shadow: 0 0 10px var(--glow-aqua), 0 0 28px var(--glow-aqua-soft);
    margin: 0;
    font-weight: 400;
  }
  .meta-row {
    color: var(--accent-2);
    font-size: 0.7rem;
    letter-spacing: 0.18em;
    margin-top: 0.85rem;
    display: flex;
    gap: 0.85rem;
    flex-wrap: wrap;
    align-items: center;
  }
  .meta-row .sep { color: var(--border-strong); }
  .meta-row .tag {
    display: inline-block;
    padding: 1px 7px;
    border: 1px solid var(--border);
    color: var(--accent-2);
    font-size: 0.625rem;
    letter-spacing: 0.08em;
  }

  .content-grid {
    display: grid;
    grid-template-columns: 130px 1fr;
    gap: 1.4rem;
    margin-top: 0.5rem;
  }
  @media (max-width: 768px) {
    .content-grid { grid-template-columns: 1fr; }
    .content-grid > :global(.toc) { display: none; }
  }

  .prev-next {
    margin-top: 2rem;
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: 1rem;
    border-top: 1px dashed var(--border);
    padding-top: 1rem;
  }
  .nav-card {
    display: block;
    padding: 0.75rem 1rem;
    background: rgba(10, 24, 40, 0.5);
    border: 1px solid var(--border);
    color: var(--text);
    text-decoration: none;
    clip-path: polygon(8px 0%, 100% 0%, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0% 100%, 0% 8px);
    transition: border-color 0.2s ease-out;
  }
  .nav-card:hover { border-color: var(--accent-2); }
  .nav-card.next { text-align: right; }
  .nav-card .nav-label {
    display: block;
    color: var(--accent-3);
    font-size: 0.625rem;
    letter-spacing: 0.25em;
    text-transform: uppercase;
  }
  .nav-card .nav-title {
    display: block;
    margin-top: 0.3rem;
    color: var(--text);
    font-size: 0.875rem;
    line-height: 1.35;
  }
</style>
```

- [ ] **Step 2: Build and visit a post**

```bash
npm run build 2>&1 | tail -20
npm run dev &
sleep 3
curl -s http://localhost:4321/posts/20260317-automating-subagent-workflow | grep -E "FIELD NOTE|MYCELIUM|automating" | head -5
kill %1
```

Expected: rendered HTML contains `FIELD NOTE`, the post title, and either the cover image or `MYCELIUM-` (procedural fallback). The `addendum` collection (used by old layout) is not referenced — that intentionally drops the addendum panel. If you want addendum back, add it as a separate task; not in scope here.

- [ ] **Step 3: Commit**

```bash
but stage src/pages/posts/[slug].astro blog-fe-redesign
but commit blog-fe-redesign --only -m "post-detail: field-note layout with cover, toc, transmission tldr, nav cards"
```

---

## Task 15: Archive — `[...page].astro` rewrite

**Files:**
- Modify: `src/pages/posts/[...page].astro`

- [ ] **Step 1: Read existing archive**

```bash
cat src/pages/posts/[...page].astro
```

It's a paginated archive using Astro's `paginate()`.

- [ ] **Step 2: Rewrite `src/pages/posts/[...page].astro`**

```astro
---
// src/pages/posts/[...page].astro
import type { GetStaticPaths, Page } from 'astro'
import type { CollectionEntry } from 'astro:content'
import Layout from '@layouts/Layout.astro'
import { getSortedPosts } from '@utils'
import PostPreviewsWithYear from '@components/PostPreviewsWithYear.astro'
import Pagination from '@components/Pagination.astro'
import siteConfig from '../../site.config'

export const getStaticPaths = (async ({ paginate }) => {
  const posts = await getSortedPosts()
  return paginate(posts, { pageSize: siteConfig.pageSize * 2 })
}) satisfies GetStaticPaths

const { page } = Astro.props as { page: Page<CollectionEntry<'posts'>> }
---

<Layout title="All Transmissions">
  <section class="archive-hero">
    <div class="label">▙ ALL TRANSMISSIONS</div>
    <h1 class="title">all transmissions</h1>
    <p class="sub">{page.total} field notes — {page.currentPage} / {page.lastPage}</p>
  </section>

  <PostPreviewsWithYear posts={page.data} />

  <Pagination
    prevLink={page.url.prev}
    prevText={page.currentPage === 2 ? 'home' : `page ${page.currentPage - 1}`}
    nextLink={page.url.next}
    nextText={page.currentPage < page.lastPage ? `page ${page.currentPage + 1}` : undefined}
  />
</Layout>

<style>
  .archive-hero {
    padding: 2rem 0 1.25rem;
    border-bottom: 1px solid var(--border);
    margin-bottom: 1.25rem;
  }
  .label {
    color: var(--accent-3);
    font-size: 0.625rem;
    letter-spacing: 0.3em;
    text-transform: uppercase;
  }
  .title {
    font-family: var(--font-display);
    font-size: 2rem;
    line-height: 1.05;
    letter-spacing: 0.04em;
    color: var(--accent-1);
    text-shadow: 0 0 10px var(--glow-aqua), 0 0 28px var(--glow-aqua-soft);
    margin: 0.5rem 0 0.4rem;
    font-weight: 400;
  }
  .sub {
    color: var(--accent-2);
    font-size: 0.7rem;
    letter-spacing: 0.18em;
    margin: 0;
  }
</style>
```

- [ ] **Step 3: Build and visit**

```bash
npm run build 2>&1 | tail -10
npm run dev &
sleep 3
curl -s http://localhost:4321/posts | grep -E "ALL TRANSMISSIONS|2026|2025" | head -5
kill %1
```

Expected: `ALL TRANSMISSIONS` heading + at least one year separator visible.

- [ ] **Step 4: Commit**

```bash
but stage src/pages/posts/[...page].astro blog-fe-redesign
but commit blog-fe-redesign --only -m "archive: all-transmissions hero + year-grouped feed + pagination"
```

---

## Task 16: Tags index (NEW) + per-tag page

**Files:**
- Create: `src/components/FrequencyBar.astro`
- Create: `src/pages/tags/index.astro`
- Modify: `src/pages/tags/[tag]/[...page].astro`

- [ ] **Step 1: Create `src/components/FrequencyBar.astro`**

```astro
---
// src/components/FrequencyBar.astro
interface Props {
  tag: string
  count: number
  max: number
}
const { tag, count, max } = Astro.props
const pct = max > 0 ? Math.max(8, Math.round((count / max) * 100)) : 0
---

<a href={`/tags/${tag.toLowerCase()}`} class="freq-row">
  <span class="ftag">#{tag.toLowerCase()}</span>
  <span class="bar"><span class="fill" style={`width:${pct}%`}></span></span>
  <span class="count">{count}</span>
</a>

<style>
  .freq-row {
    display: grid;
    grid-template-columns: 140px 1fr 36px;
    gap: 0.85rem;
    align-items: center;
    padding: 0.45rem 0;
    text-decoration: none;
    border-bottom: 1px dashed rgba(21, 40, 64, 0.5);
    font-size: 0.75rem;
    letter-spacing: 0.05em;
    transition: padding-left 0.2s ease-out;
  }
  .freq-row:hover { padding-left: 0.4rem; }
  .freq-row:hover .fill {
    box-shadow: 0 0 10px var(--glow-aqua);
  }
  .ftag { color: var(--accent-2); }
  .bar {
    height: 4px;
    background: rgba(94, 200, 255, 0.1);
    position: relative;
    display: block;
  }
  .fill {
    display: block;
    height: 100%;
    background: linear-gradient(90deg, var(--accent-1), var(--accent-2));
    box-shadow: 0 0 6px var(--glow-aqua-soft);
    transition: box-shadow 0.2s ease-out;
  }
  .count {
    color: var(--muted);
    font-size: 0.625rem;
    text-align: right;
  }
</style>
```

- [ ] **Step 2: Create `src/pages/tags/index.astro`**

```astro
---
// src/pages/tags/index.astro
import Layout from '@layouts/Layout.astro'
import { getCollection } from 'astro:content'
import FrequencyBar from '@components/FrequencyBar.astro'

const posts = await getCollection('posts')
const counts = new Map<string, number>()
for (const p of posts) {
  for (const t of (p.data.tags ?? []) as string[]) {
    const key = t.toLowerCase()
    counts.set(key, (counts.get(key) ?? 0) + 1)
  }
}
const entries = Array.from(counts.entries())
  .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
const max = entries.reduce((m, [, c]) => Math.max(m, c), 0)
---

<Layout title="Tags · Frequencies">
  <section class="tags-hero">
    <div class="label">▙ FREQUENCIES</div>
    <h1 class="title">tags</h1>
    <p class="sub">{entries.length} tags across {posts.length} transmissions</p>
  </section>

  <section class="freq-list">
    {entries.map(([tag, count]) => (
      <FrequencyBar tag={tag} count={count} max={max} />
    ))}
  </section>
</Layout>

<style>
  .tags-hero {
    padding: 2rem 0 1.25rem;
    border-bottom: 1px solid var(--border);
    margin-bottom: 1rem;
  }
  .label {
    color: var(--accent-3);
    font-size: 0.625rem;
    letter-spacing: 0.3em;
    text-transform: uppercase;
  }
  .title {
    font-family: var(--font-display);
    font-size: 2rem;
    line-height: 1.05;
    letter-spacing: 0.04em;
    color: var(--accent-1);
    text-shadow: 0 0 10px var(--glow-aqua), 0 0 28px var(--glow-aqua-soft);
    margin: 0.5rem 0 0.4rem;
    font-weight: 400;
  }
  .sub {
    color: var(--accent-2);
    font-size: 0.7rem;
    letter-spacing: 0.18em;
    margin: 0;
  }
  .freq-list { margin-top: 0.5rem; }
</style>
```

- [ ] **Step 3: Read the per-tag page**

```bash
cat src/pages/tags/[tag]/[...page].astro
```

Note its current props/imports.

- [ ] **Step 4: Rewrite `src/pages/tags/[tag]/[...page].astro`**

```astro
---
// src/pages/tags/[tag]/[...page].astro
import type { GetStaticPaths, Page } from 'astro'
import type { CollectionEntry } from 'astro:content'
import Layout from '@layouts/Layout.astro'
import { getSortedPosts } from '@utils'
import PostPreview from '@components/PostPreview.astro'
import Pagination from '@components/Pagination.astro'
import siteConfig from '../../../site.config'

export const getStaticPaths = (async ({ paginate }) => {
  const allPosts = await getSortedPosts()
  const tagSet = new Set<string>()
  for (const p of allPosts) {
    for (const t of (p.data.tags ?? []) as string[]) tagSet.add(t.toLowerCase())
  }
  return Array.from(tagSet).flatMap((tag) => {
    const tagPosts = allPosts.filter((p) =>
      (p.data.tags ?? []).map((t: string) => t.toLowerCase()).includes(tag),
    )
    return paginate(tagPosts, {
      params: { tag },
      pageSize: siteConfig.pageSize * 2,
      props: { tag, totalForTag: tagPosts.length },
    })
  })
}) satisfies GetStaticPaths

interface ExtraProps { tag: string; totalForTag: number }
const { page } = Astro.props as { page: Page<CollectionEntry<'posts'>> }
const { tag, totalForTag } = Astro.props as unknown as ExtraProps
---

<Layout title={`#${tag} · Tag`}>
  <section class="tag-hero">
    <div class="label">▙ TAG · #{tag}</div>
    <h1 class="title">#{tag}</h1>
    <p class="sub">{totalForTag} transmission{totalForTag === 1 ? '' : 's'}</p>
  </section>

  <section class="feed">
    {page.data.map((p) => <PostPreview post={p} />)}
  </section>

  <Pagination
    prevLink={page.url.prev}
    prevText={page.currentPage === 2 ? 'first page' : `page ${page.currentPage - 1}`}
    nextLink={page.url.next}
    nextText={page.currentPage < page.lastPage ? `page ${page.currentPage + 1}` : undefined}
  />
</Layout>

<style>
  .tag-hero {
    padding: 2rem 0 1.25rem;
    border-bottom: 1px solid var(--border);
    margin-bottom: 1rem;
  }
  .label {
    color: var(--accent-3);
    font-size: 0.625rem;
    letter-spacing: 0.3em;
    text-transform: uppercase;
  }
  .title {
    font-family: var(--font-display);
    font-size: 2rem;
    line-height: 1.05;
    letter-spacing: 0.04em;
    color: var(--accent-1);
    text-shadow: 0 0 10px var(--glow-aqua), 0 0 28px var(--glow-aqua-soft);
    margin: 0.5rem 0 0.4rem;
    font-weight: 400;
  }
  .sub {
    color: var(--accent-2);
    font-size: 0.7rem;
    letter-spacing: 0.18em;
    margin: 0;
  }
</style>
```

- [ ] **Step 5: Build and verify both pages**

```bash
npm run build 2>&1 | tail -15
npm run dev &
sleep 3
curl -s http://localhost:4321/tags | grep -E "FREQUENCIES|tags" | head -5
curl -s http://localhost:4321/tags/typescript 2>/dev/null | grep -E "TAG|typescript" | head -5
kill %1
```

Expected: tags index renders the `FREQUENCIES` heading; per-tag page (if `typescript` is a tag in the corpus) renders `TAG · #typescript`. Substitute another known tag if `typescript` doesn't exist yet — check available tags via `grep -h "tags:" src/content/posts/*.md | sort -u | head`.

- [ ] **Step 6: Commit**

```bash
but stage src/components/FrequencyBar.astro blog-fe-redesign
but stage src/pages/tags/index.astro blog-fe-redesign
but stage src/pages/tags/[tag]/[...page].astro blog-fe-redesign
but commit blog-fe-redesign --only -m "tags: frequencies index page + per-tag feed restyle"
```

---

## Task 17: 404 page

**Files:**
- Modify: `src/pages/404.astro` (full rewrite)

- [ ] **Step 1: Replace `src/pages/404.astro`**

```astro
---
// src/pages/404.astro
import Layout from '@layouts/Layout.astro'
---

<Layout title="No Transmission">
  <section class="lost">
    <div class="label">▙ NO TRANSMISSION</div>
    <h1 class="big">404</h1>
    <p class="msg">The signal didn't reach this page. Try returning to the surface.</p>
    <a href="/" class="surface-link">▶ RETURN TO SURFACE</a>
  </section>
</Layout>

<style>
  .lost {
    padding: 4rem 0 5rem;
    text-align: center;
  }
  .label {
    color: var(--accent-3);
    font-size: 0.7rem;
    letter-spacing: 0.32em;
    text-transform: uppercase;
  }
  .big {
    font-family: var(--font-display);
    font-size: 5.5rem;
    line-height: 1;
    color: var(--accent-1);
    text-shadow:
      0 0 12px var(--glow-aqua-strong),
      0 0 36px var(--glow-aqua),
      0 0 72px var(--glow-aqua-soft);
    margin: 1rem 0 1.25rem;
    font-weight: 400;
    letter-spacing: 0.05em;
  }
  .msg {
    color: var(--text);
    opacity: 0.85;
    font-size: 0.9rem;
    max-width: 32rem;
    margin: 0 auto 2rem;
    line-height: 1.6;
  }
  .surface-link {
    display: inline-block;
    padding: 0.65rem 1.25rem;
    color: var(--accent-3);
    font-size: 0.7rem;
    letter-spacing: 0.3em;
    text-transform: uppercase;
    text-decoration: none;
    border: 1px solid var(--border);
    background: rgba(10, 24, 40, 0.5);
    clip-path: polygon(8px 0%, 100% 0%, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0% 100%, 0% 8px);
    transition: border-color 0.2s ease-out, color 0.2s ease-out;
  }
  .surface-link:hover { border-color: var(--accent-2); color: var(--accent-1); }
</style>
```

- [ ] **Step 2: Build and visit**

```bash
npm run build 2>&1 | tail -10
npm run dev &
sleep 3
curl -s http://localhost:4321/this-page-does-not-exist 2>/dev/null | grep -E "NO TRANSMISSION|404|RETURN TO SURFACE" | head -5
kill %1
```

Expected: NO TRANSMISSION + 404 + RETURN TO SURFACE all appear.

- [ ] **Step 3: Commit**

```bash
but stage src/pages/404.astro blog-fe-redesign
but commit blog-fe-redesign --only -m "404: signal-lost page"
```

---

## Task 18: Cleanup — remove dead theme components + ReactGithubCalendar

**Files (delete):**
- `src/components/SelectTheme.astro`
- `src/components/SelectThemeLoader.astro`
- `src/components/LightDarkAutoButton.astro`
- `src/components/LightDarkAutoThemeLoader.astro`
- `src/components/ReactGithubCalendar.tsx`
- `src/components/TagsSection.astro` (if unused — check)
- `src/components/TagsSidebar.astro` (used by old Layout, gone now)
- `src/components/BlockHeader.astro` (check)
- `src/components/DividerText.astro` (check)
- `src/components/PostAddendum.astro` (used by old [slug].astro — verify unused now)
- `src/components/NavLink.astro` (used by old Header.astro — verify unused now)

Plus `src/utils.ts` cleanup of helpers no longer needed.

- [ ] **Step 1: Check what's still referenced**

```bash
for f in SelectTheme SelectThemeLoader LightDarkAutoButton LightDarkAutoThemeLoader ReactGithubCalendar TagsSection TagsSidebar BlockHeader DividerText PostAddendum NavLink; do
  echo "=== $f ==="
  grep -rn "$f" src/ 2>&1 | grep -v "^src/components/$f\." | head -3
done
```

For any component with no remaining references, it's safe to delete. Components that are still imported somewhere need investigation — usually they're imported by another file in the deletion list (a dead import chain). In that case delete both.

- [ ] **Step 2: Delete safely-orphan components**

```bash
rm src/components/SelectTheme.astro
rm src/components/SelectThemeLoader.astro
rm src/components/LightDarkAutoButton.astro
rm src/components/LightDarkAutoThemeLoader.astro
rm src/components/ReactGithubCalendar.tsx
rm src/components/TagsSection.astro 2>/dev/null || true
rm src/components/TagsSidebar.astro 2>/dev/null || true
rm src/components/PostAddendum.astro 2>/dev/null || true
rm src/components/NavLink.astro 2>/dev/null || true
# Keep DividerText.astro and BlockHeader.astro if a new task wants to repurpose them; else delete after verifying.
```

- [ ] **Step 3: Clean up `src/utils.ts`**

```bash
grep -n "resolveThemeColorStyles\|getTagCounts\|getAllPostTags\|pick\b" src/utils.ts
```

These four helpers were only used by the old Layout. If still defined, remove their definitions. (`getTagCounts` and `getAllPostTags` may still be useful; verify usage. Both are computed inline in the new pages, so can usually go.)

```bash
grep -rn "from '@utils'" src/ --include="*.astro" --include="*.ts" --include="*.tsx" | head -10
grep -rn "resolveThemeColorStyles\|getTagCounts\|getAllPostTags\|^export function pick\|^export const pick" src/ --include="*.ts" | head
```

For each helper: if it has zero remaining import sites in `.astro`/`.ts` files, delete its definition from `utils.ts`. If it still has consumers, leave alone.

- [ ] **Step 4: Verify the build is clean**

```bash
npm run build 2>&1 | tail -25
```

Expected: build completes without errors. Note any "imported but never used" warnings — these are harmless but indicate cleanup leftovers.

- [ ] **Step 5: Commit**

```bash
# Only stage what was actually deleted/modified
but stage src/components/SelectTheme.astro blog-fe-redesign
but stage src/components/SelectThemeLoader.astro blog-fe-redesign
but stage src/components/LightDarkAutoButton.astro blog-fe-redesign
but stage src/components/LightDarkAutoThemeLoader.astro blog-fe-redesign
but stage src/components/ReactGithubCalendar.tsx blog-fe-redesign
# Stage any other deleted files in the same way:
# but stage src/components/<file> blog-fe-redesign
but stage src/utils.ts blog-fe-redesign
but commit blog-fe-redesign --only -m "cleanup: remove dead theme/calendar/sidebar components and stale utils"
```

---

## Task 19: home.md migration (bannerContent → subtitle)

**Files:**
- Modify: `src/content/home.md`
- Modify: `src/content.config.ts` (if the schema needs updating)

- [ ] **Step 1: Read the current home.md and content config**

```bash
cat src/content/home.md
cat src/content.config.ts
```

Current `home.md` frontmatter has `githubCalendar` and `bannerContent`. The new design wants `subtitle`.

- [ ] **Step 2: Update `src/content/home.md`** — rename `bannerContent` to `subtitle`, drop `githubCalendar`

```yaml
---
subtitle: 'Field notes from a software engineer descending into the codebase. Async, agents, distributed systems, and the occasional rust dungeon.'
---
```

(The body of the file remains empty.)

- [ ] **Step 3: Update `src/content.config.ts`** — adjust the `home` collection schema

Open `src/content.config.ts` and find the `home` collection's `schema`. Replace the `bannerContent: z.string().optional()` (and `githubCalendar`, `avatarImage` if present) with `subtitle: z.string().optional()`.

```typescript
// Inside the home collection definition:
schema: z.object({
  subtitle: z.string().optional(),
}),
```

If there are other fields (`avatarImage`, etc.) used by other code paths, leave them — but `index.astro` only reads `subtitle` now.

- [ ] **Step 4: Build**

```bash
npm run build 2>&1 | tail -10
```

Expected: home page renders with the new subtitle copy. Verify by visiting locally.

- [ ] **Step 5: Commit**

```bash
but stage src/content/home.md blog-fe-redesign
but stage src/content.config.ts blog-fe-redesign
but commit blog-fe-redesign --only -m "home content: rename bannerContent → subtitle, drop calendar field"
```

---

## Task 20: Final smoke test + README update

**Files:**
- Modify: `README.md` (light update — site description, no longer mentions theme picker)

This is a verification task — no major code changes, just a build + manual page sweep.

- [ ] **Step 1: Full build**

```bash
npm run build 2>&1 | tee /tmp/final-build.log | tail -30
```

Expected: build completes. `dist/` populated. Pagefind post-build runs and emits index files. No fatal errors.

- [ ] **Step 2: Start the preview server and walk every page type**

```bash
npm run preview &
sleep 3

echo "=== / ==="
curl -s http://localhost:4321/ | grep -cE "RECENT TRANSMISSIONS"
echo "=== /posts ==="
curl -s http://localhost:4321/posts | grep -cE "ALL TRANSMISSIONS"
echo "=== /posts/<slug> ==="
SLUG=$(ls src/content/posts/ | head -1 | sed 's/\.md$//')
curl -s "http://localhost:4321/posts/$SLUG" | grep -cE "FIELD NOTE"
echo "=== /tags ==="
curl -s http://localhost:4321/tags | grep -cE "FREQUENCIES"
echo "=== /404 ==="
curl -s http://localhost:4321/this-does-not-exist | grep -cE "NO TRANSMISSION"

kill %1
```

Expected: every `grep -c` returns `>= 1`. If any returns `0`, that page is broken — open it in a browser and inspect.

- [ ] **Step 3: Visual sweep in a real browser**

```bash
npm run dev &
sleep 3
echo "Now manually open these URLs in your browser:"
echo "  http://localhost:4321/"
echo "  http://localhost:4321/posts"
echo "  http://localhost:4321/posts/$SLUG"
echo "  http://localhost:4321/tags"
echo "  http://localhost:4321/tags/<one-of-your-tags>"
echo "  http://localhost:4321/this-does-not-exist"
echo "Confirm: scanline overlay visible, headings glow aquamarine, code blocks have the new theme, hover states work, no console errors."
echo "Press Ctrl+C when done, then: kill %1"
```

Verify each page checklist:
- [ ] Scanline overlay visible (subtle horizontal lines)
- [ ] Status bar at top with pulse-dot
- [ ] Major Mono Display titles glow aquamarine
- [ ] JetBrains Mono body and UI
- [ ] Code blocks render with custom Shiki colors (cyan keywords, aqua strings, amber functions, muted comments)
- [ ] TLDR box has `▙ TRANSMISSION` label and aqua left border
- [ ] TOC sticky, intersection observer highlights active section
- [ ] Procedural mycelium covers render on posts without `coverImage`
- [ ] Tag frequency bars render correctly
- [ ] 404 has the big neon `404` and a `RETURN TO SURFACE` button
- [ ] Reduced-motion (toggle in OS) disables the pulse-dot animation but keeps everything else visible

- [ ] **Step 4: Update `README.md`**

Open `README.md` and replace the inherited MultiTerm marketing copy with a brief project-accurate intro. Keep the technical setup instructions (clone / install / run / build / deploy). Suggested replacement for the top section (lines ~1–35 in the existing file):

```markdown
# Async Adventures

A coding blog by John Stewart — field notes on async, agents, distributed systems, and the occasional rust dungeon. Built with Astro 5 and a custom **Bioluminescent Abyss** theme: cyberpunk-leaning structure (cyber-clip polygons, scanlines, neon glow) warmed by a deep-sea palette (aquamarine + cyan + firefly amber on a navy abyss bg).

## Stack

- **Astro 5** — static site, prefetch, view transitions
- **Tailwind v4** — via `@tailwindcss/vite`
- **Expressive Code** with the custom `bioluminescent-abyss` Shiki theme
- **Pagefind** — client-side search index, post-build
- **JetBrains Mono Variable** + **Major Mono Display** — typography
- Deterministic procedural SVG covers for posts without `coverImage`

## Run locally
...
```

Keep the existing setup, scripts, and deploy sections below the new intro. Strip the MultiTerm template imagery and the multi-theme feature description (no longer applicable).

- [ ] **Step 5: Commit**

```bash
but stage README.md blog-fe-redesign
but commit blog-fe-redesign --only -m "readme: update for bioluminescent abyss redesign"
```

- [ ] **Step 6: Final status check**

```bash
but status 2>&1 | head -30
```

Expected: `blog-fe-redesign` branch shows ~20 commits ahead of main. `unassigned changes` lane only contains the user's pre-existing in-progress work (drafts, etc.) — nothing from this redesign.

---

## Self-review checklist (run after writing implementation, not part of the task list)

After all 20 tasks are complete, verify against the spec:

- [ ] Every CSS variable from spec's "Palette" table is defined in `global.css` and used somewhere
- [ ] All six "Signature visual language" elements are present (cyber-clip, scanline, neon glow, pulse-dot, corner brackets, `▙` HUD labels)
- [ ] Every page in the spec's "Page designs" section has a corresponding implementation
- [ ] `MyceliumCover` is deterministic (verify-mycelium script passes)
- [ ] Custom Shiki theme is the only theme — no references to old Shiki theme names remain in the build
- [ ] All "Removed files" from the spec's "Files affected" section are actually deleted
- [ ] All "New files" from the spec are actually created
- [ ] `prefers-reduced-motion` disables the pulse-dot
- [ ] The `▙ FIELD NOTE // {minutes} MIN` strip uses real reading time from `remark-reading-time`
- [ ] Procedural cover renders only when `coverImage` frontmatter is missing
- [ ] No leftover references to `siteConfig.themes` anywhere in the codebase
- [ ] No `import` of `@theme` system files (`SelectTheme*`, `LightDarkAuto*`)

Fix any gap inline before opening a PR.
