import { LayoutGrid } from "lucide-react";

import type { LayoutFacilitiesContent } from "@/lib/content";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { IconBadge } from "@/components/ui/IconBadge";
import { cmsField } from "@/lib/cms-field";
import { rowFieldPath, textRows } from "@/lib/cms-rows";

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
        {content.sections.map((section, sectionIndex) => {
          const sectionId = section.id ?? sectionIndex;
          const at = (...rest: (string | number)[]) =>
            cmsField("page/practical", "layoutFacilities", "sections", sectionId, ...rest);
          return (
            <div key={sectionId}>
              <h3
                className="text-sm font-semibold text-[color:rgb(var(--heading-warm-light))]"
                {...at("title")}
              >
                {section.title}
              </h3>

              {section.intro ? (
                <p className="mt-1 text-sm text-slate-600" {...at("intro")}>
                  {section.intro}
                </p>
              ) : null}

              <ul className="mt-3 list-disc space-y-1 pl-5 text-sm text-slate-700">
                {textRows(section.bullets).map((row, index) => (
                  <li key={row.id ?? index} {...at(...rowFieldPath("bullets", row, index))}>
                    {row.text}
                  </li>
                ))}
              </ul>
            </div>
          );
        })}
      </CardContent>
    </Card>
  );
}
