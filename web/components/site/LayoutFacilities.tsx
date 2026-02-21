import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type LayoutGroup = {
  heading?: string;
  items: string[];
};

function buildLayoutGroups(items: string[]) {
  const groups: LayoutGroup[] = [];
  let active: LayoutGroup | null = null;

  items.forEach((item) => {
    const trimmed = item.trim();
    const isHeading = trimmed.endsWith(":");

    if (isHeading) {
      active = { heading: trimmed, items: [] };
      groups.push(active);
      return;
    }

    if (!active) {
      active = { items: [] };
      groups.push(active);
    }

    active.items.push(item);
  });

  return groups;
}

type LayoutFacilitiesProps = {
  title: string;
  items: string[];
};

export function LayoutFacilities({ title, items }: LayoutFacilitiesProps) {
  const groups = buildLayoutGroups(items);

  return (
    <section className="text-left">
      <Card className="bg-white text-left">
        <CardHeader className="pb-4">
          <CardTitle>{title}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-5">
          {groups.map((group, index) => (
            <div key={`${group.heading ?? "items"}-${index}`} className="space-y-2">
              {group.heading ? (
                <div className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                  {group.heading.replace(/:$/, "")}
                </div>
              ) : null}
              <ul className="list-disc space-y-2 pl-5 text-base leading-7 text-slate-600">
                {group.items.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </div>
          ))}
        </CardContent>
      </Card>
    </section>
  );
}
