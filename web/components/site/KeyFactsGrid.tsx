import { BedSingle, Ruler, ShowerHead, Users } from "lucide-react";

import { Container } from "@/components/site/Container";
import { KeyFactCard } from "@/components/site/KeyFactCard";
import type { KeyFactContent } from "@/lib/content";

const icons = [Users, Ruler, BedSingle, ShowerHead];

type KeyFactsGridProps = {
  items: KeyFactContent[];
};

export function KeyFactsGrid({ items }: KeyFactsGridProps) {
  return (
    <section>
      <Container>
        <div className="mx-auto flex w-full max-w-5xl flex-nowrap items-stretch justify-center gap-2 overflow-x-auto">
          {items.map((item, index) => {
            const Icon = icons[index] ?? icons[icons.length - 1];
            return (
              <KeyFactCard
                key={`${item.value}-${item.label}`}
                icon={<Icon />}
                value={item.value}
                label={item.label}
              />
            );
          })}
        </div>
      </Container>
    </section>
  );
}
