import assert from "node:assert/strict";
import { test } from "node:test";

import { cmsField, cmsFieldAddress } from "./cms-field";

// `contentType/slug:json.path` is a contract with the console, checked in both
// directions by `npm run check:cms`. These tests pin the shape that check
// assumes when it parses the addresses out of this source.

test("an address is the document, a colon, and the dotted path", () => {
  assert.equal(
    cmsFieldAddress("cabin/main", "hero", "title"),
    "cabin/main:hero.title",
  );
});

test("a numeric segment stays numeric in the path", () => {
  // Pre-migration rows are addressed by index; the console compares the string,
  // so a stringified number has to look the same on both sides.
  assert.equal(
    cmsFieldAddress("page/home", "highlights", 2, "title"),
    "page/home:highlights.2.title",
  );
});

test("cmsField spreads into an element as one data attribute", () => {
  // It is spread into JSX, and JSX spreads are not excess-property checked —
  // this is exactly how AmenityTile silently dropped the attribute once.
  assert.deepEqual(cmsField("contact_form/main", "title"), {
    "data-cms-field": "contact_form/main:title",
  });
});

test("a document with no path addresses the document itself", () => {
  assert.equal(cmsFieldAddress("page/area"), "page/area:");
});
