ALTER TABLE public.properties
  ADD COLUMN IF NOT EXISTS booking_channel_fee_percentage_override numeric,
  ADD COLUMN IF NOT EXISTS airbnb_channel_fee_percentage_override numeric,
  ADD COLUMN IF NOT EXISTS other_channel_fee_percentage_override numeric,
  ADD COLUMN IF NOT EXISTS cleaning_cost_fixed numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS linen_cost_fixed numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS service_cost_fixed numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS other_cost_fixed numeric NOT NULL DEFAULT 0;

UPDATE public.properties
SET
  cleaning_cost_fixed = COALESCE(cleaning_cost_fixed, 0),
  linen_cost_fixed = COALESCE(linen_cost_fixed, 0),
  service_cost_fixed = COALESCE(service_cost_fixed, 0),
  other_cost_fixed = COALESCE(other_cost_fixed, 0);
