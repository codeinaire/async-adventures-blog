# Async Adventures

A coding blog by John Stewart — field notes on async, agents, distributed systems, and the occasional rust dungeon. Built with Astro 5 and a custom **Bioluminescent Abyss** theme: cyberpunk-leaning structure (cyber-clip polygons, scanlines, neon glow) warmed by a deep-sea palette (aquamarine + cyan + firefly amber on a navy abyss background).

## Stack

- **Astro 5** — static site, prefetch, view transitions
- **Tailwind v4** — via `@tailwindcss/vite`, custom palette in `src/styles/global.css`
- **Expressive Code** with the custom `bioluminescent-abyss` Shiki theme (`src/styles/themes/bioluminescent-abyss.json`)
- **Pagefind** — client-side search index, post-build
- **JetBrains Mono Variable** + **Major Mono Display** — typography (mono body, geometric display headers)
- Deterministic procedural SVG covers (`src/components/MyceliumCover.astro`) for posts without `coverImage`

## Getting Started

**Install Dependencies**:

```bash
npm install
```

**Start the Development Server**:

```bash
npm run dev
```

**Build Your Site and View the Results**:

```bash
npm run build && npx serve dist
```

## To Deploy

Run `./scripts/deploy-ftp.sh --insecure`

## License

This project is licensed under the [MIT License](LICENSE).
