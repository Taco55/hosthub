-- Add channel_settings JSONB column to properties table.
-- This replaces the flat per-property revenue rule columns with
-- a structured per-channel configuration (commission, markup, costs with types).

ALTER TABLE public.properties
  ADD COLUMN IF NOT EXISTS channel_settings jsonb;

-- Migrate existing flat column data into the new JSONB structure.
-- Linen defaults to per_person for Airbnb and per_booking for others.
UPDATE public.properties
SET channel_settings = jsonb_build_object(
  'booking', jsonb_build_object(
    'commission_percentage', booking_channel_fee_percentage_override,
    'rate_markup_percentage', NULL,
    'costs', jsonb_build_object(
      'cleaning', jsonb_build_object('amount', cleaning_cost_fixed, 'type', 'per_booking'),
      'linen',   jsonb_build_object('amount', linen_cost_fixed,    'type', 'per_booking'),
      'service', jsonb_build_object('amount', service_cost_fixed,  'type', 'per_booking'),
      'other',   jsonb_build_object('amount', other_cost_fixed,    'type', 'per_booking')
    )
  ),
  'airbnb', jsonb_build_object(
    'commission_percentage', airbnb_channel_fee_percentage_override,
    'rate_markup_percentage', NULL,
    'costs', jsonb_build_object(
      'cleaning', jsonb_build_object('amount', cleaning_cost_fixed, 'type', 'per_booking'),
      'linen',   jsonb_build_object('amount', linen_cost_fixed,    'type', 'per_person'),
      'service', jsonb_build_object('amount', service_cost_fixed,  'type', 'per_booking'),
      'other',   jsonb_build_object('amount', other_cost_fixed,    'type', 'per_booking')
    )
  ),
  'other', jsonb_build_object(
    'commission_percentage', other_channel_fee_percentage_override,
    'rate_markup_percentage', NULL,
    'costs', jsonb_build_object(
      'cleaning', jsonb_build_object('amount', cleaning_cost_fixed, 'type', 'per_booking'),
      'linen',   jsonb_build_object('amount', linen_cost_fixed,    'type', 'per_booking'),
      'service', jsonb_build_object('amount', service_cost_fixed,  'type', 'per_booking'),
      'other',   jsonb_build_object('amount', other_cost_fixed,    'type', 'per_booking')
    )
  )
);

-- Update the Airbnb default commission from 3% to 15.5% (host-only model since 2025).
UPDATE public.admin_settings
SET airbnb_channel_fee_percentage = 15.5
WHERE airbnb_channel_fee_percentage = 3;
