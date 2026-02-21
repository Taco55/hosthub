import { notFound } from "next/navigation";
import { Car, Clock, PhoneCall, ShieldCheck } from "lucide-react";

import { QuickFactsRow } from "@/components/practical/QuickFactsRow";
import { TransportCard } from "@/components/practical/TransportCard";
import { SectionHeading } from "@/components/section-heading";
import { Container } from "@/components/site/Container";
import { Policies } from "@/components/site/Policies";
import { LayoutFacilitiesCard } from "@/components/sections/LayoutFacilitiesCard";
import { IconBadge } from "@/components/ui/IconBadge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getPracticalContent } from "@/lib/content-provider";
import { isLocale } from "@/lib/i18n";
import {
  resolveRuntimeSiteContext,
  toSiteContentOptions,
} from "@/lib/runtime-site-context";

type PageProps = {
  params: Promise<{ locale: string }>;
};

export default async function PreviewPracticalPage({ params }: PageProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const practical = await getPracticalContent(
    locale,
    toSiteContentOptions(runtimeSite, true),
  );
  const arrivalAccess = practical.arrivalAccess;
  const parkingCharging = practical.parkingCharging;

  return (
    <Container className="py-10 lg:py-14">
      <div className="space-y-10">
        <SectionHeading
          title={practical.header.title}
          subtitle={practical.header.subtitle}
        />
        <QuickFactsRow items={practical.quickFacts} />
        <div className="space-y-8">
          <div className="grid gap-6 lg:grid-cols-2 lg:items-stretch">
            <div className="space-y-6">
              <Card className="bg-white text-left">
                <CardHeader className="flex-row items-center gap-3 pb-4">
                  <IconBadge size="sm" icon={<Clock />} />
                  <CardTitle>{arrivalAccess.title}</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4 text-base leading-7 text-slate-600">
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-1">
                    <div className="text-xs uppercase tracking-wide text-muted-foreground">
                      {arrivalAccess.checkInLabel}
                    </div>
                    <div className="text-base font-medium text-slate-600">
                      {arrivalAccess.checkIn}
                    </div>
                  </div>
                  <div className="space-y-1">
                    <div className="text-xs uppercase tracking-wide text-muted-foreground">
                      {arrivalAccess.checkOutLabel}
                    </div>
                    <div className="text-base font-medium text-slate-600">
                      {arrivalAccess.checkOut}
                    </div>
                  </div>
                </div>
                <ul className="list-disc list-inside space-y-2">
                  {arrivalAccess.bullets.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
                </CardContent>
              </Card>
              <Card className="bg-white text-left">
                <CardHeader className="flex-row items-center gap-3 pb-4">
                  <IconBadge size="sm" icon={<Car />} />
                  <CardTitle>{parkingCharging.title}</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3 text-base leading-7 text-slate-600">
                  <ul className="list-disc list-inside space-y-2">
                    {parkingCharging.bullets.map((item) => (
                      <li key={item}>{item}</li>
                    ))}
                  </ul>
                  <p className="rounded-lg bg-accent/10 px-3 py-2 text-sm text-slate-600">
                    {parkingCharging.callout}
                  </p>
                </CardContent>
              </Card>
              <Card className="bg-white text-left">
                <CardHeader className="flex-row items-center gap-3 pb-4">
                  <IconBadge size="sm" icon={<ShieldCheck />} />
                  <CardTitle>{practical.goodToKnow.title}</CardTitle>
                </CardHeader>
                <CardContent className="text-base leading-7 text-slate-600">
                  <ul className="list-disc list-inside space-y-2">
                    {practical.goodToKnow.bullets.map((item) => (
                      <li key={item}>{item}</li>
                    ))}
                  </ul>
                </CardContent>
              </Card>
            </div>
            <LayoutFacilitiesCard content={practical.layoutFacilities} />
          </div>
          <TransportCard
            title={practical.transport.title}
            columns={practical.transport.columns}
          />
          <div className="grid gap-6 lg:grid-cols-2 lg:items-stretch">
            <Card className="h-full bg-white text-left">
              <CardHeader className="flex-row items-center gap-3 pb-4">
                <IconBadge size="sm" icon={<PhoneCall />} />
                <CardTitle>{practical.contactHelp.title}</CardTitle>
              </CardHeader>
              <CardContent className="text-base leading-7 text-slate-600">
                <ul className="list-disc list-inside space-y-2">
                  {practical.contactHelp.bullets.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </CardContent>
            </Card>
            <Policies
              className="h-full"
              title={practical.agreementsAndPayment.title}
              blocks={practical.agreementsAndPayment.blocks}
            />
          </div>
        </div>
      </div>
    </Container>
  );
}
