import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  // Override default ignores of eslint-config-next.
  globalIgnores([
    // Default ignores of eslint-config-next:
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
    // Cloudflare build output. `npm run build:cf` bundles the worker into
    // .open-next and wrangler caches into .wrangler; linting either buries the
    // handful of real findings under hundreds from generated code, which is how
    // this gate stopped being readable.
    ".open-next/**",
    ".wrangler/**",
  ]),
  {
    // Honour the underscore convention for deliberately unused bindings, so a
    // seam like getMinNightsForArrival(_date) — whose callers do pass a date —
    // does not have to choose between a lint warning and dropping the argument.
    rules: {
      "@typescript-eslint/no-unused-vars": [
        "warn",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
        },
      ],
    },
  },
  {
    // Node build scripts. This package has no "type": "module", so a .js file
    // here *is* CommonJS and require() is the correct call — the ESM scripts
    // use .mjs (generate-cms-snapshot.mjs). The TypeScript flavour of the rule
    // has no business in a plain Node script.
    files: ["scripts/**/*.js"],
    rules: {
      "@typescript-eslint/no-require-imports": "off",
    },
  },
]);

export default eslintConfig;
