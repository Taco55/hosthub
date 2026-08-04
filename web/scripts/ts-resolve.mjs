/**
 * Lets node's own test runner import the app's modules unchanged.
 *
 * The app is written for a bundler: relative imports carry no extension
 * (`./cms-rows`), which TypeScript resolves and node's ESM loader does not. So
 * a test could only reach a module with no relative imports of its own — which
 * excluded the interesting ones.
 *
 * This resolve hook appends `.ts`/`.tsx` when a bare relative specifier does
 * not resolve on its own, which is the rule the bundler already applies. It
 * runs only under `npm test`; nothing in the build or the deployed worker sees
 * it, and it never rewrites a specifier that already resolves.
 */

import { register } from "node:module";
import { pathToFileURL } from "node:url";

const source = `
const CANDIDATES = [".ts", ".tsx", "/index.ts", "/index.tsx"];

export async function resolve(specifier, context, next) {
  try {
    return await next(specifier, context);
  } catch (error) {
    if (!specifier.startsWith(".")) throw error;
    for (const suffix of CANDIDATES) {
      try {
        return await next(specifier + suffix, context);
      } catch {
        // Try the next shape; rethrow the original if none of them resolve, so
        // the error names the import the source actually wrote.
      }
    }
    throw error;
  }
}
`;

register(`data:text/javascript,${encodeURIComponent(source)}`, pathToFileURL("./"));
