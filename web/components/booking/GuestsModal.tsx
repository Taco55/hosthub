"use client";

import { Button } from "@/components/ui/button";
import type { Guests } from "@/lib/booking/types";
import { getDictionary, type Locale } from "@/lib/i18n";
import { cn } from "@/lib/utils";

const guestConfig = {
  adults: { min: 1, max: 16 },
  children: { min: 0, max: 16 },
} as const;

type GuestKey = keyof typeof guestConfig;

type GuestsModalProps = {
  locale: Locale;
  open: boolean;
  value: Guests;
  onOpenChange: (open: boolean) => void;
  onConfirm: (value: Guests) => void;
  className?: string;
};

export function GuestsModal({
  locale,
  open,
  value,
  onOpenChange,
  onConfirm,
  className,
}: GuestsModalProps) {
  const t = getDictionary(locale);

  const updateField = (field: GuestKey, delta: number) => {
    const bounds = guestConfig[field];
    const nextValue = Math.min(bounds.max, Math.max(bounds.min, value[field] + delta));
    onConfirm({ ...value, [field]: nextValue, pets: 0 });
  };

  if (!open) {
    return null;
  }

  return (
    <div
      className={cn(
        "absolute left-0 top-full z-40 mt-3 w-full max-w-md rounded-2xl border border-border/60 bg-white p-5 shadow-lg",
        className,
      )}
      role="dialog"
      aria-label={t.booking.numberOfGuests}
    >
      <div className="space-y-4">
        {[
          { key: "adults", label: t.lodgify.adultsLabel.other },
          { key: "children", label: t.lodgify.childrenLabel.other },
        ].map((item) => (
          <div key={item.key} className="flex items-center justify-between">
            <div className="text-sm font-medium text-foreground">{item.label}</div>
            <div className="flex items-center gap-2">
              <Button
                type="button"
                variant="outline"
                size="icon"
                onClick={() => updateField(item.key as GuestKey, -1)}
                disabled={value[item.key as GuestKey] <= guestConfig[item.key as GuestKey].min}
              >
                -
              </Button>
              <span className="w-6 text-center text-sm font-semibold">
                {value[item.key as GuestKey]}
              </span>
              <Button
                type="button"
                variant="outline"
                size="icon"
                onClick={() => updateField(item.key as GuestKey, 1)}
                disabled={value[item.key as GuestKey] >= guestConfig[item.key as GuestKey].max}
              >
                +
              </Button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
