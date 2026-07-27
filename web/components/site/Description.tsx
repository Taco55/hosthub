import { SectionHeading } from "@/components/section-heading";
import { cmsField } from "@/lib/cms-field";

type DescriptionProps = {
  title: string;
  paragraphs: string[];
};

export function Description({ title, paragraphs }: DescriptionProps) {
  return (
    <section className="space-y-4 text-center">
      <SectionHeading title={title} align="center" />
      <div className="prose mx-auto space-y-3 text-base leading-7 text-slate-600 text-center">
        {paragraphs.map((paragraph, index) => (
          <p key={paragraph} {...cmsField("cabin/main", "description", index)}>
            {paragraph}
          </p>
        ))}
      </div>
    </section>
  );
}
