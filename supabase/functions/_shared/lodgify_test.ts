// supabase/functions/_shared/lodgify_test.ts
//
// Run: deno test supabase/functions/_shared/lodgify_test.ts
//
// Two things worth pinning without a live Lodgify account or database: that
// borrowing the owner's key respects the caller's role, and that a rate limit
// survives the proxy with its Retry-After intact.

import { assertEquals } from "jsr:@std/assert@1";

import {
  proxyLodgifyResponse,
  resolveEffectiveLodgifyApiKey,
} from "./lodgify.ts";

type Row = Record<string, unknown>;

/**
 * The narrow slice of the Supabase client these calls use: `.from(table)` then
 * `.select(...)` with either `.eq(...).maybeSingle()` or `.eq(...).order(...)`.
 */
function fakeClient(tables: {
  lodgify_api_keys?: Row[];
  site_members?: Row[];
}) {
  // deno-lint-ignore no-explicit-any
  const build = (rows: Row[]): any => {
    let filtered = rows;
    const chain = {
      // deno-lint-ignore no-explicit-any
      select: (_columns: string) => chain as any,
      eq: (column: string, value: unknown) => {
        filtered = filtered.filter((row) => row[column] === value);
        return chain;
      },
      order: (_column: string, _opts?: unknown) =>
        Promise.resolve({ data: filtered, error: null }),
      maybeSingle: () =>
        Promise.resolve({ data: filtered[0] ?? null, error: null }),
    };
    return chain;
  };

  return {
    from: (table: string) =>
      build(
        table === "lodgify_api_keys"
          ? tables.lodgify_api_keys ?? []
          : tables.site_members ?? [],
      ),
    // deno-lint-ignore no-explicit-any
  } as any;
}

const OWNER = "owner-1";
const MEMBER = "member-1";

const ownerKeyTables = {
  lodgify_api_keys: [{ profile_id: OWNER, api_key: "owner-key" }],
};

function membership(role: string) {
  return [{
    profile_id: MEMBER,
    role,
    site_id: "site-1",
    created_at: "2026-01-01T00:00:00Z",
    sites: { owner_profile_id: OWNER },
  }];
}

Deno.test("a viewer may borrow the owner's key for a read", async () => {
  const { data, error } = await resolveEffectiveLodgifyApiKey(
    fakeClient({ ...ownerKeyTables, site_members: membership("viewer") }),
    MEMBER,
  );
  assertEquals(error, null);
  assertEquals(data, "owner-key");
});

Deno.test("a viewer may not borrow it for a write", async () => {
  const { data, error } = await resolveEffectiveLodgifyApiKey(
    fakeClient({ ...ownerKeyTables, site_members: membership("viewer") }),
    MEMBER,
    { minRole: "editor" },
  );
  assertEquals(error, null);
  // No key, so lodgify-reservations answers "add one in Settings" rather than
  // PATCHing the owner's reservations on a viewer's behalf.
  assertEquals(data, null);
});

Deno.test("an editor may borrow it for a write", async () => {
  const { data } = await resolveEffectiveLodgifyApiKey(
    fakeClient({ ...ownerKeyTables, site_members: membership("editor") }),
    MEMBER,
    { minRole: "editor" },
  );
  assertEquals(data, "owner-key");
});

Deno.test("an owner may too", async () => {
  const { data } = await resolveEffectiveLodgifyApiKey(
    fakeClient({ ...ownerKeyTables, site_members: membership("owner") }),
    MEMBER,
    { minRole: "editor" },
  );
  assertEquals(data, "owner-key");
});

Deno.test("your own key is never gated on a role", async () => {
  const { data } = await resolveEffectiveLodgifyApiKey(
    fakeClient({
      lodgify_api_keys: [{ profile_id: MEMBER, api_key: "my-key" }],
      site_members: [],
    }),
    MEMBER,
    { minRole: "editor" },
  );
  assertEquals(data, "my-key");
});

Deno.test("an unknown role never satisfies a minimum", async () => {
  const { data } = await resolveEffectiveLodgifyApiKey(
    fakeClient({ ...ownerKeyTables, site_members: membership("something-new") }),
    MEMBER,
    { minRole: "viewer" },
  );
  assertEquals(data, null);
});

Deno.test("a rate limit keeps its status and its Retry-After", async () => {
  const upstream = new Response(JSON.stringify({ message: "slow down" }), {
    status: 429,
    headers: { "Retry-After": "30" },
  });

  const response = await proxyLodgifyResponse(upstream);

  assertEquals(response.status, 429);
  assertEquals(response.headers.get("Retry-After"), "30");
  assertEquals(await response.json(), { message: "slow down" });
});

Deno.test("a rate limit with a non-JSON body stays a 429", async () => {
  const upstream = new Response("Too Many Requests", {
    status: 429,
    headers: { "Retry-After": "60" },
  });

  const response = await proxyLodgifyResponse(upstream);

  // Not a 502: the caller has to be able to see the one status it must react to.
  assertEquals(response.status, 429);
  assertEquals(response.headers.get("Retry-After"), "60");
});

Deno.test("an unparseable success body is a 502", async () => {
  const response = await proxyLodgifyResponse(
    new Response("<html>nope</html>", { status: 200 }),
  );
  assertEquals(response.status, 502);
});

Deno.test("an empty body keeps the upstream status", async () => {
  const response = await proxyLodgifyResponse(new Response("", { status: 200 }));
  assertEquals(response.status, 200);
  assertEquals(await response.json(), {});
});

Deno.test("a 204 comes back without a body instead of throwing", async () => {
  // Response refuses a body on 204, so building one would have crashed the
  // function on an ordinary empty reply.
  const response = await proxyLodgifyResponse(new Response(null, { status: 204 }));
  assertEquals(response.status, 204);
  assertEquals(response.body, null);
});
