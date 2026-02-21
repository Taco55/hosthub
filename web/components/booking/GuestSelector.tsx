"use client";

import { getDictionary, type Locale } from "@/lib/i18n";

type GuestCounts = {
  adults: number;
  children: number;
  pets: number;
};

type GuestSelectorProps = {
  locale: Locale;
  value: GuestCounts;
  onChange: (value: GuestCounts) => void;
};

const adultOptions = Array.from({ length: 16 }, (_, index) => index + 1);
const childOptions = Array.from({ length: 17 }, (_, index) => index);

export function GuestSelector({ locale, value, onChange }: GuestSelectorProps) {
  const t = getDictionary(locale);

  return (
    <div className="space-y-3">
      <div className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        {t.labels.guests}
      </div>
      <div className="grid gap-3 sm:grid-cols-2">
        <div className="space-y-2">
          <label
            htmlFor="guest-adults"
            className="text-xs font-semibold uppercase tracking-wide text-muted-foreground"
          >
            {t.lodgify.adultsLabel.other}
          </label>
          <select
            id="guest-adults"
            name="adults"
            value={value.adults}
            onChange={(event) =>
              onChange({
                ...value,
                adults: Math.max(1, Number(event.target.value)),
                pets: 0,
              })
            }
            className="w-full rounded-xl border border-border/60 bg-background px-3 py-2 text-sm text-foreground"
          >
            {adultOptions.map((count) => (
              <option key={count} value={count}>
                {count}
              </option>
            ))}
          </select>
        </div>
        <div className="space-y-2">
          <label
            htmlFor="guest-children"
            className="text-xs font-semibold uppercase tracking-wide text-muted-foreground"
          >
            {t.lodgify.childrenLabel.other}
          </label>
          <select
            id="guest-children"
            name="children"
            value={value.children}
            onChange={(event) =>
              onChange({
                ...value,
                children: Number(event.target.value),
                pets: 0,
              })
            }
            className="w-full rounded-xl border border-border/60 bg-background px-3 py-2 text-sm text-foreground"
          >
            {childOptions.map((count) => (
              <option key={count} value={count}>
                {count}
              </option>
            ))}
          </select>
        </div>
      </div>
    </div>
  );
}
