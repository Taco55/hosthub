import { notFound } from "next/navigation";

import { SectionHeading } from "@/components/section-heading";
import { Container } from "@/components/site/Container";
import { Card, CardContent } from "@/components/ui/card";
import { getPrivacyContent } from "@/lib/content-provider";
import { getDictionary, isLocale } from "@/lib/i18n";

type PageProps = {
  params: Promise<{ locale: string }>;
};

export default async function PreviewPrivacyPage({ params }: PageProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const t = getDictionary(locale);
  const privacy = await getPrivacyContent(locale, { preview: true });

  return (
    <Container className="max-w-5xl py-10 lg:py-14">
      <div className="space-y-8">
        <SectionHeading title={t.pages.privacy} subtitle={privacy.intro} />
        <Card className="bg-white">
          <CardContent className="prose space-y-4 pt-6 text-base leading-7 text-slate-600">
            {privacy.bullets.map((item) => (
              <p key={item}>{item}</p>
            ))}
          </CardContent>
        </Card>
      </div>
    </Container>
  );
}
