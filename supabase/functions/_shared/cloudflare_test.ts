// supabase/functions/_shared/cloudflare_test.ts
//
// Run: deno test supabase/functions/_shared/cloudflare_test.ts
//
// The two pure functions here decide what ends up in a UNIQUE column that maps
// a hostname to a customer's content, and which zone gets a DNS record written
// into it. Neither needs a Cloudflare account to be worth pinning.

import { assertEquals } from "jsr:@std/assert@1";

import { normalizeHostname, zoneCandidates } from "./cloudflare.ts";

Deno.test("normalizeHostname accepts what an owner is likely to paste", () => {
  assertEquals(normalizeHostname("example.com"), "example.com");
  assertEquals(normalizeHostname("  Example.COM  "), "example.com");
  assertEquals(normalizeHostname("https://www.example.com"), "www.example.com");
  assertEquals(normalizeHostname("http://example.com/nl?x=1"), "example.com");
  assertEquals(normalizeHostname("example.com."), "example.com");
  assertEquals(normalizeHostname("a.b.example.co.uk"), "a.b.example.co.uk");
  assertEquals(normalizeHostname("xn--ls8h.example.com"), "xn--ls8h.example.com");
});

Deno.test("normalizeHostname rejects what cannot route to one site", () => {
  for (
    const input of [
      "",
      "   ",
      "localhost", // Single label: no public zone can hold it.
      "example.com:8080", // A port is not part of a Host-header match.
      "192.0.2.1", // Numeric TLD means an address, not a domain.
      "-bad.example.com", // Labels may not start with a hyphen.
      "bad-.example.com",
      "exa mple.com",
      "example..com",
      `${"a".repeat(64)}.example.com`, // Label over 63 chars.
    ]
  ) {
    assertEquals(normalizeHostname(input), null, `expected null for "${input}"`);
  }
});

Deno.test("zoneCandidates walks up to the registrable domain", () => {
  assertEquals(zoneCandidates("a.b.example.com"), [
    "a.b.example.com",
    "b.example.com",
    "example.com",
  ]);
  assertEquals(zoneCandidates("example.com"), ["example.com"]);
});

Deno.test("zoneCandidates never offers a bare TLD as a zone", () => {
  // Delegating "com" is not a thing; findZone() would otherwise ask Cloudflare
  // about it on every lookup that misses.
  for (const hostname of ["example.com", "a.b.c.example.com"]) {
    const candidates = zoneCandidates(hostname);
    assertEquals(candidates.some((c) => !c.includes(".")), false);
  }
});
