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
