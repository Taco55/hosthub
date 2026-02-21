"use client";

import * as React from "react";
import { DayPicker } from "react-day-picker";
import { ChevronLeft, ChevronRight } from "lucide-react";

import { cn } from "@/lib/utils";

export type CalendarProps = React.ComponentProps<typeof DayPicker>;

function Calendar({
  className,
  classNames,
  showOutsideDays = false,
  components,
  ...props
}: CalendarProps) {
  return (
    <DayPicker
      showOutsideDays={showOutsideDays}
      className={cn("p-3", className)}
      classNames={{
        months: "flex flex-col gap-4",
        month: "space-y-4",
        month_caption: "flex items-center justify-between px-2",
        caption_label: "text-sm font-semibold",
        nav: "flex items-center gap-1",
        button_previous:
          "inline-flex h-8 w-8 items-center justify-center rounded-full border border-transparent text-muted-foreground transition-colors hover:border-border/70 hover:bg-accent/10 hover:text-foreground",
        button_next:
          "inline-flex h-8 w-8 items-center justify-center rounded-full border border-transparent text-muted-foreground transition-colors hover:border-border/70 hover:bg-accent/10 hover:text-foreground",
        month_grid: "w-full border-collapse",
        weekdays: "text-center",
        weekday: "w-9 text-xs font-semibold text-muted-foreground",
        week: "text-center",
        day: "relative h-9 w-9 p-0 text-center text-sm focus-within:relative focus-within:z-20",
        day_button:
          "mx-auto flex h-9 w-9 items-center justify-center rounded-full p-0 font-medium transition-colors",
        today: "bg-accent/10 text-foreground",
        outside: "text-muted-foreground opacity-40",
        disabled: "text-muted-foreground",
        range_middle: "!bg-emerald-200 !text-emerald-900 rounded-none",
        range_end: "bg-emerald-700 text-white rounded-full",
        range_start: "bg-emerald-700 text-white rounded-full",
        selected: "bg-emerald-700 text-white rounded-full",
        ...classNames,
      }}
      components={{
        Chevron: ({ orientation }) => {
          if (orientation === "left") {
            return <ChevronLeft className="h-4 w-4" />;
          }
          if (orientation === "right") {
            return <ChevronRight className="h-4 w-4" />;
          }
          return <ChevronRight className="h-4 w-4" />;
        },
        ...components,
      }}
      {...props}
    />
  );
}

Calendar.displayName = "Calendar";

export { Calendar };
