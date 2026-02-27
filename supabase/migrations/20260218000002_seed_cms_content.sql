--
-- Seed CMS content from web/lib/content.ts into cms_documents.
-- Uses a temporary site_id variable derived from the first site in the sites table.
-- All JSONB structures mirror the existing TypeScript types 1:1.
--

DO $$
DECLARE
  v_site_id uuid;
BEGIN
  -- Get the first (and currently only) site
  SELECT id INTO v_site_id FROM public.sites LIMIT 1;

  -- If no site exists yet, create one for Trysil Panorama
  IF v_site_id IS NULL THEN
    INSERT INTO public.sites (name, default_locale, locales, timezone)
    VALUES ('Trysil Panorama', 'nl', ARRAY['nl', 'en', 'no'], 'Europe/Oslo')
    RETURNING id INTO v_site_id;
  END IF;

  -- ============================================================
  -- SITE CONFIG
  -- ============================================================

  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES
  (v_site_id, 'site_config', 'main', 'en', '{
    "name": "Fageråsen 701",
    "location": "Fageråsen, Trysil, Norway",
    "capacity": 8,
    "bedrooms": 3,
    "bathrooms": 2,
    "mapEmbedUrl": "https://www.openstreetmap.org/export/embed.html?bbox=12.155%2C61.322%2C12.175%2C61.342&layer=mapnik&marker=61.332251%2C12.165275",
    "mapLinkUrl": "https://www.openstreetmap.org/?mlat=61.332251&mlon=12.165275#map=16/61.332251/12.165275"
  }', 'published', now()),

  (v_site_id, 'site_config', 'main', 'nl', '{
    "name": "Fageråsen 701",
    "location": "Fageråsen, Trysil, Noorwegen",
    "capacity": 8,
    "bedrooms": 3,
    "bathrooms": 2,
    "mapEmbedUrl": "https://www.openstreetmap.org/export/embed.html?bbox=12.155%2C61.322%2C12.175%2C61.342&layer=mapnik&marker=61.332251%2C12.165275",
    "mapLinkUrl": "https://www.openstreetmap.org/?mlat=61.332251&mlon=12.165275#map=16/61.332251/12.165275"
  }', 'published', now()),

  (v_site_id, 'site_config', 'main', 'no', '{
    "name": "Fageråsen 701",
    "location": "Fageråsen, Trysil, Norge",
    "capacity": 8,
    "bedrooms": 3,
    "bathrooms": 2,
    "mapEmbedUrl": "https://www.openstreetmap.org/export/embed.html?bbox=12.155%2C61.322%2C12.175%2C61.342&layer=mapnik&marker=61.332251%2C12.165275",
    "mapLinkUrl": "https://www.openstreetmap.org/?mlat=61.332251&mlon=12.165275#map=16/61.332251/12.165275"
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- ============================================================
  -- CABIN CONTENT (CabinContent type)
  -- ============================================================

  -- English
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'cabin', 'main', 'en', '{
    "meta": {
      "name": "Cosy ski-in/out mountain cabin with sauna",
      "locationShort": "Fageråsen, Trysil, Norway",
      "sleeps": "8–9",
      "altitude": "800 m"
    },
    "hero": {
      "title": "Cosy ski-in/out mountain cabin with sauna",
      "subtitle": "Detached chalet in Fageråsen (Trysil) with ski-in/ski-out access, private sauna, and panoramic mountain views.",
      "badges": [
        { "label": "Sleeps", "value": "8–9" },
        { "label": "Altitude", "value": "800 m" },
        { "label": "Sauna", "value": "Private" }
      ]
    },
    "experience": [
      "Ski in/out",
      "Private sauna",
      "Panoramic views",
      "Trails at the house",
      "Family friendly loft"
    ],
    "description": [
      "Detached chalet in Fageråsen (Trysil) with ski-in/ski-out access, private sauna, and panoramic mountain views. Sleeps 8–9. Covered veranda with BBQ and heater. Cozy living room with wood-burning stove, 2 bathrooms, child-friendly loft, and fully equipped kitchen. Hiking and mountain bike trails start at the house. Quiet location at 800 m altitude, a 7-minute walk from Skistar Lodge. Perfect for comfort, nature, and active holidays in any season.",
      "The house is very suitable for families and groups. The chalet comfortably sleeps 8 people, with an extra-wide bed (120 cm) in the loft. Due to the sloped roof, this bed is particularly suitable for two children or one adult."
    ],
    "layoutAndFacilities": {
      "title": "Layout & facilities",
      "items": [
        "4 bedrooms with 5 beds",
        "2 bedrooms with double beds (150 x 200 cm)",
        "1 bedroom with bunk bed (75 × 185 cm) – suitable for children or young adults",
        "Attic room with single bed (90 x 200 cm) + extra-wide bed (120 x 200 cm), suitable for 1 adult or 2 children",
        "Child-friendly play corner in the attic with daybed (120 x 175 cm), TV and stair gate",
        "2 bathrooms with shower and toilet, one with direct access to the sauna",
        "Cozy living room with wood-burning stove, TV and mountain views",
        "Fully equipped kitchen with hob, oven, microwave, dishwasher, refrigerator, freezer, Nespresso machine with milk frother and kettle",
        "Laundry room with washing machine, dryer and separate indoor storage for luggage and sports equipment"
      ]
    },
    "location": {
      "title": "Location",
      "distances": [
        { "label": "Transport track", "value": "approx. 50 m" },
        { "label": "Cross-country ski trail", "value": "approx. 150 m" },
        { "label": "Ski lift (Skistar Høyfjellssenter)", "value": "approx. 1.4 km" },
        { "label": "Skistar Lodge with restaurants, spa, shops and bar", "value": "7 minutes walk or skiing distance" },
        { "label": "Hiking and mountain bike trails", "value": "nearby" }
      ],
      "mapQuery": "Fageråsen 701, Trysil"
    },
    "accessAndTransport": {
      "title": "Access & transport",
      "car": ["Car access from Oslo via E6/Rv3/Rv25 towards Trysil."],
      "airports": [
        "Scandinavian Mountains Airport (Sälen/Trysil): 40 minutes",
        "Oslo Airport Gardermoen: 2.5 hours"
      ],
      "publicTransport": [
        "Nor-Way Trysil Express to Skistar Lodge: approx. 3 hours",
        "From Oslo S: Trysil Express train in 3.5 hours",
        "Fjällexpressen from Malmö, Gothenburg and Stockholm during winter season"
      ],
      "parking": [
        "Ample parking directly at the chalet",
        "Shuttle bus passes every 30 minutes in the morning and afternoon",
        "Charging: EV charger at the chalet."
      ],
      "notes": ["Please note that the road to the chalet is a toll road."]
    },
    "amenities": {
      "title": "Amenities",
      "groups": [
        { "title": "Pool & spa", "items": ["Private dry sauna"] },
        { "title": "Parking & facilities", "items": ["Parking included", "EV charger at the chalet", "Private garden", "Private playground", "Private porch"] },
        { "title": "Policies", "items": ["Children welcome", "Low allergen environment", "Smoking not allowed"] },
        { "title": "Kitchen & dining", "items": ["BBQ charcoal grill", "BBQ gas", "Blender", "Children''s high chair", "Coffee machine", "Cooking utensils", "Dishwasher", "Grill", "Kitchen stove", "Microwave", "Oven", "Refrigerator", "Toaster", "Vacuum cleaner"] },
        { "title": "Location features", "items": ["Mountain", "Resort", "Ski in/out"] },
        { "title": "Bathroom & laundry", "items": ["Clothes dryer", "Essentials", "Iron & board", "Shower", "Washbasin", "Washing machine"] },
        { "title": "Heating & cooling", "items": ["Air conditioning", "Electric heating", "Fireplace", "Floor heating", "Heating available", "Wood/tiled stove"] },
        { "title": "Entertainment", "items": ["Stereo system", "TV (antenna)"] },
        { "title": "Internet & office", "items": ["Wireless broadband internet"] },
        { "title": "Home safety", "items": ["Fire extinguisher", "First aid kit", "Smoke detector"] }
      ]
    },
    "houseRules": {
      "title": "House rules",
      "bullets": ["Children welcome", "Low allergen environment", "Smoking not allowed"],
      "checkIn": "From 17:00",
      "checkOut": "By 10:00",
      "checkInNote": "Check-in via electronic lock with personal code.",
      "cleaningNote": "Linen rental and final cleaning of bathrooms and living areas are mandatory and charged separately. Guests are asked to leave the chalet tidy: remove trash and ashes from the fireplace, put all furniture back in place (inside and outside), and leave used dishes, cookware, oven, and microwave clean.",
      "wifiNote": "Free Wi-Fi is available throughout the chalet."
    },
    "policies": {
      "title": "Policies",
      "blocks": [
        { "title": "Payment schedule", "items": ["50% of the total amount is due at time of reservation.", "The remaining amount is to be paid 7 day(s) before arrival."] },
        { "title": "Cancellation policy", "items": ["All paid prepayments are non-refundable."] },
        { "title": "Security deposit", "items": ["No security deposit is due."] }
      ]
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- Dutch
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'cabin', 'main', 'nl', '{
    "meta": {
      "name": "Sfeervol ski-in/out bergchalet met panoramisch uitzicht en sauna",
      "locationShort": "Fageråsen, Trysil, Noorwegen",
      "sleeps": "8–9",
      "altitude": "800 m"
    },
    "hero": {
      "title": "Sfeervol ski-in/out bergchalet met panoramisch uitzicht en sauna",
      "subtitle": "Vrijstaand chalet in Fageråsen (Trysil) met ski-in/ski-out, privé sauna en panoramisch bergzicht.",
      "badges": [
        { "label": "Slaapplaatsen", "value": "8–9" },
        { "label": "Hoogte", "value": "800 m" },
        { "label": "Sauna", "value": "Privé" }
      ]
    },
    "experience": [
      "Ski in/out",
      "Privé sauna",
      "Panoramisch uitzicht",
      "Routes starten bij het huis",
      "Kindvriendelijke vide"
    ],
    "description": [
      "Vrijstaand chalet in Fageråsen (Trysil) met ski-in/ski-out, privé sauna en panoramisch bergzicht. Overdekte veranda met BBQ en heater. Gezellige woonkamer met houtkachel, 2 badkamers, kindvriendelijke vide en volledig uitgeruste keuken. Wandel- en mountainbikeroutes starten bij het huis. Rustige ligging op 800 m hoogte, 7 minuten lopen van Skistar Lodge. Perfect voor comfort, natuur en actieve vakanties in elk seizoen.",
      "Het huis is zeer geschikt voor gezinnen en groepen. Het chalet biedt comfortabel plaats aan 8-9 personen."
    ],
    "layoutAndFacilities": {
      "title": "Indeling & faciliteiten",
      "items": [
        "4 slaapkamers, met 5 bedden",
        "2 slaapkamers met tweepersoonsbedden (150 x 200 cm)",
        "1 slaapkamer met stapelbed (75 × 185 cm) – geschikt voor kinderen of jong volwassenen",
        "Videkamer met eenpersoonsbed (90 x 200 cm) + extra breed bed (120 x 200 cm), geschikt voor 1 volwassene of 2 kinderen",
        "Kindvriendelijke speelhoek op de vide met daybed (120 x 175 cm), tv en traphekje",
        "2 badkamers met douche en toilet, één met directe toegang tot de sauna",
        "Gezellige woonkamer met houtkachel, tv en bergzicht",
        "Volledig uitgeruste keuken met kookplaat, oven, magnetron, vaatwasser, koelkast, vriezer, Nespresso-machine met melkopschuimer en waterkoker",
        "Bijkeuken met wasmachine, droger en aparte binnenberging voor bagage en sportuitrusting"
      ]
    },
    "location": {
      "title": "Locatie",
      "distances": [
        { "label": "Transporttrack", "value": "ca. 50 m" },
        { "label": "Langlaufloipe", "value": "ca. 150 m" },
        { "label": "Skilift (Skistar Høyfjellssenter)", "value": "ca. 1,4 km" },
        { "label": "Skistar Lodge met restaurants, spa, winkels en bar", "value": "7 minuten lopen of ski-afstand" }
      ],
      "mapQuery": "Fageråsen 701, Trysil"
    },
    "accessAndTransport": {
      "title": "Bereikbaarheid & vervoer",
      "car": ["Met de auto vanuit Oslo via E6/Rv3/Rv25 richting Trysil."],
      "airports": [
        "Scandinavian Mountains Airport (Sälen/Trysil): 40 minuten",
        "Oslo Airport Gardermoen: 2,5 uur"
      ],
      "publicTransport": [
        "Nor-Way Trysil Express naar Skistar Lodge: ca. 3 uur",
        "Vanaf Oslo S: Trysil Express trein in 3,5 uur",
        "Fjällexpressen vanuit Malmö, Göteborg en Stockholm in het winterseizoen"
      ],
      "parking": [
        "Ruime parkeergelegenheid direct bij het chalet",
        "Shuttlebus rijdt elke 30 minuten in de ochtend en middag",
        "Opladen: laadpunt bij het chalet."
      ],
      "notes": ["Let op: de weg naar het chalet is een tolweg."]
    },
    "amenities": {
      "title": "Voorzieningen",
      "groups": [
        { "title": "Wellness & spa", "items": ["Privé droge sauna"] },
        { "title": "Parkeren & faciliteiten", "items": ["Parkeren inbegrepen", "Laadpunt bij het chalet", "Privétuin", "Privé speelplaats", "Privé veranda"] },
        { "title": "Regels", "items": ["Kinderen welkom", "Allergiearme omgeving", "Roken niet toegestaan"] },
        { "title": "Keuken & eetruimte", "items": ["Houtskool BBQ", "Gas BBQ", "Blender", "Kinderstoel", "Koffiemachine", "Kookgerei", "Vaatwasser", "Grill", "Kookplaat", "Magnetron", "Oven", "Koelkast", "Broodrooster", "Stofzuiger"] },
        { "title": "Locatiekenmerken", "items": ["Berg", "Resort", "Ski in/out"] },
        { "title": "Badkamer & wasruimte", "items": ["Wasdroger", "Basisbenodigdheden", "Strijkijzer & plank", "Douche", "Wastafel", "Wasmachine"] },
        { "title": "Verwarming & koeling", "items": ["Airconditioning", "Elektrische verwarming", "Open haard", "Vloerverwarming", "Verwarming beschikbaar", "Hout-/tegelkachel"] },
        { "title": "Entertainment", "items": ["Stereo-installatie", "TV (antenne)"] },
        { "title": "Internet & werkplek", "items": ["Draadloos breedbandinternet"] },
        { "title": "Veiligheid", "items": ["Brandblusser", "EHBO-kit", "Rookmelder"] }
      ]
    },
    "houseRules": {
      "title": "Goed om te weten",
      "bullets": ["Kinderen welkom", "Allergiearme omgeving", "Roken niet toegestaan"],
      "checkIn": "Vanaf 17:00",
      "checkOut": "Voor 10:00",
      "checkInNote": "Inchecken via elektronisch slot met persoonlijke code.",
      "cleaningNote": "Linnenverhuur en eindschoonmaak van badkamers en woonruimtes zijn verplicht en worden apart in rekening gebracht. Gasten wordt gevraagd het chalet netjes achter te laten: afval en as uit de open haard verwijderen, alle meubels terugplaatsen (binnen en buiten) en gebruikte borden, pannen, oven en magnetron schoon achterlaten.",
      "wifiNote": "Gratis wifi is beschikbaar in het hele chalet."
    },
    "policies": {
      "title": "Voorwaarden",
      "blocks": [
        { "title": "Betalingsschema", "items": ["50% van het totaalbedrag is verschuldigd bij reservering.", "Het resterende bedrag dient 7 dag(en) voor aankomst te worden betaald."] },
        { "title": "Annuleringsbeleid", "items": ["Alle betaalde vooruitbetalingen zijn niet restitueerbaar."] },
        { "title": "Borg", "items": ["Er is geen borg verschuldigd."] }
      ]
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- Norwegian
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'cabin', 'main', 'no', '{
    "meta": {
      "name": "Koselig ski-inn/ski-ut fjellhytte med badstue",
      "locationShort": "Fageråsen, Trysil, Norge",
      "sleeps": "8–9",
      "altitude": "800 m"
    },
    "hero": {
      "title": "Koselig ski-inn/ski-ut fjellhytte med badstue",
      "subtitle": "Frittliggende hytte i Fageråsen (Trysil) med ski-inn/ski-ut, privat badstue og panoramautsikt over fjellene.",
      "badges": [
        { "label": "Sengeplasser", "value": "8–9" },
        { "label": "Høyde", "value": "800 m" },
        { "label": "Badstue", "value": "Privat" }
      ]
    },
    "experience": [
      "Ski inn/ut",
      "Privat badstue",
      "Panoramautsikt",
      "Stier starter ved hytta",
      "Familievennlig loft"
    ],
    "description": [
      "Frittliggende hytte i Fageråsen (Trysil) med ski-inn/ski-ut, privat badstue og panoramautsikt over fjellene. Sengeplasser 8–9. Overbygd veranda med BBQ og varmer. Koselig stue med vedovn, 2 bad, barnevennlig loft og fullt utstyrt kjøkken. Tur- og terrengsykkelstier starter ved huset. Rolig beliggenhet på 800 moh, 7 minutters gange fra Skistar Lodge. Perfekt for komfort, natur og aktive ferier hele året.",
      "Huset passer svært godt for familier og grupper. Hytta har komfortable sengeplasser til 8 personer, med en ekstra bred seng (120 cm) på loftet. På grunn av skråtaket er denne sengen spesielt egnet for to barn eller én voksen."
    ],
    "layoutAndFacilities": {
      "title": "Planløsning og fasiliteter",
      "items": [
        "4 soverom med 5 senger",
        "2 soverom med dobbeltsenger (150 x 200 cm)",
        "1 soverom med køyeseng (75 × 185 cm) – egnet for barn eller unge voksne",
        "Loftsrom med enkeltseng (90 x 200 cm) + ekstra bred seng (120 x 200 cm), egnet for 1 voksen eller 2 barn",
        "Barnevennlig lekehjørne på loftet med daybed (120 x 175 cm), TV og trappegrind",
        "2 bad med dusj og toalett, ett med direkte tilgang til badstuen",
        "Koselig stue med vedovn, TV og fjellutsikt",
        "Fullt utstyrt kjøkken med kokeplate, ovn, mikrobølgeovn, oppvaskmaskin, kjøleskap, fryser, Nespresso-maskin med melkeskummer og vannkoker",
        "Vaskerom med vaskemaskin, tørketrommel og separat innendørs lagring for bagasje og sportsutstyr"
      ]
    },
    "location": {
      "title": "Beliggenhet",
      "distances": [
        { "label": "Transportløype", "value": "ca. 50 m" },
        { "label": "Langrennsløype", "value": "ca. 150 m" },
        { "label": "Skilift (Skistar Høyfjellssenter)", "value": "ca. 1,4 km" },
        { "label": "Skistar Lodge med restauranter, spa, butikker og bar", "value": "7 minutters gange eller på ski" },
        { "label": "Tur- og terrengsykkelstier", "value": "i nærheten" }
      ],
      "mapQuery": "Fageråsen 701, Trysil"
    },
    "accessAndTransport": {
      "title": "Adkomst og transport",
      "car": ["Biladkomst fra Oslo via E6/Rv3/Rv25 mot Trysil."],
      "airports": [
        "Scandinavian Mountains Airport (Sälen/Trysil): 40 minutter",
        "Oslo lufthavn Gardermoen: 2,5 timer"
      ],
      "publicTransport": [
        "Nor-Way Trysil Express til Skistar Lodge: ca. 3 timer",
        "Fra Oslo S: Trysil Express tog på 3,5 timer",
        "Fjällexpressen fra Malmö, Göteborg og Stockholm i vintersesongen"
      ],
      "parking": [
        "God parkering rett ved hytta",
        "Shuttlebuss går hver 30. minutt om morgenen og ettermiddagen",
        "Lading: Elbillader ved hytta."
      ],
      "notes": ["Vennligst merk at veien til hytta er en bomvei."]
    },
    "amenities": {
      "title": "Fasiliteter",
      "groups": [
        { "title": "Spa", "items": ["Privat tørrbadstue"] },
        { "title": "Parkering og fasiliteter", "items": ["Parkering inkludert", "Elbillader ved hytta", "Privat hage", "Privat lekeplass", "Privat veranda"] },
        { "title": "Regler", "items": ["Barn velkommen", "Allergivennlig miljø", "Røyking ikke tillatt"] },
        { "title": "Kjøkken og spiseplass", "items": ["Kullgrill", "Gassgrill", "Blender", "Barnestol", "Kaffemaskin", "Kjøkkenutstyr", "Oppvaskmaskin", "Grill", "Kokeplate", "Mikrobølgeovn", "Ovn", "Kjøleskap", "Brødrister", "Støvsuger"] },
        { "title": "Beliggenhet", "items": ["Fjell", "Resort", "Ski inn/ut"] },
        { "title": "Bad og vaskerom", "items": ["Tørketrommel", "Basisutstyr", "Strykejern og strykebrett", "Dusj", "Servant", "Vaskemaskin"] },
        { "title": "Oppvarming og kjøling", "items": ["Aircondition", "Elektrisk oppvarming", "Peis", "Gulvvarme", "Oppvarming tilgjengelig", "Ved-/kakkelovn"] },
        { "title": "Underholdning", "items": ["Stereoanlegg", "TV (antenne)"] },
        { "title": "Internett og arbeidsplass", "items": ["Trådløst bredbånd"] },
        { "title": "Sikkerhet", "items": ["Brannslukker", "Førstehjelpsutstyr", "Røykvarsler"] }
      ]
    },
    "houseRules": {
      "title": "Husregler",
      "bullets": ["Barn velkommen", "Allergivennlig miljø", "Røyking ikke tillatt"],
      "checkIn": "Fra 17:00",
      "checkOut": "Senest 10:00",
      "checkInNote": "Innsjekk via elektronisk lås med personlig kode.",
      "cleaningNote": "Leie av sengetøy og sluttrengjøring av bad og oppholdsrom er obligatorisk og faktureres separat. Gjestene bes om å etterlate hytta ryddig: fjern søppel og aske fra peisen, sett alle møbler tilbake på plass (inne og ute), og etterlat brukte tallerkener, kjøkkenutstyr, ovn og mikrobølgeovn rene.",
      "wifiNote": "Gratis Wi-Fi er tilgjengelig i hele hytta."
    },
    "policies": {
      "title": "Vilkår",
      "blocks": [
        { "title": "Betalingsplan", "items": ["50% av totalbeløpet betales ved reservasjon.", "Resterende beløp skal betales 7 dag(er) før ankomst."] },
        { "title": "Avbestillingsregler", "items": ["Alle betalte forskuddsbeløp er ikke-refunderbare."] },
        { "title": "Sikkerhetsdepositum", "items": ["Ingen sikkerhetsdepositum kreves."] }
      ]
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- ============================================================
  -- PAGE: HOME (LocalizedContent — home-specific parts)
  -- ============================================================

  -- English
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'page', 'home', 'en', '{
    "tagline": "Comfortable cabin in Trysil, ideal for skiing and summer activities.",
    "keyFacts": [
      { "value": "8-9", "label": "guests" },
      { "value": "106 m²", "label": "living area" },
      { "value": "4", "label": "bedrooms" },
      { "value": "2", "label": "bathrooms" }
    ],
    "highlights": [
      { "title": "Close to slopes and trails", "description": "Ski-in/ski-out access" },
      { "title": "Family friendly layout", "description": "Space for everyone" },
      { "title": "Panoramic views", "description": "Mountain views" },
      { "title": "Private sauna", "description": "Warm up after skiing" }
    ],
    "highlightImages": [
      { "src": "/images/highlights/close_to_piste.jpg", "alt": "Cabin close to the ski slopes in Fageråsen." },
      { "src": "/images/highlights/family_friendly_layout.jpg", "alt": "Family-friendly living area with open layout." },
      { "src": "/images/highlights/panoramic_view.jpg", "alt": "Panoramic mountain view." },
      { "src": "/images/highlights/private_sauna.jpg", "alt": "Private sauna inside the cabin." }
    ],
    "amenities": [
      "Underfloor heating", "Fast internet", "Dishwasher", "Washing machine",
      "Drying room", "Fireplace", "Parking at the cabin", "EV charger at the cabin"
    ],
    "reviews": [
      { "quote": "Perfect location close to the slopes with a calm atmosphere.", "name": "James", "stay": "Feb 2024" },
      { "quote": "Bright, warm, and equipped with everything we needed.", "name": "Nora", "stay": "Jan 2024" },
      { "quote": "Fast internet and a cozy fireplace after skiing.", "name": "Leo", "stay": "Dec 2023" }
    ],
    "faq": [
      { "question": "How does check-in work?", "answer": "You will receive a digital guide and door code 24 hours before arrival. Self check-in from 17:00." },
      { "question": "Are pets allowed?", "answer": "Pets are not allowed to keep the cabin allergen-friendly." },
      { "question": "Are linens and towels provided?", "answer": "Yes, bed linens and towels are included for all guests." }
    ],
    "location": {
      "description": "Set in Fageråsen with easy access to slopes, lifts, and trails."
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- Dutch
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'page', 'home', 'nl', '{
    "tagline": "Comfortabel chalet in Trysil, ideaal voor skiën en zomeractiviteiten.",
    "keyFacts": [
      { "value": "8-9", "label": "gasten" },
      { "value": "106 m²", "label": "oppervlakte" },
      { "value": "4", "label": "slaapkamers" },
      { "value": "2", "label": "badkamers" }
    ],
    "highlights": [
      { "title": "Dicht bij pistes en trails", "description": "Ski-in/ski-out ligging" },
      { "title": "Gezinsvriendelijke indeling", "description": "Ruimte voor iedereen" },
      { "title": "Panoramisch uitzicht", "description": "Uitzicht op bergen" },
      { "title": "Privé sauna", "description": "Warm op na skiën" }
    ],
    "highlightImages": [
      { "src": "/images/highlights/close_to_piste.jpg", "alt": "Chalet vlak bij de skipiste in Fageråsen." },
      { "src": "/images/highlights/family_friendly_layout.jpg", "alt": "Gezinsvriendelijke woonkamer met open indeling." },
      { "src": "/images/highlights/panoramic_view.jpg", "alt": "Panoramisch uitzicht over de bergen." },
      { "src": "/images/highlights/private_sauna.jpg", "alt": "Privé sauna in het chalet." }
    ],
    "amenities": [
      "Vloerverwarming", "Snel internet", "Vaatwasser", "Wasmachine",
      "Droogruimte", "Open haard", "Parkeren bij het chalet", "Laadpunt bij het chalet"
    ],
    "reviews": [
      { "quote": "Fantastische ligging vlak bij de piste en toch rustig.", "name": "Sanne", "stay": "Feb 2024" },
      { "quote": "Licht, warm en alles wat je nodig hebt is aanwezig.", "name": "Mark", "stay": "Jan 2024" },
      { "quote": "Snel internet en een heerlijke open haard na het skiën.", "name": "Eva", "stay": "Dec 2023" }
    ],
    "faq": [
      { "question": "Hoe werkt het inchecken?", "answer": "Je ontvangt 24 uur voor aankomst een digitale gids en deurcode. Zelf inchecken vanaf 17:00." },
      { "question": "Zijn huisdieren toegestaan?", "answer": "Huisdieren zijn niet toegestaan om het chalet allergievriendelijk te houden." },
      { "question": "Zijn beddengoed en handdoeken inbegrepen?", "answer": "Ja, beddengoed en handdoeken zijn inbegrepen voor alle gasten." }
    ],
    "location": {
      "description": "In Fageråsen, op loopafstand van pistes, liften en trails."
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- Norwegian
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'page', 'home', 'no', '{
    "tagline": "Komfortabel hytte i Trysil, perfekt for ski og sommeraktiviteter.",
    "keyFacts": [
      { "value": "8-9", "label": "gjester" },
      { "value": "106 m²", "label": "boareal" },
      { "value": "4", "label": "soverom" },
      { "value": "2", "label": "bad" }
    ],
    "highlights": [
      { "title": "Nær bakker og løyper", "description": "Ski-in/ski-out" },
      { "title": "Familievennlig planløsning", "description": "Plass til alle" },
      { "title": "Panoramautsikt", "description": "Utsikt mot fjell" },
      { "title": "Privat badstue", "description": "Varm opp etter ski" }
    ],
    "highlightImages": [
      { "src": "/images/highlights/close_to_piste.jpg", "alt": "Hytta nær skibakken i Fageråsen." },
      { "src": "/images/highlights/family_friendly_layout.jpg", "alt": "Familievennlig stue med åpen planløsning." },
      { "src": "/images/highlights/panoramic_view.jpg", "alt": "Panoramautsikt over fjellene." },
      { "src": "/images/highlights/private_sauna.jpg", "alt": "Privat badstue i hytta." }
    ],
    "amenities": [
      "Gulvvarme", "Raskt internett", "Oppvaskmaskin", "Vaskemaskin",
      "Tørkerom", "Peis", "Parkering ved hytta", "Elbillader ved hytta"
    ],
    "reviews": [
      { "quote": "Perfekt beliggenhet nær bakkene og likevel rolig.", "name": "Ingrid", "stay": "Feb 2024" },
      { "quote": "Lys, varm og med alt vi trengte.", "name": "Erik", "stay": "Jan 2024" },
      { "quote": "Raskt internett og en koselig peis etter ski.", "name": "Lina", "stay": "Dec 2023" }
    ],
    "faq": [
      { "question": "Hvordan fungerer innsjekk?", "answer": "Du får digital guide og dørkode 24 timer før ankomst. Selv-innsjekk fra 17:00." },
      { "question": "Er kjæledyr tillatt?", "answer": "Kjæledyr er ikke tillatt for å holde hytta allergivennlig." },
      { "question": "Er sengetøy og håndklær inkludert?", "answer": "Ja, sengetøy og håndklær er inkludert for alle gjester." }
    ],
    "location": {
      "description": "I Fageråsen med kort vei til bakker, heiser og løyper."
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- ============================================================
  -- PAGE: PRACTICAL (PracticalContent)
  -- ============================================================

  -- English
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'page', 'practical', 'en', '{
    "header": {
      "title": "Practical info",
      "subtitle": "Everything you need for a pleasant stay."
    },
    "quickFacts": [
      { "label": "Check-in", "value": "17:00" },
      { "label": "Check-out", "value": "10:00" },
      { "label": "Guests", "value": "8–9" },
      { "label": "Parking", "value": "Private at the chalet" },
      { "label": "EV charger", "value": "Available" },
      { "label": "Sauna", "value": "Private" }
    ],
    "arrivalAccess": {
      "title": "Arrival & access",
      "checkInLabel": "Check-in",
      "checkIn": "From 17:00",
      "checkOutLabel": "Check-out",
      "checkOut": "By 10:00",
      "bullets": [
        "Self check-in via electronic lock with personal code.",
        "Full privacy during the stay.",
        "Local contact person available in Trysil."
      ]
    },
    "parkingCharging": {
      "title": "Parking & charging",
      "bullets": [
        "Ample parking directly at the chalet.",
        "Shuttle bus runs every 30 minutes in the morning and afternoon.",
        "EV charging: charger at the chalet."
      ],
      "callout": "Please note: the road to the chalet is a toll road."
    },
    "layoutFacilities": {
      "title": "Layout & facilities",
      "sections": [
        {
          "title": "Bedrooms",
          "intro": "4 bedrooms with 5 beds, suitable for 8–9 guests",
          "bullets": [
            "2 bedrooms with double beds (150 × 200 cm)",
            "1 bedroom with bunk bed (75 × 185 cm) – suitable for children or young adults",
            "Attic room with single bed (90 × 200 cm) + extra-wide bed (120 × 200 cm), suitable for 1 adult or 2 children",
            "Due to the sloped roof, the extra-wide bed is especially ideal for children"
          ]
        },
        {
          "title": "Family-friendly loft",
          "bullets": ["Play corner on the loft", "Daybed (120 × 175 cm)", "TV", "Stair gate available"]
        },
        {
          "title": "Bathrooms & wellness",
          "bullets": ["2 bathrooms with shower and toilet", "1 bathroom with direct access to the private sauna"]
        },
        {
          "title": "Living area",
          "bullets": ["Cozy living room with wood-burning stove, heat pump, smart TV and mountain views"]
        },
        {
          "title": "Kitchen",
          "intro": "Fully equipped for cooking and dining together",
          "bullets": ["Hob and oven", "Microwave", "Dishwasher", "Refrigerator and freezer", "Nespresso machine with milk frother", "Kettle"]
        },
        {
          "title": "Laundry & storage",
          "bullets": ["Washer and dryer", "Separate indoor storage for luggage and sports equipment"]
        }
      ]
    },
    "transport": {
      "title": "Access & transport",
      "columns": [
        { "title": "Car", "bullets": ["Car access from Oslo via E6/Rv3/Rv25 towards Trysil.", "Please note: the road to the chalet is a toll road."] },
        { "title": "Public transport", "bullets": ["Nor-Way Trysil Express to SkiStar Lodge: approx. 3 hours.", "Fjällexpressen from Malmö, Gothenburg and Stockholm during the winter season."] },
        { "title": "Airports", "bullets": ["Scandinavian Mountains Airport (Sälen/Trysil): 40 minutes.", "Oslo Airport Gardermoen: 2.5 hours."] }
      ]
    },
    "goodToKnow": {
      "title": "Good to know",
      "bullets": ["Children are very welcome", "Low-allergen environment", "Smoking is not allowed", "Pets are not allowed"]
    },
    "contactHelp": {
      "title": "Contact & help",
      "bullets": ["Questions or emergencies: contact our local contact person or us.", "Contact details are in your booking confirmation."]
    },
    "agreementsAndPayment": {
      "title": "Agreements & payment",
      "blocks": [
        { "title": "Payment", "items": ["50% at reservation", "Remaining balance 7 days before arrival"] },
        { "title": "Cancellation", "items": ["Prepayments are non-refundable"] },
        { "title": "Linen & cleaning", "items": ["Linen rental and final cleaning of bathrooms and living areas are mandatory and charged separately"] }
      ]
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- Dutch
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'page', 'practical', 'nl', '{
    "header": {
      "title": "Praktische info",
      "subtitle": "Alles wat je moet weten voor een prettig verblijf."
    },
    "quickFacts": [
      { "label": "Check-in", "value": "17:00" },
      { "label": "Check-out", "value": "10:00" },
      { "label": "Gasten", "value": "8–9" },
      { "label": "Parkeren", "value": "Privé bij het chalet" },
      { "label": "Oplaadpunt", "value": "Aanwezig" },
      { "label": "Sauna", "value": "Privé" }
    ],
    "arrivalAccess": {
      "title": "Aankomst & toegang",
      "checkInLabel": "Check-in",
      "checkIn": "Vanaf 17:00",
      "checkOutLabel": "Check-out",
      "checkOut": "Voor 10:00",
      "bullets": [
        "Self check-in via elektronisch slot met persoonlijke code.",
        "Volledige privacy tijdens het verblijf."
      ]
    },
    "parkingCharging": {
      "title": "Parkeren & laden",
      "bullets": [
        "Ruime parkeergelegenheid direct bij het chalet.",
        "Shuttlebus rijdt elke 30 minuten in de ochtend en middag.",
        "Oplaadpunt: laadpunt bij het chalet."
      ],
      "callout": "Let op: de weg naar het chalet is een tolweg."
    },
    "layoutFacilities": {
      "title": "Indeling & faciliteiten",
      "sections": [
        {
          "title": "Slaapkamers",
          "intro": "4 slaapkamers, met 5 bedden, geschikt voor 8–9 gasten",
          "bullets": [
            "2 slaapkamers met tweepersoonsbedden (150 × 200 cm)",
            "1 slaapkamer met stapelbed (75 × 185 cm) – geschikt voor kinderen of jong volwassenen",
            "Videkamer met eenpersoonsbed (90 × 200 cm) + extra breed bed (120 × 200 cm), geschikt voor 1 volwassene of 2 kinderen",
            "Door het schuine dak is het extra brede bed vooral ideaal voor kinderen"
          ]
        },
        {
          "title": "Kindvriendelijke vide",
          "bullets": ["Speelhoek op de vide", "Daybed (120 × 175 cm)", "TV", "Traphekje aanwezig"]
        },
        {
          "title": "Badkamers & wellness",
          "bullets": ["2 badkamers met douche en toilet", "1 badkamer met directe toegang tot de privé sauna"]
        },
        {
          "title": "Woonruimte",
          "bullets": ["Gezellige woonkamer met houtkachel, warmtepomp, smart TV en bergzicht"]
        },
        {
          "title": "Keuken",
          "intro": "Volledig uitgerust voor koken en samen eten",
          "bullets": ["Kookplaat en oven", "Magnetron", "Vaatwasser", "Koelkast en vriezer", "Nespresso-machine met melkopschuimer", "Waterkoker"]
        },
        {
          "title": "Bijkeuken & opslag",
          "bullets": ["Wasmachine en droger", "Aparte binnenberging voor bagage en sportuitrusting"]
        }
      ]
    },
    "transport": {
      "title": "Bereikbaarheid & vervoer",
      "columns": [
        { "title": "Auto", "bullets": ["Met de auto vanuit Oslo via E6/Rv3/Rv25 richting Trysil.", "Let op: de weg naar het chalet is een tolweg."] },
        { "title": "Openbaar vervoer", "bullets": ["Nor-Way Trysil Express naar SkiStar Lodge: ca. 3 uur.", "Fjällexpressen vanuit Malmö, Göteborg en Stockholm in het winterseizoen."] },
        { "title": "Luchthavens", "bullets": ["Scandinavian Mountains Airport (Sälen/Trysil): 40 minuten.", "Oslo Airport Gardermoen: 2,5 uur."] }
      ]
    },
    "goodToKnow": {
      "title": "Goed om te weten",
      "bullets": ["Kinderen zijn van harte welkom", "Allergiearme omgeving", "Roken is niet toegestaan", "Huisdieren zijn niet toegestaan"]
    },
    "contactHelp": {
      "title": "Contact & hulp",
      "bullets": ["Vragen of noodgeval: neem contact op met onze lokale contactpersoon of met ons.", "Contactgegevens vind je in je boekingsbevestiging."]
    },
    "agreementsAndPayment": {
      "title": "Afspraken & betaling",
      "blocks": [
        { "title": "Betaling", "items": ["50% bij reservering", "Restant 7 dagen voor aankomst"] },
        { "title": "Annulering", "items": ["Vooruitbetalingen zijn niet restitueerbaar"] },
        { "title": "Linnen & schoonmaak", "items": ["Linnenverhuur en eindschoonmaak van badkamers en woonruimtes zijn verplicht en worden apart in rekening gebracht"] }
      ]
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- Norwegian
  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES (v_site_id, 'page', 'practical', 'no', '{
    "header": {
      "title": "Praktisk info",
      "subtitle": "Alt du trenger for et hyggelig opphold."
    },
    "quickFacts": [
      { "label": "Innsjekk", "value": "17:00" },
      { "label": "Utsjekk", "value": "10:00" },
      { "label": "Gjester", "value": "8–9" },
      { "label": "Parkering", "value": "Privat ved hytta" },
      { "label": "Elbillader", "value": "Tilgjengelig" },
      { "label": "Badstue", "value": "Privat" }
    ],
    "arrivalAccess": {
      "title": "Ankomst og tilgang",
      "checkInLabel": "Innsjekk",
      "checkIn": "Fra 17:00",
      "checkOutLabel": "Utsjekk",
      "checkOut": "Senest 10:00",
      "bullets": [
        "Selvbetjent innsjekk via elektronisk lås med personlig kode.",
        "Fullt privat under oppholdet.",
        "Lokal kontaktperson tilgjengelig i Trysil."
      ]
    },
    "parkingCharging": {
      "title": "Parkering og lading",
      "bullets": [
        "God parkering rett ved hytta.",
        "Shuttlebuss går hver 30. minutt om morgenen og ettermiddagen.",
        "Lading: Elbillader ved hytta."
      ],
      "callout": "Merk: veien til hytta er en bomvei."
    },
    "layoutFacilities": {
      "title": "Planløsning og fasiliteter",
      "sections": [
        {
          "title": "Soverom",
          "intro": "4 soverom med 5 senger, egnet for 8–9 gjester",
          "bullets": [
            "2 soverom med dobbeltsenger (150 × 200 cm)",
            "1 soverom med køyeseng (75 × 185 cm) – egnet for barn eller unge voksne",
            "Loftsrom med enkeltseng (90 × 200 cm) + ekstra bred seng (120 × 200 cm), egnet for 1 voksen eller 2 barn",
            "På grunn av skråtaket er den ekstra brede sengen spesielt egnet for barn"
          ]
        },
        {
          "title": "Familievennlig loft",
          "bullets": ["Lekeområde på loftet", "Daybed (120 × 175 cm)", "TV", "Trappegrind tilgjengelig"]
        },
        {
          "title": "Bad og velvære",
          "bullets": ["2 bad med dusj og toalett", "1 bad med direkte tilgang til privat badstue"]
        },
        {
          "title": "Oppholdsrom",
          "bullets": ["Koselig stue med vedovn, varmepumpe, smart TV og fjellutsikt"]
        },
        {
          "title": "Kjøkken",
          "intro": "Fullt utstyrt for matlaging og felles måltider",
          "bullets": ["Kokeplate og ovn", "Mikrobølgeovn", "Oppvaskmaskin", "Kjøleskap og fryser", "Nespresso-maskin med melkeskummer", "Vannkoker"]
        },
        {
          "title": "Vaskerom og lagring",
          "bullets": ["Vaskemaskin og tørketrommel", "Separat innendørs lagring for bagasje og sportsutstyr"]
        }
      ]
    },
    "transport": {
      "title": "Adkomst og transport",
      "columns": [
        { "title": "Bil", "bullets": ["Biladkomst fra Oslo via E6/Rv3/Rv25 mot Trysil.", "Merk: veien til hytta er en bomvei."] },
        { "title": "Offentlig transport", "bullets": ["Nor-Way Trysil Express til SkiStar Lodge: ca. 3 timer.", "Fjällexpressen fra Malmö, Göteborg og Stockholm i vintersesongen."] },
        { "title": "Flyplasser", "bullets": ["Scandinavian Mountains Airport (Sälen/Trysil): 40 minutter.", "Oslo lufthavn Gardermoen: 2,5 timer."] }
      ]
    },
    "goodToKnow": {
      "title": "Godt å vite",
      "bullets": ["Barn er hjertelig velkommen", "Allergivennlig miljø", "Røyking er ikke tillatt", "Kjæledyr er ikke tillatt"]
    },
    "contactHelp": {
      "title": "Kontakt og hjelp",
      "bullets": ["Spørsmål eller nødstilfelle: kontakt vår lokale kontaktperson eller oss.", "Kontaktinformasjon finner du i bestillingsbekreftelsen."]
    },
    "agreementsAndPayment": {
      "title": "Avtaler og betaling",
      "blocks": [
        { "title": "Betaling", "items": ["50% ved reservasjon", "Restbeløpet 7 dager før ankomst"] },
        { "title": "Avbestilling", "items": ["Forhåndsbetalinger refunderes ikke"] },
        { "title": "Sengetøy og renhold", "items": ["Leie av sengetøy og sluttrengjøring av bad og oppholdsrom er obligatorisk og faktureres separat"] }
      ]
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- ============================================================
  -- PAGE: AREA
  -- ============================================================

  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES
  (v_site_id, 'page', 'area', 'en', '{
    "intro": "Trysil is a year-round destination for outdoor lovers.",
    "sections": [
      {
        "title": "Winter",
        "description": "Skiing, cross-country trails, and cozy evenings.",
        "bullets": [
          "Ski-in/ski-out access to Trysilfjellet",
          "Extensive cross-country trail network",
          "Ski rental and school nearby"
        ]
      },
      {
        "title": "Summer",
        "description": "Hiking, biking, and crisp mountain air.",
        "bullets": [
          "Marked hiking routes around Fageråsen",
          "Mountain bike trails and lift access",
          "Swimming spots and river activities"
        ]
      }
    ]
  }', 'published', now()),

  (v_site_id, 'page', 'area', 'nl', '{
    "intro": "Trysil is het hele jaar door een actieve bestemming.",
    "sections": [
      {
        "title": "Winter",
        "description": "Skiën, langlauf en sfeervolle avonden.",
        "bullets": [
          "Ski-in/ski-out naar Trysilfjellet",
          "Uitgebreid netwerk van langlaufloipes",
          "Skiverhuur en skischool dichtbij"
        ]
      },
      {
        "title": "Zomer",
        "description": "Wandelen, fietsen en frisse berglucht.",
        "bullets": [
          "Gemarkeerde wandelroutes rond Fageråsen",
          "Mountainbike trails en lift",
          "Zwemplekken en rivieractiviteiten"
        ]
      }
    ]
  }', 'published', now()),

  (v_site_id, 'page', 'area', 'no', '{
    "intro": "Trysil er et helårs reisemål for friluftsliv.",
    "sections": [
      {
        "title": "Vinter",
        "description": "Ski, langrenn og koselige kvelder.",
        "bullets": [
          "Ski-in/ski-out til Trysilfjellet",
          "Stort nettverk av langrennsløyper",
          "Skileie og skiskole i nærheten"
        ]
      },
      {
        "title": "Sommer",
        "description": "Vandring, sykling og frisk fjelluft.",
        "bullets": [
          "Merkede turstier rundt Fageråsen",
          "Stisykkel og heis",
          "Badeplasser og elveaktiviteter"
        ]
      }
    ]
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- ============================================================
  -- PAGE: PRIVACY
  -- ============================================================

  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES
  (v_site_id, 'page', 'privacy', 'en', '{
    "intro": "We respect your privacy and only process data needed for your inquiry or booking.",
    "bullets": [
      "We use your data only to respond and manage your stay.",
      "Bookings are handled through Lodgify and their privacy policy applies.",
      "You can request deletion of your data at any time."
    ]
  }', 'published', now()),

  (v_site_id, 'page', 'privacy', 'nl', '{
    "intro": "We respecteren je privacy en verwerken alleen de gegevens die nodig zijn voor je aanvraag of boeking.",
    "bullets": [
      "We gebruiken je gegevens uitsluitend om contact op te nemen en je verblijf te regelen.",
      "Boekingen worden afgehandeld via Lodgify en hun privacybeleid is van toepassing.",
      "Je kunt ons vragen je gegevens te verwijderen."
    ]
  }', 'published', now()),

  (v_site_id, 'page', 'privacy', 'no', '{
    "intro": "Vi respekterer personvernet ditt og behandler kun data som trengs for forespørsel eller bestilling.",
    "bullets": [
      "Vi bruker dataene dine kun for å svare og administrere oppholdet.",
      "Bestillinger håndteres via Lodgify og deres personvern gjelder.",
      "Du kan be om sletting av dataene dine når som helst."
    ]
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

  -- ============================================================
  -- CONTACT FORM
  -- ============================================================

  INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content, status, published_at)
  VALUES
  (v_site_id, 'contact_form', 'main', 'en', '{
    "title": "Contact & availability",
    "subtitle": "Have questions about availability, the area, or the stay in Fageråsen in Trysil? Use the contact form below or reach out directly via email: info@trysilpanorama.com.",
    "form": {
      "name": { "label": "Name", "placeholder": "Your full name" },
      "email": { "label": "Email", "placeholder": "you@email.com" },
      "period": { "label": "Preferred period", "placeholder": "For example 12–19 February (optional)" },
      "message": { "label": "Message", "placeholder": "Your question or message" },
      "submit": "Send message",
      "success": "Thank you! Your message has been sent. We will get back to you as soon as possible.",
      "error": "Something went wrong while sending. Please try again later."
    }
  }', 'published', now()),

  (v_site_id, 'contact_form', 'main', 'nl', '{
    "title": "Contact & beschikbaarheid",
    "subtitle": "Heb je vragen over beschikbaarheid, de omgeving of het verblijf in Fageråsen in Trysil? Gebruik het contactformulier hieronder of neem direct contact met ons op via e-mail: info@trysilpanorama.com.",
    "form": {
      "name": { "label": "Naam", "placeholder": "Je volledige naam" },
      "email": { "label": "E-mail", "placeholder": "je@emailadres.nl" },
      "period": { "label": "Gewenste periode", "placeholder": "Bijvoorbeeld 12–19 februari (optioneel)" },
      "message": { "label": "Bericht", "placeholder": "Je vraag of bericht" },
      "submit": "Stuur bericht",
      "success": "Dank je wel! Je bericht is verzonden. We nemen zo snel mogelijk contact met je op.",
      "error": "Er ging iets mis bij het verzenden. Probeer het later opnieuw."
    }
  }', 'published', now()),

  (v_site_id, 'contact_form', 'main', 'no', '{
    "title": "Kontakt og tilgjengelighet",
    "subtitle": "Har du spørsmål om tilgjengelighet, området eller oppholdet i Fageråsen i Trysil? Bruk kontaktskjemaet nedenfor eller ta direkte kontakt med oss på e-post: info@trysilpanorama.com.",
    "form": {
      "name": { "label": "Navn", "placeholder": "Ditt fulle navn" },
      "email": { "label": "E-post", "placeholder": "du@epost.no" },
      "period": { "label": "Ønsket periode", "placeholder": "For eksempel 12.–19. februar (valgfritt)" },
      "message": { "label": "Melding", "placeholder": "Spørsmålet ditt eller melding" },
      "submit": "Send melding",
      "success": "Takk! Meldingen din er sendt. Vi tar kontakt så snart som mulig.",
      "error": "Noe gikk galt under sendingen. Prøv igjen senere."
    }
  }', 'published', now())
  ON CONFLICT (site_id, content_type, slug, locale)
  DO UPDATE SET content = EXCLUDED.content, status = EXCLUDED.status, published_at = EXCLUDED.published_at, updated_at = now();

END $$;
