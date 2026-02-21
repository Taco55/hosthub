export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (!url.pathname.startsWith("/admin")) {
      return new Response("Not found", { status: 404 });
    }

    if (url.pathname === "/admin") {
      url.pathname = "/admin/";
      return Response.redirect(url.toString(), 301);
    }

    const assetPath = url.pathname.replace(/^\/admin/, "") || "/";
    const assetUrl = new URL(`${assetPath}${url.search}`, url.origin);
    return env.ASSETS.fetch(new Request(assetUrl.toString(), request));
  },
};
