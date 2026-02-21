import { CheckCircle2 } from "lucide-react";

import { IconBadge } from "@/components/ui/IconBadge";

type AmenitiesListProps = {
  amenities: string[];
};

export function AmenitiesList({ amenities }: AmenitiesListProps) {
  return (
    <ul className="grid gap-3 md:grid-cols-2">
      {amenities.map((amenity) => (
        <li key={amenity} className="flex items-center gap-3 text-base leading-7 text-slate-600">
          <IconBadge size="sm" icon={<CheckCircle2 />} />
          <span>{amenity}</span>
        </li>
      ))}
    </ul>
  );
}
