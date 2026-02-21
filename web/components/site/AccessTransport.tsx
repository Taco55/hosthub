import { SectionHeading } from "@/components/section-heading";

type AccessTransportProps = {
  title: string;
  car: string[];
  airports: string[];
  publicTransport: string[];
  notes: string[];
  labels: {
    car: string;
    airports: string;
    publicTransport: string;
  };
};

export function AccessTransport({
  title,
  car,
  airports,
  publicTransport,
  notes,
  labels,
}: AccessTransportProps) {
  return (
    <section className="space-y-6 text-center">
      <SectionHeading title={title} align="center" />
      <div className="rounded-2xl border border-border/60 bg-white p-6 text-center shadow-sm">
        <div className="grid gap-6 text-center md:grid-cols-3">
          <div className="space-y-3">
            <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              {labels.car}
            </p>
            <div className="space-y-2 text-base leading-7 text-slate-600">
              {car.map((paragraph) => (
                <p key={paragraph}>{paragraph}</p>
              ))}
              {notes.length
                ? notes.map((note) => <p key={note}>{note}</p>)
                : null}
            </div>
          </div>
          <div className="space-y-3">
            <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              {labels.publicTransport}
            </p>
            <ul className="list-disc list-inside space-y-2 text-base leading-7 text-slate-600">
              {publicTransport.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </div>
          <div className="space-y-3">
            <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              {labels.airports}
            </p>
            <ul className="list-disc list-inside space-y-2 text-base leading-7 text-slate-600">
              {airports.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
