const dayMs = 24 * 60 * 60 * 1000;

export type AvailabilityPeriod = {
  period_start: string;
  period_end: string;
  is_available: boolean;
};

export type DayStatus = "available" | "unavailable" | "tooShort";

export type DayInfo = {
  status: DayStatus;
  reason?: string;
  windowId?: number;
  windowLen?: number;
  windowStart?: string;
  windowEnd?: string;
};

export type DayMap = Map<string, DayInfo>;

export function parseDateUtc(value: string) {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) {
    return null;
  }
  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const date = new Date(Date.UTC(year, month - 1, day));
  if (
    Number.isNaN(date.getTime()) ||
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }
  return date;
}

export function formatDateUtc(date: Date) {
  return date.toISOString().slice(0, 10);
}

function formatDateKey(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function addDaysUtc(date: Date, days: number) {
  return new Date(date.getTime() + days * dayMs);
}

function isNextDay(prevKey: string, nextKey: string) {
  const prevDate = parseDateUtc(prevKey);
  const nextDate = parseDateUtc(nextKey);
  if (!prevDate || !nextDate) {
    return false;
  }
  return formatDateUtc(addDaysUtc(prevDate, 1)) === nextKey;
}

export function expandPeriodsToDays(periods: AvailabilityPeriod[]): DayMap {
  const map: DayMap = new Map();
  for (const period of periods) {
    const start = parseDateUtc(period.period_start);
    const end = parseDateUtc(period.period_end);
    if (!start || !end) {
      continue;
    }

    let cursor = start;
    while (cursor <= end) {
      map.set(formatDateUtc(cursor), {
        status: period.is_available ? "available" : "unavailable",
      });
      cursor = addDaysUtc(cursor, 1);
    }
  }
  return map;
}

export function computeContiguousAvailableWindows(dayMap: DayMap) {
  const keys = Array.from(dayMap.keys()).sort();
  let windowId = 0;
  let current: string[] = [];

  const finalizeWindow = () => {
    if (!current.length) {
      return;
    }
    const windowLen = current.length;
    const windowStart = current[0];
    const windowEnd = current[windowLen - 1];
    for (const key of current) {
      const info = dayMap.get(key);
      if (!info || info.status !== "available") {
        continue;
      }
      info.windowId = windowId;
      info.windowLen = windowLen;
      info.windowStart = windowStart;
      info.windowEnd = windowEnd;
    }
    windowId += 1;
    current = [];
  };

  for (const key of keys) {
    const info = dayMap.get(key);
    if (!info || info.status !== "available") {
      finalizeWindow();
      continue;
    }

    if (!current.length) {
      current.push(key);
      continue;
    }

    const prevKey = current[current.length - 1];
    if (isNextDay(prevKey, key)) {
      current.push(key);
    } else {
      finalizeWindow();
      current.push(key);
    }
  }

  finalizeWindow();
}

export function markTooShortWindows(dayMap: DayMap, minNights: number) {
  if (minNights <= 1) {
    return;
  }
  const keys = Array.from(dayMap.keys()).sort();
  const windows = new Map<number, string[]>();

  for (const key of keys) {
    const info = dayMap.get(key);
    if (!info || info.status !== "available" || typeof info.windowId !== "number") {
      continue;
    }
    const bucket = windows.get(info.windowId) ?? [];
    bucket.push(key);
    windows.set(info.windowId, bucket);
  }

  for (const [, windowKeys] of windows) {
    const windowLen = windowKeys.length;
    for (let index = 0; index < windowLen; index += 1) {
      const key = windowKeys[index];
      const info = dayMap.get(key);
      if (!info || info.status !== "available") {
        continue;
      }
      const remainingFromDay = windowLen - index;
      if (remainingFromDay < minNights) {
        info.status = "tooShort";
        info.reason = `Minimum stay is ${minNights} nights`;
      }
    }
  }
}

export function getDisabledDays(dayMap: DayMap) {
  const disabled: Date[] = [];
  for (const [key, info] of dayMap.entries()) {
    if (info.status === "available") {
      continue;
    }
    const date = parseDateUtc(key);
    if (date) {
      disabled.push(date);
    }
  }
  return disabled;
}

export function getDayTooltip(dayMap: DayMap, date: Date) {
  const key = formatDateKey(date);
  const info = dayMap.get(key);
  if (!info) {
    return null;
  }
  if (info.reason) {
    return info.reason;
  }
  if (info.status === "unavailable") {
    return "Not available";
  }
  return null;
}

export function buildDayMapFromDays(
  days: { date: string; isAvailable: boolean }[],
) {
  const map: DayMap = new Map();
  for (const day of days) {
    if (!day?.date) {
      continue;
    }
    map.set(day.date, {
      status: day.isAvailable ? "available" : "unavailable",
    });
  }
  return map;
}
