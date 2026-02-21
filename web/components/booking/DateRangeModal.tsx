"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  DayButton as CalendarDayButton,
  type DayButtonProps,
  type DateRange,
} from "react-day-picker";
import {
  addDays,
  differenceInCalendarDays,
  format,
  isValid,
  parseISO,
  startOfDay,
  startOfMonth,
} from "date-fns";

import { Calendar } from "@/components/ui/calendar";
import {
  buildDayMapFromDays,
  computeContiguousAvailableWindows,
  markTooShortWindows,
} from "@/lib/booking/availability";
import { getMinNightsForArrival } from "@/lib/booking/config";
import type { DateRange as BookingDateRange } from "@/lib/booking/types";
import { fetchAvailability } from "@/lib/lodgify/api";
import { getDateFnsLocale, getDictionary, type Locale } from "@/lib/i18n";
import { cn } from "@/lib/utils";

type AvailabilityDay = {
  date: string;
  isAvailable: boolean;
};

type DateRangeModalProps = {
  locale: Locale;
  open: boolean;
  value: BookingDateRange;
  onOpenChange: (open: boolean) => void;
  onConfirm: (range: BookingDateRange) => void;
  activeField?: "checkIn" | "checkOut";
  variant?: "popover" | "inline";
  onErrorChange?: (hasError: boolean) => void;
  blockedDates?: string[];
  className?: string;
};

const prefetchWindowDays = 90;

function parseDate(value: string | null) {
  if (!value) {
    return null;
  }
  const parsed = parseISO(value);
  return isValid(parsed) ? parsed : null;
}

function buildDateKeys(start: Date, end: Date) {
  const keys: string[] = [];
  let cursor = new Date(start);
  while (cursor < end) {
    keys.push(format(cursor, "yyyy-MM-dd"));
    cursor = addDays(cursor, 1);
  }
  return keys;
}

function mergeAvailability(prev: AvailabilityDay[], next: AvailabilityDay[]) {
  const map = new Map(prev.map((day) => [day.date, day.isAvailable]));
  for (const day of next) {
    map.set(day.date, day.isAvailable);
  }

  return Array.from(map.entries())
    .map(([date, isAvailable]) => ({ date, isAvailable }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

function buildAvailabilityFromWindow(start: string, end: string, unavailable: string[]) {
  const startDate = parseDate(start);
  const endDate = parseDate(end);
  if (!startDate || !endDate) {
    return [];
  }

  const keys = buildDateKeys(startDate, endDate);
  const unavailableSet = new Set(unavailable);
  return keys.map((date) => ({ date, isAvailable: !unavailableSet.has(date) }));
}

export function DateRangeModal({
  locale,
  open,
  value,
  onOpenChange,
  onConfirm,
  activeField = "checkIn",
  variant = "popover",
  onErrorChange,
  blockedDates,
  className,
}: DateRangeModalProps) {
  const t = getDictionary(locale);
  const dateLocale = getDateFnsLocale(locale);
  const [selection, setSelection] = useState<DateRange | undefined>();
  const [availability, setAvailability] = useState<AvailabilityDay[]>([]);
  const [status, setStatus] = useState<"idle" | "loading" | "error">("idle");
  const [selectionError, setSelectionError] = useState<string | null>(null);
  const [hoveredDate, setHoveredDate] = useState<Date | null>(null);
  const [activeMonth, setActiveMonth] = useState<Date>(new Date());
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const controllerRef = useRef<AbortController | null>(null);
  const didInitMonthRef = useRef(false);
  const ignoreMonthChangeRef = useRef(false);
  const ignoreMonthTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const windowStart = useMemo(() => startOfMonth(activeMonth), [activeMonth]);
  const windowEnd = useMemo(
    () => addDays(windowStart, prefetchWindowDays),
    [windowStart],
  );
  const today = useMemo(() => startOfDay(new Date()), []);
  const availabilityStart = useMemo(
    () => (differenceInCalendarDays(windowStart, today) < 0 ? today : windowStart),
    [today, windowStart],
  );

  useEffect(() => {
    if (!open) {
      return;
    }

    const from = parseDate(value.arrival);
    const to = parseDate(value.departure);
    setSelection(from ? { from, to: to ?? undefined } : undefined);
    setSelectionError(null);
    setHoveredDate(null);
    if (!didInitMonthRef.current) {
      setActiveMonth(from ?? new Date());
      didInitMonthRef.current = true;
    }
  }, [open, value.arrival, value.departure]);

  useEffect(() => {
    return () => {
      if (ignoreMonthTimeoutRef.current) {
        clearTimeout(ignoreMonthTimeoutRef.current);
      }
    };
  }, []);

  const markIgnoreMonthChange = (date: Date) => {
    if (
      date.getFullYear() === activeMonth.getFullYear() &&
      date.getMonth() === activeMonth.getMonth()
    ) {
      return;
    }
    ignoreMonthChangeRef.current = true;
    if (ignoreMonthTimeoutRef.current) {
      clearTimeout(ignoreMonthTimeoutRef.current);
    }
    ignoreMonthTimeoutRef.current = setTimeout(() => {
      ignoreMonthChangeRef.current = false;
    }, 0);
  };

  const handleMonthChange = (month: Date) => {
    if (ignoreMonthChangeRef.current) {
      ignoreMonthChangeRef.current = false;
      return;
    }
    setActiveMonth(month);
  };

  useEffect(() => {
    if (!open) {
      return;
    }

    if (differenceInCalendarDays(windowEnd, availabilityStart) <= 0) {
      return;
    }

    const start = format(availabilityStart, "yyyy-MM-dd");
    const end = format(windowEnd, "yyyy-MM-dd");

    let active = true;

    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }

    controllerRef.current?.abort();
    const controller = new AbortController();
    controllerRef.current = controller;

    debounceRef.current = setTimeout(() => {
      async function loadAvailability() {
        try {
          setStatus("loading");
          const data = await fetchAvailability(
            { start, end },
            { signal: controller.signal },
          );
          if (active) {
            const windowAvailability = buildAvailabilityFromWindow(
              data.start,
              data.end,
              data.unavailable,
            );
            setAvailability((prev) => mergeAvailability(prev, windowAvailability));
            setStatus("idle");
            onErrorChange?.(false);
          }
        } catch (error) {
          if (!active || controller.signal.aborted) {
            return;
          }
          setStatus("error");
          onErrorChange?.(true);
        }
      }

      loadAvailability();
    }, 200);

    return () => {
      active = false;
      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }
      controller.abort();
    };
  }, [availabilityStart, onErrorChange, open, windowEnd]);

  const blockedDateSet = useMemo(
    () => new Set(blockedDates ?? []),
    [blockedDates],
  );

  const minNights = useMemo(
    () => getMinNightsForArrival(selection?.from ?? new Date()),
    [selection?.from],
  );
  const minNightsLabel = useMemo(
    () => t.booking.tooltipMinNights.replace("{n}", String(minNights)),
    [minNights, t.booking.tooltipMinNights],
  );

  const dayMap = useMemo(() => {
    const map = buildDayMapFromDays(availability);
    for (const date of blockedDateSet) {
      map.set(date, { status: "unavailable" });
    }
    computeContiguousAvailableWindows(map);
    markTooShortWindows(map, minNights);
    for (const info of map.values()) {
      if (info.status === "tooShort") {
        info.reason = minNightsLabel;
      } else if (info.status === "unavailable") {
        info.reason = t.booking.tooltipUnavailable;
      }
    }
    return map;
  }, [availability, blockedDateSet, minNights, minNightsLabel, t.booking.tooltipUnavailable]);

  const arrivalKey = useMemo(
    () => (selection?.from ? format(selection.from, "yyyy-MM-dd") : null),
    [selection?.from],
  );
  const arrivalInfo = useMemo(
    () => (arrivalKey ? dayMap.get(arrivalKey) ?? null : null),
    [arrivalKey, dayMap],
  );
  const maxCheckoutDate = useMemo(() => {
    if (!arrivalInfo?.windowEnd) {
      return null;
    }
    const endDate = parseDate(arrivalInfo.windowEnd);
    return endDate ? addDays(endDate, 1) : null;
  }, [arrivalInfo?.windowEnd]);

  const isSelectingDeparture = Boolean(selection?.from && !selection?.to);
  const unavailableDates = useMemo(() => {
    const dates = Array.from(dayMap.entries())
      .filter(([, info]) => info.status === "unavailable")
      .map(([date]) => parseDate(date))
      .filter((date): date is Date => Boolean(date));

    const dateKeys = new Set(dates.map((date) => format(date, "yyyy-MM-dd")));
    const todayNext = addDays(today, 1);
    const pastEnd = windowEnd < todayNext ? windowEnd : todayNext;
    const pastKeys = buildDateKeys(windowStart, pastEnd);
    for (const key of pastKeys) {
      if (dateKeys.has(key)) {
        continue;
      }
      const parsed = parseDate(key);
      if (parsed) {
        dates.push(parsed);
        dateKeys.add(key);
      }
    }

    if (!isSelectingDeparture || !maxCheckoutDate) {
      return dates;
    }

    return dates.filter((date) => {
      if (differenceInCalendarDays(date, today) <= 0) {
        return true;
      }
      return differenceInCalendarDays(date, maxCheckoutDate) !== 0;
    });
  }, [dayMap, isSelectingDeparture, maxCheckoutDate, today, windowEnd, windowStart]);
  const tooShortDates = useMemo(() => {
    if (isSelectingDeparture) {
      return [];
    }
    return Array.from(dayMap.entries())
      .filter(([, info]) => info.status === "tooShort")
      .map(([date]) => parseDate(date))
      .filter((date): date is Date => Boolean(date));
  }, [dayMap, isSelectingDeparture]);
  const availableDates = useMemo(() => {
    if (isSelectingDeparture) {
      return [];
    }
    return Array.from(dayMap.entries())
      .filter(([, info]) => info.status === "available")
      .map(([date]) => parseDate(date))
      .filter((date): date is Date => Boolean(date));
  }, [dayMap, isSelectingDeparture]);

  const windowKeys = useMemo(
    () => buildDateKeys(availabilityStart, windowEnd),
    [availabilityStart, windowEnd],
  );
  const windowHasCoverage = useMemo(() => {
    return !windowKeys.length || windowKeys.every((key) => dayMap.has(key));
  }, [dayMap, windowKeys]);

  const disabledRanges = useMemo<DateRange[]>(() => {
    const unavailableDates = Array.from(dayMap.entries())
      .filter(([, info]) => info.status !== "available")
      .map(([date]) => parseDate(date))
      .filter((date): date is Date => Boolean(date))
      .sort((a, b) => a.getTime() - b.getTime());

    const ranges: DateRange[] = [];
    let current: DateRange | null = null;

    for (const date of unavailableDates) {
      if (!current?.from || !current.to) {
        current = { from: date, to: date };
        continue;
      }

      if (differenceInCalendarDays(date, current.to) <= 1) {
        current = { from: current.from, to: date };
        continue;
      }

      ranges.push(current);
      current = { from: date, to: date };
    }

    if (current?.from && current.to) {
      ranges.push(current);
    }

    return ranges;
  }, [dayMap]);
  const minCheckoutDate = useMemo(() => {
    if (!selection?.from) {
      return null;
    }
    return addDays(selection.from, minNights);
  }, [minNights, selection?.from]);

  const disabledMatchers = useMemo(() => {
    if (selection?.from && !selection.to) {
      return [
        { before: addDays(today, 1) },
        (date: Date) => {
          if (!selection.from) {
            return false;
          }
          if (differenceInCalendarDays(date, selection.from) <= 0) {
            return true;
          }
          if (minCheckoutDate && differenceInCalendarDays(date, minCheckoutDate) < 0) {
            return true;
          }
          if (maxCheckoutDate && differenceInCalendarDays(date, maxCheckoutDate) > 0) {
            return true;
          }
          const key = format(date, "yyyy-MM-dd");
          const info = dayMap.get(key);
          if (!info) {
            if (
              maxCheckoutDate &&
              differenceInCalendarDays(date, maxCheckoutDate) === 0
            ) {
              return false;
            }
            return true;
          }
          if (info.status === "unavailable") {
            if (
              maxCheckoutDate &&
              differenceInCalendarDays(date, maxCheckoutDate) === 0
            ) {
              return false;
            }
            return true;
          }
          return false;
        },
      ];
    }
    return [{ before: addDays(today, 1) }, ...disabledRanges];
  }, [
    dayMap,
    disabledRanges,
    maxCheckoutDate,
    minCheckoutDate,
    selection?.from,
    selection?.to,
    today,
  ]);

  const isCheckoutSelectable = useCallback(
    (date: Date) => {
      if (!isSelectingDeparture || !selection?.from) {
        return false;
      }
      const earliest = addDays(today, 1);
      if (differenceInCalendarDays(date, earliest) < 0) {
        return false;
      }
      if (differenceInCalendarDays(date, selection.from) <= 0) {
        return false;
      }
      if (minCheckoutDate && differenceInCalendarDays(date, minCheckoutDate) < 0) {
        return false;
      }
      if (maxCheckoutDate && differenceInCalendarDays(date, maxCheckoutDate) > 0) {
        return false;
      }
      const key = format(date, "yyyy-MM-dd");
      const info = dayMap.get(key);
      if (!info || info.status === "unavailable") {
        return Boolean(
          maxCheckoutDate && differenceInCalendarDays(date, maxCheckoutDate) === 0,
        );
      }
      return true;
    },
    [
      isSelectingDeparture,
      maxCheckoutDate,
      minCheckoutDate,
      selection?.from,
      today,
      dayMap,
    ],
  );

  const isCheckInSelectable = useCallback(
    (date: Date) => {
      const earliest = addDays(today, 1);
      if (differenceInCalendarDays(date, earliest) < 0) {
        return false;
      }
      const key = format(date, "yyyy-MM-dd");
      const info = dayMap.get(key);
      return info?.status === "available";
    },
    [dayMap, today],
  );

  useEffect(() => {
    if (!isSelectingDeparture) {
      setHoveredDate(null);
    }
  }, [isSelectingDeparture]);

  const hoverRange = useMemo(() => {
    if (!isSelectingDeparture || !selection?.from || !hoveredDate) {
      return null;
    }
    if (!isCheckoutSelectable(hoveredDate)) {
      return null;
    }
    return { from: selection.from, to: hoveredDate };
  }, [hoveredDate, isCheckoutSelectable, isSelectingDeparture, selection?.from]);

  const isHoverRangeMiddle = useCallback(
    (date: Date) => {
      if (!hoverRange?.from || !hoverRange.to) {
        return false;
      }
      return (
        differenceInCalendarDays(date, hoverRange.from) > 0 &&
        differenceInCalendarDays(hoverRange.to, date) > 0
      );
    },
    [hoverRange],
  );

  const getTooltipForDate = (date: Date) => {
    if (isSelectingDeparture) {
      return isCheckoutSelectable(date) ? null : t.booking.tooltipUnavailable;
    }
    return isCheckInSelectable(date) ? null : t.booking.tooltipUnavailable;
  };

  const getDayToneClass = (date: Date, modifiers?: DayButtonProps["modifiers"]) => {
    if (modifiers?.selected || modifiers?.range_start || modifiers?.range_end) {
      return null;
    }
    if (
      modifiers?.hoverRangeStart ||
      modifiers?.hoverRangeEnd ||
      modifiers?.hoverRangeMiddle
    ) {
      return null;
    }
    if (modifiers?.range_middle) {
      return null;
    }

    if (modifiers?.tooShort) {
      return "bg-amber-50 text-amber-700 ring-1 ring-inset ring-amber-200 line-through";
    }
    if (modifiers?.unavailable) {
      return "bg-slate-100 text-slate-500 ring-1 ring-inset ring-slate-200 line-through";
    }

    if (isSelectingDeparture) {
      return isCheckoutSelectable(date)
        ? "bg-emerald-50 text-emerald-900 font-semibold ring-1 ring-inset ring-emerald-200 hover:bg-emerald-100"
        : "bg-slate-100 text-slate-500 ring-1 ring-inset ring-slate-200 line-through";
    }

    if (modifiers?.available) {
      return "bg-emerald-50 text-emerald-900 font-semibold ring-1 ring-inset ring-emerald-200 hover:bg-emerald-100";
    }
    return isCheckInSelectable(date)
      ? "bg-emerald-50 text-emerald-900 font-semibold ring-1 ring-inset ring-emerald-200 hover:bg-emerald-100"
      : "bg-slate-100 text-slate-500 ring-1 ring-inset ring-slate-200 line-through";
  };

  const statusMessage = useMemo(() => {
    if (selectionError) {
      return selectionError;
    }
    if (!windowHasCoverage) {
      return status === "error" ? t.booking.error : t.booking.loading;
    }
    if (status === "loading") {
      return t.booking.loading;
    }
    if (status === "error") {
      return t.booking.error;
    }
    if (selection?.from && selection?.to) {
      const keys = buildDateKeys(selection.from, selection.to);
      if (!keys.length) {
        return t.booking.rangeHint;
      }
      const hasCoverage = keys.every((key) => dayMap.has(key));
      if (!hasCoverage) {
        return t.booking.loading;
      }
      const isAvailable = keys.every((key) => dayMap.get(key)?.status !== "unavailable");
      return isAvailable ? t.booking.available : t.booking.unavailable;
    }
    if (selection?.from && !selection.to) {
      return t.booking.selectCheckOutDate;
    }
    return t.booking.rangeHint;
  }, [
    dayMap,
    selectionError,
    selection,
    status,
    t.booking,
    windowHasCoverage,
  ]);

  const availabilityPlaceholder =
    status === "error" ? t.booking.error : t.booking.loading;

  const title = t.booking.selectDates;
  const isInline = variant === "inline";

  if (!open) {
    return null;
  }

  return (
    <div
      className={cn(
        isInline
          ? "w-full rounded-2xl border border-border/60 bg-white p-4 shadow-sm"
          : "absolute top-full z-40 mt-3 w-full max-w-2xl rounded-2xl border border-border/60 bg-white p-5 shadow-lg",
        !isInline && (activeField === "checkOut" ? "right-0" : "left-0"),
        className,
      )}
      role="dialog"
      aria-label={title}
    >
      <div className="space-y-4">
        {windowHasCoverage ? (
          <Calendar
            mode="range"
            selected={selection}
            onSelect={(_, selectedDay) => {
              if (!selectedDay) {
                return;
              }

              let nextRange: DateRange;
              if (!selection?.from || selection.to) {
                nextRange = { from: selectedDay, to: undefined };
              } else if (selectedDay <= selection.from) {
                nextRange = { from: selectedDay, to: undefined };
              } else {
                nextRange = { from: selection.from, to: selectedDay };
              }

              setSelectionError(null);
              const arrival = nextRange.from;
              if (!arrival) {
                return;
              }

              const departure = nextRange.to ? format(nextRange.to, "yyyy-MM-dd") : null;

              setSelection(nextRange);
              if (nextRange.from && nextRange.to) {
                const nights = differenceInCalendarDays(nextRange.to, nextRange.from);
                if (nights < minNights) {
                  setSelectionError(minNightsLabel);
                  setSelection({ from: nextRange.from, to: undefined });
                  onConfirm({
                    arrival: format(arrival, "yyyy-MM-dd"),
                    departure: null,
                  });
                  return;
                }
                const rangeKeys = buildDateKeys(nextRange.from, nextRange.to);
                const isRangeAvailable = rangeKeys.every(
                  (key) => dayMap.get(key)?.status !== "unavailable",
                );
                if (!isRangeAvailable) {
                  setSelectionError(t.booking.unavailable);
                  setSelection({ from: nextRange.from, to: undefined });
                  onConfirm({
                    arrival: format(arrival, "yyyy-MM-dd"),
                    departure: null,
                  });
                  return;
                }
              }
              onConfirm({
                arrival: format(arrival, "yyyy-MM-dd"),
                departure,
              });
              if (nextRange.from && nextRange.to) {
                if (!isInline) {
                  onOpenChange(false);
                }
              }
            }}
            disabled={disabledMatchers}
            numberOfMonths={2}
            navLayout="around"
            locale={dateLocale}
            month={activeMonth}
            onMonthChange={handleMonthChange}
            onDayClick={(day) => {
              markIgnoreMonthChange(day);
            }}
            onDayMouseEnter={(day) => {
              if (!isSelectingDeparture) {
                return;
              }
              setHoveredDate(isCheckoutSelectable(day) ? day : null);
            }}
            onDayMouseLeave={() => {
              if (isSelectingDeparture) {
                setHoveredDate(null);
              }
            }}
            components={{
              DayButton: (props: DayButtonProps) => {
                const tooltip = getTooltipForDate(props.day.date);
                return (
                  <span className="relative inline-flex group">
                    <CalendarDayButton
                      {...props}
                      className={cn(
                        props.className,
                        getDayToneClass(props.day.date, props.modifiers),
                      )}
                    />
                    {tooltip ? (
                      <span
                        role="tooltip"
                        className="pointer-events-none absolute left-1/2 bottom-full z-50 mb-2 w-max -translate-x-1/2 rounded-md bg-slate-900 px-2 py-1 text-[11px] text-white shadow-sm opacity-0 transition-opacity duration-0 group-hover:opacity-100 group-hover:delay-100 group-focus-within:opacity-100 group-focus-within:delay-100"
                      >
                        {tooltip}
                      </span>
                    ) : null}
                  </span>
                );
              },
            }}
            modifiers={{
              available: availableDates,
              unavailable: unavailableDates,
              tooShort: tooShortDates,
              hoverRangeStart: hoverRange?.from,
              hoverRangeEnd: hoverRange?.to,
              hoverRangeMiddle: hoverRange ? isHoverRangeMiddle : undefined,
            }}
            modifiersClassNames={{
              available:
                "bg-emerald-50 text-emerald-900 font-semibold ring-1 ring-inset ring-emerald-200",
              unavailable:
                "bg-slate-100 text-slate-500 ring-1 ring-inset ring-slate-200 line-through",
              tooShort:
                "bg-amber-50 text-amber-700 ring-1 ring-inset ring-amber-200 line-through",
              hoverRangeStart: "bg-emerald-700 text-white rounded-full",
              hoverRangeEnd: "bg-emerald-700 text-white rounded-full",
              hoverRangeMiddle: "!bg-emerald-200 !text-emerald-900 rounded-none",
            }}
            classNames={{
              months: "flex flex-col gap-4 md:flex-row",
              month: "relative space-y-4 md:flex-1",
              month_caption: "flex items-center justify-center px-10",
              button_previous:
                "absolute left-0 top-0 inline-flex h-8 w-8 items-center justify-center rounded-full border border-transparent text-muted-foreground transition-colors hover:border-border/70 hover:bg-accent/10 hover:text-foreground",
              button_next:
                "absolute right-0 top-0 inline-flex h-8 w-8 items-center justify-center rounded-full border border-transparent text-muted-foreground transition-colors hover:border-border/70 hover:bg-accent/10 hover:text-foreground",
              caption_label: "text-sm font-semibold",
            }}
          />
        ) : (
          <div className="flex min-h-[320px] items-center justify-center rounded-2xl border border-border/60 bg-background/80 px-4 py-6 text-sm text-muted-foreground">
            {availabilityPlaceholder}
          </div>
        )}
        <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
          <span className="inline-flex items-center gap-2">
            <span className="h-3 w-3 rounded-full border border-emerald-300 bg-emerald-100" />
            {t.booking.calendarLegendAvailable}
          </span>
          <span className="inline-flex items-center gap-2">
            <span className="h-3 w-3 rounded-full bg-emerald-700" />
            {t.booking.calendarLegendSelected}
          </span>
          <span className="inline-flex items-center gap-2">
            <span className="h-3 w-3 rounded-full border border-slate-300 bg-slate-100" />
            {t.booking.calendarLegendUnavailable}
          </span>
          <span className="inline-flex items-center gap-2">
            <span className="h-3 w-3 rounded-full border border-amber-300 bg-amber-100" />
            {t.booking.calendarLegendMinStay}
          </span>
        </div>
        <div
          className={cn(
            "text-xs",
            statusMessage === t.booking.available && "text-emerald-600",
            (statusMessage === t.booking.unavailable || statusMessage === selectionError) &&
              "text-rose-600",
            statusMessage !== t.booking.available &&
              statusMessage !== t.booking.unavailable &&
              statusMessage !== selectionError &&
              "text-muted-foreground",
          )}
        >
          {statusMessage}
        </div>
      </div>
    </div>
  );
}
