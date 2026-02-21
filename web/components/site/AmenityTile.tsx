import type { ComponentType } from "react";

import { IconBadge } from "@/components/ui/IconBadge";

type AmenityTileProps = {
  icon: ComponentType<any>;
  label: string;
};

export function AmenityTile({ icon: Icon, label }: AmenityTileProps) {
  return (
    <div className="flex h-full flex-col items-center gap-2 rounded-xl border border-border/60 bg-white p-3 text-center shadow-sm md:aspect-[4/3] md:justify-center">
      <IconBadge size="sm" icon={<Icon />} />
      <span className="text-sm font-medium text-slate-700">{label}</span>
    </div>
  );
}
