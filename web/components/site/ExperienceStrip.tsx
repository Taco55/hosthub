import { Home, Mountain, Snowflake, TreePine, Waves } from "lucide-react";

import { IconBadge } from "@/components/ui/IconBadge";

type ExperienceStripProps = {
  items: string[];
};

const icons = [Mountain, Snowflake, Waves, TreePine, Home];

export function ExperienceStrip({ items }: ExperienceStripProps) {
  return (
    <section className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
      {items.map((item, index) => {
        const Icon = icons[index % icons.length];
        return (
          <div
            key={item}
            className="flex items-center gap-3 rounded-2xl border border-border/60 bg-white/80 px-4 py-3 shadow-sm"
          >
            <IconBadge size="sm" icon={<Icon />} />
            <span className="text-base font-medium text-[color:rgb(var(--heading-warm-light))]">
              {item}
            </span>
          </div>
        );
      })}
    </section>
  );
}
