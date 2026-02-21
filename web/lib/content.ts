import type { Locale } from "./i18n";

type Localized<T> = Record<Locale, T>;

export type DistanceItem = { label: string; value: string };
export type AmenityGroup = { title: string; items: string[] };
export type PolicyBlock = { title: string; items: string[] };

export type CabinContent = {
  meta: {
    name: string;
    locationShort: string;
    sleeps: string;
    altitude: string;
  };
  hero: {
    title: string;
    subtitle: string;
    badges: { label: string; value: string }[];
  };
  experience: string[];
  description: string[];
  layoutAndFacilities: {
    title: string;
    items: string[];
  };
  location: {
    title: string;
    distances: DistanceItem[];
    mapQuery: string;
  };
  accessAndTransport: {
    title: string;
    car: string[];
    airports: string[];
    publicTransport: string[];
    parking: string[];
    notes: string[];
  };
  amenities: {
    title: string;
    groups: AmenityGroup[];
  };
  houseRules: {
    title: string;
    bullets: string[];
    checkIn: string;
    checkOut: string;
    checkInNote: string;
    cleaningNote: string;
    wifiNote: string;
  };
  policies: {
    title: string;
    blocks: PolicyBlock[];
  };
};

export type LayoutFacilitiesContent = {
  title: string;
  sections: Array<{
    title: string;
    intro?: string;
    bullets: string[];
  }>;
};

export type PracticalQuickFact = {
  label: string;
  value: string;
};

export type PracticalTransportColumn = {
  title: string;
  bullets: string[];
};

export type KeyFactContent = {
  value: string;
  label: string;
};

export type PracticalContent = {
  header: {
    title: string;
    subtitle: string;
  };
  quickFacts: PracticalQuickFact[];
  arrivalAccess: {
    title: string;
    checkInLabel: string;
    checkIn: string;
    checkOutLabel: string;
    checkOut: string;
    bullets: string[];
  };
  parkingCharging: {
    title: string;
    bullets: string[];
    callout: string;
  };
  layoutFacilities: LayoutFacilitiesContent;
  transport: {
    title: string;
    columns: PracticalTransportColumn[];
  };
  goodToKnow: {
    title: string;
    bullets: string[];
  };
  contactHelp: {
    title: string;
    bullets: string[];
  };
  agreementsAndPayment: {
    title: string;
    blocks: PolicyBlock[];
  };
};

const checkTimes = {
  checkIn: "17:00",
  checkOut: "10:00",
} as const;

const checkInOutPhrases: Record<Locale, { checkIn: string; checkOut: string }> = {
  nl: {
    checkIn: `Vanaf ${checkTimes.checkIn}`,
    checkOut: `Voor ${checkTimes.checkOut}`,
  },
  en: {
    checkIn: `From ${checkTimes.checkIn}`,
    checkOut: `By ${checkTimes.checkOut}`,
  },
  no: {
    checkIn: `Fra ${checkTimes.checkIn}`,
    checkOut: `Senest ${checkTimes.checkOut}`,
  },
};

const tollRoadNote: Localized<string> = {
  nl: "Let op: de weg naar het chalet is een tolweg.",
  en: "Please note: the road to the chalet is a toll road.",
  no: "Merk: veien til hytta er en bomvei.",
};

const cabinContentEn: CabinContent = {
  meta: {
    name: "Cosy ski-in/out mountain cabin with sauna",
    locationShort: "Fageråsen, Trysil, Norway",
    sleeps: "8–9",
    altitude: "800 m",
  },

  hero: {
    title: "Cosy ski-in/out mountain cabin with sauna",
    subtitle:
      "Detached chalet in Fageråsen (Trysil) with ski-in/ski-out access, private sauna, and panoramic mountain views.",
    badges: [
      { label: "Sleeps", value: "8–9" },
      { label: "Altitude", value: "800 m" },
      { label: "Sauna", value: "Private" },
    ],
  },
  experience: [
    "Ski in/out",
    "Private sauna",
    "Panoramic views",
    "Trails at the house",
    "Family friendly loft",
  ],

  description: [
    "Detached chalet in Fageråsen (Trysil) with ski-in/ski-out access, private sauna, and panoramic mountain views. Sleeps 8–9. Covered veranda with BBQ and heater. Cozy living room with wood-burning stove, 2 bathrooms, child-friendly loft, and fully equipped kitchen. Hiking and mountain bike trails start at the house. Quiet location at 800 m altitude, a 7-minute walk from Skistar Lodge. Perfect for comfort, nature, and active holidays in any season.",
    "The house is very suitable for families and groups. The chalet comfortably sleeps 8 people, with an extra-wide bed (120 cm) in the loft. Due to the sloped roof, this bed is particularly suitable for two children or one adult.",
  ],

  layoutAndFacilities: {
    title: "Layout & facilities",
    items: [
      "4 bedrooms with 5 beds",
      "2 bedrooms with double beds (150 x 200 cm)",
      "1 bedroom with bunk bed (75 × 185 cm) – suitable for children or young adults",
      "Attic room with single bed (90 x 200 cm) + extra-wide bed (120 x 200 cm), suitable for 1 adult or 2 children",
      "Child-friendly play corner in the attic with daybed (120 x 175 cm), TV and stair gate",
      "2 bathrooms with shower and toilet, one with direct access to the sauna",
      "Cozy living room with wood-burning stove, TV and mountain views",
      "Fully equipped kitchen with hob, oven, microwave, dishwasher, refrigerator, freezer, Nespresso machine with milk frother and kettle",
      "Laundry room with washing machine, dryer and separate indoor storage for luggage and sports equipment",
    ],
  },

  location: {
    title: "Location",
    distances: [
      { label: "Transport track", value: "approx. 50 m" },
      { label: "Cross-country ski trail", value: "approx. 150 m" },
      { label: "Ski lift (Skistar Høyfjellssenter)", value: "approx. 1.4 km" },
      {
        label: "Skistar Lodge with restaurants, spa, shops and bar",
        value: "7 minutes walk or skiing distance",
      },
      { label: "Hiking and mountain bike trails", value: "nearby" },
    ],
    mapQuery: "Fageråsen 701, Trysil",
  },

  accessAndTransport: {
    title: "Access & transport",
    car: ["Car access from Oslo via E6/Rv3/Rv25 towards Trysil."],
    airports: [
      "Scandinavian Mountains Airport (Sälen/Trysil): 40 minutes",
      "Oslo Airport Gardermoen: 2.5 hours",
    ],
    publicTransport: [
      "Nor-Way Trysil Express to Skistar Lodge: approx. 3 hours",
      "From Oslo S: Trysil Express train in 3.5 hours",
      "Fjällexpressen from Malmö, Gothenburg and Stockholm during winter season",
    ],
    parking: [
      "Ample parking directly at the chalet",
      "Shuttle bus passes every 30 minutes in the morning and afternoon",
      "Charging: EV charger at the chalet.",
    ],
    notes: ["Please note that the road to the chalet is a toll road."],
  },

  amenities: {
    title: "Amenities",
    groups: [
      {
        title: "Pool & spa",
        items: ["Private dry sauna"],
      },
      {
        title: "Parking & facilities",
        items: [
          "Parking included",
          "EV charger at the chalet",
          "Private garden",
          "Private playground",
          "Private porch",
        ],
      },
      {
        title: "Policies",
        items: ["Children welcome", "Low allergen environment", "Smoking not allowed"],
      },
      {
        title: "Kitchen & dining",
        items: [
          "BBQ charcoal grill",
          "BBQ gas",
          "Blender",
          "Children’s high chair",
          "Coffee machine",
          "Cooking utensils",
          "Dishwasher",
          "Grill",
          "Kitchen stove",
          "Microwave",
          "Oven",
          "Refrigerator",
          "Toaster",
          "Vacuum cleaner",
        ],
      },
      {
        title: "Location features",
        items: ["Mountain", "Resort", "Ski in/out"],
      },
      {
        title: "Bathroom & laundry",
        items: [
          "Clothes dryer",
          "Essentials",
          "Iron & board",
          "Shower",
          "Washbasin",
          "Washing machine",
        ],
      },
      {
        title: "Heating & cooling",
        items: [
          "Air conditioning",
          "Electric heating",
          "Fireplace",
          "Floor heating",
          "Heating available",
          "Wood/tiled stove",
        ],
      },
      {
        title: "Entertainment",
        items: ["Stereo system", "TV (antenna)"],
      },
      {
        title: "Internet & office",
        items: ["Wireless broadband internet"],
      },
      {
        title: "Home safety",
        items: ["Fire extinguisher", "First aid kit", "Smoke detector"],
      },
    ],
  },

  houseRules: {
    title: "House rules",
    bullets: ["Children welcome", "Low allergen environment", "Smoking not allowed"],
    checkIn: checkInOutPhrases.en.checkIn,
    checkOut: checkInOutPhrases.en.checkOut,
    checkInNote: "Check-in via electronic lock with personal code.",
    cleaningNote:
      "Linen rental and final cleaning of bathrooms and living areas are mandatory and charged separately. Guests are asked to leave the chalet tidy: remove trash and ashes from the fireplace, put all furniture back in place (inside and outside), and leave used dishes, cookware, oven, and microwave clean.",
    wifiNote: "Free Wi-Fi is available throughout the chalet.",
  },

  policies: {
    title: "Policies",
    blocks: [
      {
        title: "Payment schedule",
        items: [
          "50% of the total amount is due at time of reservation.",
          "The remaining amount is to be paid 7 day(s) before arrival.",
        ],
      },
      {
        title: "Cancellation policy",
        items: ["All paid prepayments are non-refundable."],
      },
      {
        title: "Security deposit",
        items: ["No security deposit is due."],
      },
    ],
  },
};

const cabinContentNl: CabinContent = {
  meta: {
    name: "Sfeervol ski-in/out bergchalet met panoramisch uitzicht en sauna",
    locationShort: "Fageråsen, Trysil, Noorwegen",
    sleeps: "8–9",
    altitude: "800 m",
  },

  hero: {
    title: "Sfeervol ski-in/out bergchalet met panoramisch uitzicht en sauna",
    subtitle:
      "Vrijstaand chalet in Fageråsen (Trysil) met ski-in/ski-out, privé sauna en panoramisch bergzicht.",
    badges: [
      { label: "Slaapplaatsen", value: "8–9" },
      { label: "Hoogte", value: "800 m" },
      { label: "Sauna", value: "Privé" },
    ],
  },
  experience: [
    "Ski in/out",
    "Privé sauna",
    "Panoramisch uitzicht",
    "Routes starten bij het huis",
    "Kindvriendelijke vide",
  ],

  description: [
    "Vrijstaand chalet in Fageråsen (Trysil) met ski-in/ski-out, privé sauna en panoramisch bergzicht. Overdekte veranda met BBQ en heater. Gezellige woonkamer met houtkachel, 2 badkamers, kindvriendelijke vide en volledig uitgeruste keuken. Wandel- en mountainbikeroutes starten bij het huis. Rustige ligging op 800 m hoogte, 7 minuten lopen van Skistar Lodge. Perfect voor comfort, natuur en actieve vakanties in elk seizoen.",
    "Het huis is zeer geschikt voor gezinnen en groepen. Het chalet biedt comfortabel plaats aan 8-9 personen.",
  ],

  layoutAndFacilities: {
    title: "Indeling & faciliteiten",
    items: [
      "4 slaapkamers, met 5 bedden",
      "2 slaapkamers met tweepersoonsbedden (150 x 200 cm)",
      "1 slaapkamer met stapelbed (75 × 185 cm) – geschikt voor kinderen of jong volwassenen",
      "Videkamer met eenpersoonsbed (90 x 200 cm) + extra breed bed (120 x 200 cm), geschikt voor 1 volwassene of 2 kinderen",
      "Kindvriendelijke speelhoek op de vide met daybed (120 x 175 cm), tv en traphekje",
      "2 badkamers met douche en toilet, één met directe toegang tot de sauna",
      "Gezellige woonkamer met houtkachel, tv en bergzicht",
      "Volledig uitgeruste keuken met kookplaat, oven, magnetron, vaatwasser, koelkast, vriezer, Nespresso-machine met melkopschuimer en waterkoker",
      "Bijkeuken met wasmachine, droger en aparte binnenberging voor bagage en sportuitrusting",
    ],
  },

  location: {
    title: "Locatie",
    distances: [
      { label: "Transporttrack", value: "ca. 50 m" },
      { label: "Langlaufloipe", value: "ca. 150 m" },
      { label: "Skilift (Skistar Høyfjellssenter)", value: "ca. 1,4 km" },
      {
        label: "Skistar Lodge met restaurants, spa, winkels en bar",
        value: "7 minuten lopen of ski-afstand",
      },
    ],
    mapQuery: "Fageråsen 701, Trysil",
  },

  accessAndTransport: {
    title: "Bereikbaarheid & vervoer",
    car: ["Met de auto vanuit Oslo via E6/Rv3/Rv25 richting Trysil."],
    airports: [
      "Scandinavian Mountains Airport (Sälen/Trysil): 40 minuten",
      "Oslo Airport Gardermoen: 2,5 uur",
    ],
    publicTransport: [
      "Nor-Way Trysil Express naar Skistar Lodge: ca. 3 uur",
      "Vanaf Oslo S: Trysil Express trein in 3,5 uur",
      "Fjällexpressen vanuit Malmö, Göteborg en Stockholm in het winterseizoen",
    ],
    parking: [
      "Ruime parkeergelegenheid direct bij het chalet",
      "Shuttlebus rijdt elke 30 minuten in de ochtend en middag",
      "Opladen: laadpunt bij het chalet.",
    ],
    notes: ["Let op: de weg naar het chalet is een tolweg."],
  },

  amenities: {
    title: "Voorzieningen",
    groups: [
      {
        title: "Wellness & spa",
        items: ["Privé droge sauna"],
      },
      {
        title: "Parkeren & faciliteiten",
        items: [
          "Parkeren inbegrepen",
          "Laadpunt bij het chalet",
          "Privétuin",
          "Privé speelplaats",
          "Privé veranda",
        ],
      },
      {
        title: "Regels",
        items: ["Kinderen welkom", "Allergiearme omgeving", "Roken niet toegestaan"],
      },
      {
        title: "Keuken & eetruimte",
        items: [
          "Houtskool BBQ",
          "Gas BBQ",
          "Blender",
          "Kinderstoel",
          "Koffiemachine",
          "Kookgerei",
          "Vaatwasser",
          "Grill",
          "Kookplaat",
          "Magnetron",
          "Oven",
          "Koelkast",
          "Broodrooster",
          "Stofzuiger",
        ],
      },
      {
        title: "Locatiekenmerken",
        items: ["Berg", "Resort", "Ski in/out"],
      },
      {
        title: "Badkamer & wasruimte",
        items: [
          "Wasdroger",
          "Basisbenodigdheden",
          "Strijkijzer & plank",
          "Douche",
          "Wastafel",
          "Wasmachine",
        ],
      },
      {
        title: "Verwarming & koeling",
        items: [
          "Airconditioning",
          "Elektrische verwarming",
          "Open haard",
          "Vloerverwarming",
          "Verwarming beschikbaar",
          "Hout-/tegelkachel",
        ],
      },
      {
        title: "Entertainment",
        items: ["Stereo-installatie", "TV (antenne)"],
      },
      {
        title: "Internet & werkplek",
        items: ["Draadloos breedbandinternet"],
      },
      {
        title: "Veiligheid",
        items: ["Brandblusser", "EHBO-kit", "Rookmelder"],
      },
    ],
  },

  houseRules: {
    title: "Goed om te weten",
    bullets: ["Kinderen welkom", "Allergiearme omgeving", "Roken niet toegestaan"],
    checkIn: checkInOutPhrases.nl.checkIn,
    checkOut: checkInOutPhrases.nl.checkOut,
    checkInNote: "Inchecken via elektronisch slot met persoonlijke code.",
    cleaningNote:
      "Linnenverhuur en eindschoonmaak van badkamers en woonruimtes zijn verplicht en worden apart in rekening gebracht. Gasten wordt gevraagd het chalet netjes achter te laten: afval en as uit de open haard verwijderen, alle meubels terugplaatsen (binnen en buiten) en gebruikte borden, pannen, oven en magnetron schoon achterlaten.",
    wifiNote: "Gratis wifi is beschikbaar in het hele chalet.",
  },

  policies: {
    title: "Voorwaarden",
    blocks: [
      {
        title: "Betalingsschema",
        items: [
          "50% van het totaalbedrag is verschuldigd bij reservering.",
          "Het resterende bedrag dient 7 dag(en) voor aankomst te worden betaald.",
        ],
      },
      {
        title: "Annuleringsbeleid",
        items: ["Alle betaalde vooruitbetalingen zijn niet restitueerbaar."],
      },
      {
        title: "Borg",
        items: ["Er is geen borg verschuldigd."],
      },
    ],
  },
};

const cabinContentNo: CabinContent = {
  meta: {
    name: "Koselig ski-inn/ski-ut fjellhytte med badstue",
    locationShort: "Fageråsen, Trysil, Norge",
    sleeps: "8–9",
    altitude: "800 m",
  },

  hero: {
    title: "Koselig ski-inn/ski-ut fjellhytte med badstue",
    subtitle:
      "Frittliggende hytte i Fageråsen (Trysil) med ski-inn/ski-ut, privat badstue og panoramautsikt over fjellene.",
    badges: [
      { label: "Sengeplasser", value: "8–9" },
      { label: "Høyde", value: "800 m" },
      { label: "Badstue", value: "Privat" },
    ],
  },
  experience: [
    "Ski inn/ut",
    "Privat badstue",
    "Panoramautsikt",
    "Stier starter ved hytta",
    "Familievennlig loft",
  ],

  description: [
    "Frittliggende hytte i Fageråsen (Trysil) med ski-inn/ski-ut, privat badstue og panoramautsikt over fjellene. Sengeplasser 8–9. Overbygd veranda med BBQ og varmer. Koselig stue med vedovn, 2 bad, barnevennlig loft og fullt utstyrt kjøkken. Tur- og terrengsykkelstier starter ved huset. Rolig beliggenhet på 800 moh, 7 minutters gange fra Skistar Lodge. Perfekt for komfort, natur og aktive ferier hele året.",
    "Huset passer svært godt for familier og grupper. Hytta har komfortable sengeplasser til 8 personer, med en ekstra bred seng (120 cm) på loftet. På grunn av skråtaket er denne sengen spesielt egnet for to barn eller én voksen.",
  ],

  layoutAndFacilities: {
    title: "Planløsning og fasiliteter",
    items: [
      "4 soverom med 5 senger",
      "2 soverom med dobbeltsenger (150 x 200 cm)",
      "1 soverom med køyeseng (75 × 185 cm) – egnet for barn eller unge voksne",
      "Loftsrom med enkeltseng (90 x 200 cm) + ekstra bred seng (120 x 200 cm), egnet for 1 voksen eller 2 barn",
      "Barnevennlig lekehjørne på loftet med daybed (120 x 175 cm), TV og trappegrind",
      "2 bad med dusj og toalett, ett med direkte tilgang til badstuen",
      "Koselig stue med vedovn, TV og fjellutsikt",
      "Fullt utstyrt kjøkken med kokeplate, ovn, mikrobølgeovn, oppvaskmaskin, kjøleskap, fryser, Nespresso-maskin med melkeskummer og vannkoker",
      "Vaskerom med vaskemaskin, tørketrommel og separat innendørs lagring for bagasje og sportsutstyr",
    ],
  },

  location: {
    title: "Beliggenhet",
    distances: [
      { label: "Transportløype", value: "ca. 50 m" },
      { label: "Langrennsløype", value: "ca. 150 m" },
      { label: "Skilift (Skistar Høyfjellssenter)", value: "ca. 1,4 km" },
      {
        label: "Skistar Lodge med restauranter, spa, butikker og bar",
        value: "7 minutters gange eller på ski",
      },
      { label: "Tur- og terrengsykkelstier", value: "i nærheten" },
    ],
    mapQuery: "Fageråsen 701, Trysil",
  },

  accessAndTransport: {
    title: "Adkomst og transport",
    car: ["Biladkomst fra Oslo via E6/Rv3/Rv25 mot Trysil."],
    airports: [
      "Scandinavian Mountains Airport (Sälen/Trysil): 40 minutter",
      "Oslo lufthavn Gardermoen: 2,5 timer",
    ],
    publicTransport: [
      "Nor-Way Trysil Express til Skistar Lodge: ca. 3 timer",
      "Fra Oslo S: Trysil Express tog på 3,5 timer",
      "Fjällexpressen fra Malmö, Göteborg og Stockholm i vintersesongen",
    ],
    parking: [
      "God parkering rett ved hytta",
      "Shuttlebuss går hver 30. minutt om morgenen og ettermiddagen",
      "Lading: Elbillader ved hytta.",
    ],
    notes: ["Vennligst merk at veien til hytta er en bomvei."],
  },

  amenities: {
    title: "Fasiliteter",
    groups: [
      {
        title: "Spa",
        items: ["Privat tørrbadstue"],
      },
      {
        title: "Parkering og fasiliteter",
        items: [
          "Parkering inkludert",
          "Elbillader ved hytta",
          "Privat hage",
          "Privat lekeplass",
          "Privat veranda",
        ],
      },
      {
        title: "Regler",
        items: ["Barn velkommen", "Allergivennlig miljø", "Røyking ikke tillatt"],
      },
      {
        title: "Kjøkken og spiseplass",
        items: [
          "Kullgrill",
          "Gassgrill",
          "Blender",
          "Barnestol",
          "Kaffemaskin",
          "Kjøkkenutstyr",
          "Oppvaskmaskin",
          "Grill",
          "Kokeplate",
          "Mikrobølgeovn",
          "Ovn",
          "Kjøleskap",
          "Brødrister",
          "Støvsuger",
        ],
      },
      {
        title: "Beliggenhet",
        items: ["Fjell", "Resort", "Ski inn/ut"],
      },
      {
        title: "Bad og vaskerom",
        items: [
          "Tørketrommel",
          "Basisutstyr",
          "Strykejern og strykebrett",
          "Dusj",
          "Servant",
          "Vaskemaskin",
        ],
      },
      {
        title: "Oppvarming og kjøling",
        items: [
          "Aircondition",
          "Elektrisk oppvarming",
          "Peis",
          "Gulvvarme",
          "Oppvarming tilgjengelig",
          "Ved-/kakkelovn",
        ],
      },
      {
        title: "Underholdning",
        items: ["Stereoanlegg", "TV (antenne)"],
      },
      {
        title: "Internett og arbeidsplass",
        items: ["Trådløst bredbånd"],
      },
      {
        title: "Sikkerhet",
        items: ["Brannslukker", "Førstehjelpsutstyr", "Røykvarsler"],
      },
    ],
  },

  houseRules: {
    title: "Husregler",
    bullets: ["Barn velkommen", "Allergivennlig miljø", "Røyking ikke tillatt"],
    checkIn: checkInOutPhrases.no.checkIn,
    checkOut: checkInOutPhrases.no.checkOut,
    checkInNote: "Innsjekk via elektronisk lås med personlig kode.",
    cleaningNote:
      "Leie av sengetøy og sluttrengjøring av bad og oppholdsrom er obligatorisk og faktureres separat. Gjestene bes om å etterlate hytta ryddig: fjern søppel og aske fra peisen, sett alle møbler tilbake på plass (inne og ute), og etterlat brukte tallerkener, kjøkkenutstyr, ovn og mikrobølgeovn rene.",
    wifiNote: "Gratis Wi-Fi er tilgjengelig i hele hytta.",
  },

  policies: {
    title: "Vilkår",
    blocks: [
      {
        title: "Betalingsplan",
        items: [
          "50% av totalbeløpet betales ved reservasjon.",
          "Resterende beløp skal betales 7 dag(er) før ankomst.",
        ],
      },
      {
        title: "Avbestillingsregler",
        items: ["Alle betalte forskuddsbeløp er ikke-refunderbare."],
      },
      {
        title: "Sikkerhetsdepositum",
        items: ["Ingen sikkerhetsdepositum kreves."],
      },
    ],
  },
};

export const cabinContent = cabinContentEn;

export const cabinContentByLocale: Record<Locale, CabinContent> = {
  nl: cabinContentNl,
  en: cabinContentEn,
  no: cabinContentNo,
};

export function getCabinContent(locale: Locale) {
  return cabinContentByLocale[locale];
}

export type GalleryImage = {
  src: string;
  alt: Localized<string>;
};

export type Review = {
  quote: string;
  name: string;
  stay: string;
};

export type FaqItem = {
  question: string;
  answer: string;
};

export type PracticalTitles = {
  checkInOut: string;
  parkingCharging: string;
  cleaningLinen: string;
  wifiOther: string;
};

export type AreaSection = {
  title: string;
  description: string;
  bullets: string[];
};

export type LocalizedImage = {
  src: string;
  alt: string;
};

export type HighlightItem = {
  title: string;
  description: string;
};

type HighlightImageSelection = {
  src: string;
  alt: Localized<string>;
};

export type ContactFormSectionContent = {
  title: string;
  subtitle: string;
  form: {
    name: {
      label: string;
      placeholder: string;
    };
    email: {
      label: string;
      placeholder: string;
    };
    period: {
      label: string;
      placeholder: string;
    };
    message: {
      label: string;
      placeholder: string;
    };
    submit: string;
    success: string;
    error: string;
  };
};

export type LocalizedContent = {
  tagline: string;
  keyFacts: KeyFactContent[];
  highlights: HighlightItem[];
  highlightImages?: LocalizedImage[];
  amenities: string[];
  reviews: Review[];
  faq: FaqItem[];
  location: {
    description: string;
  };
  practical: PracticalContent;
  area: {
    intro: string;
    sections: AreaSection[];
  };
  privacy: {
    intro: string;
    bullets: string[];
  };
};

export type SiteConfig = {
  name: string;
  location: string;
  capacity: number;
  bedrooms: number;
  bathrooms: number;
  imagePaths: {
    base: string;
    hero: string;
    galleryAll: string;
    highlights: string;
  };
  galleryAllFilenames: string[];
  heroImages: string[];
  gallery: Array<{
    src: string;
    alt: Localized<string>;
  }>;
  mapEmbedUrl: string;
  mapLinkUrl: string;
  bookingUrl: string;
};

const imagePaths = {
  base: "/images",
  hero: "/images/hero",
  galleryAll: "/images/all",
  highlights: "/images/highlights",
};

export const heroImageFilenames = [
  "Fagerasen701_hero - 1.jpeg",
  "Fagerasen701_hero - 2.jpeg",
  "Fagerasen701_hero - 3.jpeg",
];

export const galleryAllFilenames = [
  "Fagerasen701 - 1.jpeg",
  "Fagerasen701 - 2.jpeg",
  "Fagerasen701 - 3.jpeg",
  "Fagerasen701 - 4.jpeg",
  "Fagerasen701 - 5.jpeg",
  "Fagerasen701 - 6.jpeg",
  "Fagerasen701 - 7.jpeg",
  "Fagerasen701 - 8.jpeg",
  "Fagerasen701 - 9.jpeg",
  "Fagerasen701 - 10.jpeg",
  "Fagerasen701 - 11.jpeg",
  "Fagerasen701 - 12.jpeg",
  "Fagerasen701 - 13.jpeg",
  "Fagerasen701 - 14.jpeg",
  "Fagerasen701 - 15.jpeg",
  "Fagerasen701 - 16.jpeg",
  "Fagerasen701 - 17.jpeg",
  "Fagerasen701 - 18.jpeg",
  "Fagerasen701 - 19.jpeg",
  "Fagerasen701 - 20.jpeg",
  "Fagerasen701 - 21.jpeg",
  "Fagerasen701 - 22.jpeg",
  "Fagerasen701 - 23.jpeg",
  "Fagerasen701 - 24.jpeg",
  "Fagerasen701 - 25.jpeg",
  "Fagerasen701 - 26.jpeg",
  "Fagerasen701 - 27.jpeg",
  "Fagerasen701 - 28.jpeg",
  "Fagerasen701 - 29.jpeg",
  "Fagerasen701 - 30.jpeg",
  "Fagerasen701 - 31.jpeg",
  "Fagerasen701 - 32.jpeg",
  "Fagerasen701 - 33.jpeg",
];

const highlightImageSelection: HighlightImageSelection[] = [
  {
    src: `${imagePaths.highlights}/close_to_piste.jpg`,
    alt: {
      nl: "Chalet vlak bij de skipiste in Fageråsen.",
      en: "Cabin close to the ski slopes in Fageråsen.",
      no: "Hytta nær skibakken i Fageråsen.",
    },
  },
  {
    src: `${imagePaths.highlights}/family_friendly_layout.jpg`,
    alt: {
      nl: "Gezinsvriendelijke woonkamer met open indeling.",
      en: "Family-friendly living area with open layout.",
      no: "Familievennlig stue med åpen planløsning.",
    },
  },
  {
    src: `${imagePaths.highlights}/panoramic_view.jpg`,
    alt: {
      nl: "Panoramisch uitzicht over de bergen.",
      en: "Panoramic mountain view.",
      no: "Panoramautsikt over fjellene.",
    },
  },
  {
    src: `${imagePaths.highlights}/private_sauna.jpg`,
    alt: {
      nl: "Privé sauna in het chalet.",
      en: "Private sauna inside the cabin.",
      no: "Privat badstue i hytta.",
    },
  },
];

const getHighlightImages = (locale: Locale): LocalizedImage[] =>
  highlightImageSelection.map((image) => ({
    src: image.src,
    alt: image.alt[locale],
  }));

export const site: SiteConfig = {
  name: "Fageråsen 701",
  location: "Fageråsen, Trysil, Norway",
  capacity: 8,
  bedrooms: 3,
  bathrooms: 2,
  imagePaths,
  galleryAllFilenames,
  heroImages: heroImageFilenames.map((name) => `${imagePaths.hero}/${name}`),
  // Select which 6 images from the full set appear in the homepage gallery preview.
  gallery: [
    {
      src: `${imagePaths.galleryAll}/Fagerasen701 - 1.jpeg`,
      alt: {
        nl: "Buitenzicht van het chalet in Fageråsen in winterse omstandigheden.",
        en: "Exterior view of the cabin in Fageråsen in winter conditions.",
        no: "Utvendig bilde av hytta i Fageråsen i vinterforhold.",
      },
    },
    {
      src: `${imagePaths.galleryAll}/Fagerasen701 - 2.jpeg`,
      alt: {
        nl: "Buitenzicht van het chalet bij zonsondergang met uitzicht over de bergen.",
        en: "Exterior view of the cabin at sunset with mountain views.",
        no: "Utvendig bilde av hytta ved solnedgang med utsikt mot fjellene.",
      },
    },
    {
      src: `${imagePaths.galleryAll}/Fagerasen701 - 4.jpeg`,
      alt: {
        nl: "Buitenzijde van het chalet met grasdak en terras aan de voorzijde.",
        en: "Exterior of the cabin with grass roof and front terrace.",
        no: "Utvendig bilde av hytta med torvtak og terrasse på forsiden.",
      },
    },
    {
      src: `${imagePaths.galleryAll}/Fagerasen701 - 6.jpeg`,
      alt: {
        nl: "Buiten vuurplaats met grill in de tuin en uitzicht op de bergen.",
        en: "Outdoor fire pit with grill in the garden and mountain views.",
        no: "Ute bålplass med grill i hagen og utsikt mot fjellene.",
      },
    },
    {
      src: `${imagePaths.galleryAll}/Fagerasen701 - 9.jpeg`,
      alt: {
        nl: "Ruime woon- en eetkamer met zithoek, eettafel en openslaande deuren.",
        en: "Spacious living and dining area with seating, dining table and French doors.",
        no: "Romslig stue- og spiseplass med sittegruppe, spisebord og doble terrassedører.",
      },
    },
    // {
    //   src: `${imagePaths.galleryAll}/Fagerasen701 - 8.jpeg`,
    //   alt: {
    //     nl: "Woonkamer met zithoek en uitzicht op de bergen door grote ramen.",
    //     en: "Living room with seating area and mountain views through large windows.",
    //     no: "Stue med sittegruppe og utsikt mot fjellene gjennom store vinduer.",
    //   },
    // },
    {
  src: `${imagePaths.galleryAll}/Fagerasen701 - 12.jpeg`,
  alt: {
    nl: "Traditionele Finse sauna met houten banken en elektrische saunakachel.",
    en: "Traditional Finnish sauna with wooden benches and electric sauna heater.",
    no: "Tradisjonell finsk badstue med trebenker og elektrisk badstuovn.",
  },
},
    
  ],
  mapEmbedUrl:
    "https://www.openstreetmap.org/export/embed.html?bbox=12.155%2C61.322%2C12.175%2C61.342&layer=mapnik&marker=61.332251%2C12.165275",
  mapLinkUrl:
    "https://www.openstreetmap.org/?mlat=61.332251&mlon=12.165275#map=16/61.332251/12.165275",
  bookingUrl: "",
};

export const primaryHeroImage =
  site.heroImages?.[0] ?? site.gallery?.[0]?.src ?? "";

export const localizedContent: Record<Locale, LocalizedContent> = {
  nl: {
    tagline: "Comfortabel chalet in Trysil, ideaal voor skiën en zomeractiviteiten.",
    keyFacts: [
      { value: "8-9", label: "gasten" },
      { value: "106 m²", label: "oppervlakte" },
      { value: "4", label: "slaapkamers" },
      { value: "2", label: "badkamers" },
    ],
    highlights: [
      {
        title: "Dicht bij pistes en trails",
        description: "Ski-in/ski-out ligging",
      },
      {
        title: "Gezinsvriendelijke indeling",
        description: "Ruimte voor iedereen",
      },
      {
        title: "Panoramisch uitzicht",
        description: "Uitzicht op bergen",
      },
      {
        title: "Privé sauna",
        description: "Warm op na skiën",
      },
    ],
    highlightImages: getHighlightImages("nl"),
    amenities: [
      "Vloerverwarming",
      "Snel internet",
      "Vaatwasser",
      "Wasmachine",
      "Droogruimte",
      "Open haard",
      "Parkeren bij het chalet",
      "Laadpunt bij het chalet",
    ],
    reviews: [
      {
        quote: "Fantastische ligging vlak bij de piste en toch rustig.",
        name: "Sanne",
        stay: "Feb 2024",
      },
      {
        quote: "Licht, warm en alles wat je nodig hebt is aanwezig.",
        name: "Mark",
        stay: "Jan 2024",
      },
      {
        quote: "Snel internet en een heerlijke open haard na het skiën.",
        name: "Eva",
        stay: "Dec 2023",
      },
    ],
    faq: [
      {
        question: "Hoe werkt het inchecken?",
        answer: `Je ontvangt 24 uur voor aankomst een digitale gids en deurcode. Zelf inchecken ${checkInOutPhrases.nl.checkIn.toLowerCase()}.`,
      },
      {
        question: "Zijn huisdieren toegestaan?",
        answer: "Huisdieren zijn niet toegestaan om het chalet allergievriendelijk te houden.",
      },
      {
        question: "Zijn beddengoed en handdoeken inbegrepen?",
        answer: "Ja, beddengoed en handdoeken zijn inbegrepen voor alle gasten.",
      },
    ],
    location: {
      description: "In Fageråsen, op loopafstand van pistes, liften en trails.",
    },
    practical: {
      header: {
        title: "Praktische info",
        subtitle: "Alles wat je moet weten voor een prettig verblijf.",
      },
      quickFacts: [
        { label: "Check-in", value: checkTimes.checkIn },
        { label: "Check-out", value: checkTimes.checkOut },
        { label: "Gasten", value: "8–9" },
        { label: "Parkeren", value: "Privé bij het chalet" },
        { label: "Oplaadpunt", value: "Aanwezig" },
        { label: "Sauna", value: "Privé" },
      ],
      arrivalAccess: {
        title: "Aankomst & toegang",
        checkInLabel: "Check-in",
        checkIn: checkInOutPhrases.nl.checkIn,
        checkOutLabel: "Check-out",
        checkOut: checkInOutPhrases.nl.checkOut,
        bullets: [
          "Self check-in via elektronisch slot met persoonlijke code.",
          "Volledige privacy tijdens het verblijf.",
        ],
      },
      parkingCharging: {
        title: "Parkeren & laden",
        bullets: [
          "Ruime parkeergelegenheid direct bij het chalet.",
          "Shuttlebus rijdt elke 30 minuten in de ochtend en middag.",
          "Oplaadpunt: laadpunt bij het chalet.",
        ],
        callout: tollRoadNote.nl,
      },
      layoutFacilities: {
        title: "Indeling & faciliteiten",
        sections: [
          {
            title: "Slaapkamers",
            intro: "4 slaapkamers, met 5 bedden, geschikt voor 8–9 gasten",
            bullets: [
              "2 slaapkamers met tweepersoonsbedden (150 × 200 cm)",
              "1 slaapkamer met stapelbed (75 × 185 cm) – geschikt voor kinderen of jong volwassenen",
              "Videkamer met eenpersoonsbed (90 × 200 cm) + extra breed bed (120 × 200 cm), geschikt voor 1 volwassene of 2 kinderen",
              "Door het schuine dak is het extra brede bed vooral ideaal voor kinderen",
            ],
          },
          {
            title: "Kindvriendelijke vide",
            bullets: ["Speelhoek op de vide", "Daybed (120 × 175 cm)", "TV", "Traphekje aanwezig"],
          },
          {
            title: "Badkamers & wellness",
            bullets: ["2 badkamers met douche en toilet", "1 badkamer met directe toegang tot de privé sauna"],
          },
          {
            title: "Woonruimte",
            bullets: ["Gezellige woonkamer met houtkachel, warmtepomp, smart TV en bergzicht"],
          },
          {
            title: "Keuken",
            intro: "Volledig uitgerust voor koken en samen eten",
            bullets: [
              "Kookplaat en oven",
              "Magnetron",
              "Vaatwasser",
              "Koelkast en vriezer",
              "Nespresso-machine met melkopschuimer",
              "Waterkoker",
            ],
          },
          {
            title: "Bijkeuken & opslag",
            bullets: ["Wasmachine en droger", "Aparte binnenberging voor bagage en sportuitrusting"],
          },
        ],
      },
      transport: {
        title: "Bereikbaarheid & vervoer",
        columns: [
          {
            title: "Auto",
            bullets: [
              "Met de auto vanuit Oslo via E6/Rv3/Rv25 richting Trysil.",
              tollRoadNote.nl,
            ],
          },
          {
            title: "Openbaar vervoer",
            bullets: [
              "Nor-Way Trysil Express naar SkiStar Lodge: ca. 3 uur.",
              "Fjällexpressen vanuit Malmö, Göteborg en Stockholm in het winterseizoen.",
            ],
          },
          {
            title: "Luchthavens",
            bullets: [
              "Scandinavian Mountains Airport (Sälen/Trysil): 40 minuten.",
              "Oslo Airport Gardermoen: 2,5 uur.",
            ],
          },
        ],
      },
      goodToKnow: {
        title: "Goed om te weten",
        bullets: [
          "Kinderen zijn van harte welkom",
          "Allergiearme omgeving",
          "Roken is niet toegestaan",
          "Huisdieren zijn niet toegestaan",
        ],
      },
      contactHelp: {
        title: "Contact & hulp",
        bullets: [
          "Vragen of noodgeval: neem contact op met onze lokale contactpersoon of met ons.",
          "Contactgegevens vind je in je boekingsbevestiging.",
        ],
      },
      agreementsAndPayment: {
        title: "Afspraken & betaling",
        blocks: [
          {
            title: "Betaling",
            items: ["50% bij reservering", "Restant 7 dagen voor aankomst"],
          },
          {
            title: "Annulering",
            items: ["Vooruitbetalingen zijn niet restitueerbaar"],
          },
          {
            title: "Linnen & schoonmaak",
            items: [
              "Linnenverhuur en eindschoonmaak van badkamers en woonruimtes zijn verplicht en worden apart in rekening gebracht",
            ],
          },
        ],
      },
    },
    area: {
      intro: "Trysil is het hele jaar door een actieve bestemming.",
      sections: [
        {
          title: "Winter",
          description: "Skiën, langlauf en sfeervolle avonden.",
          bullets: [
            "Ski-in/ski-out naar Trysilfjellet",
            "Uitgebreid netwerk van langlaufloipes",
            "Skiverhuur en skischool dichtbij",
          ],
        },
        {
          title: "Zomer",
          description: "Wandelen, fietsen en frisse berglucht.",
          bullets: [
            "Gemarkeerde wandelroutes rond Fageråsen",
            "Mountainbike trails en lift",
            "Zwemplekken en rivieractiviteiten",
          ],
        },
      ],
    },
    privacy: {
      intro:
        "We respecteren je privacy en verwerken alleen de gegevens die nodig zijn voor je aanvraag of boeking.",
      bullets: [
        "We gebruiken je gegevens uitsluitend om contact op te nemen en je verblijf te regelen.",
        "Boekingen worden afgehandeld via Lodgify en hun privacybeleid is van toepassing.",
        "Je kunt ons vragen je gegevens te verwijderen.",
      ],
    },
  },
  en: {
    tagline: "Comfortable cabin in Trysil, ideal for skiing and summer activities.",
    keyFacts: [
      { value: "8-9", label: "guests" },
      { value: "106 m²", label: "living area" },
      { value: "4", label: "bedrooms" },
      { value: "2", label: "bathrooms" },
    ],
    highlights: [
      {
        title: "Close to slopes and trails",
        description: "Ski-in/ski-out access",
      },
      {
        title: "Family friendly layout",
        description: "Space for everyone",
      },
      {
        title: "Panoramic views",
        description: "Mountain views",
      },
      {
        title: "Private sauna",
        description: "Warm up after skiing",
      },
    ],
    highlightImages: getHighlightImages("en"),
    amenities: [
      "Underfloor heating",
      "Fast internet",
      "Dishwasher",
      "Washing machine",
      "Drying room",
      "Fireplace",
      "Parking at the cabin",
      "EV charger at the cabin",
    ],
    reviews: [
      {
        quote: "Perfect location close to the slopes with a calm atmosphere.",
        name: "James",
        stay: "Feb 2024",
      },
      {
        quote: "Bright, warm, and equipped with everything we needed.",
        name: "Nora",
        stay: "Jan 2024",
      },
      {
        quote: "Fast internet and a cozy fireplace after skiing.",
        name: "Leo",
        stay: "Dec 2023",
      },
    ],
    faq: [
      {
        question: "How does check-in work?",
        answer: `You will receive a digital guide and door code 24 hours before arrival. Self check-in ${checkInOutPhrases.en.checkIn.toLowerCase()}.`,
      },
      {
        question: "Are pets allowed?",
        answer: "Pets are not allowed to keep the cabin allergen-friendly.",
      },
      {
        question: "Are linens and towels provided?",
        answer: "Yes, bed linens and towels are included for all guests.",
      },
    ],
    location: {
      description: "Set in Fageråsen with easy access to slopes, lifts, and trails.",
    },
    practical: {
      header: {
        title: "Practical info",
        subtitle: "Everything you need for a pleasant stay.",
      },
      quickFacts: [
        { label: "Check-in", value: checkTimes.checkIn },
        { label: "Check-out", value: checkTimes.checkOut },
        { label: "Guests", value: "8–9" },
        { label: "Parking", value: "Private at the chalet" },
        { label: "EV charger", value: "Available" },
        { label: "Sauna", value: "Private" },
      ],
      arrivalAccess: {
        title: "Arrival & access",
        checkInLabel: "Check-in",
        checkIn: checkInOutPhrases.en.checkIn,
        checkOutLabel: "Check-out",
        checkOut: checkInOutPhrases.en.checkOut,
        bullets: [
          "Self check-in via electronic lock with personal code.",
          "Full privacy during the stay.",
          "Local contact person available in Trysil.",
        ],
      },
      parkingCharging: {
        title: "Parking & charging",
        bullets: [
          "Ample parking directly at the chalet.",
          "Shuttle bus runs every 30 minutes in the morning and afternoon.",
          "EV charging: charger at the chalet.",
        ],
        callout: tollRoadNote.en,
      },
      layoutFacilities: {
        title: "Layout & facilities",
        sections: [
          {
            title: "Bedrooms",
            intro: "4 bedrooms with 5 beds, suitable for 8–9 guests",
            bullets: [
              "2 bedrooms with double beds (150 × 200 cm)",
              "1 bedroom with bunk bed (75 × 185 cm) – suitable for children or young adults",
              "Attic room with single bed (90 × 200 cm) + extra-wide bed (120 × 200 cm), suitable for 1 adult or 2 children",
              "Due to the sloped roof, the extra-wide bed is especially ideal for children",
            ],
          },
          {
            title: "Family-friendly loft",
            bullets: ["Play corner on the loft", "Daybed (120 × 175 cm)", "TV", "Stair gate available"],
          },
          {
            title: "Bathrooms & wellness",
            bullets: ["2 bathrooms with shower and toilet", "1 bathroom with direct access to the private sauna"],
          },
          {
            title: "Living area",
            bullets: ["Cozy living room with wood-burning stove, heat pump, smart TV and mountain views"],
          },
          {
            title: "Kitchen",
            intro: "Fully equipped for cooking and dining together",
            bullets: [
              "Hob and oven",
              "Microwave",
              "Dishwasher",
              "Refrigerator and freezer",
              "Nespresso machine with milk frother",
              "Kettle",
            ],
          },
          {
            title: "Laundry & storage",
            bullets: ["Washer and dryer", "Separate indoor storage for luggage and sports equipment"],
          },
        ],
      },
      transport: {
        title: "Access & transport",
        columns: [
          {
            title: "Car",
            bullets: [
              "Car access from Oslo via E6/Rv3/Rv25 towards Trysil.",
              tollRoadNote.en,
            ],
          },
          {
            title: "Public transport",
            bullets: [
              "Nor-Way Trysil Express to SkiStar Lodge: approx. 3 hours.",
              "Fjällexpressen from Malmö, Gothenburg and Stockholm during the winter season.",
            ],
          },
          {
            title: "Airports",
            bullets: [
              "Scandinavian Mountains Airport (Sälen/Trysil): 40 minutes.",
              "Oslo Airport Gardermoen: 2.5 hours.",
            ],
          },
        ],
      },
      goodToKnow: {
        title: "Good to know",
        bullets: [
          "Children are very welcome",
          "Low-allergen environment",
          "Smoking is not allowed",
          "Pets are not allowed",
        ],
      },
      contactHelp: {
        title: "Contact & help",
        bullets: [
          "Questions or emergencies: contact our local contact person or us.",
          "Contact details are in your booking confirmation.",
        ],
      },
      agreementsAndPayment: {
        title: "Agreements & payment",
        blocks: [
          {
            title: "Payment",
            items: ["50% at reservation", "Remaining balance 7 days before arrival"],
          },
          {
            title: "Cancellation",
            items: ["Prepayments are non-refundable"],
          },
          {
            title: "Linen & cleaning",
            items: [
              "Linen rental and final cleaning of bathrooms and living areas are mandatory and charged separately",
            ],
          },
        ],
      },
    },
    area: {
      intro: "Trysil is a year-round destination for outdoor lovers.",
      sections: [
        {
          title: "Winter",
          description: "Skiing, cross-country trails, and cozy evenings.",
          bullets: [
            "Ski-in/ski-out access to Trysilfjellet",
            "Extensive cross-country trail network",
            "Ski rental and school nearby",
          ],
        },
        {
          title: "Summer",
          description: "Hiking, biking, and crisp mountain air.",
          bullets: [
            "Marked hiking routes around Fageråsen",
            "Mountain bike trails and lift access",
            "Swimming spots and river activities",
          ],
        },
      ],
    },
    privacy: {
      intro: "We respect your privacy and only process data needed for your inquiry or booking.",
      bullets: [
        "We use your data only to respond and manage your stay.",
        "Bookings are handled through Lodgify and their privacy policy applies.",
        "You can request deletion of your data at any time.",
      ],
    },
  },
  no: {
    tagline: "Komfortabel hytte i Trysil, perfekt for ski og sommeraktiviteter.",
    keyFacts: [
      { value: "8-9", label: "gjester" },
      { value: "106 m²", label: "boareal" },
      { value: "4", label: "soverom" },
      { value: "2", label: "bad" },
    ],
    highlights: [
      {
        title: "Nær bakker og løyper",
        description: "Ski-in/ski-out",
      },
      {
        title: "Familievennlig planløsning",
        description: "Plass til alle",
      },
      {
        title: "Panoramautsikt",
        description: "Utsikt mot fjell",
      },
      {
        title: "Privat badstue",
        description: "Varm opp etter ski",
      },
    ],
    highlightImages: getHighlightImages("no"),
    amenities: [
      "Gulvvarme",
      "Raskt internett",
      "Oppvaskmaskin",
      "Vaskemaskin",
      "Tørkerom",
      "Peis",
      "Parkering ved hytta",
      "Elbillader ved hytta",
    ],
    reviews: [
      {
        quote: "Perfekt beliggenhet nær bakkene og likevel rolig.",
        name: "Ingrid",
        stay: "Feb 2024",
      },
      {
        quote: "Lys, varm og med alt vi trengte.",
        name: "Erik",
        stay: "Jan 2024",
      },
      {
        quote: "Raskt internett og en koselig peis etter ski.",
        name: "Lina",
        stay: "Dec 2023",
      },
    ],
    faq: [
      {
        question: "Hvordan fungerer innsjekk?",
        answer: `Du får digital guide og dørkode 24 timer før ankomst. Selv-innsjekk ${checkInOutPhrases.no.checkIn.toLowerCase()}.`,
      },
      {
        question: "Er kjæledyr tillatt?",
        answer: "Kjæledyr er ikke tillatt for å holde hytta allergivennlig.",
      },
      {
        question: "Er sengetøy og håndklær inkludert?",
        answer: "Ja, sengetøy og håndklær er inkludert for alle gjester.",
      },
    ],
    location: {
      description: "I Fageråsen med kort vei til bakker, heiser og løyper.",
    },
    practical: {
      header: {
        title: "Praktisk info",
        subtitle: "Alt du trenger for et hyggelig opphold.",
      },
      quickFacts: [
        { label: "Innsjekk", value: checkTimes.checkIn },
        { label: "Utsjekk", value: checkTimes.checkOut },
        { label: "Gjester", value: "8–9" },
        { label: "Parkering", value: "Privat ved hytta" },
        { label: "Elbillader", value: "Tilgjengelig" },
        { label: "Badstue", value: "Privat" },
      ],
      arrivalAccess: {
        title: "Ankomst og tilgang",
        checkInLabel: "Innsjekk",
        checkIn: checkInOutPhrases.no.checkIn,
        checkOutLabel: "Utsjekk",
        checkOut: checkInOutPhrases.no.checkOut,
        bullets: [
          "Selvbetjent innsjekk via elektronisk lås med personlig kode.",
          "Fullt privat under oppholdet.",
          "Lokal kontaktperson tilgjengelig i Trysil.",
        ],
      },
      parkingCharging: {
        title: "Parkering og lading",
        bullets: [
          "God parkering rett ved hytta.",
          "Shuttlebuss går hver 30. minutt om morgenen og ettermiddagen.",
          "Lading: Elbillader ved hytta.",
        ],
        callout: tollRoadNote.no,
      },
      layoutFacilities: {
        title: "Planløsning og fasiliteter",
        sections: [
          {
            title: "Soverom",
            intro: "4 soverom med 5 senger, egnet for 8–9 gjester",
            bullets: [
              "2 soverom med dobbeltsenger (150 × 200 cm)",
              "1 soverom med køyeseng (75 × 185 cm) – egnet for barn eller unge voksne",
              "Loftsrom med enkeltseng (90 × 200 cm) + ekstra bred seng (120 × 200 cm), egnet for 1 voksen eller 2 barn",
              "På grunn av skråtaket er den ekstra brede sengen spesielt egnet for barn",
            ],
          },
          {
            title: "Familievennlig loft",
            bullets: ["Lekeområde på loftet", "Daybed (120 × 175 cm)", "TV", "Trappegrind tilgjengelig"],
          },
          {
            title: "Bad og velvære",
            bullets: ["2 bad med dusj og toalett", "1 bad med direkte tilgang til privat badstue"],
          },
          {
            title: "Oppholdsrom",
            bullets: ["Koselig stue med vedovn, varmepumpe, smart TV og fjellutsikt"],
          },
          {
            title: "Kjøkken",
            intro: "Fullt utstyrt for matlaging og felles måltider",
            bullets: [
              "Kokeplate og ovn",
              "Mikrobølgeovn",
              "Oppvaskmaskin",
              "Kjøleskap og fryser",
              "Nespresso-maskin med melkeskummer",
              "Vannkoker",
            ],
          },
          {
            title: "Vaskerom og lagring",
            bullets: ["Vaskemaskin og tørketrommel", "Separat innendørs lagring for bagasje og sportsutstyr"],
          },
        ],
      },
      transport: {
        title: "Adkomst og transport",
        columns: [
          {
            title: "Bil",
            bullets: [
              "Biladkomst fra Oslo via E6/Rv3/Rv25 mot Trysil.",
              tollRoadNote.no,
            ],
          },
          {
            title: "Offentlig transport",
            bullets: [
              "Nor-Way Trysil Express til SkiStar Lodge: ca. 3 timer.",
              "Fjällexpressen fra Malmö, Göteborg og Stockholm i vintersesongen.",
            ],
          },
          {
            title: "Flyplasser",
            bullets: [
              "Scandinavian Mountains Airport (Sälen/Trysil): 40 minutter.",
              "Oslo lufthavn Gardermoen: 2,5 timer.",
            ],
          },
        ],
      },
      goodToKnow: {
        title: "Godt å vite",
        bullets: [
          "Barn er hjertelig velkommen",
          "Allergivennlig miljø",
          "Røyking er ikke tillatt",
          "Kjæledyr er ikke tillatt",
        ],
      },
      contactHelp: {
        title: "Kontakt og hjelp",
        bullets: [
          "Spørsmål eller nødstilfelle: kontakt vår lokale kontaktperson eller oss.",
          "Kontaktinformasjon finner du i bestillingsbekreftelsen.",
        ],
      },
      agreementsAndPayment: {
        title: "Avtaler og betaling",
        blocks: [
          {
            title: "Betaling",
            items: ["50% ved reservasjon", "Restbeløpet 7 dager før ankomst"],
          },
          {
            title: "Avbestilling",
            items: ["Forhåndsbetalinger refunderes ikke"],
          },
          {
            title: "Sengetøy og renhold",
            items: [
              "Leie av sengetøy og sluttrengjøring av bad og oppholdsrom er obligatorisk og faktureres separat",
            ],
          },
        ],
      },
    },
    area: {
      intro: "Trysil er et helårs reisemål for friluftsliv.",
      sections: [
        {
          title: "Vinter",
          description: "Ski, langrenn og koselige kvelder.",
          bullets: [
            "Ski-in/ski-out til Trysilfjellet",
            "Stort nettverk av langrennsløyper",
            "Skileie og skiskole i nærheten",
          ],
        },
        {
          title: "Sommer",
          description: "Vandring, sykling og frisk fjelluft.",
          bullets: [
            "Merkede turstier rundt Fageråsen",
            "Stisykkel og heis",
            "Badeplasser og elveaktiviteter",
          ],
        },
      ],
    },
    privacy: {
      intro:
        "Vi respekterer personvernet ditt og behandler kun data som trengs for forespørsel eller bestilling.",
      bullets: [
        "Vi bruker dataene dine kun for å svare og administrere oppholdet.",
        "Bestillinger håndteres via Lodgify og deres personvern gjelder.",
        "Du kan be om sletting av dataene dine når som helst.",
      ],
    },
  },
} satisfies Record<Locale, LocalizedContent>;

export const contactFormSection = {
  nl: {
    title: "Contact & beschikbaarheid",
    subtitle:
      "Heb je vragen over beschikbaarheid, de omgeving of het verblijf in Fageråsen in Trysil? Gebruik het contactformulier hieronder of neem direct contact met ons op via e-mail: info@trysilpanorama.com.",
    form: {
      name: {
        label: "Naam",
        placeholder: "Je volledige naam",
      },
      email: {
        label: "E-mail",
        placeholder: "je@emailadres.nl",
      },
      period: {
        label: "Gewenste periode",
        placeholder: "Bijvoorbeeld 12–19 februari (optioneel)",
      },
      message: {
        label: "Bericht",
        placeholder: "Je vraag of bericht",
      },
      submit: "Stuur bericht",
      success: "Dank je wel! Je bericht is verzonden. We nemen zo snel mogelijk contact met je op.",
      error: "Er ging iets mis bij het verzenden. Probeer het later opnieuw.",
    },
  },
  en: {
    title: "Contact & availability",
    subtitle:
      "Have questions about availability, the area, or the stay in Fageråsen in Trysil? Use the contact form below or reach out directly via email: info@trysilpanorama.com.",
    form: {
      name: {
        label: "Name",
        placeholder: "Your full name",
      },
      email: {
        label: "Email",
        placeholder: "you@email.com",
      },
      period: {
        label: "Preferred period",
        placeholder: "For example 12–19 February (optional)",
      },
      message: {
        label: "Message",
        placeholder: "Your question or message",
      },
      submit: "Send message",
      success: "Thank you! Your message has been sent. We will get back to you as soon as possible.",
      error: "Something went wrong while sending. Please try again later.",
    },
  },
  no: {
    title: "Kontakt og tilgjengelighet",
    subtitle:
      "Har du spørsmål om tilgjengelighet, området eller oppholdet i Fageråsen i Trysil? Bruk kontaktskjemaet nedenfor eller ta direkte kontakt med oss på e-post: info@trysilpanorama.com.",
    form: {
      name: {
        label: "Navn",
        placeholder: "Ditt fulle navn",
      },
      email: {
        label: "E-post",
        placeholder: "du@epost.no",
      },
      period: {
        label: "Ønsket periode",
        placeholder: "For eksempel 12.–19. februar (valgfritt)",
      },
      message: {
        label: "Melding",
        placeholder: "Spørsmålet ditt eller melding",
      },
      submit: "Send melding",
      success: "Takk! Meldingen din er sendt. Vi tar kontakt så snart som mulig.",
      error: "Noe gikk galt under sendingen. Prøv igjen senere.",
    },
  },
} satisfies Record<Locale, ContactFormSectionContent>;
