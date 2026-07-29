"use client";

import { useMemo } from "react";

import { InteractiveMap } from "@/components/interactive-map";
import { cmsFieldAddress } from "@/lib/cms-field";
import {
  usePreviewDraftValue,
  usePreviewFocus,
} from "@/lib/preview-focus";

const MAP_QUERY_ADDRESS = cmsFieldAddress("cabin/main", "location", "mapQuery");

type PreviewMapPinProps = {
  mapQuery: string;
  mapEmbedUrl: string;
  className?: string;
};

/**
 * The map, with the one field that steers it wired to the console editor.
 *
 * `cabin.location.mapQuery` is not text on the page — it decides where the pin
 * sits — so the section-marking that answers "where do I see this back?" for
 * every other field has nothing to mark. The answer here is that the map
 * *moves*: typing a new query re-centres the embed, and focusing the field says
 * so in the editor's own note.
 *
 * Outside a preview no message ever arrives and this renders exactly what the
 * server rendered.
 */
export function PreviewMapPin({
  mapQuery,
  mapEmbedUrl,
  className,
}: PreviewMapPinProps) {
  const draftQuery = usePreviewDraftValue(MAP_QUERY_ADDRESS);
  const focusedAddress = usePreviewFocus();

  // Derived, not stored: the embed url is a function of the drafted query and
  // the server-rendered one, and state would only be a slower copy of that.
  const embedUrl = useMemo(() => {
    const query = draftQuery?.trim();
    if (!query) return mapEmbedUrl;
    // Rebuild from the server-rendered url so every other parameter it carries
    // (language, zoom, output mode) survives; only the place changes.
    try {
      const next = new URL(mapEmbedUrl);
      next.searchParams.set("q", query);
      return next.toString();
    } catch {
      return mapEmbedUrl;
    }
  }, [draftQuery, mapEmbedUrl]);

  const isPointed = focusedAddress === MAP_QUERY_ADDRESS;

  return (
    <div
      // The map is its own section for pointing purposes: the bridge marks
      // this wrapper rather than hunting for a text node that does not exist.
      data-cms-section=""
      data-cms-map-pointed={isPointed ? "" : undefined}
      className={isPointed ? "cms-pointed" : undefined}
    >
      <InteractiveMap
        title={`${draftQuery?.trim() || mapQuery} map`}
        src={embedUrl}
        className={className}
      />
    </div>
  );
}
