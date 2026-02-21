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

import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import {
  buildDayMapFromDays,
  computeContiguousAvailableWindows,
  markTooShortWindows,
} from "@/lib/booking/availability";
import { getMinNightsForArrival } from "@/lib/booking/config";
import { fetchAvailability } from "@/lib/lodgify/api";
import { getDateFnsLocale, getDictionary, type Locale } from "@/lib/i18n";
import { cn } from "@/lib/utils";

type AvailabilityDay = {
  date: string;
  isAvailable: boolean;
};

type DateRangePickerProps = {
  locale: Locale;
  value: DateRange | undefined;
  onChange?: (range: DateRange | undefined) => void;
  onErrorChange?: (hasError: boolean) => void;
};

function parseDate(value: string) {
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

export function DateRangePicker({
  locale,
  value,
  onChange,
  onErrorChange,
}: DateRangePickerProps) {
  const t = getDictionary(locale);
  const dateLocale = getDateFnsLocale(locale);
  const [availability, setAvailability] = useState<AvailabilityDay[]>([]);
  const [status, setStatus] = useState<"idle" | "loading" | "error">("idle");
  const [open, setOpen] = useState(false);
  const [activeMonth, setActiveMonth] = useState<Date>(new Date());
  const [selectionError, setSelectionError] = useState<string | null>(null);
  const [hoveredDate, setHoveredDate] = useState<Date | null>(null);
  const popoverRef = useRef<HTMLDivElement | null>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const controllerRef = useRef<AbortController | null>(null);
  const ignoreMonthChangeRef = useRef(false);
  const ignoreMonthTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const windowStart = useMemo(() => startOfMonth(activeMonth), [activeMonth]);
  const windowEnd = useMemo(() => addDays(windowStart, 60), [windowStart]);
  const today = useMemo(() => startOfDay(new Date()), []);
  const availabilityStart = useMemo(
    () => (differenceInCalendarDays(windowStart, today) < 0 ? today : windowStart),
    [today, windowStart],
  );

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
    }, 250);

    return () => {
      active = false;
      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }
      controller.abort();
    };
  }, [availabilityStart, onErrorChange, open, windowEnd]);

  useEffect(() => {
    if (!open) {
      return;
    }

    const handleClick = (event: MouseEvent) => {
      if (!popoverRef.current) {
        return;
      }
      if (!popoverRef.current.contains(event.target as Node)) {
        setOpen(false);
      }
    };

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClick);
    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("mousedown", handleClick);
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [open]);

  useEffect(() => {
    if (!open) {
      setSelectionError(null);
      setHoveredDate(null);
    }
  }, [open]);

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

  const minNights = useMemo(
    () => getMinNightsForArrival(value?.from ?? new Date()),
    [value?.from],
  );
  const minNightsLabel = useMemo(
    () => t.booking.tooltipMinNights.replace("{n}", String(minNights)),
    [minNights, t.booking.tooltipMinNights],
  );

  const dayMap = useMemo(() => {
    const map = buildDayMapFromDays(availability);
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
  }, [availability, minNights, minNightsLabel, t.booking.tooltipUnavailable]);

  const arrivalKey = useMemo(
    () => (value?.from ? format(value.from, "yyyy-MM-dd") : null),
    [value?.from],
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

  const isSelectingDeparture = Boolean(value?.from && !value?.to);
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
    if (!value?.from) {
      return null;
    }
    return addDays(value.from, minNights);
  }, [minNights, value?.from]);

  const disabledMatchers = useMemo(() => {
    if (value?.from && !value.to) {
      return [
        { before: addDays(today, 1) },
        (date: Date) => {
          if (!value.from) {
            return false;
          }
          if (differenceInCalendarDays(date, value.from) <= 0) {
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
    today,
    value?.from,
    value?.to,
  ]);

  const isCheckoutSelectable = useCallback(
    (date: Date) => {
      if (!isSelectingDeparture || !value?.from) {
        return false;
      }
      const earliest = addDays(today, 1);
      if (differenceInCalendarDays(date, earliest) < 0) {
        return false;
      }
      if (differenceInCalendarDays(date, value.from) <= 0) {
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
      today,
      value?.from,
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
    if (!isSelectingDeparture || !value?.from || !hoveredDate) {
      return null;
    }
    if (!isCheckoutSelectable(hoveredDate)) {
      return null;
    }
    return { from: value.from, to: hoveredDate };
  }, [hoveredDate, isCheckoutSelectable, isSelectingDeparture, value?.from]);

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
    if (modifiers?.unavailable) {
      return "text-muted-foreground opacity-40 line-through";
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
    if (isSelectingDeparture) {
      return isCheckoutSelectable(date)
        ? "text-emerald-700 hover:bg-emerald-50 font-semibold"
        : "text-muted-foreground line-through";
    }
    return isCheckInSelectable(date)
      ? "text-emerald-700 hover:bg-emerald-50 font-semibold"
      : "text-muted-foreground line-through";
  };

  const statusMessage = useMemo(() => {
    if (selectionError) {
      return selectionError;
    }
    if (open && !windowHasCoverage) {
      return status === "error" ? t.booking.error : t.booking.loading;
    }
    if (status === "loading") {
      return t.booking.loading;
    }
    if (status === "error") {
      return t.booking.error;
    }
    if (value?.from && value?.to) {
      const keys = buildDateKeys(value.from, value.to);
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
    return t.booking.rangeHint;
  }, [
    dayMap,
    open,
    selectionError,
    status,
    t.booking,
    value?.from,
    value?.to,
    windowHasCoverage,
  ]);

  const availabilityPlaceholder =
    status === "error" ? t.booking.error : t.booking.loading;

  const rangeLabel =
    value?.from && value?.to
      ? `${format(value.from, "PPP", { locale: dateLocale })} - ${format(value.to, "PPP", {
          locale: dateLocale,
        })}`
      : t.booking.selectDates;

  return (
    <div className="space-y-3">
      <div className="relative" ref={popoverRef}>
        <button
          type="button"
          className="flex w-full items-center justify-between rounded-xl border border-border/60 bg-background px-3 py-2 text-left text-sm text-foreground transition hover:border-border"
          onClick={() =>
            setOpen((prev) => {
              const next = !prev;
              if (next) {
                setActiveMonth(value?.from ?? new Date());
              }
              return next;
            })
          }
          aria-expanded={open}
          aria-haspopup="dialog"
        >
          <span className={cn(!value?.from || !value?.to ? "text-muted-foreground" : undefined)}>
            {rangeLabel}
          </span>
        </button>
        {open ? (
          <div className="absolute left-0 right-0 z-20 mt-2 rounded-2xl border border-border/60 bg-popover p-3 shadow-sm">
            {windowHasCoverage ? (
              <>
                <Calendar
                  mode="range"
                  selected={value}
                  onSelect={(next) => {
                    setSelectionError(null);
                    if (next?.from && next?.to) {
                      const nights = differenceInCalendarDays(next.to, next.from);
                      if (nights < minNights) {
                        setSelectionError(minNightsLabel);
                        onChange?.({ from: next.from, to: undefined });
                        return;
                      }
                      const rangeKeys = buildDateKeys(next.from, next.to);
                      const isRangeAvailable = rangeKeys.every(
                        (key) => dayMap.get(key)?.status !== "unavailable",
                      );
                      if (!isRangeAvailable) {
                        setSelectionError(t.booking.unavailable);
                        onChange?.({ from: next.from, to: undefined });
                        return;
                      }
                    }
                    onChange?.(next);
                    if (next?.from && next?.to) {
                      setOpen(false);
                    }
                  }}
                  disabled={disabledMatchers}
                  numberOfMonths={1}
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
                    unavailable: unavailableDates,
                    tooShort: tooShortDates,
                    hoverRangeStart: hoverRange?.from,
                    hoverRangeEnd: hoverRange?.to,
                    hoverRangeMiddle: hoverRange ? isHoverRangeMiddle : undefined,
                  }}
                  modifiersClassNames={{
                    hoverRangeStart: "bg-emerald-700 text-white rounded-full",
                    hoverRangeEnd: "bg-emerald-700 text-white rounded-full",
                    hoverRangeMiddle: "!bg-emerald-200 !text-emerald-900 rounded-none",
                  }}
                />
                <div className="mt-2">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      onChange?.(undefined);
                    }}
                    className="w-full"
                  >
                    {t.booking.clear}
                  </Button>
                </div>
              </>
            ) : (
              <div className="flex min-h-[260px] items-center justify-center rounded-xl border border-border/60 bg-background/80 px-4 py-6 text-sm text-muted-foreground">
                {availabilityPlaceholder}
              </div>
            )}
          </div>
        ) : null}
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
  );
}
