"use client";

import { useMemo } from "react";

import { InteractiveMap } from "@/components/interactive-map";
import { cmsFieldAddress } from "@/lib/cms-field";
import {
  usePreviewDraftValue,
  usePreviewFocus,
} from "@/lib/preview-focus";

const MAP_EMBED_ADDRESS = cmsFieldAddress("site_config/main", "mapEmbedUrl");

type PreviewMapPinProps = {
  mapQuery: string;
  mapEmbedUrl: string;
  className?: string;
};

/**
 * The map, with the field that steers it wired to the console editor.
 *
 * `site_config.mapEmbedUrl` is not text on the page — it decides where the pin
 * sits — so the section-marking that answers "where do I see this back?" for
 * every other field has nothing to mark. The answer here is that the map
 * *moves*: a new embed url re-centres it, and focusing the field says so in
 * the editor's own note.
 *
 * This used to listen on `cabin/main:location.mapQuery`, rewriting `?q=` on the
 * embed. That field held nothing, and the embed is an OpenStreetMap url that
 * positions itself with `bbox=`, so the rewrite moved no pin. The editor now
 * offers the url itself.
 *
 * Outside a preview no message ever arrives and this renders exactly what the
 * server rendered.
 */
export function PreviewMapPin({
  mapQuery,
  mapEmbedUrl,
  className,
}: PreviewMapPinProps) {
  const draftEmbedUrl = usePreviewDraftValue(MAP_EMBED_ADDRESS);
  const focusedAddress = usePreviewFocus();

  // Derived, not stored: the embed url is a function of the drafted query and
  // the server-rendered one, and state would only be a slower copy of that.
  const embedUrl = useMemo(() => {
    const drafted = draftEmbedUrl?.trim();
    if (!drafted) return mapEmbedUrl;
    // Only take a url that parses: the owner is typing, and a half-pasted one
    // would blank the map on every keystroke until it is complete.
    try {
      return new URL(drafted).toString();
    } catch {
      return mapEmbedUrl;
    }
  }, [draftEmbedUrl, mapEmbedUrl]);

  const isPointed = focusedAddress === MAP_EMBED_ADDRESS;

  return (
    <div
      // The map is its own section for pointing purposes: the bridge marks
      // this wrapper rather than hunting for a text node that does not exist.
      data-cms-section=""
      data-cms-map-pointed={isPointed ? "" : undefined}
      className={isPointed ? "cms-pointed" : undefined}
    >
      <InteractiveMap
        title={`${mapQuery} map`}
        src={embedUrl}
        className={className}
      />
    </div>
  );
}
