type CorsOptions = {
  origin?: string;
  methods?: string[];
  headers?: string[];
  contentType?: string;
};

export function buildCorsHeaders(
  options: CorsOptions = {},
): Record<string, string> {
  const origin = options.origin ?? "*";
  const methods = options.methods ?? ["POST", "OPTIONS"];
  const headers = options.headers ?? ["*"];
  const contentType = options.contentType ?? "application/json";

  const corsHeaders: Record<string, string> = {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Methods": methods.join(", "),
    "Access-Control-Allow-Headers": headers.join(", "),
    "Content-Type": contentType,
  };

  if (origin !== "*") {
    corsHeaders.Vary = "Origin";
  }

  return corsHeaders;
}

export function jsonResponse(
  body: unknown,
  status = 200,
  corsOptions: CorsOptions = {},
): Response {
  const headers = buildCorsHeaders({
    ...corsOptions,
    contentType: "application/json; charset=utf-8",
  });
  return new Response(JSON.stringify(body), { status, headers });
}

export function jsonError(
  status: number,
  message: string,
  corsOptions: CorsOptions = {},
): Response {
  return jsonResponse({ error: message }, status, corsOptions);
}
