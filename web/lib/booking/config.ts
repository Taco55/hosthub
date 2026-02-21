const DEFAULT_MIN_NIGHTS = 4;

function parseMinNights(value: string | undefined) {
  if (!value) {
    return DEFAULT_MIN_NIGHTS;
  }
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return DEFAULT_MIN_NIGHTS;
  }
  const normalized = Math.floor(parsed);
  return normalized >= 1 ? normalized : DEFAULT_MIN_NIGHTS;
}

export const MIN_NIGHTS = parseMinNights(process.env.NEXT_PUBLIC_MIN_NIGHTS);

export function getMinNightsForArrival(_date: Date): number {
  return MIN_NIGHTS;
}
