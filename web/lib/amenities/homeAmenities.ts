export type AmenityId = string;
export type AmenityGroup = { titleKey: string; items: AmenityId[] };

export const homeAmenityGroups: AmenityGroup[] = [
  {
    titleKey: "amenitiesGroupWellness",
    items: ["sauna", "fireplace", "airConditioningHeatPump", "bathroomFloorHeating"],
  },
  {
    titleKey: "amenitiesGroupOutdoor",
    items: ["terrace", "firePitTripod", "gasBbq", "parkingIncluded"],
  },
  {
    titleKey: "amenitiesGroupPractical",
    items: ["wifi", "smartTv", "evCharger", "washerDryer"],
  },
  {
    titleKey: "amenitiesGroupKitchen",
    items: ["fullKitchen", "nespresso", "inductionCooktop", "premiumOven"],
  },
];
