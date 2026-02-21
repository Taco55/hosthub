export type AvailabilityParams = {
  start: string;
  end: string;
};

export type AvailabilityResponse = {
  start: string;
  end: string;
  unavailable: string[];
  daysAvailable?: string[];
  daysUnavailable?: string[];
  available: boolean;
};

export type QuoteParams = {
  arrival: string;
  departure: string;
  adults: number;
  children?: number;
  pets?: number;
  promo?: string;
};

export type QuoteLineItem = {
  label: string;
  amount: number;
  meta?: string | null;
};

export type QuotePayment = {
  label: string;
  amount: number;
  dueDate: string | null;
};

export type QuoteRental = {
  amount: number;
  nightlyRate?: number | null;
  nights: number;
};

export type QuoteResponse = {
  currency: string;
  total: number;
  arrival: string;
  departure: string;
  nights: number;
  taxesIncluded: boolean;
  rental: QuoteRental | null;
  discounts: QuoteLineItem[];
  fees: QuoteLineItem[];
  breakdown: QuoteLineItem[];
  payments: QuotePayment[];
};

export type ApiErrorResponse = {
  error: string;
  status: number;
  reason?: string;
};

export class LodgifyApiError extends Error {
  status: number;
  details?: unknown;

  constructor(message: string, status: number, details?: unknown) {
    super(message);
    this.name = "LodgifyApiError";
    this.status = status;
    this.details = details;
  }
}

const defaultTimeoutMs = 10_000;

type RequestOptions = {
  signal?: AbortSignal;
  timeoutMs?: number;
} & Omit<RequestInit, "signal">;

function createTimeoutSignal(timeoutMs: number, signal?: AbortSignal) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  const handleAbort = () => controller.abort();

  if (signal) {
    if (signal.aborted) {
      controller.abort();
    } else {
      signal.addEventListener("abort", handleAbort);
    }
  }

  return {
    signal: controller.signal,
    cleanup: () => {
      clearTimeout(timeout);
      if (signal) {
        signal.removeEventListener("abort", handleAbort);
      }
    },
  };
}

function parseApiError(data: unknown) {
  if (!data || typeof data !== "object") {
    return null;
  }
  const record = data as Record<string, unknown>;
  if (typeof record.error !== "string" || typeof record.status !== "number") {
    return null;
  }
  const reason = typeof record.reason === "string" ? record.reason : undefined;
  return {
    error: record.error,
    status: record.status,
    ...(reason ? { reason } : {}),
  } satisfies ApiErrorResponse;
}

async function requestJson<T>(url: string, options: RequestOptions = {}) {
  const { timeoutMs = defaultTimeoutMs, signal, ...init } = options;
  const { signal: requestSignal, cleanup } = createTimeoutSignal(timeoutMs, signal);

  try {
    const response = await fetch(url, { ...init, signal: requestSignal });
    const text = await response.text();
    const data = text ? (JSON.parse(text) as unknown) : null;

    if (!response.ok) {
      const apiError = parseApiError(data);
      const status = apiError?.status ?? response.status;
      const message = apiError?.error ?? "Request failed";
      throw new LodgifyApiError(message, status, apiError ?? data ?? text);
    }

    return data as T;
  } catch (error) {
    if (error instanceof LodgifyApiError) {
      throw error;
    }
    const status = error instanceof DOMException && error.name === "AbortError" ? 408 : 500;
    const message = error instanceof Error ? error.message : "Request failed";
    throw new LodgifyApiError(message, status);
  } finally {
    cleanup();
  }
}

export async function fetchAvailability(params: AvailabilityParams, options?: RequestOptions) {
  const searchParams = new URLSearchParams({
    start: params.start,
    end: params.end,
  });
  return requestJson<AvailabilityResponse>(
    `/api/lodgify/availability?${searchParams.toString()}`,
    options,
  );
}

export async function fetchQuote(params: QuoteParams, options?: RequestOptions) {
  const searchParams = new URLSearchParams({
    arrival: params.arrival,
    departure: params.departure,
    adults: String(params.adults),
  });

  if (typeof params.children === "number") {
    searchParams.set("children", String(params.children));
  }

  if (typeof params.pets === "number") {
    searchParams.set("pets", String(params.pets));
  }

  if (params.promo) {
    searchParams.set("promo", params.promo);
  }

  return requestJson<QuoteResponse>(
    `/api/lodgify/quote?${searchParams.toString()}`,
    options,
  );
}
