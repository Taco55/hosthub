ALTER TABLE public.admin_settings
  ADD COLUMN IF NOT EXISTS booking_channel_fee_percentage numeric NOT NULL DEFAULT 15,
  ADD COLUMN IF NOT EXISTS airbnb_channel_fee_percentage numeric NOT NULL DEFAULT 3,
  ADD COLUMN IF NOT EXISTS other_channel_fee_percentage numeric NOT NULL DEFAULT 0;

UPDATE public.admin_settings
SET
  booking_channel_fee_percentage = COALESCE(booking_channel_fee_percentage, 15),
  airbnb_channel_fee_percentage = COALESCE(airbnb_channel_fee_percentage, 3),
  other_channel_fee_percentage = COALESCE(other_channel_fee_percentage, 0);
