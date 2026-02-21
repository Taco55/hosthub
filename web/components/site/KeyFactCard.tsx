import type { ReactNode } from "react";

import { IconBadge } from "@/components/ui/IconBadge";

type KeyFactCardProps = {
  icon: ReactNode;
  value: string;
  label: string;
};

export function KeyFactCard({ icon, value, label }: KeyFactCardProps) {
  return (
    <div className="flex basis-0 flex-1 min-w-0 flex-col gap-3 rounded-xl bg-white/80 px-3 py-2 text-sm shadow-sm md:flex-row md:items-center lg:gap-4">
      <div className="flex justify-center md:justify-start">
        <IconBadge size="sm" icon={icon} />
      </div>
      <div className="flex flex-1 flex-col items-center gap-1 text-center md:items-start md:text-left lg:flex-row lg:items-baseline lg:gap-1">
        <span className="text-sm font-semibold text-slate-500">{value}</span>
        <span className="text-sm font-semibold text-slate-500">{label}</span>
      </div>
    </div>
  );
}
