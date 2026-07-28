import type { ComponentType, SVGProps } from "react";
import { Check } from "lucide-react";

import { IconBadge } from "@/components/ui/IconBadge";

type AmenityTileProps = {
  /**
   * The icon for a known amenity. Omitted for an item the owner typed: the
   * registry is keyed by ids, and guessing an icon from free text would put a
   * shower next to "wood for the stove".
   */
  icon?: ComponentType<SVGProps<SVGSVGElement>>;
  label: string;
};

export function AmenityTile({ icon: Icon, label }: AmenityTileProps) {
  return (
    <div className="flex h-full flex-col items-center gap-2 rounded-xl border border-border/60 bg-white p-3 text-center shadow-sm md:aspect-[4/3] md:justify-center">
      <IconBadge size="sm" icon={Icon ? <Icon /> : <Check />} />
      <span className="text-sm font-medium text-slate-700">{label}</span>
    </div>
  );
}
