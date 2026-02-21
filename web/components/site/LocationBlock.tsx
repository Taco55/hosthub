import { Home, Mountain, MountainSnow, Snowflake, TreePine } from "lucide-react";
import type { LucideIcon } from "lucide-react";

import { InteractiveMap } from "@/components/interactive-map";
import { Button } from "@/components/ui/button";
import { IconBadge } from "@/components/ui/IconBadge";
import { SectionHeading } from "@/components/section-heading";
import type { DistanceItem } from "@/lib/content";

type LocationBlockProps = {
  title: string;
  locationShort: string;
  distances: DistanceItem[];
  mapQuery: string;
  mapEmbedUrl: string;
  mapLinkUrl: string;
  ctaLabel: string;
  footerTitle?: string;
};

type LocationIconRule = {
  keywords: string[];
  icon: LucideIcon;
};

const locationIconRules: LocationIconRule[] = [
  { keywords: ["cross-country", "langlauf", "langrenn"], icon: TreePine },
  { keywords: ["ski lift", "skilift", "lift", "heis"], icon: MountainSnow },
  { keywords: ["lodge", "skistar"], icon: Home },
  { keywords: ["transport"], icon: Snowflake },
  {
    keywords: [
      "hiking",
      "mountain bike",
      "bikeroute",
      "bikeroutes",
      "wandel",
      "terrengsykkel",
      "sykkel",
      "stier",
      "trails",
      "routes",
      "trail",
    ],
    icon: Mountain,
  },
];

function normalizeLabel(label: string) {
  return label
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

function getLocationIcon(label: string) {
  const normalized = normalizeLabel(label);
  const rule = locationIconRules.find(({ keywords }) =>
    keywords.some((keyword) => normalized.includes(keyword)),
  );
  return rule?.icon ?? Mountain;
}

export function LocationBlock({
  title,
  locationShort,
  distances,
  mapQuery,
  mapEmbedUrl,
  mapLinkUrl,
  ctaLabel,
  footerTitle,
}: LocationBlockProps) {
  return (
    <section className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,1.2fr)] lg:grid-rows-[auto_1fr] lg:gap-x-6 lg:gap-y-4 lg:items-start">
      <div className="text-center lg:col-span-2 lg:row-start-1">
        <SectionHeading title={title} subtitle={locationShort} align="center" />
      </div>
      <div className="space-y-4 text-center lg:col-start-1 lg:row-start-2">
        <ul className="space-y-3">
          {distances.map((distance) => {
            const Icon = getLocationIcon(distance.label);
            return (
              <li key={distance.label}>
                <div className="flex items-start gap-4 rounded-2xl border border-border/60 bg-white p-4 text-left shadow-sm">
                  <IconBadge icon={<Icon />} />
                  <div className="space-y-1">
                    <div className="text-base font-medium text-[color:rgb(var(--heading-warm-light))]">
                      {distance.label}
                    </div>
                    <div className="text-base leading-7 text-slate-600">
                      {distance.value}
                    </div>
                  </div>
                </div>
              </li>
            );
          })}
        </ul>
      </div>
      <div className="relative overflow-hidden rounded-2xl border border-border/60 bg-white shadow-sm lg:col-start-2 lg:row-start-2">
        <div className="absolute right-3 top-3 z-20">
          <Button asChild variant="outline" size="sm" className="bg-white/90 shadow-sm">
            <a href={mapLinkUrl} target="_blank" rel="noreferrer">
              {ctaLabel}
            </a>
          </Button>
        </div>
        <InteractiveMap
          title={`${mapQuery} map`}
          src={mapEmbedUrl}
          className="h-72 w-full border-0 md:h-96"
        />
      </div>
      {footerTitle ? (
        <div className="text-center lg:col-span-2 lg:row-start-3">
          <SectionHeading title={footerTitle} align="center" />
        </div>
      ) : null}
    </section>
  );
}
