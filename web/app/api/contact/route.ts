import { NextResponse } from "next/server";
import { Resend } from "resend";

import { resolveRuntimeSiteContext } from "@/lib/runtime-site-context";
import { getSiteSettings } from "@/lib/site-settings";

const MIN_SUBMIT_DELAY_MS = 2500;

// Strip characters that could break the email "Name <addr>" header.
function sanitizeFromName(name: string): string {
  const cleaned = name.replace(/[\r\n<>"]/g, "").trim();
  return cleaned || "HostHub";
}

export async function POST(req: Request) {
  try {
    const {
      name,
      email,
      period,
      message,
      contact_company: contactCompany,
      started_at: startedAt,
    } = await req.json();
    const normalizedName = typeof name === "string" ? name.trim() : "";
    const normalizedEmail = typeof email === "string" ? email.trim() : "";
    const normalizedPeriod = typeof period === "string" ? period.trim() : "";
    const normalizedMessage = typeof message === "string" ? message.trim() : "";
    const normalizedContactCompany =
      typeof contactCompany === "string" ? contactCompany.trim() : "";
    const normalizedStartedAt =
      typeof startedAt === "string"
        ? Number(startedAt)
        : typeof startedAt === "number"
          ? startedAt
          : Number.NaN;
    if (!normalizedName || !normalizedEmail || !normalizedMessage) {
      return NextResponse.json({ error: "Missing fields" }, { status: 400 });
    }

    if (normalizedContactCompany) {
      return NextResponse.json({ ok: true });
    }

    if (!Number.isFinite(normalizedStartedAt)) {
      return NextResponse.json({ ok: true });
    }

    if (Date.now() - normalizedStartedAt < MIN_SUBMIT_DELAY_MS) {
      return NextResponse.json({ ok: true });
    }

    // Resolve per-site config (contact recipient + sender name) from the request
    // domain. Falls back to the worker env for sites with no values set yet.
    const site = await resolveRuntimeSiteContext();
    if (!site.siteId) {
      // Without a site there is no recipient that belongs to this domain, and
      // the env fallback below is platform-wide: sending would deliver a
      // visitor's enquiry to the wrong inbox.
      console.error(
        `[contact] refusing to send: host ${site.domain ?? "(none)"} resolved to no site (${site.source})`,
      );
      return NextResponse.json({ error: "Unknown site" }, { status: 404 });
    }
    const settings = await getSiteSettings(site.siteId);

    const contactEmailTo = settings?.contactEmail || process.env.CONTACT_EMAIL_TO;
    const fromName = sanitizeFromName(
      settings?.emailFromName ||
        settings?.name ||
        process.env.EMAIL_FROM_NAME ||
        "HostHub",
    );
    // Platform sending address on the verified domain. No default: the previous
    // one was a customer's own domain, which every other site would then have
    // sent its mail from.
    const fromAddress = process.env.EMAIL_FROM_ADDRESS?.trim();

    const resendApiKey = process.env.RESEND_API_KEY;
    if (!contactEmailTo) {
      return NextResponse.json({ error: "Missing contact destination" }, { status: 500 });
    }
    if (!fromAddress) {
      console.error("[contact] EMAIL_FROM_ADDRESS is not configured");
      return NextResponse.json({ error: "Missing sender address" }, { status: 500 });
    }
    if (!resendApiKey) {
      return NextResponse.json({ error: "Missing email API key" }, { status: 500 });
    }

    const resend = new Resend(resendApiKey);
    const { data, error } = await resend.emails.send({
      from: `${fromName} <${fromAddress}>`,
      to: contactEmailTo,
      replyTo: normalizedEmail,
      subject: `Nieuw bericht via website – ${normalizedName}`,
      html: `
        <strong>Naam:</strong> ${normalizedName}<br/>
        <strong>E-mail:</strong> ${normalizedEmail}<br/>
        <strong>Gewenste periode:</strong> ${normalizedPeriod || "-"}<br/><br/>
        <strong>Bericht:</strong><br/>
        ${normalizedMessage.replace(/\n/g, "<br/>")}
      `,
    });

    if (error) {
      console.error("Contact email send failed.", error);
      return NextResponse.json({ error: "Send failed" }, { status: 502 });
    }

    return NextResponse.json({ ok: true, id: data?.id ?? null });
  } catch (error) {
    console.error("Contact email handler failed.", error);
    return NextResponse.json({ error: "Send failed" }, { status: 500 });
  }
}
