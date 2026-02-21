import { MapPin } from "lucide-react";

import type { PracticalTransportColumn } from "@/lib/content";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { IconBadge } from "@/components/ui/IconBadge";

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
          {columns.map((column) => (
            <div key={column.title} className="space-y-3 text-left">
              <h3 className="text-sm font-semibold text-[color:rgb(var(--heading-warm-light))]">
                {column.title}
              </h3>
              <div className="space-y-2 text-base leading-7 text-slate-600">
                {column.bullets.map((bullet) => (
                  <p key={bullet}>{bullet}</p>
                ))}
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
