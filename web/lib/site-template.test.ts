import assert from "node:assert/strict";
import { test } from "node:test";

import {
  chaletTemplate,
  defaultSiteTemplate,
  documentKeysOf,
  siteTemplateFor,
  siteTemplates,
} from "./site-template";

test("a site resolves to the template it records", () => {
  assert.equal(siteTemplateFor("chalet-v1").id, "chalet-v1");
  assert.ok(chaletTemplate.id in siteTemplates);
});

test("an unknown, absent or blank id falls back to the default", () => {
  // Falling back rather than failing, matching `templateFor` in the console: a
  // site whose template was renamed should still render — imperfectly — instead
  // of serving an error to its visitors.
  for (const id of ["a-template-that-no-longer-exists", null, undefined, ""]) {
    assert.equal(
      siteTemplateFor(id).id,
      defaultSiteTemplate.id,
      `for ${JSON.stringify(id)}`,
    );
  }
});

test("document keys are contentType/slug, in declaration order", () => {
  // The preview banner reports "missing" against this list, so its contents and
  // its shape are both load-bearing.
  assert.deepEqual(documentKeysOf(chaletTemplate), [
    "site_config/main",
    "cabin/main",
    "page/home",
    "page/practical",
    "page/area",
    "page/privacy",
    "contact_form/main",
  ]);
});

test("no template declares the same document twice", () => {
  // A duplicate would double-count the document in the preview banner.
  for (const template of Object.values(siteTemplates)) {
    const keys = documentKeysOf(template);
    assert.equal(new Set(keys).size, keys.length, `in ${template.id}`);
  }
});

test("every registry key matches the id of the template it holds", () => {
  // The registry is looked up by `sites.template_id`; a key that disagrees with
  // its own template's id resolves the wrong site to the wrong pages.
  for (const [key, template] of Object.entries(siteTemplates)) {
    assert.equal(key, template.id);
  }
});
