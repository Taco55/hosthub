"use client";

import { useState } from "react";

import { cn } from "@/lib/utils";

type InteractiveMapProps = {
  title: string;
  src: string;
  className?: string;
  activateLabel?: string;
};

const DEFAULT_ACTIVATE_LABEL = "Activate map interactions";

export function InteractiveMap({
  title,
  src,
  className,
  activateLabel = DEFAULT_ACTIVATE_LABEL,
}: InteractiveMapProps) {
  const [isActive, setIsActive] = useState(false);

  return (
    <div className="relative" onMouseLeave={() => setIsActive(false)}>
      {!isActive && (
        <button
          type="button"
          aria-label={activateLabel}
          className="absolute inset-0 z-10 cursor-pointer bg-transparent"
          onClick={() => setIsActive(true)}
        />
      )}
      <iframe
        title={title}
        src={src}
        loading="lazy"
        className={cn(
          "h-72 w-full border-0 md:h-96",
          isActive ? "pointer-events-auto" : "pointer-events-none",
          className,
        )}
      />
    </div>
  );
}
