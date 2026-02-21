import { cloneElement, isValidElement, type ReactElement, type ReactNode } from "react";

import { cn } from "@/lib/utils";

type IconBadgeProps = {
  icon: ReactNode;
  size?: "sm" | "md";
};

type IconProps = {
  className?: string;
  title?: string;
  "aria-label"?: string;
  "aria-labelledby"?: string;
  "aria-hidden"?: boolean;
  focusable?: string;
};

const sizeClasses = {
  sm: "h-8 w-8",
  md: "h-10 w-10",
};

const iconSizeClasses = {
  sm: "h-4 w-4",
  md: "h-[18px] w-[18px]",
};

function isIconLabeled(icon: ReactElement<IconProps>) {
  return Boolean(
    icon.props["aria-label"] || icon.props["aria-labelledby"] || icon.props.title,
  );
}

export function IconBadge({ icon, size = "md" }: IconBadgeProps) {
  const iconElement = isValidElement(icon) ? (icon as ReactElement<IconProps>) : null;
  const isDecorative = !(iconElement && isIconLabeled(iconElement));
  const iconNode = iconElement
    ? cloneElement(iconElement, {
        className: cn(
          iconElement.props.className,
          iconSizeClasses[size],
          "text-[color:rgb(var(--heading-warm))]",
        ),
        "aria-hidden": isDecorative ? true : undefined,
        focusable: "false",
      })
    : icon;

  return (
    <span
      className={cn(
        "flex items-center justify-center rounded-full bg-[rgb(var(--heading-warm)/0.12)]",
        sizeClasses[size],
      )}
      aria-hidden={isDecorative ? true : undefined}
    >
      {iconNode}
    </span>
  );
}
