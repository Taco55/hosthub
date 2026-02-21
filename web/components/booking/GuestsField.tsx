import { cn } from "@/lib/utils";

type GuestsFieldProps = {
  label: string;
  value: string;
  onClick: () => void;
};

export function GuestsField({ label, value, onClick }: GuestsFieldProps) {
  return (
    <div className="space-y-2">
      <label className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        {label}
      </label>
      <button
        type="button"
        onClick={onClick}
        className={cn(
          "flex w-full items-center justify-between rounded-xl border border-border/60 bg-background px-3 py-3 text-left text-sm text-foreground transition hover:border-border",
        )}
      >
        <span>{value}</span>
      </button>
    </div>
  );
}
