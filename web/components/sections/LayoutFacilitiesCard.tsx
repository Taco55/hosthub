import { LayoutGrid } from "lucide-react";

import type { LayoutFacilitiesContent } from "@/lib/content";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { IconBadge } from "@/components/ui/IconBadge";

type Props = {
  content: LayoutFacilitiesContent;
};

export function LayoutFacilitiesCard({ content }: Props) {
  return (
    <Card className="h-full bg-white text-left">
      <CardHeader className="flex-row items-center gap-3 pb-4">
        <IconBadge size="sm" icon={<LayoutGrid />} />
        <CardTitle>{content.title}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-6 text-left">
        {content.sections.map((section) => (
          <div key={section.title}>
            <h3 className="text-sm font-semibold text-[color:rgb(var(--heading-warm-light))]">
              {section.title}
            </h3>

            {section.intro ? (
              <p className="mt-1 text-sm text-slate-600">{section.intro}</p>
            ) : null}

            <ul className="mt-3 list-disc space-y-1 pl-5 text-sm text-slate-700">
              {section.bullets.map((bullet) => (
                <li key={bullet}>{bullet}</li>
              ))}
            </ul>
          </div>
        ))}
      </CardContent>
    </Card>
  );
}
