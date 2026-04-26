#!/usr/bin/env node
import { readFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const manifestPath = resolve(repoRoot, 'workshops.config.json');
const config = JSON.parse(await readFile(manifestPath, 'utf8'));

if (!Array.isArray(config) || config.length === 0) {
  console.error(`No entries in ${manifestPath}`);
  process.exit(1);
}

for (const { dir, title, base, out } of config) {
  const entry = `workshops/${dir}/slides.md`;
  const absOut = resolve(repoRoot, out);
  console.log(`\n=== Building ${title} (${dir}) → ${out} (base ${base}) ===\n`);
  const r = spawnSync(
    'npx',
    ['slidev', 'build', entry, '--base', base, '--out', absOut],
    { cwd: repoRoot, stdio: 'inherit' }
  );
  if (r.status !== 0) {
    console.error(`Build failed for ${dir} (exit ${r.status})`);
    process.exit(r.status ?? 1);
  }
}

console.log('\nAll decks built successfully.');
