import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Snowflake, Sun } from "lucide-react";

import { SectionHeading } from "@/components/section-heading";
import { Container } from "@/components/site/Container";
import { Card, CardContent } from "@/components/ui/card";
import { IconBadge } from "@/components/ui/IconBadge";
import { getAreaContent, getLocalizedContent } from "@/lib/content-provider";
import { getDictionary, isLocale } from "@/lib/i18n";
import {
  resolveRuntimeSiteContext,
  toSiteContentOptions,
} from "@/lib/runtime-site-context";

type PageProps = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) {
    return {};
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const localized = await getLocalizedContent(
    locale,
    toSiteContentOptions(runtimeSite),
  );
  const t = getDictionary(locale);
  return {
    title: t.pages.area,
    description: localized.tagline,
  };
}

export default async function AreaPage({ params }: PageProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const t = getDictionary(locale);
  const area = await getAreaContent(locale, toSiteContentOptions(runtimeSite));

  const icons = [Snowflake, Sun];

  return (
    <Container className="py-10 lg:py-14">
      <div className="space-y-10">
        <SectionHeading title={t.pages.area} subtitle={area.intro} />
        <div className="grid gap-6 md:grid-cols-2">
          {area.sections.map((section, index) => {
            const Icon = icons[index % icons.length];
            return (
              <Card key={section.title} className="bg-white">
                <CardContent className="space-y-4 pt-6">
                  <div className="flex items-center gap-3">
                    <IconBadge icon={<Icon />} />
                    <div className="font-sans text-lg font-medium text-[color:rgb(var(--heading-warm-light))] md:text-xl">
                      {section.title}
                    </div>
                  </div>
                  <p className="text-base leading-7 text-slate-600">{section.description}</p>
                  <ul className="space-y-2 text-base leading-7 text-slate-600">
                    {section.bullets.map((bullet) => (
                      <li key={bullet} className="flex gap-2">
                        <span className="mt-2 h-1.5 w-1.5 rounded-full bg-foreground/50" />
                        <span>{bullet}</span>
                      </li>
                    ))}
                  </ul>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>
    </Container>
  );
}
