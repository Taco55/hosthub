import { X } from "lucide-react";

import { cn } from "@/lib/utils";

type DateFieldProps = {
  label: string;
  value: string;
  placeholder: string;
  onClick: () => void;
  onClear?: () => void;
  clearLabel?: string;
};

export function DateField({
  label,
  value,
  placeholder,
  onClick,
  onClear,
  clearLabel = "Clear",
}: DateFieldProps) {
  const hasValue = Boolean(value);
  const showClear = hasValue && Boolean(onClear);

  return (
    <div className="space-y-2">
      <label className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        {label}
      </label>
      <div className="relative">
        <button
          type="button"
          onClick={onClick}
          className={cn(
            "flex w-full items-center justify-between rounded-xl border border-border/60 bg-background px-3 py-3 text-left text-sm text-foreground transition hover:border-border",
            showClear && "pr-10",
            !hasValue && "text-muted-foreground",
          )}
        >
          <span>{hasValue ? value : placeholder}</span>
        </button>
        {showClear ? (
          <button
            type="button"
            onClick={(event) => {
              event.preventDefault();
              event.stopPropagation();
              onClear?.();
            }}
            className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full p-1 text-muted-foreground transition hover:text-foreground"
          >
            <X className="h-4 w-4" />
            <span className="sr-only">{clearLabel}</span>
          </button>
        ) : null}
      </div>
    </div>
  );
}
