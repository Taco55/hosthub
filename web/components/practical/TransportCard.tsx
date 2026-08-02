import { MapPin } from "lucide-react";

import type { PracticalTransportColumn } from "@/lib/content";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { IconBadge } from "@/components/ui/IconBadge";
import { cmsField } from "@/lib/cms-field";
import { rowFieldPath, textRows } from "@/lib/cms-rows";

type TransportCardProps = {
  title: string;
  columns: PracticalTransportColumn[];
};

export function TransportCard({ title, columns }: TransportCardProps) {
  return (
    <Card className="bg-white">
      <CardHeader className="flex-row items-center gap-3 pb-4">
        <IconBadge size="sm" icon={<MapPin />} />
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid max-w-4xl gap-6 pl-11 md:grid-cols-3">
          {columns.map((column, columnIndex) => {
            const columnId = column.id ?? columnIndex;
            return (
              <div key={columnId} className="space-y-3 text-left">
                <h3
                  className="text-sm font-semibold text-[color:rgb(var(--heading-warm-light))]"
                  {...cmsField(
                    "page/practical",
                    "transport",
                    "columns",
                    columnId,
                    "title",
                  )}
                >
                  {column.title}
                </h3>
                <div className="space-y-2 text-base leading-7 text-slate-600">
                  {textRows(column.bullets).map((row, index) => (
                    <p
                      key={row.id ?? index}
                      {...cmsField(
                        "page/practical",
                        "transport",
                        "columns",
                        columnId,
                        ...rowFieldPath("bullets", row, index),
                      )}
                    >
                      {row.text}
                    </p>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
}
