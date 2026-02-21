import type * as React from "react";
import {
  AirVent,
  Bath,
  BrickWallFire,
  Coffee,
  Droplets,
  Flame,
  FlameKindling,
  House,
  Mountain,
  MountainSnow,
  ParkingCircle,
  PlugZap,
  Sparkles,
  ThermometerSun,
  Trees,
  Tv,
  Utensils,
  WashingMachine,
  Wifi,
  Zap,
} from "lucide-react";

import type { AmenityId } from "@/lib/amenities/homeAmenities";

export type AmenityDef = {
  id: AmenityId;
  labelKey: string;
  icon: React.ComponentType<any>;
};

export const amenityRegistry: Record<AmenityId, AmenityDef> = {
  sauna: { id: "sauna", labelKey: "saunaLabel", icon: Bath },
  fireplace: { id: "fireplace", labelKey: "fireplaceLabel", icon: BrickWallFire },
  floorHeating: { id: "floorHeating", labelKey: "floorHeatingLabel", icon: ThermometerSun },
  airConditioning: {
    id: "airConditioning",
    labelKey: "airConditioningLabel",
    icon: AirVent,
  },
  heatPump: { id: "heatPump", labelKey: "heatPumpLabel", icon: ThermometerSun },
  airConditioningHeatPump: {
    id: "airConditioningHeatPump",
    labelKey: "airConditioningHeatPumpLabel",
    icon: AirVent,
  },
  skiInOut: { id: "skiInOut", labelKey: "skiInOutLabel", icon: MountainSnow },
  privateGarden: { id: "privateGarden", labelKey: "privateGardenLabel", icon: Trees },
  terrace: { id: "terrace", labelKey: "terraceLabel", icon: House },
  bbqCharcoal: { id: "bbqCharcoal", labelKey: "bbqCharcoalLabel", icon: FlameKindling },
  gasBbq: { id: "gasBbq", labelKey: "gasBbqLabel", icon: FlameKindling },
  firePitTripod: { id: "firePitTripod", labelKey: "firePitTripodLabel", icon: Flame },
  mountainViews: { id: "mountainViews", labelKey: "mountainViewsLabel", icon: Mountain },
  wifi: { id: "wifi", labelKey: "wifiLabel", icon: Wifi },
  smartTv: { id: "smartTv", labelKey: "smartTvLabel", icon: Tv },
  parkingIncluded: { id: "parkingIncluded", labelKey: "parkingIncludedLabel", icon: ParkingCircle },
  evCharger: { id: "evCharger", labelKey: "evChargerLabel", icon: PlugZap },
  dishwasher: { id: "dishwasher", labelKey: "dishwasherLabel", icon: Droplets },
  fullKitchen: { id: "fullKitchen", labelKey: "fullKitchenLabel", icon: Utensils },
  nespresso: { id: "nespresso", labelKey: "nespressoLabel", icon: Coffee },
  inductionCooktop: {
    id: "inductionCooktop",
    labelKey: "inductionCooktopLabel",
    icon: Zap,
  },
  premiumOven: {
    id: "premiumOven",
    labelKey: "premiumOvenLabel",
    icon: Sparkles,
  },
  bathroomFloorHeating: {
    id: "bathroomFloorHeating",
    labelKey: "bathroomFloorHeatingLabel",
    icon: ThermometerSun,
  },
  washerDryer: { id: "washerDryer", labelKey: "washerDryerLabel", icon: WashingMachine },
};
