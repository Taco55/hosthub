"use client";

import { useState } from "react";
import Image from "next/image";

import Link from "next/link";

import { GalleryLightbox } from "@/components/gallery-lightbox";
import { Button } from "@/components/ui/button";
import { SectionHeading } from "@/components/section-heading";
import type { GalleryImage } from "@/lib/gallery";

type GalleryPreviewProps = {
  id?: string;
  title: string;
  ctaLabel: string;
  href: string;
  images: GalleryImage[];
};

const PREVIEW_COUNT = 6;

export function GalleryPreview({ id, title, ctaLabel, href, images }: GalleryPreviewProps) {
  const [index, setIndex] = useState<number | null>(null);
  const previewImages = images.slice(0, PREVIEW_COUNT).map((image, imageIndex) => ({
    ...image,
    fullIndex: imageIndex,
  }));

  return (
    <section id={id} className="space-y-6 text-center">
      <div className="flex flex-col items-center gap-4">
        <SectionHeading title={title} align="center" />
        <Button asChild variant="outline">
          <Link href={href}>{ctaLabel}</Link>
        </Button>
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {previewImages.map((image, imageIndex) => (
          <button
            key={image.src}
            type="button"
            className="group relative overflow-hidden rounded-2xl border border-border/60 bg-white shadow-sm"
            onClick={() => setIndex(image.fullIndex)}
          >
            <div className="relative aspect-[4/3] w-full">
              <Image
                src={image.src}
                alt={image.alt}
                fill
                priority={imageIndex === 0}
                className="object-cover transition-transform duration-300 group-hover:scale-105"
                sizes={image.sizes}
              />
            </div>
          </button>
        ))}
      </div>
      <GalleryLightbox images={images} index={index} onClose={() => setIndex(null)} />
    </section>
  );
}
