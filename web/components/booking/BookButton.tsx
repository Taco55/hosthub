"use client";

import { Button } from "@/components/ui/button";

type BookButtonProps = {
  href: string;
  disabled: boolean;
  label: string;
};

export function BookButton({ href, disabled, label }: BookButtonProps) {
  if (disabled) {
    return (
      <Button className="w-full" disabled>
        {label}
      </Button>
    );
  }

  return (
    <Button asChild className="w-full">
      <a href={href} target="_blank" rel="noreferrer">
        {label}
      </a>
    </Button>
  );
}
