# Designopdracht — actieplaatsing en knopcomposities in modals

Prompt voor Claude Design (claude.ai/design), project **HostHub CMS**.
Aanleiding: het API-key-dialoog in Accountinstellingen zet zijn primaire actie rechtsboven
in de header, terwijl het prototype overal een footer gebruikt. Voordat we dat één dialoog
verplaatsen willen we de regel voor alle gevallen.

---

## Wat ik van je wil

Eén regel voor waar acties in een modal staan, plus de knopcompositie per geval hieronder.
Geen nieuwe modal-chrome ontwerpen — de `modal` / `modal-hd` / `modal-body` / `modal-foot`
structuur staat en blijft.

## Wat er al staat — niet opnieuw ontwerpen

In `HostHub CMS.dc.html`:

- `.modal-foot` — `display:flex; gap:12px; justify-content:flex-end`, padding `16px 24px`,
  achtergrond `--jo-surface-low`, in de brede variant met `border-top: 1px solid --jo-border`.
- `.modal-foot .fl` — `margin-right:auto`, 11.5px, `--jo-fg-muted`: een metaregel links in de
  footer, tegenover de knoppen.
- Bestaande voorbeelden: bronwissel-bevestiging (`Cancel` + `Change source language`),
  Lid uitnodigen (`Annuleren` + `Uitnodiging sturen`), profiel (alleen `Close`),
  mediakiezer, publish-modal "Wat gaat live" (teller ín het label van de primaire knop).
- Kleuren en type uit `_ds/.../colors_and_type.css`.

Neem geen CSS of hex-waarden over als spec — dit wordt in Flutter met `styled_widgets`
gebouwd. Wat ik nodig heb is de **regel** plus per geval de knoppen, hun hiërarchie, hun
volgorde en hun states.

## De gevallen

1. **Bevestiging zonder formulier.** Annuleren + één primaire actie. Bestaat al
   (bronwissel) — neem hem mee als referentiepunt zodat de rest ertegen klopt.
2. **Eén-veld-formulier met een destructieve nevenactie.** Dit is de casus. Een API-key:
   veld met de bestaande waarde voorgevuld, primair `Opslaan`, en `Verwijderen` moet
   bereikbaar zijn zonder de primaire actie te worden. Nu staat `Verwijderen` als volle
   rode knop in de body onder het veld — dat trekt meer aandacht dan `Opslaan`. Waar hoort
   hij, en met welk gewicht (tekstknop, outline, icoon, footer-links tegenover de rest)?
3. **Formulier dat nog laadt.** De voorgevulde waarde komt van de server, dus het veld is
   even leeg en disabled. Wat doet de footer in die seconde: primaire knop disabled,
   spinner in de knop, of spinner in het veld en de knop gewoon actief?
4. **Alleen-lezen / informatief.** Eén `Sluiten`. Hoort die rechts (primaire positie) of
   is dit een outline-knop?
5. **Meerstapsflow.** Terug + Volgende, laatste stap Afronden, plus waar de
   stap-aanduiding zit. Onze modal-shell kan per stap een ander actielabel zetten.
6. **Footer met een metaregel.** Bijvoorbeeld "3 van 12 geselecteerd" of "Laatste sync:
   6 dagen geleden" links, knoppen rechts. De `.fl`-klasse suggereert dat dit al bedacht
   is; maak er een expliciete regel van.

## Wat er per geval beslist moet worden

- Volgorde en uitlijning (secundair links van primair? destructief apart?).
- Hiërarchie: welke knop is gevuld, welke outline, welke tekst-only.
- Wanneer een sluitkruis in de header nog nodig is naast een `Annuleren` in de footer —
  onze conventie is: kruis alleen als de modal het nodig heeft, en dan links.
- States: disabled, busy (spinner), en disabled-met-uitleg.
- Of er een geval bestaat waarin de actie tóch in de header hoort. Zo niet, zeg dat
  expliciet — dan halen we die variant uit de code weg in plaats van hem te laten staan.

## Randvoorwaarden

- Bouwbaar met `styled_widgets`: `StyledButton` (primair / outline / tekst / destructief),
  `showStyledModal` met `actionLabel` + `footerActionBuilder`, `leadingLabel`, en
  `showCloseButton` + `leadingClose`. Wat een nieuwe lib-capability vraagt: benoem het als
  zodanig, dan landt het als optionele toevoeging in de lib.
- Material 3 kleurrollen, geen M2-spellingen. Licht én donker.
- Labels komen uit ARB in NL en EN: NL is doorgaans langer ("Uitnodiging sturen" vs
  "Send invite"), dus de compositie moet niet op labelbreedte leunen.
- Modalbreedte 520px standaard, 760px voor de brede variant; ook bruikbaar als het
  venster smal is.

## Deliverable

Per geval een kaart in het designsysteem met de knopcompositie in alle states, plus één
tabel "geval → actieplaatsing → knophiërarchie" die ik als regel kan aanhouden. Als een
bestaand voorbeeld in het prototype tegen de regel in gaat die je voorstelt, noem het —
dan passen we het prototype aan in plaats van er twee regels naast elkaar te hebben.
