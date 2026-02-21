"use client";

import { useRef, useState, type FormEvent } from "react";

import { SectionHeading } from "@/components/section-heading";
import { Container } from "@/components/site/Container";
import type { ContactFormSectionContent } from "@/lib/content";

type ContactFormSectionProps = {
  content: ContactFormSectionContent;
};

export function ContactFormSection({ content }: ContactFormSectionProps) {
  const [status, setStatus] = useState<"idle" | "success" | "error">("idle");
  const [loading, setLoading] = useState(false);
  const startedAtRef = useRef(Date.now());

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    setLoading(true);
    setStatus("idle");
    const data = Object.fromEntries(new FormData(form));

    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      let isSuccess = res.ok;
      let body: { ok?: unknown } | null = null;

      if (res.headers.get("content-type")?.includes("application/json")) {
        const parsed = await res.json().catch(() => null);
        if (parsed && typeof parsed === "object") {
          body = parsed as { ok?: unknown };
        }
        if (body && typeof body.ok === "boolean") {
          isSuccess = body.ok;
        }
      }

      setStatus(isSuccess ? "success" : "error");
      if (isSuccess) form.reset();
    } catch {
      setStatus("error");
    } finally {
      setLoading(false);
    }
  }

  const contactEmail =
    content.subtitle.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i)?.[0] ?? null;
  const emailIndex = contactEmail ? content.subtitle.indexOf(contactEmail) : -1;
  const subtitleNodes =
    !contactEmail || emailIndex === -1 ? (
      content.subtitle
    ) : (
      <>
        {content.subtitle.slice(0, emailIndex)}
        <a
          href={`mailto:${contactEmail}`}
          className="font-semibold text-slate-900 underline underline-offset-4 hover:text-slate-950"
        >
          {contactEmail}
        </a>
        {content.subtitle.slice(emailIndex + contactEmail.length)}
      </>
    );

  return (
    <section>
      <Container>
        <div className="space-y-8">
          <div className="mx-auto max-w-3xl space-y-3 text-center">
            <SectionHeading title={content.title} align="center" />
            <div className="prose mx-auto text-base leading-7 text-slate-600">
              <p>{subtitleNodes}</p>
            </div>
          </div>
          <div className="mx-auto w-full max-w-2xl">
            <form
              onSubmit={handleSubmit}
              className="space-y-4 rounded-2xl border border-border/60 bg-white p-6 shadow-sm"
            >
              <div>
                <label className="text-sm font-medium">{content.form.name.label}</label>
                <input
                  name="name"
                  required
                  placeholder={content.form.name.placeholder}
                  className="mt-1 w-full rounded-md border px-3 py-2"
                />
              </div>

              <div>
                <label className="text-sm font-medium">{content.form.email.label}</label>
                <input
                  name="email"
                  type="email"
                  required
                  placeholder={content.form.email.placeholder}
                  className="mt-1 w-full rounded-md border px-3 py-2"
                />
              </div>

              <div>
                <label className="text-sm font-medium">{content.form.period.label}</label>
                <input
                  name="period"
                  placeholder={content.form.period.placeholder}
                  className="mt-1 w-full rounded-md border px-3 py-2"
                />
              </div>

              <div>
                <label className="text-sm font-medium">{content.form.message.label}</label>
                <textarea
                  name="message"
                  required
                  rows={4}
                  placeholder={content.form.message.placeholder}
                  className="mt-1 w-full rounded-md border px-3 py-2"
                />
              </div>

              <input type="hidden" name="started_at" defaultValue={startedAtRef.current} />

              <div className="hidden" aria-hidden="true">
                <label htmlFor="contact_company">Company</label>
                <input
                  id="contact_company"
                  name="contact_company"
                  type="text"
                  tabIndex={-1}
                  autoComplete="off"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full rounded-md bg-slate-900 py-2 text-white disabled:opacity-70"
              >
                {content.form.submit}
              </button>

              {status === "success" && (
                <p className="text-sm text-green-600">{content.form.success}</p>
              )}
              {status === "error" && (
                <p className="text-sm text-red-600">{content.form.error}</p>
              )}
            </form>
          </div>
        </div>
      </Container>
    </section>
  );
}
