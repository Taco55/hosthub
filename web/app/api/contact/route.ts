import { NextResponse } from "next/server";
import { Resend } from "resend";

const MIN_SUBMIT_DELAY_MS = 2500;

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
    const contactEmailTo = process.env.CONTACT_EMAIL_TO;

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

    const resendApiKey = process.env.RESEND_API_KEY;
    if (!contactEmailTo) {
      return NextResponse.json({ error: "Missing contact destination" }, { status: 500 });
    }
    if (!resendApiKey) {
      return NextResponse.json({ error: "Missing email API key" }, { status: 500 });
    }

    const resend = new Resend(resendApiKey);
    const { data, error } = await resend.emails.send({
      from: "Trysil Panorama <no-reply@trysilpanorama.com>",
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
