import { NextResponse } from "next/server";

import { mergeRanges, parseIcal } from "@/lib/ical";

const cacheSeconds = 900;
const staleSeconds = 300;

export async function GET() {
  const rawUrls = process.env.ICAL_URLS ?? "";
  const urls = rawUrls
    .split(",")
    .map((url) => url.trim())
    .filter(Boolean);

  if (urls.length === 0) {
    return NextResponse.json(
      {
        ranges: [],
        sources: [],
        updatedAt: new Date().toISOString(),
        warnings: ["ICAL_URLS is not set."],
      },
      {
        headers: {
          "Cache-Control": `s-maxage=${cacheSeconds}, stale-while-revalidate=${staleSeconds}`,
        },
      },
    );
  }

  const results = await Promise.allSettled(
    urls.map(async (url) => {
      const response = await fetch(url, { next: { revalidate: cacheSeconds } });
      if (!response.ok) {
        throw new Error(`Failed to fetch iCal: ${response.status}`);
      }
      const text = await response.text();
      return parseIcal(text, url);
    }),
  );

  const ranges = mergeRanges(
    results.flatMap((result) => (result.status === "fulfilled" ? result.value : [])),
  );

  const errors = results.flatMap((result) =>
    result.status === "rejected" ? [String(result.reason)] : [],
  );

  return NextResponse.json(
    {
      ranges,
      sources: urls,
      updatedAt: new Date().toISOString(),
      errors: errors.length ? errors : undefined,
    },
    {
      headers: {
        "Cache-Control": `s-maxage=${cacheSeconds}, stale-while-revalidate=${staleSeconds}`,
      },
    },
  );
}
