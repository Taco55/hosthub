"use client";

import { useEffect } from "react";

import { PREVIEW_DRAFT_EVENT, PREVIEW_FOCUS_EVENT } from "@/lib/preview-focus";

/**
 * The console's two-way window into the rendered preview.
 *
 * Two messages travel over one channel, both keyed on the `data-cms-field`
 * addresses the page already carries:
 *
 *  * **draft** — the preview route renders what the CMS holds, which is the
 *    last *saved* version, so typing in the editor changed nothing on screen
 *    while the pane said "Live preview". The draft is written straight into the
 *    matching elements. Nothing is stored and the published site is never
 *    involved, so the no-autosave rule is untouched.
 *  * **focus** — at ~60 fields per page, *"where do I see this back?"* is the
 *    question asked most, and the cheapest answer is not to explain but to
 *    point. The section a field lands in is marked and scrolled into view while
 *    the cursor is in it. The text itself is never highlighted: that shifts the
 *    layout and reads as an error.
 *
 * Only the console that belongs to this site may send either. That origin is
 * derived, not configured: the console lives on `admin.<this site's domain>`
 * (see cloudflare/scripts/deploy_hosthub.sh, HOSTHUB_PUBLIC_DOMAIN), so every
 * new customer domain is covered without an env var to keep in sync. On
 * localhost any localhost port qualifies — that is the dev console.
 */
const DRAFT_MESSAGE = "hosthub-preview-draft";
const FOCUS_MESSAGE = "hosthub-preview-focus";
const READY_MESSAGE = "hosthub-preview-ready";

const LOCAL_HOSTS = ["localhost", "127.0.0.1", "[::1]", "::1"];

/** The class the marking uses; the rule itself lives in globals.css. */
const POINTED_CLASS = "cms-pointed";

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

/**
 * The block a field belongs to.
 *
 * A field is a line of text; what the reader is looking for is the block it
 * sits in. `section` first, then any explicit `[data-cms-section]` a component
 * declares, then the nearest sensible container.
 */
function sectionFor(element: HTMLElement): HTMLElement {
  const named = element.closest<HTMLElement>("[data-cms-section]");
  if (named) return named;
  const section = element.closest<HTMLElement>("section, article");
  if (section) return section;
  return element.parentElement ?? element;
}

function clearPointing() {
  document
    .querySelectorAll<HTMLElement>(`.${POINTED_CLASS}`)
    .forEach((element) => element.classList.remove(POINTED_CLASS));
}

function pointAt(address: string | null) {
  clearPointing();
  if (!address) return;

  const element = document.querySelector<HTMLElement>(
    `[data-cms-field="${CSS.escape(address)}"]`,
  );
  if (!element) return;

  const section = sectionFor(element);
  section.classList.add(POINTED_CLASS);

  // Only scroll when the section is actually out of the way. Scrolling a
  // section that is already on screen makes the page twitch on every tab.
  const box = section.getBoundingClientRect();
  const fullyVisible = box.top >= 0 && box.bottom <= window.innerHeight;
  if (!fullyVisible) {
    section.scrollIntoView({ behavior: "smooth", block: "center" });
  }
}

export function PreviewDraftBridge({ locale }: { locale: string }) {
  useEffect(() => {
    const onMessage = (event: MessageEvent) => {
      if (!isConsoleOrigin(event.origin)) return;
      const data = event.data as
        | {
            type?: string;
            locale?: string;
            fields?: Record<string, unknown>;
            address?: string | null;
          }
        | null;
      if (!data) return;
      // A message for another language is not ours to render.
      if (typeof data.locale === "string" && data.locale !== locale) return;

      if (data.type === DRAFT_MESSAGE) {
        const fields = data.fields ?? {};
        applyDraft(fields);
        // Values that are not rendered as text cannot be written into the DOM
        // — the map query recomputes its embed from this instead.
        window.dispatchEvent(
          new CustomEvent(PREVIEW_DRAFT_EVENT, { detail: fields }),
        );
        return;
      }
      if (data.type === FOCUS_MESSAGE) {
        const address = typeof data.address === "string" ? data.address : null;
        pointAt(address);
        // The handful of fields that are not text on their own page need the
        // preview to act rather than to mark; they subscribe here.
        window.dispatchEvent(
          new CustomEvent(PREVIEW_FOCUS_EVENT, { detail: address }),
        );
      }
    };

    window.addEventListener("message", onMessage);

    // A save reloads this frame, so a fresh document starts without the draft
    // that is still in the form. Announce readiness and let the editor resend
    // both the draft and whatever it is pointing at.
    // Sent to any parent: it says nothing the embedder does not already know
    // (it chose this url), and the payloads only ever travel inbound, from an
    // origin isConsoleOrigin accepts.
    if (window.parent && window.parent !== window) {
      window.parent.postMessage({ type: READY_MESSAGE, locale }, "*");
    }

    return () => {
      window.removeEventListener("message", onMessage);
      clearPointing();
    };
  }, [locale]);

  return null;
}
