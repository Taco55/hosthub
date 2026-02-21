import "server-only";

export type LodgifyClientOptions = {
  apiKey: string;
  baseUrl: string;
};

export type LodgifyAvailabilityDay = {
  date: string;
  isAvailable: boolean;
};

export type LodgifyDailyRate = {
  date: string;
  rate: number;
};

export type LodgifyQuoteLine = {
  label: string;
  amount: number;
};

export type LodgifyPayment = {
  label: string;
  amount: number;
  dueDate?: string;
};

export type LodgifyQuote = {
  currency: string;
  total: number;
  nightlyTotal: number;
  feesTotal: number;
  taxesTotal: number;
  lines: LodgifyQuoteLine[];
  payments: LodgifyPayment[];
  taxesIncluded?: boolean | null;
};

export type LodgifyErrorDetails = {
  status: number;
  message: string;
  details?: string | null;
};

export class LodgifyError extends Error {
  status: number;
  details: string | null;
  body: string | null;
  url: string;

  constructor(message: string, status: number, url: string, details?: string | null) {
    super(message);
    this.name = "LodgifyError";
    this.status = status;
    this.details = details ?? null;
    this.body = this.details;
    this.url = url;
  }
}

const defaultTimeoutMs = 10_000;
const maxBodySnippetLength = 1_000;
const dayMs = 24 * 60 * 60 * 1000;
const maxRetryAttempts = 3;
const retryBaseDelayMs = 250;
const retryJitterMs = 250;

function delay(ms: number) {
  return new Promise<void>((resolve) => {
    setTimeout(resolve, ms);
  });
}

function shouldRetryStatus(status: number) {
  return status === 408 || status === 429 || status >= 500;
}

function getRetryDelayMs(attempt: number) {
  const exponential = retryBaseDelayMs * 2 ** attempt;
  const jitter = Math.floor(Math.random() * retryJitterMs);
  return exponential + jitter;
}

function normalizeBaseUrl(baseUrl: string) {
  return baseUrl.endsWith("/") ? baseUrl.slice(0, -1) : baseUrl;
}

async function readBody(response: Response) {
  const text = await response.text();
  if (!text) {
    return { data: null, text: "" } as const;
  }

  try {
    return { data: JSON.parse(text) as unknown, text } as const;
  } catch {
    return { data: null, text } as const;
  }
}

function hasParamError(message: string) {
  const normalized = message.toLowerCase();
  return (
    normalized.includes("missing") ||
    normalized.includes("invalid") ||
    normalized.includes("parameter") ||
    normalized.includes("start") ||
    normalized.includes("end") ||
    normalized.includes("arrival") ||
    normalized.includes("departure") ||
    normalized.includes("from") ||
    normalized.includes("to") ||
    normalized.includes("date")
  );
}

function toNumberPrimitive(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string") {
    const cleaned = value.replace(/[^0-9.-]/g, "");
    if (!cleaned) {
      return null;
    }
    const parsed = Number(cleaned);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function toNumber(value: unknown) {
  const primitive = toNumberPrimitive(value);
  if (primitive !== null) {
    return primitive;
  }
  if (!value || typeof value !== "object") {
    return null;
  }

  const record = value as Record<string, unknown>;
  const candidates = [
    record.amount,
    record.value,
    record.total,
    record.price,
    record.rate,
    record.net,
    record.gross,
    record.sum,
  ];

  for (const candidate of candidates) {
    const parsed = toNumberPrimitive(candidate);
    if (parsed !== null) {
      return parsed;
    }
  }

  return null;
}

function toBoolean(value: unknown) {
  if (typeof value === "boolean") {
    return value;
  }
  if (typeof value === "number") {
    return value > 0;
  }
  if (typeof value === "string") {
    const normalized = value.toLowerCase().replace(/[_-]+/g, " ").trim();
    if (["true", "available", "yes", "open", "free"].includes(normalized)) {
      return true;
    }
    if (
      [
        "false",
        "unavailable",
        "booked",
        "no",
        "closed",
        "blocked",
        "reserved",
        "pending",
        "request",
        "hold",
        "on hold",
        "occupied",
        "maintenance",
      ].includes(normalized)
    ) {
      return false;
    }
  }
  return null;
}

function toDateKey(value: Date) {
  return value.toISOString().slice(0, 10);
}

function parseDateKey(value: unknown) {
  if (typeof value !== "string") {
    return null;
  }
  const match = value.match(/^(\d{4}-\d{2}-\d{2})/);
  return match ? match[1] : null;
}

function expandAvailabilityPeriods(entries: Record<string, unknown>[]) {
  const days: LodgifyAvailabilityDay[] = [];

  for (const entry of entries) {
    const startKey = parseDateKey(
      entry.period_start ??
        entry.periodStart ??
        entry.start ??
        entry.startDate ??
        entry.Start ??
        entry.StartDate,
    );
    const endKey = parseDateKey(
      entry.period_end ??
        entry.periodEnd ??
        entry.end ??
        entry.endDate ??
        entry.End ??
        entry.EndDate,
    );
    const isAvailable = toBoolean(
      entry.is_available ?? entry.isAvailable ?? entry.available,
    );

    if (!startKey || !endKey || isAvailable === null) {
      continue;
    }

    const startDate = new Date(`${startKey}T00:00:00Z`);
    const endDate = new Date(`${endKey}T00:00:00Z`);
    if (!Number.isFinite(startDate.getTime()) || !Number.isFinite(endDate.getTime())) {
      continue;
    }

    for (let cursor = startDate; cursor <= endDate; ) {
      days.push({ date: toDateKey(cursor), isAvailable });
      cursor = new Date(cursor.getTime() + dayMs);
    }
  }

  return days;
}

function normalizeAvailabilityEntry(item: Record<string, unknown>) {
  const dateValue =
    item.date ?? item.day ?? item.startDate ?? item.start ?? item.dateFrom ?? item.from;

  if (typeof dateValue !== "string") {
    return null;
  }

  const availabilityValue = item.availability;
  const availabilityRecord =
    typeof availabilityValue === "object" && availabilityValue !== null
      ? (availabilityValue as Record<string, unknown>)
      : null;
  const bookedValue = toBoolean(item.booked);
  const blockedValue = toBoolean(item.blocked);
  const closedValue = toBoolean(item.closed);

  const boolValue =
    toBoolean(item.isAvailable) ??
    toBoolean(item.available) ??
    (availabilityRecord ? null : toBoolean(availabilityValue)) ??
    (availabilityRecord
      ? toBoolean(
          availabilityRecord.isAvailable ??
            availabilityRecord.available ??
            availabilityRecord.status ??
            availabilityRecord.availability ??
            availabilityRecord.state ??
            availabilityRecord.value,
        )
      : null) ??
    toBoolean(item.status) ??
    toBoolean(item.state) ??
    (bookedValue === null ? null : !bookedValue) ??
    (blockedValue === null ? null : !blockedValue) ??
    (closedValue === null ? null : !closedValue);

  if (boolValue === null) {
    return null;
  }

  return { date: dateValue, isAvailable: boolValue };
}

function mergeAvailabilityDays(days: LodgifyAvailabilityDay[]) {
  const map = new Map<string, boolean>();
  for (const day of days) {
    const existing = map.get(day.date);
    if (existing === undefined) {
      map.set(day.date, day.isAvailable);
      continue;
    }
    map.set(day.date, existing || day.isAvailable);
  }

  return Array.from(map.entries())
    .map(([date, isAvailable]) => ({ date, isAvailable }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

function normalizeAvailabilityResponse(data: unknown): LodgifyAvailabilityDay[] {
  if (!data) {
    return [];
  }

  if (Array.isArray(data)) {
    const records = data.filter((item) => typeof item === "object" && item !== null);
    const hasPeriods = records.some(
      (item) =>
        "period_start" in item ||
        "periodStart" in item ||
        (item as Record<string, unknown>).periods !== undefined,
    );
    if (hasPeriods) {
      const periodEntries = records.flatMap((item) => {
        const record = item as Record<string, unknown>;
        if (Array.isArray(record.periods)) {
          return record.periods.filter(
            (period) => typeof period === "object" && period !== null,
          ) as Record<string, unknown>[];
        }
        return [record];
      });
      return mergeAvailabilityDays(expandAvailabilityPeriods(periodEntries));
    }

    return mergeAvailabilityDays(
      records
        .map((item) => normalizeAvailabilityEntry(item as Record<string, unknown>))
        .filter((item): item is LodgifyAvailabilityDay => Boolean(item)),
    );
  }

  if (typeof data === "object") {
    const record = data as Record<string, unknown>;

    if (Array.isArray(record.availability)) {
      return normalizeAvailabilityResponse(record.availability);
    }

    if (Array.isArray(record.days)) {
      return normalizeAvailabilityResponse(record.days);
    }

    if (Array.isArray(record.items)) {
      return normalizeAvailabilityResponse(record.items);
    }

    if (record.calendar && typeof record.calendar === "object") {
      const calendarEntries = Object.entries(record.calendar as Record<string, unknown>).map(
        ([date, value]) => {
          const availability =
            typeof value === "object" && value !== null
              ? normalizeAvailabilityEntry({ ...(value as Record<string, unknown>), date })
              : normalizeAvailabilityEntry({ date, availability: value });
          return availability;
        },
      );
      return mergeAvailabilityDays(
        calendarEntries.filter(
          (item): item is LodgifyAvailabilityDay => Boolean(item),
        ),
      );
    }

    if (Array.isArray(record.rooms)) {
      const roomDays = record.rooms.flatMap((room) => normalizeAvailabilityResponse(room));
      return mergeAvailabilityDays(roomDays);
    }
  }

  return [];
}

function normalizeDailyRatesResponse(data: unknown) {
  if (!data) {
    return { currency: "", rates: [] as LodgifyDailyRate[] };
  }

  const rates: LodgifyDailyRate[] = [];
  let currency = "";

  const extractRate = (item: Record<string, unknown>) => {
    const dateValue =
      item.date ?? item.day ?? item.startDate ?? item.start ?? item.dateFrom ?? item.from;

    if (typeof dateValue !== "string") {
      return;
    }

    const rateValue =
      toNumber(item.rate) ??
      toNumber(item.price) ??
      toNumber(item.value) ??
      toNumber(item.amount);

    if (rateValue === null) {
      return;
    }

    const currencyValue =
      typeof item.currency === "string"
        ? item.currency
        : typeof item.currencyCode === "string"
          ? item.currencyCode
          : "";

    if (!currency && currencyValue) {
      currency = currencyValue;
    }

    rates.push({ date: dateValue, rate: rateValue });
  };

  const walk = (value: unknown) => {
    if (!value) {
      return;
    }

    if (Array.isArray(value)) {
      value.forEach((item) => walk(item));
      return;
    }

    if (typeof value === "object") {
      const record = value as Record<string, unknown>;
      if (Array.isArray(record.rates)) {
        walk(record.rates);
      }
      if (Array.isArray(record.items)) {
        walk(record.items);
      }
      if (Array.isArray(record.days)) {
        walk(record.days);
      }
      if (record.currency && typeof record.currency === "string" && !currency) {
        currency = record.currency;
      }
      if (record.currencyCode && typeof record.currencyCode === "string" && !currency) {
        currency = record.currencyCode;
      }

      const dateValue =
        record.date ??
        record.day ??
        record.startDate ??
        record.start ??
        record.dateFrom ??
        record.from;

      if (typeof dateValue === "string") {
        extractRate(record);
      }
    }
  };

  walk(data);

  const deduped = new Map<string, number>();
  for (const rate of rates) {
    if (!deduped.has(rate.date)) {
      deduped.set(rate.date, rate.rate);
    }
  }

  return {
    currency,
    rates: Array.from(deduped.entries())
      .map(([date, rate]) => ({ date, rate }))
      .sort((a, b) => a.date.localeCompare(b.date)),
  };
}

function extractV2QuoteDetails(record: Record<string, unknown>) {
  const lines: LodgifyQuoteLine[] = [];
  const payments: LodgifyPayment[] = [];
  let nightlyTotal = 0;
  let feesTotal = 0;
  let taxesTotal = 0;
  let hasNightlyTotal = false;
  let hasFeesTotal = false;
  let hasTaxesTotal = false;

  const roomTypesValue = record.room_types ?? record.roomTypes;
  const roomTypes = Array.isArray(roomTypesValue) ? roomTypesValue : [];

  for (const roomType of roomTypes) {
    if (!roomType || typeof roomType !== "object") {
      continue;
    }
    const roomRecord = roomType as Record<string, unknown>;
    const priceTypesValue = roomRecord.price_types ?? roomRecord.priceTypes;
    const priceTypes = Array.isArray(priceTypesValue) ? priceTypesValue : [];

    for (const priceType of priceTypes) {
      if (!priceType || typeof priceType !== "object") {
        continue;
      }
      const priceTypeRecord = priceType as Record<string, unknown>;
      const rawType = priceTypeRecord.type;
      const typeValue =
        typeof rawType === "number"
          ? rawType
          : typeof rawType === "string"
            ? Number(rawType)
            : null;
      const subtotal =
        toNumber(priceTypeRecord.subtotal) ??
        toNumber(priceTypeRecord.amount) ??
        toNumber(priceTypeRecord.total);

      if (subtotal !== null && Number.isFinite(subtotal)) {
        if (typeValue === 0) {
          nightlyTotal += subtotal;
          hasNightlyTotal = true;
        } else if (typeValue === 2) {
          feesTotal += subtotal;
          hasFeesTotal = true;
        } else if (typeValue === 4) {
          taxesTotal += subtotal;
          hasTaxesTotal = true;
        }
      }

      const pricesValue = priceTypeRecord.prices ?? priceTypeRecord.items;
      const prices = Array.isArray(pricesValue) ? pricesValue : [];

      if (prices.length > 0) {
        for (const price of prices) {
          if (!price || typeof price !== "object") {
            continue;
          }
          const priceRecord = price as Record<string, unknown>;
          const labelValue =
            (typeof priceRecord.description === "string" && priceRecord.description) ||
            (typeof priceRecord.name === "string" && priceRecord.name) ||
            (typeof priceRecord.title === "string" && priceRecord.title) ||
            (typeof priceTypeRecord.description === "string" && priceTypeRecord.description) ||
            "";
          const amountValue =
            toNumber(priceRecord.amount) ??
            toNumber(priceRecord.price) ??
            toNumber(priceRecord.value) ??
            null;
          if (!labelValue || amountValue === null) {
            continue;
          }
          lines.push({ label: labelValue, amount: amountValue });
        }
        continue;
      }

      if (subtotal !== null) {
        const labelValue =
          (typeof priceTypeRecord.description === "string" &&
            priceTypeRecord.description) ||
          (typeof priceTypeRecord.name === "string" && priceTypeRecord.name) ||
          "";
        if (labelValue) {
          lines.push({ label: labelValue, amount: subtotal });
        }
      }
    }
  }

  const addonSources: unknown[] = [];
  if (Array.isArray(record.add_ons)) {
    addonSources.push(...record.add_ons);
  }
  if (Array.isArray(record.addOns)) {
    addonSources.push(...record.addOns);
  }
  if (Array.isArray(record.other_items)) {
    addonSources.push(...record.other_items);
  }
  if (Array.isArray(record.otherItems)) {
    addonSources.push(...record.otherItems);
  }

  for (const item of addonSources) {
    if (!item || typeof item !== "object") {
      continue;
    }
    const entry = item as Record<string, unknown>;
    const labelValue =
      (typeof entry.description === "string" && entry.description) ||
      (typeof entry.name === "string" && entry.name) ||
      (typeof entry.title === "string" && entry.title) ||
      "";
    const amountValue =
      toNumber(entry.amount) ??
      toNumber(entry.price) ??
      toNumber(entry.total) ??
      null;
    if (!labelValue || amountValue === null) {
      continue;
    }
    lines.push({ label: labelValue, amount: amountValue });
  }

  const scheduledValue = record.scheduled_payments ?? record.scheduledPayments;
  const scheduledPayments = Array.isArray(scheduledValue) ? scheduledValue : [];

  for (const payment of scheduledPayments) {
    if (!payment || typeof payment !== "object") {
      continue;
    }
    const entry = payment as Record<string, unknown>;
    const labelValue =
      (typeof entry.type === "string" && entry.type) ||
      (typeof entry.status === "string" && entry.status) ||
      "Payment";
    const amountValue = toNumber(entry.amount) ?? toNumber(entry.value) ?? null;
    if (amountValue === null) {
      continue;
    }
    const dueDateValue =
      (typeof entry.date_due === "string" && entry.date_due) ||
      (typeof entry.dueDate === "string" && entry.dueDate) ||
      (typeof entry.date === "string" && entry.date) ||
      null;
    payments.push({
      label: labelValue,
      amount: amountValue,
      ...(dueDateValue ? { dueDate: dueDateValue } : {}),
    });
  }

  return {
    lines,
    payments,
    nightlyTotal: hasNightlyTotal ? nightlyTotal : null,
    feesTotal: hasFeesTotal ? feesTotal : null,
    taxesTotal: hasTaxesTotal ? taxesTotal : null,
  };
}

function normalizeQuoteResponse(data: unknown): LodgifyQuote {
  let record: Record<string, unknown> = {};
  if (Array.isArray(data)) {
    const first = data.find((item) => typeof item === "object" && item !== null);
    if (first && typeof first === "object") {
      record = first as Record<string, unknown>;
    }
  } else if (typeof data === "object" && data !== null) {
    record = data as Record<string, unknown>;
  }

  const embedded =
    (record.data && typeof record.data === "object" && record.data !== null
      ? (record.data as Record<string, unknown>)
      : null) ||
    (record.quote && typeof record.quote === "object" && record.quote !== null
      ? (record.quote as Record<string, unknown>)
      : null) ||
    (record.result && typeof record.result === "object" && record.result !== null
      ? (record.result as Record<string, unknown>)
      : null);
  if (embedded) {
    record = embedded;
  }

  const summary =
    typeof record.summary === "object" && record.summary !== null
      ? (record.summary as Record<string, unknown>)
      : null;
  const v2Details = extractV2QuoteDetails(record);

  const currency =
    (typeof record.currency === "string" && record.currency) ||
    (typeof record.Currency === "string" && record.Currency) ||
    (typeof record.currencyCode === "string" && record.currencyCode) ||
    (typeof record.currency_code === "string" && record.currency_code) ||
    (summary && typeof summary.currency === "string"
      ? (summary.currency as string)
      : "");

  const total =
    toNumber(record.total_including_vat) ??
    toNumber(record.amount_gross) ??
    toNumber(record.total_excluding_vat) ??
    toNumber(record.total) ??
    toNumber(record.Total) ??
    toNumber(record.totalPrice) ??
    toNumber(record.total_amount) ??
    toNumber(record.grandTotal) ??
    toNumber(record.totalAmount) ??
    (summary ? toNumber(summary.total) : null) ??
    0;

  const nightlyTotal =
    v2Details.nightlyTotal ??
    toNumber(record.nightlyTotal) ??
    toNumber(record.nightsTotal) ??
    toNumber(record.nightly_amount) ??
    toNumber(record.subtotal) ??
    toNumber(record.subTotal) ??
    (summary ? toNumber(summary.nightlyTotal) ?? toNumber(summary.subtotal) : null) ??
    0;

  const feesTotal =
    v2Details.feesTotal ??
    toNumber(record.fees) ??
    toNumber(record.feesTotal) ??
    toNumber(record.feeTotal) ??
    (summary ? toNumber(summary.fees) : null) ??
    0;

  const taxesTotal =
    v2Details.taxesTotal ??
    toNumber(record.total_vat) ??
    toNumber(record.vat) ??
    toNumber(record.taxes) ??
    toNumber(record.taxesTotal) ??
    toNumber(record.taxTotal) ??
    (summary ? toNumber(summary.taxes) : null) ??
    0;

  const taxesIncluded =
    toBoolean(record.taxesIncluded) ??
    toBoolean(record.taxIncluded) ??
    toBoolean(record.includeTaxes) ??
    (summary ? toBoolean(summary.taxesIncluded) : null) ??
    null;

  const lineSources: unknown[] = [];
  if (Array.isArray(record.lines)) {
    lineSources.push(...record.lines);
  }
  if (Array.isArray(record.items)) {
    lineSources.push(...record.items);
  }
  if (Array.isArray(record.priceLines)) {
    lineSources.push(...record.priceLines);
  }
  if (Array.isArray(record.breakdown)) {
    lineSources.push(...record.breakdown);
  }
  if (lineSources.length === 0 && v2Details.lines.length > 0) {
    lineSources.push(...v2Details.lines);
  }

  const lines = lineSources
    .filter((item) => typeof item === "object" && item !== null)
    .map((item) => {
      const entry = item as Record<string, unknown>;
      const labelValue =
        (typeof entry.label === "string" && entry.label) ||
        (typeof entry.name === "string" && entry.name) ||
        (typeof entry.description === "string" && entry.description) ||
        "";
      const amountValue =
        toNumber(entry.amount) ?? toNumber(entry.total) ?? toNumber(entry.price) ?? null;
      if (!labelValue || amountValue === null) {
        return null;
      }
      return { label: labelValue, amount: amountValue };
    })
    .filter((entry): entry is LodgifyQuoteLine => Boolean(entry));

  const paymentSources: unknown[] = [];
  if (Array.isArray(record.payments)) {
    paymentSources.push(...record.payments);
  }
  if (Array.isArray(record.paymentSchedule)) {
    paymentSources.push(...record.paymentSchedule);
  }
  if (Array.isArray(record.installments)) {
    paymentSources.push(...record.installments);
  }
  if (Array.isArray(record.schedule)) {
    paymentSources.push(...record.schedule);
  }
  if (paymentSources.length === 0 && v2Details.payments.length > 0) {
    paymentSources.push(...v2Details.payments);
  }

  const payments = paymentSources
    .filter((item) => typeof item === "object" && item !== null)
    .map((item) => {
      const entry = item as Record<string, unknown>;
      const labelValue =
        (typeof entry.label === "string" && entry.label) ||
        (typeof entry.name === "string" && entry.name) ||
        (typeof entry.title === "string" && entry.title) ||
        (typeof entry.description === "string" && entry.description) ||
        "";
      const amountValue =
        toNumber(entry.amount) ??
        toNumber(entry.total) ??
        toNumber(entry.price) ??
        toNumber(entry.value) ??
        null;
      if (!labelValue || amountValue === null) {
        return null;
      }
      const dueDateValue =
        (typeof entry.dueDate === "string" && entry.dueDate) ||
        (typeof entry.due_on === "string" && entry.due_on) ||
        (typeof entry.dueOn === "string" && entry.dueOn) ||
        (typeof entry.date === "string" && entry.date) ||
        null;
      return {
        label: labelValue,
        amount: amountValue,
        ...(dueDateValue ? { dueDate: dueDateValue } : {}),
      };
    })
    .filter((entry): entry is LodgifyPayment => Boolean(entry));

  return {
    currency,
    total,
    nightlyTotal,
    feesTotal,
    taxesTotal,
    lines,
    payments,
    taxesIncluded,
  };
}

export function createLodgifyClient({ apiKey, baseUrl }: LodgifyClientOptions) {
  const normalizedBaseUrl = normalizeBaseUrl(baseUrl);

  async function request<T>(path: string, init?: RequestInit, timeoutMs = defaultTimeoutMs) {
    const url = new URL(path, normalizedBaseUrl);
    const headers = new Headers(init?.headers);
    headers.set("accept", "application/json");
    headers.set("X-ApiKey", apiKey);

    let lastError: LodgifyError | null = null;

    for (let attempt = 0; attempt < maxRetryAttempts; attempt += 1) {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), timeoutMs);

      try {
        const response = await fetch(url.toString(), {
          ...init,
          headers,
          signal: controller.signal,
        });
        const body = await readBody(response);
        if (!response.ok) {
          const snippet = body.text.slice(0, maxBodySnippetLength);
          throw new LodgifyError(
            `Lodgify API request failed with status ${response.status}`,
            response.status,
            url.toString(),
            snippet,
          );
        }

        return (body.data ?? body.text) as T;
      } catch (error) {
        const wrappedError =
          error instanceof LodgifyError
            ? error
            : new LodgifyError(
                error instanceof Error ? error.message : "Lodgify request failed",
                error instanceof DOMException && error.name === "AbortError" ? 408 : 500,
                url.toString(),
                null,
              );

        lastError = wrappedError;
        if (attempt >= maxRetryAttempts - 1 || !shouldRetryStatus(wrappedError.status)) {
          throw wrappedError;
        }

        await delay(getRetryDelayMs(attempt));
      } finally {
        clearTimeout(timeout);
      }
    }

    throw lastError ?? new LodgifyError("Lodgify request failed", 500, url.toString(), null);
  }

  async function getProperties() {
    return request<unknown>("/v2/properties");
  }

  async function getRooms(propertyId: string | number) {
    return request<unknown>(`/v2/properties/${propertyId}/rooms`);
  }

  function toDateTime(value: string) {
    return /^\d{4}-\d{2}-\d{2}$/.test(value) ? `${value}T00:00:00Z` : value;
  }

  function toDateTimeLocal(value: string) {
    return /^\d{4}-\d{2}-\d{2}$/.test(value) ? `${value}T00:00:00` : value;
  }

  async function getAvailability(propertyId: string | number, startDate: string, endDate: string) {
    const start = toDateTime(startDate);
    const end = toDateTime(endDate);
    const attempts = [
      new URLSearchParams({ start, end, includeDetails: "false" }),
      new URLSearchParams({ start: startDate, end: endDate }),
      new URLSearchParams({ from: startDate, to: endDate }),
    ];

    let lastError: unknown;

    for (let index = 0; index < attempts.length; index += 1) {
      const params = attempts[index];
      const url = `/v2/availability/${propertyId}?${params.toString()}`;

      try {
        const data = await request<unknown>(url);
        return normalizeAvailabilityResponse(data);
      } catch (error) {
        lastError = error;
        if (
          index === 0 &&
          error instanceof LodgifyError &&
          error.status >= 400 &&
          error.status < 500 &&
          hasParamError(error.details ?? "")
        ) {
          continue;
        }
        throw error;
      }
    }

    throw lastError instanceof Error ? lastError : new Error("Availability lookup failed");
  }

  async function getDailyRates(params: {
    startDate: string;
    endDate: string;
    houseId?: string | number;
    roomTypeId?: string | number;
  }) {
    const baseParams: Record<string, string> = {};
    if (params.houseId) {
      baseParams.HouseId = String(params.houseId);
    }
    if (params.roomTypeId) {
      baseParams.RoomTypeId = String(params.roomTypeId);
    }

    const attempts = [
      new URLSearchParams({
        ...baseParams,
        StartDate: params.startDate,
        EndDate: params.endDate,
      }),
      new URLSearchParams({
        ...baseParams,
        start: params.startDate,
        end: params.endDate,
      }),
      new URLSearchParams({
        ...baseParams,
        from: params.startDate,
        to: params.endDate,
      }),
    ];

    let lastError: unknown;

    for (let index = 0; index < attempts.length; index += 1) {
      const query = attempts[index];
      const url = `/v2/rates/calendar?${query.toString()}`;
      try {
        const data = await request<unknown>(url);
        return normalizeDailyRatesResponse(data);
      } catch (error) {
        lastError = error;
        if (
          index === 0 &&
          error instanceof LodgifyError &&
          error.status >= 400 &&
          error.status < 500 &&
          hasParamError(error.details ?? "")
        ) {
          continue;
        }
        throw error;
      }
    }

    throw lastError instanceof Error ? lastError : new Error("Daily rates lookup failed");
  }

  async function getQuote(params: {
    propertyId: string | number;
    roomTypeId: string | number;
    arrival: string;
    departure: string;
    guests: number;
    adults: number;
    children?: number;
    pets?: number;
  }) {
    const attempts = [
      {
        arrival: params.arrival,
        departure: params.departure,
      },
      {
        arrival: toDateTimeLocal(params.arrival),
        departure: toDateTimeLocal(params.departure),
      },
      {
        arrival: toDateTime(params.arrival),
        departure: toDateTime(params.departure),
      },
    ];

    let lastError: unknown;

    for (let index = 0; index < attempts.length; index += 1) {
      const attempt = attempts[index];
      const searchParams = new URLSearchParams();
      searchParams.set("arrival", attempt.arrival);
      searchParams.set("departure", attempt.departure);
      searchParams.set("roomTypes[0].Id", String(params.roomTypeId));
      searchParams.set("roomTypes[0].People", String(params.guests));
      searchParams.set("roomTypes[0].guest_breakdown.adults", String(params.adults));

      if (typeof params.children === "number") {
        searchParams.set("roomTypes[0].guest_breakdown.children", String(params.children));
      }
      if (typeof params.pets === "number") {
        searchParams.set("roomTypes[0].guest_breakdown.pets", String(params.pets));
      }

      const url = `/v2/quote/${params.propertyId}?${searchParams.toString()}`;
      try {
        const data = await request<unknown>(url);
        return normalizeQuoteResponse(data);
      } catch (error) {
        lastError = error;
        if (error instanceof LodgifyError && error.status === 400 && index < attempts.length - 1) {
          continue;
        }
        throw error;
      }
    }

    throw lastError instanceof Error ? lastError : new Error("Quote lookup failed");
  }

  return {
    getProperties,
    getRooms,
    getAvailability,
    getDailyRates,
    getQuote,
  };
}
