# Fageråsen 701 Cabin Website

> Deze README beschrijft het `web/`-workspacegedeelte; gebruik de root-commando's (`npm run web:dev`, `npm run web:build`, ...) of voer scripts direct vanuit deze map uit.

Modern, fast marketing + booking funnel site for the Fageråsen 701 cabin in Trysil, Norway. Built with Next.js App Router, Tailwind CSS, and copy‑owned shadcn/ui components.

## Features
- Localized routes for Dutch, English, and Norwegian (`/nl`, `/en`, `/no`)
- Booking funnel with Lodgify availability and quote proxy endpoints
- Gallery with lightbox, practical info, area guides, and privacy page
- SEO metadata, JSON‑LD structured data, sitemap.xml, and robots.txt
- Content stored in a single typed file for easy future CMS integration

## Requirements
- Node.js 20+

## Install
```bash
npm install
```

## Run locally
```bash
npm run dev
```

By default this workspace runs on `http://localhost:43001` so the HostHub admin
console (typically `http://localhost:43000`) can open `/preview/<locale>` in a
separate local app.

## Typecheck
```bash
npm run typecheck
```

## Build
```bash
npm run build
```

## Changelog
- Added parallax to hero image with reduced-motion support.
- Premium visual refresh: new design tokens, typography hierarchy, and wider container rhythm.
- Updated home layout (hero, experience strip, highlights, gallery preview) and booking card UX.
- Refreshed section components (layout/facilities, amenities accordion, access/transport, house rules/policies accordions).
- Gallery grid now uses lightbox with thumbnails; optional category filters supported when image folders are used.
- Set `NEXT_PUBLIC_LODGIFY_CHECKOUT_URL` to your Lodgify checkout URL for the booking CTA.

## Environment variables
Create a `.env.local` file in the project root with:
```bash
ICAL_URLS="https://example.com/calendar1.ics,https://example.com/calendar2.ics"
NEXT_PUBLIC_LODGIFY_CHECKOUT_URL="https://checkout.lodgify.com/fagerasen701/706211/reservation"
NEXT_PUBLIC_LODGIFY_CURRENCY="NOK"
NEXT_PUBLIC_MIN_NIGHTS="4"
LODGIFY_BOOKING_URL="https://your-lodgify-booking-link"
NEXT_PUBLIC_SITE_URL="https://your-production-domain"
LODGIFY_API_KEY="your-rotated-lodgify-api-key"
LODGIFY_PROPERTY_ID="123456"
LODGIFY_ROOM_TYPE_ID="654321"
LODGIFY_API_BASE="https://api.lodgify.com"
```

Lodgify API key notes:
- Use `LODGIFY_API_KEY` only. Never prefix it with `NEXT_PUBLIC_`.
- Rotate the key by creating a new key in Lodgify, updating `LODGIFY_API_KEY` in `.env.local` and your hosting provider, then revoking the old key.
- `LODGIFY_API_BASE` is optional and defaults to `https://api.lodgify.com`.

## Where to edit content
- `lib/content.ts` holds the structured `cabinContent` drop-in data plus the localized content used by legacy pages.
- `lib/i18n.ts` holds navigation and UI string translations.
- `lib/content.ts` also holds the hero list, full gallery list, and the 6-image homepage selection.

## Hero images
- Place hero background images in `public/images/hero/` and list them in `lib/content.ts`.
- The hero crossfade respects `prefers-reduced-motion` and shows only the first image when enabled.
- Run `npm run resize-images` after adding or replacing frontend assets in `public/images/hero/`, `public/images/all/` or `public/highlights/` to keep the `@<width>w` variants and manifest in sync.

## Availability and pricing APIs
- `GET /api/lodgify/availability?start=YYYY-MM-DD&end=YYYY-MM-DD`
- `GET /api/lodgify/quote?arrival=YYYY-MM-DD&departure=YYYY-MM-DD&adults=2&children=0&pets=0&guests=2`
- `GET /api/availability` remains available for iCal-based ranges.

## Lodgify availability checks (v2)

- `scripts/check-lodgify-availability.sh` calls the Lodgify `/v2/availability/{propertyId}` endpoint using the values defined in `.env.local`. Run `./scripts/check-lodgify-availability.sh 2025-12-01 2025-12-31` to reproduce the availability request that the booking widget uses.
- `scripts/check-lodgify-quote.sh` calls the Lodgify `/v2/quote/{propertyId}` endpoint using the values defined in `.env.local`. Run `./scripts/check-lodgify-quote.sh 2026-01-09 2026-01-15 2 0 0` to reproduce the pricing request.

## Deploy to Cloudflare Pages
1) Push the repo to GitHub.
2) Create a new Cloudflare Pages project and select the Next.js preset.
3) Set the environment variables from `.env.example`.
4) Set `NODE_VERSION=20` and enable Node.js compatibility in Pages settings (Functions).
5) Deploy.

## Deploy to Vercel
1) Push the repo to GitHub.
2) Create a new Vercel project and import the repo.
3) Set the same environment variables in Vercel.
4) Deploy.

## Booking link
Set `NEXT_PUBLIC_LODGIFY_CHECKOUT_URL` to the Lodgify reservation URL. The booking form will deep‑link there with arrival, departure, and guest counts.

## Lodgify ID discovery
Use the helper script to print properties and room types (requires `LODGIFY_API_KEY`, plus `LODGIFY_PROPERTY_ID` for rooms):
```bash
node scripts/lodgify-discover.js
```

## TODO
- Use ParallaxImage for a mid-page banner if desired.
