function normalizeBasePath(value, fallback = "/") {
  const raw = (value ?? "").trim();
  if (!raw) return fallback;

  const withLeadingSlash = raw.startsWith("/") ? raw : `/${raw}`;
  const trimmed = withLeadingSlash.replace(/\/+$/, "");
  if (!trimmed || trimmed == "/") return "/";
  return trimmed;
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
    return env.ASSETS.fetch(new Request(assetUrl.toString(), request));
  },
};
