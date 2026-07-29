"use client";

import { useEffect, useState } from "react";

/**
 * What the console editor is currently pointing at, for the handful of fields
 * that cannot be pointed at with a marked section.
 *
 * Most fields are text on their own page: `PreviewDraftBridge` marks the block
 * they land in and that is the whole answer. A few are not text at all — the
 * map pin, the two form states — and for those the preview has to *do*
 * something to make the field visible. That is what these hooks are for.
 *
 * The rule behind them: focus a field and the preview does whatever is needed
 * to show it, and says in one line why that was needed. A field that cannot
 * manage either does not belong in the editor.
 */

export const PREVIEW_FOCUS_EVENT = "hosthub-preview-focus-changed";
export const PREVIEW_DRAFT_EVENT = "hosthub-preview-draft-changed";

/** The address the cursor is in, or null. */
export function usePreviewFocus(): string | null {
  const [address, setAddress] = useState<string | null>(null);

  useEffect(() => {
    const onFocus = (event: Event) => {
      setAddress((event as CustomEvent<string | null>).detail ?? null);
    };
    window.addEventListener(PREVIEW_FOCUS_EVENT, onFocus);
    return () => window.removeEventListener(PREVIEW_FOCUS_EVENT, onFocus);
  }, []);

  return address;
}

/**
 * The drafted value of one address, or null while the editor has sent nothing.
 *
 * Used by the values that are not rendered as text and therefore cannot be
 * written into the DOM — the map query being the one that exists today.
 */
export function usePreviewDraftValue(address: string): string | null {
  const [value, setValue] = useState<string | null>(null);

  useEffect(() => {
    const onDraft = (event: Event) => {
      const fields = (event as CustomEvent<Record<string, unknown>>).detail;
      const next = fields?.[address];
      if (typeof next === "string") setValue(next);
    };
    window.addEventListener(PREVIEW_DRAFT_EVENT, onDraft);
    return () => window.removeEventListener(PREVIEW_DRAFT_EVENT, onDraft);
  }, [address]);

  return value;
}
