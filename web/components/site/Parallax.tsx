"use client";

import Image from "next/image";
import { useEffect, useRef, type ReactNode } from "react";

import { cn } from "@/lib/utils";
import type { ResponsiveImage } from "@/lib/responsive-images";

type ParallaxImageProps = {
  image: ResponsiveImage;
  alt: string;
  sizes?: string;
  priority?: boolean;
  className?: string;
  imageClassName?: string;
  background?: ReactNode;
  enabled?: boolean;
  intensityDesktop?: number;
  intensityMobile?: number;
  contentSelector?: string;
  contentIntensityDesktop?: number;
  contentIntensityMobile?: number;
  scale?: number;
  children?: ReactNode;
};

const DEFAULT_INTENSITY_DESKTOP = 18;
const DEFAULT_INTENSITY_MOBILE = 6;
const DEFAULT_CONTENT_INTENSITY_DESKTOP = 48;
const DEFAULT_CONTENT_INTENSITY_MOBILE = 24;
const DEFAULT_SCALE = 1.06;
const MOBILE_BREAKPOINT = 768;
const DEFAULT_CONTENT_SELECTOR = "[data-parallax-content]";

const clamp = (value: number, min: number, max: number) =>
  Math.min(max, Math.max(min, value));

export function ParallaxImage({
  image,
  alt,
  sizes,
  priority = false,
  className,
  imageClassName,
  background,
  enabled = true,
  intensityDesktop = DEFAULT_INTENSITY_DESKTOP,
  intensityMobile = DEFAULT_INTENSITY_MOBILE,
  contentSelector = DEFAULT_CONTENT_SELECTOR,
  contentIntensityDesktop = DEFAULT_CONTENT_INTENSITY_DESKTOP,
  contentIntensityMobile = DEFAULT_CONTENT_INTENSITY_MOBILE,
  scale = DEFAULT_SCALE,
  children,
}: ParallaxImageProps) {
  const wrapperRef = useRef<HTMLDivElement | null>(null);
  const innerRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const wrapper = wrapperRef.current;
    const inner = innerRef.current;

    if (!wrapper || !inner) {
      return;
    }

    const content = contentSelector
      ? wrapper.querySelector<HTMLElement>(contentSelector)
      : null;

    if (!enabled) {
      inner.style.transform = "translate3d(0, 0, 0)";
      if (content) {
        content.style.transform = "translate3d(0, 0, 0)";
      }
      return;
    }

    let frame = 0;
    let isInView = true;
    let viewportHeight = Math.max(window.innerHeight, 1);

    const resolveIntensity = () =>
      window.innerWidth < MOBILE_BREAKPOINT ? intensityMobile : intensityDesktop;
    const resolveContentIntensity = () =>
      window.innerWidth < MOBILE_BREAKPOINT
        ? contentIntensityMobile
        : contentIntensityDesktop;
    const resolveMarginTop = () => {
      const value = window.getComputedStyle(wrapper).marginTop;
      const parsed = Number.parseFloat(value ?? "0");
      return Number.isFinite(parsed) ? parsed : 0;
    };

    let intensity = resolveIntensity();
    let contentIntensity = resolveContentIntensity();
    let marginTop = resolveMarginTop();

    const update = () => {
      if (intensity <= 0) {
        inner.style.transform = "translate3d(0, 0, 0)";
        if (content) {
          content.style.transform = "translate3d(0, 0, 0)";
        }
        return;
      }

      const rect = wrapper.getBoundingClientRect();
      const height = Math.max(rect.height, 1);
      const adjustedTop = rect.top - marginTop;
      const progress = clamp(-adjustedTop / height, 0, 1);
      const maxOffset = (Math.max(1, scale) - 1) * height;
      const effectiveIntensity = Math.max(intensity, maxOffset);
      const offset = clamp(-progress * effectiveIntensity, -maxOffset, 0);

      inner.style.transform = `translate3d(0, ${offset}px, 0)`;
      if (content) {
        if (contentIntensity <= 0) {
          content.style.transform = "translate3d(0, 0, 0)";
        } else {
          const contentOffset = progress * contentIntensity;
          content.style.transform = `translate3d(0, ${contentOffset}px, 0)`;
        }
      }
    };

    const schedule = () => {
      if (frame) {
        return;
      }
      frame = window.requestAnimationFrame(() => {
        frame = 0;
        if (!isInView) {
          return;
        }
        update();
      });
    };

    const handleScroll = () => {
      schedule();
    };

    const handleResize = () => {
      viewportHeight = Math.max(window.innerHeight, 1);
      intensity = resolveIntensity();
      contentIntensity = resolveContentIntensity();
      marginTop = resolveMarginTop();
      schedule();
    };

    const observer = new IntersectionObserver(
      ([entry]) => {
        isInView = Boolean(entry?.isIntersecting);
        if (isInView) {
          schedule();
        }
      },
      { rootMargin: "200px 0px", threshold: 0 },
    );

    observer.observe(wrapper);
    window.addEventListener("scroll", handleScroll, { passive: true });
    window.addEventListener("resize", handleResize);

    schedule();

    return () => {
      observer.disconnect();
      window.removeEventListener("scroll", handleScroll);
      window.removeEventListener("resize", handleResize);
      if (frame) {
        window.cancelAnimationFrame(frame);
      }
    };
  }, [
    enabled,
    intensityDesktop,
    intensityMobile,
    contentSelector,
    contentIntensityDesktop,
    contentIntensityMobile,
    scale,
  ]);

  return (
    <div ref={wrapperRef} className={cn("relative overflow-hidden", className)}>
      <div
        ref={innerRef}
        className="absolute inset-0 will-change-transform"
        style={{ transform: "translate3d(0, 0, 0)" }}
      >
        <div
          className="absolute inset-0 origin-top"
          style={{ transform: `scale(${Math.max(1, scale)})` }}
        >
          {background ?? (
      <Image
        src={image.src}
        alt={alt}
            fill
              priority={priority}
              sizes={sizes ?? image.sizes}
              className={cn("object-cover", imageClassName)}
            />
          )}
        </div>
      </div>
      {children}
    </div>
  );
}
