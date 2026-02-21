export type DateRange = {
  arrival: string | null;
  departure: string | null;
};

export type Guests = {
  adults: number;
  children: number;
  pets: number;
};

export type Money = {
  currency: string;
  amount: number;
  formatted: string;
};

export type QuoteLine = {
  label: string;
  amount: Money;
  meta?: string;
};

export type QuoteSection = {
  title: string;
  lines: QuoteLine[];
  subtotal?: Money;
};

export type Payment = {
  label: string;
  dueLabel: string;
  amount: Money;
  dueDate?: string | null;
};

export type QuoteView = {
  rentalTitle: string;
  rentalImageSrc: string;
  arrival: string;
  departure: string;
  nights: number;
  currency: string;
  sections: QuoteSection[];
  total: Money;
  taxesIncluded: boolean;
  payments: Payment[];
};
