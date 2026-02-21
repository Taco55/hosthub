import { InteractiveMap } from "@/components/interactive-map";
import { Button } from "@/components/ui/button";

type LocationMapProps = {
  title: string;
  description: string;
  mapEmbedUrl: string;
  mapLinkUrl: string;
  ctaLabel: string;
};

export function LocationMap({
  title,
  description,
  mapEmbedUrl,
  mapLinkUrl,
  ctaLabel,
}: LocationMapProps) {
  return (
    <section className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,1.2fr)] lg:items-center">
      <div className="space-y-4">
        <h2 className="font-sans text-2xl font-semibold tracking-tight text-[color:rgb(var(--heading-warm))] md:text-3xl">
          {title}
        </h2>
        <p className="text-base leading-7 text-slate-600">{description}</p>
        <Button asChild variant="outline">
          <a href={mapLinkUrl} target="_blank" rel="noreferrer">
            {ctaLabel}
          </a>
        </Button>
      </div>
      <div className="overflow-hidden rounded-3xl border border-border/60 bg-muted/30">
        <InteractiveMap
          title={title}
          src={mapEmbedUrl}
          className="h-72 w-full border-0 md:h-96"
        />
      </div>
    </section>
  );
}
