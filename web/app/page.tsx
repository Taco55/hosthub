import { redirect } from "next/navigation";

import { detectLocale } from "@/lib/detect-locale";

/**
 * `/` carries no language, so it cannot render — it picks one and forwards.
 * This used to be the Proxy's job; see lib/detect-locale.ts for why it moved.
 */
export default async function RootPage() {
  redirect(`/${await detectLocale()}`);
}
