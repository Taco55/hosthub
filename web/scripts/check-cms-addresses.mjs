#!/usr/bin/env node
//
// Checks this site's CMS addresses against the console's manifest.
//
// The address `contentType/slug:json.path` is a contract between two codebases
// in two languages: the console derives it from its template, and the page
// carries it in `data-cms-field` so the live preview can patch what the owner
// is typing. Both sides implemented it independently and nothing compared
// them, so they drifted three times in one afternoon — a field the editor
// deleted that PreviewMapPin still listened for, and four fields the editor
// gained that no element carried.
//
// Two directions, both worth failing on:
//
//   stale  — the page addresses something the console does not offer. Whatever
//            listens for it is dead code, silently.
//   unmarked — the console offers a plain text field the page never marks, so
//            focusing it points the preview at nothing. Only checked for
//            fields that are text on their own page (`inPage`) and are not
//            list rows, because those are the ones whose address is fully
//            known here without rendering.
//
// Run: npm run check:cms

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const WEB_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MANIFEST = path.join(WEB_ROOT, "cms-address-manifest.json");

if (!fs.existsSync(MANIFEST)) {
  console.error(
    `Missing ${path.relative(WEB_ROOT, MANIFEST)}. Regenerate it from the console:\n` +
      "  cd ../hosthub_console && UPDATE_CMS_MANIFEST=1 flutter test " +
      "test/features/website_editor/cms_address_manifest_test.dart",
  );
  process.exit(1);
}

const manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
const known = new Set(manifest.fields.map((f) => f.address));
/** Addresses whose row id the page fills in: match on the prefix before `{id}`. */
const listPrefixes = manifest.fields
  .filter((f) => f.isList)
  .map((f) => f.address.slice(0, f.address.indexOf("{id}")));

function* sourceFiles(dir) {
  const full = path.join(WEB_ROOT, dir);
  if (!fs.existsSync(full)) return;
  for (const entry of fs.readdirSync(full, { withFileTypes: true })) {
    const rel = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* sourceFiles(rel);
    else if (/\.(ts|tsx)$/.test(entry.name)) yield rel;
  }
}

/**
 * Addresses the source states outright: a `cmsField`/`cmsFieldAddress` call
 * whose arguments are all string literals. A call carrying a variable segment
 * (a row id, a spread path) is skipped — its address is only known at render
 * time, and guessing would trade a real check for false failures.
 */
const CALL = /cmsField(?:Address)?\(\s*([^)]*?)\s*\)/gs;
const ALL_LITERAL = /^"([^"]+)"(?:\s*,\s*"([^"]+)")*\s*,?$/;

const stale = [];
const seen = new Set();

for (const file of [...sourceFiles("app"), ...sourceFiles("components"), ...sourceFiles("lib")]) {
  const source = fs.readFileSync(path.join(WEB_ROOT, file), "utf8");
  for (const match of source.matchAll(CALL)) {
    const args = match[1].trim();
    if (!ALL_LITERAL.test(args)) continue;
    const parts = [...args.matchAll(/"([^"]+)"/g)].map((m) => m[1]);
    if (parts.length < 2) continue;
    const address = `${parts[0]}:${parts.slice(1).join(".")}`;
    seen.add(address);
    const covered =
      known.has(address) ||
      listPrefixes.some((prefix) => address.startsWith(prefix));
    if (!covered) stale.push({ file, address });
  }
}

// An address may opt out where the page genuinely cannot carry it — the
// contact subtitle is split around a mailto link, so there is no single text
// node to patch. The exemption lives in the source, next to the reason.
const EXEMPT = /cms-address-exempt:\s*([^\s]+)/g;
const exempt = new Set();
for (const file of [
  ...sourceFiles("app"),
  ...sourceFiles("components"),
  ...sourceFiles("lib"),
]) {
  const source = fs.readFileSync(path.join(WEB_ROOT, file), "utf8");
  for (const match of source.matchAll(EXEMPT)) exempt.add(match[1]);
}

const unmarked = manifest.fields
  .filter((f) => !f.isList && f.visibility === "inPage")
  .filter((f) => !seen.has(f.address) && !exempt.has(f.address))
  .map((f) => f.address);

let failed = false;

if (stale.length > 0) {
  failed = true;
  console.error("\nAddresses this site uses that the console does not offer:");
  for (const { file, address } of stale) console.error(`  ${address}  (${file})`);
  console.error("  → the code listening for these is dead; repoint or remove it.");
}

if (unmarked.length > 0) {
  failed = true;
  console.error("\nEditable text fields no element on this site marks:");
  for (const address of unmarked) console.error(`  ${address}`);
  console.error(
    "  → focusing these points the preview at nothing. Add {...cmsField(…)}\n" +
      "    to the element that renders them, or give the field a visibility\n" +
      "    other than inPage if it genuinely is not text on the page.",
  );
}

if (failed) process.exit(1);

console.log(
  `CMS addresses agree: ${seen.size} used, ${manifest.fields.length} offered ` +
    `(template ${manifest.template}).`,
);
