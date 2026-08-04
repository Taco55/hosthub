import assert from "node:assert/strict";
import { test } from "node:test";

import type {
  CabinContent,
  LocalizedContent,
  PracticalContent,
} from "./content";
import {
  normalizeAreaContent,
  normalizeCabinContent,
  normalizeHomeContent,
  normalizePracticalContent,
  normalizePrivacyContent,
} from "./normalize-content";

// This is the module the live site went down over: `/en` and `/no` returned 500
// with "Objects are not valid as a React child (found: object with keys
// {id, text})" because an edited list arrived as rows and reached React
// unnormalized. Every list the console can edit has to leave here as rows.

/** A partial document, as the CMS may really hold it. */
type Doc = Record<string, unknown>;
const asCabin = (doc: Doc) => doc as unknown as CabinContent;
const asPractical = (doc: Doc) => doc as unknown as PracticalContent;
const asArea = (doc: Doc) => doc as unknown as LocalizedContent["area"];
const asPrivacy = (doc: Doc) => doc as unknown as LocalizedContent["privacy"];
/** Reads a normalized result back as plain data. */
const read = (value: unknown) => value as Doc;

test("a paragraph list keeps each row's id", () => {
  // A string carries no id at all — not `id: undefined`. The difference matters:
  // the renderer branches on whether the row has one to decide the address it
  // gives the live preview.
  const out = read(normalizeCabinContent(asCabin({
    description: [{ id: "d1", text: "Eerste" }, "Tweede"],
  })));
  assert.deepEqual(out.description, [
    { id: "d1", text: "Eerste" },
    { text: "Tweede" },
  ]);
});

test("house rules and amenity items normalize one level down", () => {
  const out = read(normalizeCabinContent(asCabin({
    houseRules: { title: "Regels", bullets: ["Geen feesten"] },
    amenities: {
      title: "Voorzieningen",
      groups: [{ id: "g1", title: "Keuken", items: [{ id: "i1", text: "Oven" }] }],
    },
  })));
  assert.deepEqual(read(out.houseRules).bullets, [{ text: "Geen feesten" }]);
  const groups = read(out.amenities).groups as Doc[];
  assert.deepEqual(groups[0].items, [{ id: "i1", text: "Oven" }]);
  // The group's own fields survive the copy.
  assert.equal(groups[0].title, "Keuken");
});

test("a highlight's own image becomes the parallel image array", () => {
  const out = normalizeHomeContent({
    highlights: [
      { id: "h1", title: "Uitzicht", image: "/images/a.jpg", alt: "Vergezicht" },
      { id: "h2", title: "Sauna" },
    ] as unknown as LocalizedContent["highlights"],
  });
  assert.deepEqual(out.highlightImages, [
    { src: "/images/a.jpg", alt: "Vergezicht" },
  ]);
});

test("an explicit image array is not overwritten by the derived one", () => {
  const out = normalizeHomeContent({
    highlightImages: [{ src: "/images/kept.jpg", alt: "Bewaard" }],
    highlights: [
      { id: "h1", title: "X", image: "/images/derived.jpg" },
    ] as unknown as LocalizedContent["highlights"],
  });
  assert.deepEqual(out.highlightImages, [
    { src: "/images/kept.jpg", alt: "Bewaard" },
  ]);
});

test("highlights without images produce no image array at all", () => {
  // Not an empty array: an empty one renders an image strip with nothing in it,
  // and the caller distinguishes absent from empty.
  const out = normalizeHomeContent({
    highlights: [{ id: "h1", title: "X" }] as unknown as LocalizedContent["highlights"],
  });
  assert.equal(out.highlightImages, undefined);
});

test("every grouped list on the practical page normalizes its items", () => {
  // agreementsAndPayment is the one that caused the outage: it became editable,
  // so it started arriving as rows, and it was not in this table.
  const out = read(normalizePracticalContent(asPractical({
    layoutFacilities: { sections: [{ id: "s1", bullets: [{ id: "b1", text: "Zolder" }] }] },
    transport: { columns: [{ id: "c1", bullets: ["Bus"] }] },
    agreementsAndPayment: { blocks: [{ id: "a1", items: [{ id: "x1", text: "Borg" }] }] },
    arrivalAccess: { bullets: [{ id: "n1", text: "Sleutelkluis" }] },
  })));

  const sections = read(out.layoutFacilities).sections as Doc[];
  const columns = read(out.transport).columns as Doc[];
  const blocks = read(out.agreementsAndPayment).blocks as Doc[];
  assert.deepEqual(sections[0].bullets, [{ id: "b1", text: "Zolder" }]);
  assert.deepEqual(columns[0].bullets, [{ text: "Bus" }]);
  assert.deepEqual(blocks[0].items, [{ id: "x1", text: "Borg" }]);
  assert.deepEqual(read(out.arrivalAccess).bullets, [
    { id: "n1", text: "Sleutelkluis" },
  ]);
});

test("area sections and privacy bullets normalize", () => {
  const area = read(normalizeAreaContent(asArea({
    intro: "Trysil",
    sections: [{ id: "s1", bullets: [{ id: "b1", text: "Langlauf" }] }],
  })));
  const sections = area.sections as Doc[];
  assert.deepEqual(sections[0].bullets, [{ id: "b1", text: "Langlauf" }]);

  const privacy = read(normalizePrivacyContent(asPrivacy({
    intro: "Wij",
    bullets: ["Geen tracking"],
  })));
  assert.deepEqual(privacy.bullets, [{ text: "Geen tracking" }]);
});

test("a normalizer does not mutate the document it was handed", () => {
  // The provider hands over a decoded document that other code also holds; a
  // normalizer that wrote through would change what the caller reads next.
  const doc = { description: [{ id: "d1", text: "Eerste" }] };
  normalizeCabinContent(asCabin(doc));
  assert.deepEqual(doc, { description: [{ id: "d1", text: "Eerste" }] });
});

test("a list key the document does not have is not invented", () => {
  // `key in target` is the guard: adding an empty list would make an absent
  // section render as a present, empty one.
  const out = read(normalizePrivacyContent(asPrivacy({ intro: "Wij" })));
  assert.equal("bullets" in out, false);
});

test("a malformed group is passed through, not dropped", () => {
  // Rendering less than the document holds is worse than rendering something
  // odd: the owner can see and fix odd.
  const out = read(normalizePracticalContent(asPractical({
    transport: { columns: ["not a group", null] },
  })));
  assert.deepEqual(read(out.transport).columns, ["not a group", null]);
});
