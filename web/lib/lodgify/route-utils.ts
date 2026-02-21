import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

import { LodgifyError } from "@/lib/lodgify/client";

const ipHeaders = [
  "cf-connecting-ip",
  "x-real-ip",
  "x-client-ip",
  "x-vercel-forwarded-for",
  "x-forwarded-for",
] as const;

function normalizeIpCandidate(value: string | null | undefined) {
  if (!value) {
    return null;
  }
  let candidate = value.trim();
  if (!candidate || candidate.toLowerCase() === "unknown") {
    return null;
  }

  if (candidate.startsWith("for=")) {
    candidate = candidate.slice(4);
  }

  if (candidate.startsWith("\"") && candidate.endsWith("\"")) {
    candidate = candidate.slice(1, -1);
  }

  if (candidate.startsWith("[") && candidate.includes("]")) {
    candidate = candidate.slice(1, candidate.indexOf("]"));
  }

  if (/^\d+\.\d+\.\d+\.\d+:\d+$/.test(candidate)) {
    candidate = candidate.replace(/:\d+$/, "");
  }

  return candidate || null;
}

function parseForwardedHeader(value: string | null) {
  if (!value) {
    return null;
  }

  const segments = value.split(",");
  for (const segment of segments) {
    const match = /for=("?\[?[A-Za-z0-9:.\-]+\]?"?)/i.exec(segment);
    const candidate = normalizeIpCandidate(match?.[1]);
    if (candidate) {
      return candidate;
    }
  }
  return null;
}

function sanitizeForKey(value: string | null, fallback: string) {
  if (!value) {
    return fallback;
  }
  const normalized = value.toLowerCase().replace(/[^a-z0-9]+/g, "");
  if (!normalized) {
    return fallback;
  }
  return normalized.slice(0, 32);
}

export function getClientIp(request: NextRequest) {
  for (const header of ipHeaders) {
    const rawValue = request.headers.get(header);
    if (!rawValue) {
      continue;
    }
    const firstCandidate = rawValue.split(",")[0];
    const candidate = normalizeIpCandidate(firstCandidate);
    if (candidate) {
      return candidate;
    }
  }

  const fromForwarded = parseForwardedHeader(request.headers.get("forwarded"));
  if (fromForwarded) {
    return fromForwarded;
  }

  const fromRequestIp = normalizeIpCandidate((request as NextRequest & { ip?: string }).ip);
  if (fromRequestIp) {
    return fromRequestIp;
  }

  const ua = sanitizeForKey(request.headers.get("user-agent"), "ua");
  const lang = sanitizeForKey(request.headers.get("accept-language"), "lang");
  return `anon:${ua}:${lang}`;
}

export function jsonError(message: string, error: unknown, fallbackStatus = 500) {
  const status = error instanceof LodgifyError ? error.status : fallbackStatus;
  const safeStatus = status >= 400 && status < 600 ? status : fallbackStatus;
  const reason =
    error instanceof LodgifyError
      ? error.details ?? error.message
      : error instanceof Error
        ? error.message
        : undefined;

  console.error("[lodgify] api error", {
    message,
    status: safeStatus,
    ...(reason ? { reason } : {}),
    ...(error instanceof LodgifyError ? { url: error.url } : {}),
  });
  return NextResponse.json(
    {
      error: message,
      status: safeStatus,
      ...(reason ? { reason } : {}),
    },
    { status: safeStatus },
  );
}

export function jsonRateLimit() {
  return NextResponse.json(
    {
      error: "Too many requests",
      status: 429,
    },
    { status: 429 },
  );
}
