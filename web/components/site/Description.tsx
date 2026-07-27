import { SectionHeading } from "@/components/section-heading";
import { cmsField } from "@/lib/cms-field";
import { rowFieldPath, textRows, type TextRow } from "@/lib/cms-rows";

type DescriptionProps = {
  title: string;
  paragraphs: Array<string | TextRow>;
};

export function Description({ title, paragraphs }: DescriptionProps) {
  const rows = textRows(paragraphs);
  return (
    <section className="space-y-4 text-center">
      <SectionHeading title={title} align="center" />
      <div className="prose mx-auto space-y-3 text-base leading-7 text-slate-600 text-center">
        {rows.map((row, index) => (
          <p
            key={row.id ?? row.text}
            {...cmsField(
              "cabin/main",
              ...rowFieldPath("description", row, index),
            )}
          >
            {row.text}
          </p>
        ))}
      </div>
    </section>
  );
}
