"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Lightbox from "yet-another-react-lightbox";
import type { ThumbnailsRef } from "yet-another-react-lightbox";
import "yet-another-react-lightbox/styles.css";
import Thumbnails from "yet-another-react-lightbox/plugins/thumbnails";
import "yet-another-react-lightbox/plugins/thumbnails.css";

const EnterFullscreenIcon = () => (
  <svg
    className="yarl__icon"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    width="24"
    height="24"
    aria-hidden="true"
    focusable="false"
  >
    <path d="M0 0h24v24H0z" fill="none" />
    <path
      d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"
      fill="currentColor"
    />
  </svg>
);

const ExitFullscreenIcon = () => (
  <svg
    className="yarl__icon"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    width="24"
    height="24"
    aria-hidden="true"
    focusable="false"
  >
    <path d="M0 0h24v24H0z" fill="none" />
    <path
      d="M5 16h3v3h2v-5H5v2zm3-8H5v2h5V5H8v3zm6 11h2v-3h3v-2h-5v5zm2-11V5h-2v5h5V8h-3z"
      fill="currentColor"
    />
  </svg>
);

type GalleryLightboxProps = {
  images: { src: string; alt: string }[];
  index: number | null;
  onClose: () => void;
};

export function GalleryLightbox({ images, index, onClose }: GalleryLightboxProps) {
  const thumbnailsRef = useRef<ThumbnailsRef | null>(null);
  const scrollYRef = useRef(0);
  const [isFocusMode, setIsFocusMode] = useState(false);

  useEffect(() => {
    const ref = thumbnailsRef.current;
    if (!ref) {
      return;
    }
    if (isFocusMode) {
      ref.hide();
    } else {
      ref.show();
    }
  }, [isFocusMode]);

  useEffect(() => {
    if (!isFocusMode) {
      if (scrollYRef.current) {
        window.scrollTo({ top: scrollYRef.current });
      }
      return;
    }
    scrollYRef.current = window.scrollY;
    requestAnimationFrame(() => {
      window.scrollTo({ top: Math.max(1, scrollYRef.current + 1) });
    });
  }, [isFocusMode]);

  const toggleFocusMode = useCallback(() => {
    setIsFocusMode((value) => !value);
  }, []);

  const handleClose = useCallback(() => {
    if (isFocusMode) {
      setIsFocusMode(false);
    }
    onClose();
  }, [isFocusMode, onClose]);

  const fullscreenButton = (
    <button
      key="fullscreen-toggle"
      type="button"
      title={isFocusMode ? "Exit fullscreen" : "Fullscreen"}
      aria-label={isFocusMode ? "Exit fullscreen" : "Fullscreen"}
      className="yarl__button"
      onClick={toggleFocusMode}
    >
      {isFocusMode ? <ExitFullscreenIcon /> : <EnterFullscreenIcon />}
    </button>
  );

  return (
    <Lightbox
      open={index !== null}
      close={handleClose}
      index={index ?? 0}
      slides={images.map((image) => ({ src: image.src, alt: image.alt }))}
      carousel={{ imageFit: "contain", padding: 0, spacing: 0 }}
      controller={{ touchAction: isFocusMode ? "pan-y" : "none" }}
      noScroll={{ disabled: isFocusMode }}
      render={isFocusMode ? { buttonPrev: () => null, buttonNext: () => null } : undefined}
      plugins={[Thumbnails]}
      toolbar={{ buttons: [fullscreenButton, "close"] }}
      thumbnails={{ position: "bottom", width: 120, height: 80, ref: thumbnailsRef }}
    />
  );
}
