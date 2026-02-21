ALTER TABLE public.settings
  DROP COLUMN IF EXISTS max_lists_per_user,
  DROP COLUMN IF EXISTS max_items_per_list;
