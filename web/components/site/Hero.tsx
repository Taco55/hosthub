import { Button } from "@/components/ui/button";
import { Container } from "@/components/site/Container";
import { HeroCrossfadeBackground } from "@/components/site/HeroCrossfadeBackground";
import { ParallaxImage } from "@/components/site/Parallax";
import { getHeroImages } from "@/lib/heroImages";
import { getDictionary, type Locale } from "@/lib/i18n";
import { heroImageSizes, type ResponsiveImage } from "@/lib/responsive-images";

type HeroProps = {
  locale: Locale;
  title: string;
  subtitle?: string;
  locationShort: string;
  imageSrc: string;
  imageAlt: string;
  primaryCtaHref?: string;
  secondaryCtaHref: string;
  parallaxEnabled?: boolean;
};

export function Hero({
  locale,
  title,
  subtitle,
  locationShort,
  imageSrc,
  imageAlt,
  primaryCtaHref = "#booking",
  secondaryCtaHref,
  parallaxEnabled = true,
}: HeroProps) {
  const t = getDictionary(locale);
  const heroImages = getHeroImages();
  const heroImage = heroImages[0];
  const fallbackImage: ResponsiveImage = {
    src: encodeURI(imageSrc),
    srcSet: encodeURI(imageSrc),
    sizes: heroImageSizes,
  };
  const hasHeroImages = heroImages.length > 0;

  return (
    <section className="relative -mt-16 sm:-mt-20" data-hero-section>
      <ParallaxImage
        className="min-h-[100svh]"
        image={heroImage ?? fallbackImage}
        alt={imageAlt}
        enabled={parallaxEnabled}
        intensityDesktop={120}
        intensityMobile={60}
        scale={1.4}
        imageClassName="object-[position:50%_20%]"
        background={
          hasHeroImages ? (
            <HeroCrossfadeBackground images={heroImages} intervalMs={5000} fadeMs={900} />
          ) : undefined
        }
      >
        <div className="absolute inset-0 z-10 bg-gradient-to-b from-black/55 via-black/35 to-black/10" />
        <div className="absolute inset-0 z-10 bg-gradient-to-r from-black/35 via-black/10 to-transparent" />
        <Container
          data-parallax-content
          className="relative z-20 flex min-h-[100svh] items-end justify-center pb-12 pt-28 text-center will-change-transform lg:pb-16 lg:pt-36"
        >
          <div className="mx-auto max-w-2xl space-y-6 text-center text-white">
            <div className="text-xs uppercase tracking-[0.3em] text-white/70">
              {locationShort}
            </div>
            <h1 className="font-sans text-4xl font-semibold tracking-tight text-[color:rgb(var(--hero-text))] md:text-5xl">
              {title}
            </h1>
            {subtitle ? (
              <p className="mx-auto max-w-xl text-base leading-7 text-[color:rgb(var(--hero-subtext))]">
                {subtitle}
              </p>
            ) : null}
            <div className="flex flex-wrap justify-center gap-3">
              <Button asChild size="lg" className="shadow-sm">
                <a href={primaryCtaHref}>{t.cta.checkAvailability}</a>
              </Button>
              <Button
                asChild
                size="lg"
                variant="outline"
                className="border-white/40 bg-white/10 text-white hover:bg-white/20 hover:text-white"
              >
                <a href={secondaryCtaHref}>{t.cta.viewGallery}</a>
              </Button>
            </div>
          </div>
        </Container>
      </ParallaxImage>
    </section>
  );
}
