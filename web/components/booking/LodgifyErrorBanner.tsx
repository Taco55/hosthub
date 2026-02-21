"use client";

import { cn } from "@/lib/utils";

type LodgifyErrorBannerProps = {
  message: string | null;
  className?: string;
};

export function LodgifyErrorBanner({ message, className }: LodgifyErrorBannerProps) {
  if (!message) {
    return null;
  }

  return (
    <div
      className={cn(
        "w-full rounded-2xl bg-rose-600 text-white shadow-sm",
        className,
      )}
      role="alert"
      aria-live="assertive"
    >
      <div className="mx-auto flex max-w-5xl items-center justify-center px-4 py-3 text-sm font-semibold">
        {message}
      </div>
    </div>
  );
}
