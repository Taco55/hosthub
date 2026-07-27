import { cn } from "@/lib/utils";
import type { ReactNode } from "react";

type SectionHeadingProps = {
  title: string;
  subtitle?: ReactNode;
  align?: "left" | "center";
  /**
   * CMS addresses (`contentType/slug:json.path`) for the heading's own text,
   * when it comes from an editable field. Set by the caller, because this
   * component renders headings from all over the site — only the page knows
   * which field it is showing. See `lib/cms-field.ts`.
   */
  titleField?: string;
  subtitleField?: string;
};

export function SectionHeading({
  title,
  subtitle,
  align = "left",
  titleField,
  subtitleField,
}: SectionHeadingProps) {
  return (
    <div className={cn("space-y-2", align === "center" && "text-center")}>
      <h2
        className="font-sans text-2xl font-semibold tracking-tight text-[color:rgb(var(--heading-warm))] md:text-3xl"
        data-cms-field={titleField}
      >
        {title}
      </h2>
      {subtitle ? (
        <p className="text-base leading-7 text-slate-600" data-cms-field={subtitleField}>
          {subtitle}
        </p>
      ) : null}
    </div>
  );
}
