import { NextResponse } from "next/server";

const destinationUrl =
  "https://tough-postage-c61.notion.site/Home-manual-Fagerasen-701-2cc98c23a88880aba6d5e480ab31e80e";

function redirectResponse() {
  const response = NextResponse.redirect(destinationUrl, {
    status: 302,
  });

  response.headers.set("X-Robots-Tag", "noindex, nofollow, noarchive");
  response.headers.set("Cache-Control", "no-store");

  return response;
}

export function GET() {
  return redirectResponse();
}

export function HEAD() {
  return redirectResponse();
}
