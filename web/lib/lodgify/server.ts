import "server-only";

import { createLodgifyClient } from "@/lib/lodgify/client";

export function getLodgifyClient() {
  const apiKey = process.env.LODGIFY_API_KEY;
  if (!apiKey) {
    throw new Error("LODGIFY_API_KEY is not set");
  }

  const baseUrl = process.env.LODGIFY_API_BASE ?? "https://api.lodgify.com";
  return createLodgifyClient({ apiKey, baseUrl });
}

export function getLodgifyPropertyId() {
  const propertyId = process.env.LODGIFY_PROPERTY_ID;
  if (!propertyId) {
    throw new Error("LODGIFY_PROPERTY_ID is not set");
  }
  return propertyId;
}

export function getLodgifyRoomTypeId() {
  const roomTypeId = process.env.LODGIFY_ROOM_TYPE_ID;
  if (!roomTypeId) {
    throw new Error("LODGIFY_ROOM_TYPE_ID is not set");
  }
  return roomTypeId;
}
