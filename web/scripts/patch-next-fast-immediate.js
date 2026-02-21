const fs = require("node:fs");
const path = require("node:path");

const targets = [
  "node_modules/next/dist/server/node-environment-extensions/fast-set-immediate.external.js",
  "node_modules/next/dist/esm/server/node-environment-extensions/fast-set-immediate.external.js",
];
const reactPaths = [
  "node_modules/next/dist/compiled/react-server-dom-webpack/cjs/react-server-dom-webpack-client.browser.development.js",
  "node_modules/next/dist/compiled/react-server-dom-webpack/cjs/react-server-dom-webpack-client.edge.development.js",
  "node_modules/next/dist/compiled/react-server-dom-webpack/cjs/react-server-dom-webpack-client.node.development.js",
];
const placeholderMappings = [
  "Locales.js",
  "Pluralization.js",
  "helpers/camelCaseKeys.js",
  "helpers/isSet.js",
  "helpers/expandRoundMode.js",
  "helpers/roundNumber.js",
  "helpers/formatNumber.js",
  "helpers/getFullScope.js",
  "helpers/inferType.js",
  "helpers/interpolate.js",
  "helpers/lookup.js",
  "helpers/numberToHuman.js",
  "helpers/numberToHumanSize.js",
  "helpers/parseDate.js",
  "helpers/pluralize.js",
  "helpers/strftime.js",
  "helpers/timeAgoInWords.js",
  "MissingTranslation.js",
  "I18n.js",
  "helpers/createTranslationOptions.js",
  "helpers/numberToDelimited.js",
];

const marker = "try { globalThis.setImmediate = patchedSetImmediate; }";

function patchFile(relativePath) {
  const fullPath = path.join(process.cwd(), relativePath);
  if (!fs.existsSync(fullPath)) {
    return { status: "missing", path: relativePath };
  }

  const content = fs.readFileSync(fullPath, "utf8");
  if (content.includes(marker)) {
    return { status: "skipped", path: relativePath };
  }

  const newline = content.includes("\r\n") ? "\r\n" : "\n";
  const pattern =
    /(\s*)const nodeTimers = require\('node:timers'\);[\s\S]*?process\.nextTick = patchedNextTick;/;

  const match = content.match(pattern);
  if (!match) {
    return { status: "pattern-not-found", path: relativePath };
  }

  const indent = match[1] ?? "";
  const replacement = [
    `${indent}const nodeTimers = require('node:timers');`,
    `${indent}try { globalThis.setImmediate = patchedSetImmediate; } catch {}`,
    `${indent}try { nodeTimers.setImmediate = patchedSetImmediate; } catch {}`,
    `${indent}try { globalThis.clearImmediate = patchedClearImmediate; } catch {}`,
    `${indent}try { nodeTimers.clearImmediate = patchedClearImmediate; } catch {}`,
    `${indent}const nodeTimersPromises = require('node:timers/promises');`,
    `${indent}try { nodeTimersPromises.setImmediate = patchedSetImmediatePromise; } catch {}`,
    `${indent}try { process.nextTick = patchedNextTick; } catch {}`,
  ].join(newline);

  const updated = content.replace(pattern, replacement);
  fs.writeFileSync(fullPath, updated, "utf8");
  return { status: "patched", path: relativePath };
}

function patchReactSourceMaps(relativePath) {
  const fullPath = path.join(process.cwd(), relativePath);
  if (!fs.existsSync(fullPath)) {
    return { status: "missing", path: relativePath };
  }

  const content = fs.readFileSync(fullPath, "utf8");
  let updated = content;
  const replacements = [
    {
      regex: /,\s*\(col \+= "\\n\/\/# sourceMappingURL=" \+ sourceMap\)\)/g,
      replacement: ", 0)",
    },
    {
      regex: /,\s*\(encodedName \+= "\\n\/\/# sourceMappingURL=" \+ sourceMap\)\)/g,
      replacement: ", 0)",
    },
  ];

  replacements.forEach(({ regex, replacement }) => {
    updated = updated.replace(regex, replacement);
  });

  if (updated === content) {
    return { status: "skipped", path: relativePath };
  }

  fs.writeFileSync(fullPath, updated, "utf8");
  return { status: "patched", path: relativePath };
}

function ensurePlaceholderSourceMaps() {
  const results = [];
  const distRoot = path.join(process.cwd(), "dist", "import");

  for (const mapping of placeholderMappings) {
    const mapPath = path.join(distRoot, `${mapping}.map`);
    const dir = path.dirname(mapPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    if (fs.existsSync(mapPath)) {
      results.push({ status: "exists", path: mapPath });
      continue;
    }

    const content = JSON.stringify(
      {
        version: 3,
        file: mapping,
        sources: [],
        names: [],
        mappings: "",
      },
      null,
      2
    );

    fs.writeFileSync(mapPath, content, "utf8");
    results.push({ status: "created", path: mapPath });
  }

  return results;
}

const results = targets.map(patchFile);
const failed = results.filter((result) => result.status === "pattern-not-found");

results.forEach((result) => {
  if (result.status === "patched") {
    console.log(`[patch-next] patched ${result.path}`);
  } else if (result.status === "skipped") {
    console.log(`[patch-next] already patched ${result.path}`);
  } else if (result.status === "missing") {
    console.log(`[patch-next] missing ${result.path}`);
  }
});

if (failed.length > 0) {
  console.warn("[patch-next] pattern not found:", failed.map((r) => r.path).join(", "));
}

const reactResults = reactPaths.map(patchReactSourceMaps);
reactResults.forEach((result) => {
  if (result.status === "patched") {
    console.log(`[patch-next] stripped sourceMappingURL from ${result.path}`);
  } else if (result.status === "skipped") {
    console.log(`[patch-next] no sourceMappingURL in ${result.path}`);
  } else if (result.status === "missing") {
    console.log(`[patch-next] missing ${result.path}`);
  }
});

const placeholderResults = ensurePlaceholderSourceMaps();
placeholderResults.forEach((result) => {
  if (result.status === "created") {
    console.log(`[patch-next] created placeholder ${result.path}`);
  }
});
