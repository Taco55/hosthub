-- Seed a Recipes template into the unified tables (lists/list_properties/fields).
-- Idempotent: upserts list, list_properties and fields by fixed IDs.
do $$
declare
  v_list_id uuid := 'c85e08fc-8726-443f-a327-34003f55017f';
  v_props_id uuid := '9f0f6a46-2d5c-4f6e-8b0f-5c8bd612f111';
  v_demo_preview_main uuid := 'd40f787f-b8af-4c59-a09d-4c4cf24e7b3d';
  v_demo_preview_secondary uuid := '5645805e-35bb-46d1-b5d5-208ed12889fe';
  v_demo_new_list uuid := '2b2a915d-b41a-4b97-9d6c-5e2d8f153d47';
  v_demo_tile uuid := '6fa1fb4a-cbc3-4144-916a-ba4eeb073bf1';
  v_now timestamptz := timezone('utc', now());
begin
  -- Ensure required columns exist (in case seeds run before migrations).
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='lists') then
    if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='lists' and column_name='version') then
      alter table public.lists add column version integer not null default 1;
    end if;
    if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='lists' and column_name='status') then
      alter table public.lists add column status public.template_status not null default 'draft'::public.template_status;
    end if;
    if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='lists' and column_name='names_i18n') then
      alter table public.lists add column names_i18n jsonb;
    end if;
  end if;

  insert into public.list_properties (
    id,
    scope,
    use_item_history,
    filter_completed_in_item_history,
    add_item_methods,
    is_reordering_enabled,
    list_type,
    item_tap_behavior,
    created_at,
    updated_at
  ) values (
    v_props_id,
    'template',
    false,
    false,
    array['edit_view'::text, 'weblink_basic_metadata'::text],
    true,
    'recipes',
    'show_details',
    v_now,
    v_now
  )
  on conflict (id) do update set
    scope = excluded.scope,
    list_type = excluded.list_type,
    updated_at = excluded.updated_at;

  insert into public.lists (
    id, custom_name, scope,
    names_i18n, names_i18n_plural, icon_key, list_view_setting, shared_with_user_ids,
    version, status, tile_demo_use_relative_dates, list_properties_id,
    created_at, updated_at
  ) values (
    v_list_id,
    null,
    'template',
    jsonb_build_object(
      'en', 'Recipes',
      'nl', 'Recepten'
    ),
    jsonb_build_object(
      'en', 'All recipes',
      'nl', 'Alle recepten'
    ),
    'recipe_book',
    '{}'::jsonb,
    '{}'::text[],
    1,
    'active',
    false,
    v_props_id,
    v_now,
    v_now
  )
  on conflict (id) do update set
    custom_name = excluded.custom_name,
    names_i18n = excluded.names_i18n,
    names_i18n_plural = excluded.names_i18n_plural,
    icon_key = excluded.icon_key,
    version = excluded.version,
    status = excluded.status,
    list_properties_id = excluded.list_properties_id,
    updated_at = excluded.updated_at;

  -- Reset demo items for this template to avoid duplicate sort_order conflicts.
  delete from public.list_template_demo_items
  where id in (v_demo_preview_main, v_demo_preview_secondary, v_demo_new_list, v_demo_tile);

  insert into public.fields (
    id,
    scope,
    custom_name,
    key,
    field_type,
    can_be_filtered,
    can_be_sorted,
    is_required,
    is_quick_edit_enabled,
    form_display_mode,
    icon_key,
    list_view_layout,
    detail_view_layout,
    position,
    properties_json,
    is_tracked_in_history,
    created_at,
    updated_at,
    list_properties_id,
    description,
    name_i18n,
    field_subtype
  )
  values
  (
    '3eed419b-0e70-4db8-bba5-8e5388a8736b',
    'template',
    null,
    'cover',
    'cover',
    false,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'photo',
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(-2, 0),
      'alignment',
      'left',
      'center_in_tile',
      true,
      'show_leading_icon',
      false),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(0, 0),
      'show_leading_icon',
      false
    ),
    0,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'Image field used as the recipe cover photo in list tiles.',
    jsonb_build_object('en', 'Cover', 'nl', 'Omslag'),
    null
  ),
  (
    '1b322951-9956-4cac-8f96-0b57a2cb8024',
    'template',
    null,
    'name',
    'name',
    true,
    true,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    null,
    jsonb_build_object(
      'alignment',
      'left',
      'role',
      'title',
      'grid_position',
      jsonb_build_array(0, 0),
      'show_leading_icon',
      false
    ),
    jsonb_build_object(
      'alignment',
      'left',
      'role',
      'title',
      'grid_position',
      jsonb_build_array(1, 0),
      'show_leading_icon',
      false
    ),
    1,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'Recipe name shown in lists and detail views.',
    jsonb_build_object('en', 'Name', 'nl', 'Naam'),
    null
  ),
  (
    'a4c49d9e-f997-4a2e-98b7-567972931d54',
    'template',
    null,
    'servings',
    'number',
    true,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'scale',
    jsonb_build_object(
      'grid_position', jsonb_build_array()
    ),
    jsonb_build_object(
      'alignment',
      'left',
      'grid_position',
      jsonb_build_array(2, 0),
      'show_leading_icon',
      true
    ),
    2,
    jsonb_build_object('number_type', 'integer'),
    false,
    v_now,
    v_now,
    v_props_id,
    'Whole number showing how many people the recipe serves.',
    jsonb_build_object('en', 'Servings', 'nl', 'Porties'),
    null
  ),
  (
    'd7ab50c6-81b6-4ac8-a7a6-930edfee80b9',
    'template',
    null,
    'cooking_time',
    'duration',
    true,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'clock',
    jsonb_build_object(
      'grid_position', jsonb_build_array()
    ),
    jsonb_build_object(
      'alignment',
      'left',
      'grid_position',
      jsonb_build_array(3, 0),
      'show_leading_icon',
      true
    ),
    3,
    jsonb_build_object(
      'default_labels',
      jsonb_build_array('Preparation', 'Cooking time', 'Oven')
    ),
    false,
    v_now,
    v_now,
    v_props_id,
    'Duration field capturing preparation or cook time.',
    jsonb_build_object('en', 'Cooking time', 'nl', 'Kooktijd'),
    'duration'
  ),
  (
    '811f01db-54bd-49ae-b719-f956bab9dd39',
    'template',
    null,
    'source',
    'text',
    true,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'source',
    jsonb_build_object(
      'grid_position', jsonb_build_array(),
      'show_leading_icon', true,
      'detail_level', 'minimal',
      'role', 'meta',
      'show_name', false),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(4, 0),
      'show_leading_icon',
      true,
      'show_name',
      true
    ),
    4,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'Short text describing where the recipe came from.',
    jsonb_build_object('en', 'Source', 'nl', 'Bron'),
    'text'
  ),
  (
    'c7f8342a-828e-487e-9c23-0c70e8ae65a1',
    'template',
    null,
    'website',
    'url',
    true,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'globe',
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(),
      'role',
      'meta',
      'show_leading_icon',
      true,
      'detail_level',
      'minimal'),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(5, 0),
      'show_leading_icon',
      true,
      'show_name',
      false
    ),
    5,
    jsonb_build_object('fetch_metadata', true),
    false,
    v_now,
    v_now,
    v_props_id,
    'URL linking back to the original recipe or reference page.',
    jsonb_build_object('en', 'Website', 'nl', 'Website'),
    'url'
  ),
  (
    '99d7c6f8-21af-45da-8e6d-07a2cbb76154',
    'template',
    null,
    'category',
    'tag',
    true,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'label',
    jsonb_build_object(
      'alignment',
      'right',
      'grid_position',
      jsonb_build_array(1, 0),
      'inline_separator',
      'comma',
      'inline_gap',
      4,
      'show_leading_icon',
      false,
      'role',
      'badge'
    ),
    jsonb_build_object(
      'alignment',
      'left',
      'grid_position',
      jsonb_build_array(6, 0),
      'show_leading_icon',
      false
    ),
    6,
    jsonb_build_object(
      'tags',
      jsonb_build_array(
        jsonb_build_object(
          'key',
          'vegetarian',
          'name_i18n',
          jsonb_build_object('en', 'Vegetarian', 'nl', 'Vegetarisch'),
          'primary_color_hex',
          11872553
        ),
        jsonb_build_object(
          'key',
          'dessert',
          'name_i18n',
          jsonb_build_object('en', 'Dessert', 'nl', 'Nagerecht'),
          'primary_color_hex',
          7428915
        ),
        jsonb_build_object(
          'key',
          'breakfast',
          'name_i18n',
          jsonb_build_object('en', 'Breakfast', 'nl', 'Ontbijt'),
          'primary_color_hex',
          7951394
        )
      ),
      'show_at_top_of_list',
      true
    ),
    false,
    v_now,
    v_now,
    v_props_id,
    'Tag list used to tag the recipe with dietary or meal categories.',
    jsonb_build_object('en', 'Category', 'nl', 'Categorie'),
    'tag'
  ),
  (
    'bd373a31-c401-458b-af6e-e558b741cc69',
    'template',
    null,
    'planned',
    'date',
    true,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    null,
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(0, 1),
      'alignment',
      'left',
      'inline_separator',
      'vertical_line',
      'inline_gap',
      6,
      'show_leading_icon',
      false,
      'show_name',
      true,
      'detail_level',
      'minimal',
      'role',
      'meta'
    ),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(7, 0),
      'show_name',
      true,
      'role',
      'body',
      'role_style_override',
      jsonb_build_object('font_size', 13)
    ),
    7,
    jsonb_build_object(
      'show_on_calendar',
      true,
      'schedule_from_calendar',
      true,
      'date_picker_type',
      'multi',
      'is_default_date_today',
      false
    ),
    false,
    v_now,
    v_now,
    v_props_id,
    'Multi-date selector representing planned cooking dates.',
    jsonb_build_object('en', 'Planned', 'nl', 'Gepland'),
    'multi_date'
  ),
  (
    'a87985d5-a371-4989-8d0e-771b0682931e',
    'template',
    null,
    'ingredients',
    'sublist',
    true,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'bullet_lists',
    jsonb_build_object(
      'alignment',
      'left',
      'grid_position',
      jsonb_build_array(),
      'show_leading_icon',
      true
    ),
    jsonb_build_object(
      'alignment',
      'left',
      'grid_position',
      jsonb_build_array(8, 0),
      'show_leading_icon',
      true
    ),
    8,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'Sublist where each ingredient line is captured.',
    jsonb_build_object('en', 'Ingredients', 'nl', 'Ingrediënten'),
    'ingredients'
  ),
  (
    '032df3e9-3962-4375-afd8-c66a9a8fa25d',
    'template',
    null,
    'preparation',
    'text',
    false,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'notes_2',
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(),
      'alignment',
      'left',
      'show_leading_icon',
      true,
      'detail_level',
      'minimal',
      'role',
      'body',
      'show_name',
      true),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(9, 0),
      'alignment',
      'left',
      'show_leading_icon',
      true,
      'show_name',
      true
    ),
    9,
    jsonb_build_object(
      'edit_in_expanded_view',
      true,
      'min_input_lines',
      3,
      'max_input_lines',
      8
    ),
    false,
    v_now,
    v_now,
    v_props_id,
    'Multiline instructions describing how to make the recipe.',
    jsonb_build_object('en', 'Preparation', 'nl', 'Bereiding'),
    'text_box'
  ),
  (
    'b758431d-6d9c-4718-b939-f2aedc60d6f7',
    'template',
    null,
    'comments',
    'text',
    false,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'text',
    jsonb_build_object(
    'grid_position',
    jsonb_build_array(2, 0),
    'alignment',
    'left',
    'show_leading_icon',
    true,
    'detail_level',
    'minimal',
    'show_name',
    true),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(10, 0),
      'alignment',
      'left',
      'show_leading_icon',
      true,
      'show_name',
      true,
      'detail_level',
      'minimal'
    ),
    10,
    jsonb_build_object(
      'edit_in_expanded_view',
      false,
      'min_input_lines',
      1,
      'max_input_lines',
      4
    ),
    false,
    v_now,
    v_now,
    v_props_id,
    'Free-form notes for tweaks, tips, or observations.',
    jsonb_build_object('en', 'Comments', 'nl', 'Opmerkingen'),
    'text'
  ),
  (
    '82f0c65e-118f-4466-b70e-0e89421a1ff5',
    'template',
    null,
    'image',
    'file',
    false,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'photo_library',
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(),
      'show_leading_icon',
      true),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(11, 0),
      'show_leading_icon',
      true
    ),
    11,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'Attachment list for saving additional recipe photos.',
    jsonb_build_object('en', 'Image', 'nl', 'Afbeelding'),
    'file'
  ),
  (
    'f5293dfa-1eeb-482b-b640-709e2f8a7507',
    'template',
    null,
    'date_updated',
    'updated_at',
    false,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'calendar',
    jsonb_build_object(),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(12, 0)
    ),
    12,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'System timestamp for when the recipe entry was last updated.',
    jsonb_build_object('en', 'Date updated', 'nl', 'Datum bijgewerkt'),
    'updated_at'
  ),
  (
    '504c31c0-2d4d-4c78-87d2-9517c207bc40',
    'template',
    null,
    'creation_date',
    'created_at',
    false,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'add_calendar',
    jsonb_build_object(),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(13, 0)
    ),
    13,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'System timestamp for when the recipe entry was created.',
    jsonb_build_object('en', 'Creation date', 'nl', 'Aanmaakdatum'),
    'created_at'
  ),
  (
    '376548aa-8c73-4971-8678-aec0a352cfd7',
    'template',
    null,
    'last_viewed',
    'last_viewed_at',
    false,
    false,
    false,
    false,
    'show_in_form'::public.form_display_mode,
    'clock',
    jsonb_build_object(),
    jsonb_build_object(
      'grid_position',
      jsonb_build_array(14, 0)
    ),
    14,
    '{}'::jsonb,
    false,
    v_now,
    v_now,
    v_props_id,
    'System timestamp logging the most recent view of the recipe.',
    jsonb_build_object('en', 'Last viewed', 'nl', 'Laatst bekeken'),
    'last_viewed_at'
  )
  on conflict (id) do update set
    list_properties_id = excluded.list_properties_id,
    scope = excluded.scope,
    custom_name = excluded.custom_name,
    key = excluded.key,
    field_type = excluded.field_type,
    can_be_filtered = excluded.can_be_filtered,
    can_be_sorted = excluded.can_be_sorted,
    is_required = excluded.is_required,
    is_quick_edit_enabled = excluded.is_quick_edit_enabled,
    form_display_mode = excluded.form_display_mode,
    icon_key = excluded.icon_key,
    list_view_layout = excluded.list_view_layout,
    detail_view_layout = excluded.detail_view_layout,
    position = excluded.position,
    properties_json = excluded.properties_json,
    is_tracked_in_history = excluded.is_tracked_in_history,
    name_i18n = excluded.name_i18n,
    description = excluded.description,
    field_subtype = excluded.field_subtype,
    updated_at = excluded.updated_at;
  insert into public.list_template_demo_items (
    id,
    list_id,
    sort_order,
    is_preview_demo,
    is_new_list_demo,
    is_dev_demo,
    is_tile_demo,
    data
  ) values
  (
    v_demo_preview_main,
    v_list_id,
    0,
    true,
    false,
    false,
    false,
    jsonb_build_object(
      'en', jsonb_build_object(
        'name', 'Best Vegetable Lasagna',
        'servings', 8,
        'category', jsonb_build_array('vegetarian', 'dessert'),
        'website', 'https://cookieandkate.com/best-vegetable-lasagna-recipe/',
        'cover', 'assets/images/lasagne.jpg'
      ),
      'nl', jsonb_build_object(
        'name', 'Beste groentelasagne',
        'servings', 8,
        'category', jsonb_build_array('vegetarian', 'dessert'),
        'website', 'https://cookieandkate.com/best-vegetable-lasagna-recipe/',
        'cover', 'assets/images/lasagne.jpg'
      )
    )
  ),
  (
    v_demo_preview_secondary,
    v_list_id,
    1,
    true,
    false,
    false,
    false,
    jsonb_build_object(
      'en', jsonb_build_object(
        'name', 'Another recipe',
        'servings', 4,
        'category', jsonb_build_array('vegetarian'),
        'website', 'https://cookieandkate.com/best-vegetable-lasagna-recipe/'
      ),
      'nl', jsonb_build_object(
        'name', 'Nog een recept',
        'servings', 4,
        'category', jsonb_build_array('vegetarian'),
        'website', 'https://cookieandkate.com/best-vegetable-lasagna-recipe/'
      )
    )
  ),
  (
    v_demo_new_list,
    v_list_id,
    2,
    false,
    false,
    false,
    false,
    jsonb_build_object(
      'en', jsonb_build_object(
        'name', 'Your first recipe',
        'servings', 2,
        'category', jsonb_build_array('breakfast'),
        'preparation',
        'Combine ingredients, cook until golden, then enjoy.'
      ),
      'nl', jsonb_build_object(
        'name', 'Je eerste recept',
        'servings', 2,
        'category', jsonb_build_array('breakfast'),
        'preparation',
        'Meng de ingredienten, bak tot goudbruin en geniet.'
      )
    )
  ),
  (
    v_demo_tile,
    v_list_id,
    -1,
    false,
    false,
    false,
    true,
    '{
      "en": {
        "name": "Best Vegetable Lasagna",
        "cover": "assets/images/lasagne.jpg",
        "image": [
          "https://example.com/images/vegetable-lasagna-step1.jpg",
          "https://example.com/images/vegetable-lasagna-step2.jpg"
        ],
        "source": "Cookie and Kate",
        "planned": [
          "2025-12-24",
          "2025-12-26"
        ],
        "website": "https://cookieandkate.com/best-vegetable-lasagna-recipe/",
        "category": [
          "vegetarian",
          "dessert"
        ],
        "comments": "Works well as a make-ahead dish. Let it rest 15 minutes before slicing.",
        "servings": 8,
        "created_at": -1,
        "updated_at": 0,
        "ingredients": [
          {
            "items": [
              {
                "name": "2 tablespoons olive oil"
              },
              {
                "name": "1 large onion, chopped"
              },
              {
                "name": "2 bell peppers, chopped"
              }
            ],
            "title": "Vegetables"
          },
          {
            "items": [
              {
                "name": "500 g ricotta"
              },
              {
                "name": "200 g mozzarella, grated"
              }
            ],
            "title": "Cheese mixture"
          },
          {
            "items": [
              {
                "name": "Lasagna noodles"
              },
              {
                "name": "Tomato sauce"
              }
            ],
            "title": "Other"
          }
        ],
        "preparation": "1. Preheat the oven to 190C.\\n2. Saute the vegetables until soft.\\n3. Layer noodles, sauce, vegetables and cheese in a baking dish.\\n4. Bake until golden and bubbling.",
        "cooking_time": [
          {
            "days": 0,
            "hours": 0,
            "label": "Preparation",
            "minutes": 25,
            "seconds": 0
          },
          {
            "days": 0,
            "hours": 0,
            "label": "Cooking",
            "minutes": 40,
            "seconds": 0
          },
          {
            "days": 0,
            "hours": 0,
            "label": "Total",
            "minutes": 65,
            "seconds": 0
          }
        ],
        "last_viewed_at": 0
      },
      "nl": {
        "name": "Beste groentelasagne",
        "cover": "assets/images/lasagne.jpg",
        "image": [
          "https://example.com/images/vegetable-lasagna-step1.jpg",
          "https://example.com/images/vegetable-lasagna-step2.jpg"
        ],
        "source": "Cookie and Kate",
        "planned": [
          "2025-12-24",
          "2025-12-26"
        ],
        "website": "https://cookieandkate.com/best-vegetable-lasagna-recipe/",
        "category": [
          "vegetarian",
          "dessert"
        ],
        "comments": "Werkt goed om vooraf te maken. Laat het 15 minuten rusten voor je het aansnijdt.",
        "servings": 8,
        "created_at": -1,
        "updated_at": 0,
        "ingredients": [
          {
            "items": [
              {
                "name": "2 eetlepels olijfolie"
              },
              {
                "name": "1 grote ui, gesnipperd"
              },
              {
                "name": "2 paprikas, in blokjes"
              }
            ],
            "title": "Groenten"
          },
          {
            "items": [
              {
                "name": "500 g ricotta"
              },
              {
                "name": "200 g mozzarella, geraspt"
              }
            ],
            "title": "Kaaslaag"
          },
          {
            "items": [
              {
                "name": "Lasagnebladen"
              },
              {
                "name": "Tomatensaus"
              }
            ],
            "title": "Overig"
          }
        ],
        "preparation": "1. Verwarm de oven voor op 190C.\\n2. Bak de groenten tot ze zacht zijn.\\n3. Leg lagen van bladen, saus, groenten en kaas in een ovenschaal.\\n4. Bak tot de bovenkant goudbruin en bubbelend is.",
        "cooking_time": [
          {
            "days": 0,
            "hours": 0,
            "label": "Voorbereiding",
            "minutes": 25,
            "seconds": 0
          },
          {
            "days": 0,
            "hours": 0,
            "label": "Bereiding",
            "minutes": 40,
            "seconds": 0
          },
          {
            "days": 0,
            "hours": 0,
            "label": "Totaal",
            "minutes": 65,
            "seconds": 0
          }
        ],
        "last_viewed_at": 0
      }
    }'::jsonb
  )
  on conflict (id) do update set
    list_id = excluded.list_id,
    sort_order = excluded.sort_order,
    is_preview_demo = excluded.is_preview_demo,
    is_new_list_demo = excluded.is_new_list_demo,
    is_dev_demo = excluded.is_dev_demo,
    is_tile_demo = excluded.is_tile_demo,
    data = excluded.data;
end$$;
