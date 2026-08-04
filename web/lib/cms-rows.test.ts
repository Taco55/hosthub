import assert from "node:assert/strict";
import { test } from "node:test";

import { rowFieldPath, rowTexts, textRows } from "./cms-rows";

// The union these helpers exist to absorb is not hypothetical: handing a row
// object straight to React is what took `/en` and `/no` down with "Objects are
// not valid as a React child" on the live customer site.

test("rows keep their id, strings become rows without one", () => {
  assert.deepEqual(textRows([{ id: "a1", text: "Hei" }, "Plain"]), [
    { id: "a1", text: "Hei" },
    { text: "Plain" },
  ]);
});

test("a row with a non-string id or text is still a row", () => {
  // The id is identity, so a bad one must not become a string that could
  // collide with a real id; the text falls back to empty rather than undefined,
  // because a renderer interpolates it.
  assert.deepEqual(textRows([{ id: 7, text: null }]), [
    { id: undefined, text: "" },
  ]);
});

test("anything that is not a list is an empty list", () => {
  for (const value of [null, undefined, "text", 3, {}]) {
    assert.deepEqual(textRows(value), [], `for ${JSON.stringify(value)}`);
  }
});

test("rowTexts drops the ids for render paths that have no use for them", () => {
  assert.deepEqual(rowTexts([{ id: "a1", text: "Hei" }, "Plain"]), [
    "Hei",
    "Plain",
  ]);
});

test("a row's address uses its id, and its index only without one", () => {
  // The id form is the address the console derives; the index form is what
  // pre-migration data can still be addressed by. Getting this wrong points the
  // live preview at the wrong row, or at nothing.
  assert.deepEqual(rowFieldPath("description", { id: "a1" }, 3), [
    "description",
    "a1",
    "text",
  ]);
  assert.deepEqual(rowFieldPath("description", {}, 3), ["description", 3]);
  assert.deepEqual(rowFieldPath("bullets", { id: "b2" }, 0, "alt"), [
    "bullets",
    "b2",
    "alt",
  ]);
});
