"use client";

import { useEffect } from "react";

/**
 * Applies the console editor's unsaved draft to the rendered preview.
 *
 * The preview route renders what the CMS holds, which is the last *saved*
 * version — so typing in the editor changed nothing on screen while the pane
 * said "Live preview". This bridge closes that gap without weakening the
 * no-autosave rule: the draft travels over `postMessage` and is written
 * straight into the elements carrying a matching `data-cms-field` address.
 * Nothing is stored, and the published site is never involved.
 *
 * Only the console that belongs to this site may send one. That origin is
 * derived, not configured: the console lives on `admin.<this site's domain>`
 * (see cloudflare/scripts/deploy_hosthub.sh, HOSTHUB_PUBLIC_DOMAIN), so every
 * new customer domain is covered without an env var to keep in sync. On
 * localhost any localhost port qualifies — that is the dev console.
 */
const DRAFT_MESSAGE = "hosthub-preview-draft";
const READY_MESSAGE = "hosthub-preview-ready";

const LOCAL_HOSTS = ["localhost", "127.0.0.1", "[::1]", "::1"];

function isConsoleOrigin(origin: string): boolean {
  let candidate: URL;
  try {
    candidate = new URL(origin);
  } catch {
    return false;
  }

  if (LOCAL_HOSTS.includes(window.location.hostname)) {
    return LOCAL_HOSTS.includes(candidate.hostname);
  }

  const site = window.location.hostname.replace(/^www\./, "");
  return candidate.protocol === "https:" && candidate.hostname === `admin.${site}`;
}

function applyDraft(fields: Record<string, unknown>) {
  const elements = document.querySelectorAll<HTMLElement>("[data-cms-field]");
  elements.forEach((element) => {
    const address = element.dataset.cmsField;
    if (!address) return;
    const value = fields[address];
    if (typeof value !== "string") return;
    // Only touch what actually changed: writing textContent on every keystroke
    // for every field would fight the browser's own layout work.
    if (element.textContent !== value) {
      element.textContent = value;
    }
  });
}

export function PreviewDraftBridge({ locale }: { locale: string }) {
  useEffect(() => {
    const onMessage = (event: MessageEvent) => {
      if (!isConsoleOrigin(event.origin)) return;
      const data = event.data as
        | { type?: string; locale?: string; fields?: Record<string, unknown> }
        | null;
      if (!data || data.type !== DRAFT_MESSAGE) return;
      // A draft for another language is not ours to render.
      if (typeof data.locale === "string" && data.locale !== locale) return;
      applyDraft(data.fields ?? {});
    };

    window.addEventListener("message", onMessage);

    // A save reloads this frame, so a fresh document starts without the draft
    // that is still in the form. Announce readiness and let the editor resend.
    // Sent to any parent: it says nothing the embedder does not already know
    // (it chose this url), and the draft itself only ever travels inbound, from
    // an origin isConsoleOrigin accepts.
    if (window.parent && window.parent !== window) {
      window.parent.postMessage({ type: READY_MESSAGE, locale }, "*");
    }

    return () => window.removeEventListener("message", onMessage);
  }, [locale]);

  return null;
}
