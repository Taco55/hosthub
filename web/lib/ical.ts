import type { VEvent } from "node-ical";
import ical from "node-ical/ical.js";

export type UnavailableRange = {
  start: string;
  end: string;
  source?: string;
};

const timeZone = "Europe/Oslo";
const rangeMonths = 18;
const dayMs = 24 * 60 * 60 * 1000;

const dateFormatter = new Intl.DateTimeFormat("en-CA", {
  timeZone,
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
});

function formatDate(date: Date) {
  const parts = dateFormatter.formatToParts(date);
  const year = parts.find((part) => part.type === "year")?.value ?? "0000";
  const month = parts.find((part) => part.type === "month")?.value ?? "01";
  const day = parts.find((part) => part.type === "day")?.value ?? "01";
  return `${year}-${month}-${day}`;
}

function addDays(date: Date, days: number) {
  const next = new Date(date);
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

function addMonths(date: Date, months: number) {
  const next = new Date(date);
  next.setUTCMonth(next.getUTCMonth() + months);
  return next;
}

function normalizeRange(start: Date, end: Date, datetype?: string) {
  const normalizedEnd = datetype === "date" ? addDays(end, -1) : end;
  if (normalizedEnd < start) {
    return null;
  }

  return {
    start: formatDate(start),
    end: formatDate(normalizedEnd),
  };
}

function expandRecurringEvent(event: VEvent, until: Date) {
  if (!event.rrule) {
    return [];
  }

  const durationMs = (event.end ?? event.start).getTime() - event.start.getTime();
  const occurrences = event.rrule.between(new Date(), until, true);
  const exdates = new Set(
    Object.values(event.exdate ?? {}).map((date) => formatDate(date as Date)),
  );

  return occurrences.flatMap((occurrence) => {
    if (exdates.has(formatDate(occurrence))) {
      return [];
    }

    const end = new Date(occurrence.getTime() + durationMs);
    const normalized = normalizeRange(occurrence, end, event.datetype);
    return normalized ? [normalized] : [];
  });
}

function isVEvent(entry: unknown): entry is VEvent {
  return (
    typeof entry === "object" &&
    entry !== null &&
    "type" in entry &&
    (entry as { type?: string }).type === "VEVENT"
  );
}

export function parseIcal(text: string, source?: string) {
  const parsed = ical.parseICS(text);
  const entries = Object.values(parsed).filter(isVEvent);
  const until = addMonths(new Date(), rangeMonths);

  const ranges = entries.flatMap((event) => {
    if (!event.start) {
      return [];
    }

    if (event.rrule) {
      return expandRecurringEvent(event, until).map((range) => ({
        ...range,
        source,
      }));
    }

    const normalized = normalizeRange(event.start, event.end ?? event.start, event.datetype);
    return normalized
      ? [
          {
            ...normalized,
            source,
          },
        ]
      : [];
  });

  return ranges;
}

function toDateValue(value: string) {
  return new Date(`${value}T00:00:00Z`).getTime();
}

export function mergeRanges(ranges: UnavailableRange[]) {
  const sorted = [...ranges].sort((a, b) => a.start.localeCompare(b.start));
  const merged: UnavailableRange[] = [];

  for (const range of sorted) {
    const last = merged[merged.length - 1];
    if (!last) {
      merged.push({ ...range });
      continue;
    }

    const lastEnd = toDateValue(last.end);
    const nextStart = toDateValue(range.start);

    if (nextStart <= lastEnd + dayMs) {
      if (range.end > last.end) {
        last.end = range.end;
      }
      continue;
    }

    merged.push({ ...range });
  }

  return merged;
}
