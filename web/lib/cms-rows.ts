/**
 * Repeatable-list rows with stable ids.
 *
 * Since the stable-row-id migration, every repeatable list in a CMS document
 * stores objects carrying an `id` (`[{ id, text }]` instead of `["..."]`).
 * The id is the row's identity — translations and editor state key on it —
 * and the array index is display order, nothing more.
 *
 * These helpers accept **both** shapes (pre- and post-migration, plus the
 * static/snapshot fallbacks that still hold plain strings), so the site keeps
 * rendering whichever the database serves. That property is what makes the
 * data migration deployable independently of this code.
 */

export type TextRow = { id?: string; text: string };

/** Normalizes a text list to rows, keeping ids where the data has them. */
export function textRows(value: unknown): TextRow[] {
  if (!Array.isArray(value)) return [];
  const rows: TextRow[] = [];
  for (const entry of value) {
    if (typeof entry === "string") {
      rows.push({ text: entry });
    } else if (entry && typeof entry === "object") {
      const row = entry as { id?: unknown; text?: unknown };
      rows.push({
        id: typeof row.id === "string" ? row.id : undefined,
        text: typeof row.text === "string" ? row.text : "",
      });
    }
  }
  return rows;
}

/** Normalizes a text list to plain strings (for render paths without ids). */
export function rowTexts(value: unknown): string[] {
  return textRows(value).map((row) => row.text);
}

/**
 * The CMS-field address of one row's text (`description.<id>.text`), falling
 * back to the pre-migration index address for rows without an id — the same
 * address the console derives, so the live preview can patch the element.
 */
export function rowFieldPath(
  listPath: string,
  row: { id?: string },
  index: number,
  sub = "text",
): (string | number)[] {
  return row.id ? [listPath, row.id, sub] : [listPath, index];
}
