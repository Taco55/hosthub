function normalizeBasePath(value, fallback = "/") {
  const raw = (value ?? "").trim();
  if (!raw) return fallback;

  const withLeadingSlash = raw.startsWith("/") ? raw : `/${raw}`;
  const trimmed = withLeadingSlash.replace(/\/+$/, "");
  if (!trimmed || trimmed == "/") return "/";
  return trimmed;
}

function isLikelyAssetPath(pathname) {
  const lastSegment = pathname.split("/").pop() ?? "";
  return lastSegment.includes(".");
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const adminBasePath = normalizeBasePath(env.HOSTHUB_ADMIN_PATH, "/");
    const isRootBasePath = adminBasePath === "/";
    const adminPrefix = `${adminBasePath}/`;

    if (!isRootBasePath) {
      if (url.pathname != adminBasePath && !url.pathname.startsWith(adminPrefix)) {
        return new Response("Not found", { status: 404 });
      }

      if (url.pathname === adminBasePath) {
        url.pathname = adminPrefix;
        return Response.redirect(url.toString(), 301);
      }
    }

    const assetPath = isRootBasePath
      ? url.pathname || "/"
      : url.pathname.slice(adminBasePath.length) || "/";
    const assetUrl = new URL(`${assetPath}${url.search}`, url.origin);
    const assetRequest = new Request(assetUrl.toString(), request);
    const assetResponse = await env.ASSETS.fetch(assetRequest);
    const method = request.method.toUpperCase();
    const isDocumentRequest = method === "GET" || method === "HEAD";
    const isAppRoute = isDocumentRequest && !isLikelyAssetPath(assetPath);
    const isRedirect =
      assetResponse.status >= 300 && assetResponse.status < 400;
    const shouldFallbackToShell =
      isAppRoute && (assetResponse.status === 404 || isRedirect);

    if (!shouldFallbackToShell) {
      return assetResponse;
    }

    // SPA fallback for Flutter routes like /calendar and /settings.
    const shellUrl = new URL(`/${url.search}`, url.origin);
    return env.ASSETS.fetch(new Request(shellUrl.toString(), request));
  },
};
