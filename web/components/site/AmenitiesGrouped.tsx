import { SectionHeading } from "@/components/section-heading";
import { AmenityTile } from "@/components/site/AmenityTile";
import { amenityRegistry } from "@/lib/amenities/amenityRegistry";
import { homeAmenityGroups } from "@/lib/amenities/homeAmenities";
import { getDictionary, type Dictionary, type Locale } from "@/lib/i18n";

type AmenitiesGroupedProps = {
  title: string;
  locale: Locale;
};

function resolveLabel(dictionary: Dictionary, key: string) {
  const value = (dictionary as Record<string, unknown>)[key];
  return typeof value === "string" ? value : key;
}

export function AmenitiesGrouped({ title, locale }: AmenitiesGroupedProps) {
  const t = getDictionary(locale);

  return (
    <section className="space-y-6 text-center">
      <SectionHeading title={title} align="center" />
      <div className="space-y-8">
        {homeAmenityGroups.map((group) => (
          <div key={group.titleKey} className="space-y-4">
            <h3 className="text-lg font-semibold text-[color:rgb(var(--heading-warm-light))]">
              {resolveLabel(t, group.titleKey)}
            </h3>
            <div className="mx-auto grid w-full max-w-3xl grid-cols-2 gap-4 md:grid-cols-4">
              {group.items.map((itemId) => {
                const amenity = amenityRegistry[itemId];
                return (
                  <AmenityTile
                    key={amenity.id}
                    icon={amenity.icon}
                    label={resolveLabel(t, amenity.labelKey)}
                  />
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
