"use client";

import Image from "next/image";
import { useEffect, useRef, useState } from "react";

import type { ResponsiveImage } from "@/lib/responsive-images";

type HeroCrossfadeBackgroundProps = {
  images: ResponsiveImage[];
  intervalMs?: number;
  fadeMs?: number;
};

const DEFAULT_INTERVAL_MS = 5000;
const DEFAULT_FADE_MS = 900;

export function HeroCrossfadeBackground({
  images,
  intervalMs = DEFAULT_INTERVAL_MS,
  fadeMs = DEFAULT_FADE_MS,
}: HeroCrossfadeBackgroundProps) {
  const [activeIndex, setActiveIndex] = useState(0);
  const [nextIndex, setNextIndex] = useState(images.length > 1 ? 1 : 0);
  const [isFading, setIsFading] = useState(false);
  const [reduceMotion, setReduceMotion] = useState<boolean | null>(null);

  const activeIndexRef = useRef(activeIndex);
  const isFadingRef = useRef(isFading);

  useEffect(() => {
    activeIndexRef.current = activeIndex;
  }, [activeIndex]);

  useEffect(() => {
    isFadingRef.current = isFading;
  }, [isFading]);

  useEffect(() => {
    if (typeof window === "undefined") {
      return;
    }

    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    const handleChange = () => {
      const shouldReduce = mediaQuery.matches;
      setReduceMotion(shouldReduce);
      if (shouldReduce) {
        setActiveIndex(0);
        setNextIndex(0);
        setIsFading(false);
      }
    };

    handleChange();

    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener("change", handleChange);
      return () => {
        mediaQuery.removeEventListener("change", handleChange);
      };
    }

    mediaQuery.addListener(handleChange);
    return () => {
      mediaQuery.removeListener(handleChange);
    };
  }, []);

  const allowMotion = reduceMotion === false;
  const shouldAnimate = allowMotion && images.length > 1;

  useEffect(() => {
    if (!shouldAnimate) {
      return;
    }

    let intervalId: number | null = null;
    let fadeTimeoutId: number | null = null;

    const startFade = () => {
      if (isFadingRef.current) {
        return;
      }

      const current = activeIndexRef.current;
      const next = (current + 1) % images.length;
      setNextIndex(next);
      setIsFading(true);

      fadeTimeoutId = window.setTimeout(() => {
        setActiveIndex(next);
        setIsFading(false);
      }, fadeMs);
    };

    intervalId = window.setInterval(startFade, intervalMs);

    return () => {
      if (intervalId) {
        window.clearInterval(intervalId);
      }
      if (fadeTimeoutId) {
        window.clearTimeout(fadeTimeoutId);
      }
    };
  }, [fadeMs, images.length, intervalMs, shouldAnimate]);

  const firstImage = images[0];
  const displayActiveIndex = allowMotion ? activeIndex : 0;
  const displayNextIndex = allowMotion ? nextIndex : 0;
  const currentImage = images[displayActiveIndex] ?? firstImage;
  const nextImage = images[displayNextIndex] ?? firstImage;

  if (!firstImage || !currentImage) {
    return null;
  }

  return (
    <div className="absolute inset-0 z-0" aria-hidden="true">
      <div className="absolute inset-0">
          <Image
            src={currentImage.src}
            alt=""
            fill
            sizes={currentImage.sizes}
            priority={currentImage.src === firstImage.src}
            className="object-cover object-top"
        />
      </div>
      {shouldAnimate ? (
        <div
          className="absolute inset-0 transition-opacity ease-in-out"
          style={{ opacity: isFading ? 1 : 0, transitionDuration: `${fadeMs}ms` }}
        >
          <Image
            src={nextImage.src}
            alt=""
            fill
            sizes={nextImage.sizes}
            priority={nextImage.src === firstImage.src}
            className="object-cover object-top"
          />
        </div>
      ) : null}
    </div>
  );
}
