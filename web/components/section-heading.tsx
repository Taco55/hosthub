import { cn } from "@/lib/utils";
import type { ReactNode } from "react";

type SectionHeadingProps = {
  title: string;
  subtitle?: ReactNode;
  align?: "left" | "center";
};

export function SectionHeading({
  title,
  subtitle,
  align = "left",
}: SectionHeadingProps) {
  return (
    <div className={cn("space-y-2", align === "center" && "text-center")}>
      <h2 className="font-sans text-2xl font-semibold tracking-tight text-[color:rgb(var(--heading-warm))] md:text-3xl">
        {title}
      </h2>
      {subtitle ? <p className="text-base leading-7 text-slate-600">{subtitle}</p> : null}
    </div>
  );
}
