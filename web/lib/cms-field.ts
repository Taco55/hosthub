/**
 * Marks a rendered element as bound to one CMS field.
 *
 * The address is `contentType/slug:json.path` — the same address the console's
 * editor derives from its field mapping (see `EditorFieldLocation.address`).
 * The live preview uses it to patch what the owner is typing into the page
 * without a save or a round trip: the editor sends values keyed by address, and
 * the bridge in the preview layout writes them into the matching elements.
 *
 * Harmless on the public site — it is a data attribute, and having one code
 * path for both routes is what keeps the addresses honest.
 */
export function cmsFieldAddress(
  document: string,
  ...path: (string | number)[]
): string {
  return `${document}:${path.join(".")}`;
}

export function cmsField(
  document: string,
  ...path: (string | number)[]
): { "data-cms-field": string } {
  return { "data-cms-field": cmsFieldAddress(document, ...path) };
}
