// supabase/functions/delete_user/index.ts
// deno-lint-ignore-file no-explicit-any
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

import { deleteAuthUser } from "../_shared/auth.ts";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SUPABASE_ANON_KEY = env("SUPABASE_ANON_KEY", "SUPABASE_KEY");
const SUPABASE_SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

const STORAGE_BUCKET = "images";
const STORAGE_BATCH_SIZE = 1000;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase environment configuration.");
}

const cors = () => buildCorsHeaders();
const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: cors() });
const jsonError = (status: number, message: string) =>
  jsonResponse({ error: message }, status);

const isMissingRelationError = (error: any) => {
  if (!error) return false;
  const message = `${error.message ?? ""}`.toLowerCase();
  const details = `${error.details ?? ""}`.toLowerCase();

  return (
    error.code === "42P01" ||
    error.code === "PGRST205" ||
    (message.includes("relation") && message.includes("does not exist")) ||
    (details.includes("relation") && details.includes("does not exist")) ||
    message.includes("could not find the table") ||
    message.includes("schema cache")
  );
};

const isMissingColumnError = (error: any, column: string) => {
  if (!error) return false;
  const columnName = column.split(".").pop()?.replace(/"/g, "") ?? column;
  const message = `${error.message ?? ""}`.toLowerCase();
  const details = `${error.details ?? ""}`.toLowerCase();

  return (
    message.includes(`column ${columnName}`) ||
    message.includes(`column "${columnName}"`) ||
    details.includes(`column ${columnName}`) ||
    details.includes(`column "${columnName}"`)
  );
};

type CleanupSpec = {
  table: string;
  columns: readonly string[];
};

const CLEANUP_SPECS: readonly CleanupSpec[] = [
  { table: "profiles", columns: ["id"] },
];

type FileReferenceLookup = {
  select: string;
  column: string;
};

const FILE_REFERENCE_LOOKUPS: readonly FileReferenceLookup[] = [
  {
    select: "remote_full_key, remote_thumbnail_key, items!inner(created_by)",
    column: "items.created_by",
  },
  {
    select: "remote_full_key, remote_thumbnail_key, items!inner(owner_id)",
    column: "items.owner_id",
  },
];

type EdgeSupabaseClient = SupabaseClient<any, "public", any>;

const collectImageKeys = async (
  client: EdgeSupabaseClient,
  userId: string,
): Promise<string[]> => {
  for (const lookup of FILE_REFERENCE_LOOKUPS) {
    const { data, error } = await client
      .from("file_references")
      .select(lookup.select)
      .eq(lookup.column, userId);

    if (!error && Array.isArray(data)) {
      return data
        .flatMap((row: any) => [
          row.remote_full_key,
          row.remote_thumbnail_key,
        ])
        .filter((key): key is string => Boolean(key));
    }

    if (
      isMissingRelationError(error) ||
      isMissingColumnError(error, lookup.column)
    ) {
      continue;
    }

    if (error) throw error;
  }

  return [];
};

const deleteStorageKeys = async (
  client: EdgeSupabaseClient,
  keys: readonly string[],
) => {
  for (let index = 0; index < keys.length; index += STORAGE_BATCH_SIZE) {
    const batch = keys.slice(index, index + STORAGE_BATCH_SIZE);
    const { error } = await client.storage.from(STORAGE_BUCKET).remove(batch);
    if (error) {
      console.warn("[delete_user] storage.remove:", error.message);
    }
  }
};

const deleteDataForUser = async (
  client: EdgeSupabaseClient,
  userId: string,
) => {
  for (const spec of CLEANUP_SPECS) {
    let columnMatched = false;

    for (const column of spec.columns) {
      const { error } = await client.from(spec.table).delete().eq(column, userId);

      if (isMissingRelationError(error)) {
        console.warn(
          `[delete_user] Skipping table ${spec.table}; relation missing.`,
        );
        columnMatched = true;
        break;
      }

      if (!error) {
        columnMatched = true;
        break;
      }

      if (isMissingColumnError(error, column)) {
        continue;
      }

      console.error(
        `[delete_user] Failed deleting from ${spec.table} using ${column}:`,
        error,
      );
      const errorMessage = error?.message ?? JSON.stringify(error);
      throw new Error(
        `Failed to delete from ${spec.table} using ${column}: ${errorMessage}`,
      );
    }

    if (!columnMatched && spec.columns.length > 0) {
      console.warn(
        `[delete_user] Skipped table ${spec.table}; columns ${
          spec.columns.join(
            ", ",
          )
        } not found.`,
      );
    }
  }
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(undefined, { status: 204, headers: cors() });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  try {
    const payload = await req.json().catch(() => ({}));
    const userId = typeof payload?.user_id === "string"
      ? payload.user_id
      : typeof payload?.userId === "string"
      ? payload.userId
      : null;

    if (!userId) {
      return jsonError(400, "Missing or invalid user_id");
    }

    const authorization = req.headers.get("Authorization");
    if (!authorization) {
      return jsonError(401, "Authorization header missing");
    }

    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: authorization,
          apikey: SUPABASE_ANON_KEY,
        },
      },
    });

    const {
      data: authContext,
      error: authError,
    } = await (userClient.auth as Record<string, any>).getUser();

    if (authError) {
      return jsonError(401, authError.message ?? "Unauthorized");
    }

    if (!authContext?.user || authContext.user.id !== userId) {
      return jsonError(403, "Forbidden");
    }

    const adminClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const storageKeys = await collectImageKeys(adminClient, userId);

    await deleteDataForUser(adminClient, userId);

    await deleteStorageKeys(adminClient, storageKeys);

    await deleteAuthUser(adminClient, userId);

    console.log("[delete_user] User deleted successfully", userId);

    return jsonResponse({ success: true });
  } catch (error) {
    let message: string;
    if (error instanceof Error) {
      message = error.message;
    } else if (typeof error === "object" && error !== null) {
      try {
        message = JSON.stringify(error);
      } catch (_) {
        message = String(error);
      }
    } else {
      message = String(error);
    }

    console.error("[delete_user] Unexpected error", error);
    return jsonError(500, message);
  }
});
