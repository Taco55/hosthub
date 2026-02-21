"use client";

import { useState } from "react";
import type { DateRange } from "react-day-picker";

import { DateRangePicker } from "@/components/booking/DateRangePicker";
import type { Locale } from "@/lib/i18n";

type AvailabilityPickerProps = {
  locale: Locale;
  onRangeChange?: (range: DateRange | undefined) => void;
};

export function AvailabilityPicker({ locale, onRangeChange }: AvailabilityPickerProps) {
  const [range, setRange] = useState<DateRange | undefined>();

  return (
    <DateRangePicker
      locale={locale}
      value={range}
      onChange={(next) => {
        setRange(next);
        onRangeChange?.(next);
      }}
    />
  );
}
