import { SectionHeading } from "@/components/section-heading";
import { AmenityTile } from "@/components/site/AmenityTile";
import { amenityRegistry } from "@/lib/amenities/amenityRegistry";
import { homeAmenityGroups } from "@/lib/amenities/homeAmenities";
import { cmsField, cmsFieldAddress } from "@/lib/cms-field";
import { rowFieldPath, textRows, type TextList } from "@/lib/cms-rows";
import { getDictionary, type Dictionary, type Locale } from "@/lib/i18n";

type AmenityGroupContent = {
  id?: string;
  title: string;
  items: TextList;
};

type AmenitiesGroupedProps = {
  title: string;
  locale: Locale;
  /**
   * Groups from the CMS document. The owner writes these (README fase 2
   * par. 0.1: the items moved out of the repo so the card is editable and not
   * just its heading), and `homeAmenities.ts` is what seeded them.
   *
   * Empty or absent falls back to that seed, so a site whose document has not
   * been filled yet still renders.
   */
  groups?: AmenityGroupContent[];
};

function resolveLabel(dictionary: Dictionary, key: string) {
  const value = (dictionary as Record<string, unknown>)[key];
  return typeof value === "string" ? value : key;
}

export function AmenitiesGrouped({ title, locale, groups }: AmenitiesGroupedProps) {
  const t = getDictionary(locale);

  const resolved: AmenityGroupContent[] =
    groups && groups.length > 0
      ? groups
      : homeAmenityGroups.map((group) => ({
          title: resolveLabel(t, group.titleKey),
          items: group.items.map((itemId) =>
            resolveLabel(t, amenityRegistry[itemId].labelKey),
          ),
        }));

  return (
    <section className="space-y-6 text-center">
      <SectionHeading
        title={title}
        titleField={cmsFieldAddress("cabin/main", "amenities", "title")}
        align="center"
      />
      <div className="space-y-8">
        {resolved.map((group, groupIndex) => (
          <div key={group.id ?? group.title} className="space-y-4">
            <h3
              className="text-lg font-semibold text-[color:rgb(var(--heading-warm-light))]"
              {...cmsField(
                "cabin/main",
                "amenities",
                "groups",
                group.id ?? groupIndex,
                "title",
              )}
            >
              {group.title}
            </h3>
            <div className="mx-auto grid w-full max-w-3xl grid-cols-2 gap-4 md:grid-cols-4">
              {textRows(group.items).map((row, itemIndex) => (
                // An item the owner typed cannot carry an icon from a registry
                // keyed by ids, so every tile gets the same neutral mark. That
                // is the price of the items being editable at all.
                <AmenityTile
                  key={row.id ?? itemIndex}
                  label={row.text}
                  {...cmsField(
                    "cabin/main",
                    "amenities",
                    "groups",
                    group.id ?? groupIndex,
                    ...rowFieldPath("items", row, itemIndex),
                  )}
                />
              ))}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
