import type { PracticalQuickFact } from "@/lib/content";

type QuickFactsRowProps = {
  items: PracticalQuickFact[];
};

export function QuickFactsRow({ items }: QuickFactsRowProps) {
  return (
    <div className="grid gap-3 sm:grid-cols-3 lg:grid-cols-6">
      {items.map((item) => (
        <div
          key={`${item.label}-${item.value}`}
          className="rounded-xl border border-border/60 bg-white/80 px-4 py-3 text-left shadow-sm"
        >
          <div className="text-xs uppercase tracking-wide text-muted-foreground">
            {item.label}
          </div>
          <div className="text-base font-semibold text-slate-700">{item.value}</div>
        </div>
      ))}
    </div>
  );
}
