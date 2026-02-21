import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";

type HouseRulesProps = {
  title: string;
  bullets: string[];
  checkIn: string;
  checkOut: string;
  cleaningNote: string;
  wifiNote: string;
  showCheckTimes?: boolean;
  showNotes?: boolean;
  labels: {
    checkIn: string;
    checkOut: string;
  };
};

export function HouseRules({
  title,
  bullets,
  checkIn,
  checkOut,
  cleaningNote,
  wifiNote,
  showCheckTimes = true,
  showNotes = true,
  labels,
}: HouseRulesProps) {
  return (
    <section>
      <Accordion
        type="single"
        collapsible
        className="rounded-2xl border border-border/60 bg-white shadow-sm"
      >
        <AccordionItem value="house-rules" className="border-b-0">
          <AccordionTrigger className="justify-center gap-2 px-6 text-center font-sans text-2xl font-semibold tracking-tight text-[color:rgb(var(--heading-warm))] md:text-3xl">
            {title}
          </AccordionTrigger>
          <AccordionContent className="px-6 pb-6 text-center">
            <div className="space-y-4 text-center">
              {showCheckTimes ? (
                <div className="grid gap-4 text-center sm:grid-cols-2">
                  <div>
                    <div className="text-xs uppercase tracking-wide text-muted-foreground">
                      {labels.checkIn}
                    </div>
                    <div className="text-base font-medium text-slate-600">{checkIn}</div>
                  </div>
                  <div>
                    <div className="text-xs uppercase tracking-wide text-muted-foreground">
                      {labels.checkOut}
                    </div>
                    <div className="text-base font-medium text-slate-600">
                      {checkOut}
                    </div>
                  </div>
                </div>
              ) : null}
              <ul className="list-disc list-inside space-y-2 text-base leading-7 text-slate-600">
                {bullets.map((bullet) => (
                  <li key={bullet}>{bullet}</li>
                ))}
              </ul>
              {showNotes ? (
                <div className="space-y-2 text-base leading-7 text-slate-600">
                  <p>{cleaningNote}</p>
                  <p>{wifiNote}</p>
                </div>
              ) : null}
            </div>
          </AccordionContent>
        </AccordionItem>
      </Accordion>
    </section>
  );
}
