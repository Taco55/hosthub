const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
const dayMs = 24 * 60 * 60 * 1000;

export function parseDateParam(value: string | null) {
  if (!value || !dateRegex.test(value)) {
    return null;
  }

  const [year, month, day] = value.split("-").map((part) => Number(part));
  if (!year || !month || !day) {
    return null;
  }

  const date = new Date(Date.UTC(year, month - 1, day));
  if (
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }

  return date;
}

export function diffDays(start: Date, end: Date) {
  return Math.ceil((end.getTime() - start.getTime()) / dayMs);
}

export function clampCount(
  value: string | null,
  fallback: number,
  options: { min?: number; max?: number } = {},
) {
  const min = options.min ?? 0;
  const max = options.max ?? 20;
  if (value === null || value.trim() === "") {
    return Math.min(max, Math.max(min, Math.floor(fallback)));
  }
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, Math.floor(parsed)));
}
