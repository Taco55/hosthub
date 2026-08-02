// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'nl';

  static String m0(count) =>
      "${Intl.plural(count, one: 'Maandelijks · 1 property', other: 'Maandelijks · ${count} properties')}";

  static String m1(count) =>
      "${Intl.plural(count, one: '1 property krijgt deze waarde', other: '${count} properties krijgen deze waarde')}";

  static String m2(count) =>
      "${Intl.plural(count, one: '1 property met een eigen waarde blijft ongewijzigd.', other: '${count} properties met een eigen waarde blijven ongewijzigd.')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Nog geen properties', one: '1 property', other: '${count} properties')}";

  static String m4(count) =>
      "${Intl.plural(count, one: '1 van Lodgify', other: '${count} van Lodgify')}";

  static String m5(count) =>
      "${Intl.plural(count, one: '1 handmatig', other: '${count} handmatig')}";

  static String m6(name) => "${name} verwijderen?";

  static String m7(language) =>
      "Eenmalige actie: zet de brontaal op ${language}.";

  static String m8(version, environment) =>
      "Versie ${version} · ${environment}";

  static String m9(language) =>
      "Je schrijft je website voortaan in ${language}. De andere talen worden bij publiceren opnieuw vanuit de nieuwe brontaal vertaald; vergrendelde velden behouden jouw tekst.";

  static String m10(language) => "Brontaal wijzigen naar ${language}?";

  static String m11(percentage) => "Commissie ${percentage}%";

  static String m12(error) => "Content laden mislukt: ${error}";

  static String m13(version) =>
      "Huidige content vervangen door versie ${version}? De herstelde content wordt opgeslagen als concept ter controle.";

  static String m14(date) => "Gepubliceerd ${date}";

  static String m15(version) => "Versie ${version}";

  static String m16(error) => "Contentdocumenten laden mislukt: ${error}";

  static String m17(publishedAt) => "Gepubliceerd ${publishedAt}";

  static String m18(status, updatedAt) => "${status} • bijgewerkt ${updatedAt}";

  static String m19(slug, version) => "${slug} (v${version})";

  static String m20(following, total) =>
      "${Intl.plural(following, zero: 'Geen property volgt', other: '${following} van ${total} volgen')}";

  static String m21(property) =>
      "${property} heeft eigen waarden — open Prijzen";

  static String m22(error) => "Gebruiker kon niet worden aangemaakt: ${error}";

  static String m23(domain) => "${domain} serveert nu deze website.";

  static String m24(zone) =>
      "${zone} wordt hier nog niet beheerd, dus we kunnen het niet routeren. Voeg het domein toe aan Cloudflare en wijzig de nameservers bij je registrar. Stel het domein daarna hier opnieuw in.";

  static String m25(zone) => "Wijs ${zone} eerst naar ons";

  static String m26(email) =>
      "Weet je zeker dat je ${email} wilt verwijderen? Dit verwijdert ook de inhoud van dit account en kan niet ongedaan worden gemaakt.";

  static String m27(count) => "Minimaal ${count} tekens";

  static String m28(fieldType) =>
      "Veld is gekoppeld aan veld van type \'${fieldType}\'";

  static String m29(locale) => "Weergavenaam (${locale})";

  static String m30(source) =>
      "Gelezen, gesluimerd en gearchiveerd houdt HostHub zelf bij. ${source} weet daarvan niets.";

  static String m31(source) => "Openen in ${source}";

  static String m32(count) =>
      "${Intl.plural(count, zero: 'Eerste boeking', one: '1 eerdere boeking', other: '${count} eerdere boekingen')}";

  static String m33(guest, channel) => "Antwoord ${guest} via ${channel}…";

  static String m34(channel) => "Antwoord gaat via ${channel}";

  static String m35(source) => "Antwoorden gaat nog via ${source}.";

  static String m36(date) => "Sluimert tot ${date}";

  static String m37(property, dates, channel) =>
      "${property} · ${dates} · via ${channel}";

  static String m38(property, channel) => "${property} · via ${channel}";

  static String m39(language) => "Vertalen naar ${language}";

  static String m40(count) =>
      "${Intl.plural(count, one: '1 ongelezen gesprek', other: '${count} ongelezen gesprekken')}";

  static String m41(role) => "Rol: ${role}";

  static String m42(date) => "Sinds ${date}";

  static String m43(name) => "Wijzig template-gegevens ${name}";

  static String m44(code) => "Veldnaam (${code})";

  static String m45(count) =>
      "${count} veld${Intl.plural(count, one: '', other: 'en')}";

  static String m46(path) => "Standaard seed-map: ${path}";

  static String m47(path) => "JSON opgeslagen in ${path}";

  static String m48(code) => "Taal ${code}";

  static String m49(code) => "Lijstnaam (${code})";

  static String m50(code) => "Meervoudige naam (${code})";

  static String m51(count) =>
      "${count} voorbeeld${Intl.plural(count, one: 'item', other: 'items')}";

  static String m52(prod, dev) => "${prod} prod / ${dev} dev";

  static String m53(error) => "Kon gebruiker niet laden: ${error}";

  static String m54(error) => "Kon gebruikers niet laden: ${error}";

  static String m55(time) => "laatste sync ${time}";

  static String m56(count) =>
      "${Intl.plural(count, one: '1 listing overgenomen', other: '${count} listings overgenomen')}";

  static String m57(name) =>
      "Koppelen aan ${name}. De website-content die er al op staat blijft staan.";

  static String m58(count) =>
      "${Intl.plural(count, one: '1 koppelt aan een property die je zelf aanmaakte', other: '${count} koppelen aan properties die je zelf aanmaakte')}";

  static String m59(count) =>
      "${Intl.plural(count, one: '1 nieuwe listing', other: '${count} nieuwe listings')}";

  static String m60(error) => "Inloggen mislukt: ${error}";

  static String m61(email) =>
      "We hebben een magic link gestuurd naar ${email}. Controleer je inbox en spamfolder.";

  static String m62(error) => "Kon wachtwoord niet wijzigen: ${error}";

  static String m63(count, total) =>
      "${count} van ${Intl.plural(total, one: '1 property', other: '${total} properties')}";

  static String m64(percentage) => "Commissie ${percentage}%";

  static String m65(nights, rate) => "Bruto (${nights} × ${rate})";

  static String m66(percentage) => "Prijsopslag ${percentage}%";

  static String m67(guests) => "Service (${guests} gasten)";

  static String m68(nights, guests, rate, channel) =>
      "Verblijf van ${nights} nachten · ${guests} gasten · basisprijs ${rate}/nacht via ${channel}";

  static String m69(error) => "Kon profiel niet laden: ${error}";

  static String m70(count) =>
      "${Intl.plural(count, one: '1 boeking', other: '${count} boekingen')}";

  static String m71(count) =>
      "${Intl.plural(count, one: '1 eigen waarde', other: '${count} eigen waarden')}";

  static String m72(name) => "${name} verwijderen?";

  static String m73(lodgifyId, lastSync) =>
      "Gekoppeld · ID ${lodgifyId} · laatste sync ${lastSync}";

  static String m74(lodgifyId) =>
      "Gekoppeld · ID ${lodgifyId} · nog niet gesynchroniseerd";

  static String m75(count) =>
      "${Intl.plural(count, one: '1 gast', other: '${count} gasten')}";

  static String m76(days) =>
      "${Intl.plural(days, one: 'Per nacht', other: 'Per ${days} nachten')}";

  static String m77(rating) => "${rating} van 5";

  static String m78(lastSync) =>
      "Laatste synchronisatie met Lodgify: ${lastSync}. Haalt de gegevens nu opnieuw op.";

  static String m79(count) =>
      "${Intl.plural(count, one: '1 kamer', other: '${count} kamers')}";

  static String m80(name) => "${name} ontkoppelen?";

  static String m81(language) => "${language} verwijderen?";

  static String m82(seconds) => "Opnieuw verzenden over ${seconds} s";

  static String m83(count) => "${count} nieuw";

  static String m84(guests) => "Gasten: ${guests}";

  static String m85(nights) => "${nights} nachten";

  static String m86(source) => "Bron: ${source}";

  static String m87(status) => "Status: ${status}";

  static String m88(property) => "Boekingen · ${property}";

  static String m89(month, gross, net) =>
      "${month}: ${gross} bruto · ${net} netto";

  static String m90(propertyName) => "Omzet · ${propertyName}";

  static String m91(nights) => "${nights} nachten";

  static String m92(count) => "${count} boekingen";

  static String m93(quarter, year) => "Kwartaal ${quarter} ${year}";

  static String m94(error) => "Sites laden mislukt: ${error}";

  static String m95(defaultLocale, locales) =>
      "Taal: ${defaultLocale} • Talen: ${locales}";

  static String m96(status) => "Abonnement: ${status}";

  static String m97(table) =>
      "Kan de gegevens niet laden omdat Supabase de tabel \"${table}\" niet kan vinden. Voer de nieuwste database-migraties uit en vernieuw de schema-cache.";

  static String m98(siteName) =>
      "Nodig iemand uit om samen te werken aan \"${siteName}\".";

  static String m99(name) => "Weet je zeker dat je ${name} wilt verwijderen?";

  static String m100(error) => "Kan adminrechten niet wijzigen: ${error}";

  static String m101(error) => "Kon profiel niet bijwerken: ${error}";

  static String m102(error) => "Kon gebruiker niet verwijderen: ${error}";

  static String m103(email) => "Verificatiecode verstuurd naar ${email}";

  static String m104(version) => "v${version}";

  static String m105(source) =>
      "Typ over een veld om het te vergrendelen; ongewijzigde velden blijven automatisch en volgen de ${source} bron.";

  static String m106(language) => "Je bewerkt de ${language} vertaling";

  static String m107(languages) =>
      "${languages} worden automatisch bijgewerkt bij publiceren. Vergrendelde velden behouden je tekst.";

  static String m108(language) => "Je schrijft in het ${language}";

  static String m109(lang) => "Bewerken · ${lang}";

  static String m110(number) => "Ervaring ${number}";

  static String m111(number) => "Hoogtepunt ${number}";

  static String m112(number) => "Introductie van sectie ${number}";

  static String m113(count) => "${count} gewijzigd";

  static String m114(item) => "${item} toevoegen";

  static String m115(count, max) => "${count} van ${max}";

  static String m116(item) => "Nog geen ${item}";

  static String m117(max) => "Maximum van ${max} bereikt";

  static String m118(min) => "Er moeten er minimaal ${min} zijn";

  static String m119(locked, total) =>
      "${locked} van ${total} velden in jouw woorden";

  static String m120(count) => "${count} toevoegen";

  static String m121(count, max, min) =>
      "${count} van maximaal ${max} · minimaal ${min}";

  static String m122(min) => "Er moeten minimaal ${min} foto\'s zijn";

  static String m123(min, max) =>
      "${min} tot ${max} foto\'s. De mediakiezer komt met het beeldbeheer.";

  static String m124(remaining) =>
      "Kies foto\'s uit de bibliotheek of upload nieuwe. Nog ${remaining} te kiezen.";

  static String m125(language) => "${language} voorbeeld";

  static String m126(count) => "${count} talen publiceren";

  static String m127(count) =>
      "${count} gewijzigde velden · vergrendelde velden houden jouw woorden";

  static String m128(count) => "${count} gewijzigde velden · bekeken";

  static String m129(count) => "${count} gewijzigde velden · nog niet bekeken";

  static String m130(seen, total) => "${seen} van ${total} bekeken";

  static String m131(count) =>
      "${count} velden gewijzigd sinds de vorige publicatie";

  static String m132(source) => "Alleen ${source} publiceren";

  static String m133(language) => "${language} · bron";

  static String m134(source) =>
      "Je ${source} content publiceert zoals die is. De andere talen worden opnieuw vertaald door AI, met behoud van wat je hebt vergrendeld.";

  static String m135(count, pages) =>
      "${count} gewijzigde velden op ${pages} pagina\'s";

  static String m136(lang) => "Bron · ${lang}";

  static String m137(source, count) =>
      "${source} + ${count} vertalingen staan live";

  static String m138(languages) =>
      "${languages} vertalen zodra je ze opent, of bij publiceren";

  static String m139(language) =>
      "Rijen wijzigen doe je in de bron (${language})";

  static String m140(source) => "Volgt nu de ${source} bron.";

  static String m141(width, height) => "${width} × ${height}";

  static String m142(width, height) =>
      "Te klein (${width} × ${height}). Minimaal 1600 × 1200.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountBillingExternalNotice": MessageLookupByLibrary.simpleMessage(
      "Betaalmethode en facturen beheer je bij onze betaalprovider. Die koppeling volgt nog.",
    ),
    "accountBillingHeader": MessageLookupByLibrary.simpleMessage(
      "Abonnement & facturering",
    ),
    "accountBillingInvoices": MessageLookupByLibrary.simpleMessage("Facturen"),
    "accountBillingInvoicesValue": MessageLookupByLibrary.simpleMessage(
      "Bekijk en download je facturen",
    ),
    "accountBillingPaymentMethod": MessageLookupByLibrary.simpleMessage(
      "Betaalmethode",
    ),
    "accountBillingPlan": MessageLookupByLibrary.simpleMessage("Abonnement"),
    "accountBillingPlanPro": MessageLookupByLibrary.simpleMessage("Pro"),
    "accountBillingPlanSubtitle": m0,
    "accountBillingVatHint": MessageLookupByLibrary.simpleMessage(
      "Vul dit in als je factuur op een bedrijf moet staan.",
    ),
    "accountBillingVatNumber": MessageLookupByLibrary.simpleMessage(
      "BTW- of ondernemingsnummer",
    ),
    "accountConnectionNeverSynced": MessageLookupByLibrary.simpleMessage(
      "nog niet gesynchroniseerd",
    ),
    "accountConnectionScope": MessageLookupByLibrary.simpleMessage(
      "Boekingen, prijzen en beschikbaarheid",
    ),
    "accountConnectionsFooter": MessageLookupByLibrary.simpleMessage(
      "Betalingsschema, annulering en borg blijven in Lodgify staan. HostHub leest ze alleen.",
    ),
    "accountConnectionsHeader": MessageLookupByLibrary.simpleMessage(
      "Koppelingen",
    ),
    "accountDefaultsApplied": MessageLookupByLibrary.simpleMessage(
      "Standaardwaarden toegepast.",
    ),
    "accountDefaultsApply": MessageLookupByLibrary.simpleMessage("Toepassen"),
    "accountDefaultsChannelsHeader": MessageLookupByLibrary.simpleMessage(
      "Kanaal & kosten",
    ),
    "accountDefaultsImpactNone": MessageLookupByLibrary.simpleMessage(
      "Geen property volgt deze standaard",
    ),
    "accountDefaultsImpactNotYetApplied": MessageLookupByLibrary.simpleMessage(
      "Wordt pas doorgevoerd als je toepast.",
    ),
    "accountDefaultsImpactSingleProperty": MessageLookupByLibrary.simpleMessage(
      "Dit verandert je property",
    ),
    "accountDefaultsImpactSome": m1,
    "accountDefaultsImpactUnchanged": m2,
    "accountDefaultsLanguagesFooter": MessageLookupByLibrary.simpleMessage(
      "Dit is het startpunt van je volgende property. Bestaande websites veranderen hier niet van.",
    ),
    "accountDefaultsLanguagesHeader": MessageLookupByLibrary.simpleMessage(
      "Talen",
    ),
    "accountDefaultsReadOnlyNotice": MessageLookupByLibrary.simpleMessage(
      "Alleen de eigenaar van het account kan standaardwaarden wijzigen. Per property afwijken kan wel.",
    ),
    "accountDefaultsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Wat elke property overneemt, tenzij die property zelf iets anders zegt.",
    ),
    "accountDefaultsTitle": MessageLookupByLibrary.simpleMessage(
      "Standaardwaarden",
    ),
    "accountInviteMember": MessageLookupByLibrary.simpleMessage(
      "Lid uitnodigen",
    ),
    "accountMemberInvited": MessageLookupByLibrary.simpleMessage(
      "· uitgenodigd",
    ),
    "accountPreferencesMovedFooter": MessageLookupByLibrary.simpleMessage(
      "Interfacetaal en compact zijmenu zijn van jou, niet van het account. Die staan bij je profiel onderin de zijbalk.",
    ),
    "accountPropertiesCount": m3,
    "accountPropertiesFromLodgifyCount": m4,
    "accountPropertiesManualCount": m5,
    "accountRemoveMemberMessage": MessageLookupByLibrary.simpleMessage(
      "Deze gebruiker verliest toegang tot al je properties.",
    ),
    "accountRemoveMemberTitle": m6,
    "accountRoleAdmin": MessageLookupByLibrary.simpleMessage("Beheerder"),
    "accountRoleAdminDescription": MessageLookupByLibrary.simpleMessage(
      "Content, prijzen en afwijkingen per property. Geen facturering, geen leden.",
    ),
    "accountRoleOwner": MessageLookupByLibrary.simpleMessage("Eigenaar"),
    "accountRoleOwnerDescription": MessageLookupByLibrary.simpleMessage(
      "Alles, inclusief facturering en leden.",
    ),
    "accountRoleViewer": MessageLookupByLibrary.simpleMessage("Alleen lezen"),
    "accountRoleViewerDescription": MessageLookupByLibrary.simpleMessage(
      "Meekijken zonder iets te wijzigen.",
    ),
    "accountTitle": MessageLookupByLibrary.simpleMessage("Account"),
    "accountUsersFooter": MessageLookupByLibrary.simpleMessage(
      "Een rol geldt voor het hele account, dus voor al je properties. Eigenaar regelt alles; beheerder beheert content en prijzen, maar geen facturering.",
    ),
    "accountUsersHeader": MessageLookupByLibrary.simpleMessage(
      "Gebruikers & rollen",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Toevoegen"),
    "addLanguageAction": MessageLookupByLibrary.simpleMessage("Taal toevoegen"),
    "addPropertyFooter": MessageLookupByLibrary.simpleMessage(
      "Uit Lodgify is de normale weg. Handmatig is er voor een website opzetten voordat Lodgify klaar is.",
    ),
    "addPropertyFromLodgifyBody": MessageLookupByLibrary.simpleMessage(
      "Haalt je listings op en laat zien wat er nieuw is.",
    ),
    "addPropertyFromLodgifyTitle": MessageLookupByLibrary.simpleMessage(
      "Uit Lodgify ophalen",
    ),
    "addPropertyLodgifyNotConnected": MessageLookupByLibrary.simpleMessage(
      "Koppel Lodgify eerst bij Account.",
    ),
    "addPropertyManualAction": MessageLookupByLibrary.simpleMessage("Aanmaken"),
    "addPropertyManualBody": MessageLookupByLibrary.simpleMessage(
      "Alleen een naam. De rest vul je in de website-editor aan.",
    ),
    "addPropertyManualTitle": MessageLookupByLibrary.simpleMessage(
      "Handmatig aanmaken",
    ),
    "addPropertyNameLabel": MessageLookupByLibrary.simpleMessage(
      "Naam van de property",
    ),
    "addressBook": MessageLookupByLibrary.simpleMessage("Adresboek"),
    "adminOnlyBadge": MessageLookupByLibrary.simpleMessage("Alleen beheerders"),
    "adminOptionsSectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Instellingen voor de hele omgeving, niet voor dit account.",
    ),
    "adminRightsActive": MessageLookupByLibrary.simpleMessage(
      "Adminrechten actief",
    ),
    "adminRightsDescription": MessageLookupByLibrary.simpleMessage(
      "Bepaalt of deze gebruiker toegang heeft tot de console.",
    ),
    "adminRightsDisabled": MessageLookupByLibrary.simpleMessage(
      "Adminrechten zijn uitgeschakeld.",
    ),
    "adminRightsEnabled": MessageLookupByLibrary.simpleMessage(
      "Adminrechten zijn ingeschakeld.",
    ),
    "adminRightsTitle": MessageLookupByLibrary.simpleMessage("Adminrechten"),
    "adminSettingsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Voorkeuren voor jouw console-ervaring.",
    ),
    "adminSettingsTitle": MessageLookupByLibrary.simpleMessage("Instellingen"),
    "adoptInterfaceLanguageSubtitle": m7,
    "adoptInterfaceLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Overnemen van interfacetaal",
    ),
    "airplane": MessageLookupByLibrary.simpleMessage("Vliegtuig"),
    "alarm": MessageLookupByLibrary.simpleMessage("Alarm"),
    "alarmClock": MessageLookupByLibrary.simpleMessage("Wekker"),
    "alert": MessageLookupByLibrary.simpleMessage("Waarschuwing"),
    "alreadyAnAccount": MessageLookupByLibrary.simpleMessage("Al een account?"),
    "amount": MessageLookupByLibrary.simpleMessage("Bedrag"),
    "anUnknownErrorOccurred": MessageLookupByLibrary.simpleMessage(
      "Er is een onbekende fout opgetreden.",
    ),
    "analysis": MessageLookupByLibrary.simpleMessage("Analyse"),
    "analytics": MessageLookupByLibrary.simpleMessage("Analyse"),
    "appInfoTileTitle": MessageLookupByLibrary.simpleMessage("App informatie"),
    "appInfoTileValue": m8,
    "appName": MessageLookupByLibrary.simpleMessage("HostHub"),
    "appTitle": MessageLookupByLibrary.simpleMessage("HostHub"),
    "appsTitle": MessageLookupByLibrary.simpleMessage("Apps"),
    "arrow": MessageLookupByLibrary.simpleMessage("Pijl"),
    "arrowsUpDown": MessageLookupByLibrary.simpleMessage(
      "Pijlen omhoog omlaag",
    ),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "authWelcome": MessageLookupByLibrary.simpleMessage("Welkom"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "avocado": MessageLookupByLibrary.simpleMessage("Avocado"),
    "baby": MessageLookupByLibrary.simpleMessage("Baby"),
    "back": MessageLookupByLibrary.simpleMessage("Terug"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Terug naar inloggen"),
    "backToOverview": MessageLookupByLibrary.simpleMessage(
      "Terug naar overzicht",
    ),
    "balance": MessageLookupByLibrary.simpleMessage("Balans"),
    "balloon": MessageLookupByLibrary.simpleMessage("Ballon"),
    "banner": MessageLookupByLibrary.simpleMessage("Banner"),
    "barcode": MessageLookupByLibrary.simpleMessage("Barcode"),
    "bauble": MessageLookupByLibrary.simpleMessage("Kerstbal"),
    "beach": MessageLookupByLibrary.simpleMessage("Strand"),
    "beachUmbrella": MessageLookupByLibrary.simpleMessage("Strandparasol"),
    "beer": MessageLookupByLibrary.simpleMessage("Bier"),
    "bell": MessageLookupByLibrary.simpleMessage("Bel"),
    "beta": MessageLookupByLibrary.simpleMessage("Beta"),
    "bike": MessageLookupByLibrary.simpleMessage("Fiets"),
    "birthday": MessageLookupByLibrary.simpleMessage("Verjaardag"),
    "blank": MessageLookupByLibrary.simpleMessage("Leeg"),
    "blender": MessageLookupByLibrary.simpleMessage("Blender"),
    "bookingLinkLabel": MessageLookupByLibrary.simpleMessage("Boekingslink"),
    "bookmarks": MessageLookupByLibrary.simpleMessage("Bladwijzers"),
    "bottle": MessageLookupByLibrary.simpleMessage("Fles"),
    "bowlAndChopsticks": MessageLookupByLibrary.simpleMessage(
      "Kom en eetstokjes",
    ),
    "braces": MessageLookupByLibrary.simpleMessage("Haakjes"),
    "bread": MessageLookupByLibrary.simpleMessage("Brood"),
    "broccoli": MessageLookupByLibrary.simpleMessage("Broccoli"),
    "brush": MessageLookupByLibrary.simpleMessage("Borstel"),
    "budget": MessageLookupByLibrary.simpleMessage("Budget"),
    "bug": MessageLookupByLibrary.simpleMessage("Bug"),
    "bulb": MessageLookupByLibrary.simpleMessage("Lamp"),
    "bulletLists": MessageLookupByLibrary.simpleMessage("Opsommingstekens"),
    "bus": MessageLookupByLibrary.simpleMessage("Bus"),
    "business": MessageLookupByLibrary.simpleMessage("Zakelijk"),
    "calendar": MessageLookupByLibrary.simpleMessage("Kalender"),
    "call": MessageLookupByLibrary.simpleMessage("Bellen"),
    "cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "cannotAddList": MessageLookupByLibrary.simpleMessage(
      "Kan lijst niet toevoegen.",
    ),
    "cannotDeleteAllUserData": MessageLookupByLibrary.simpleMessage(
      "Kan alle gebruikersgegevens niet verwijderen.",
    ),
    "cannotDeleteField": MessageLookupByLibrary.simpleMessage(
      "Kan veld niet verwijderen",
    ),
    "cannotLoadLinkData": MessageLookupByLibrary.simpleMessage(
      "Kan geen gegevens van de link ophalen",
    ),
    "cannotOpenLink": MessageLookupByLibrary.simpleMessage(
      "Kan de link niet openen",
    ),
    "car": MessageLookupByLibrary.simpleMessage("Auto"),
    "card": MessageLookupByLibrary.simpleMessage("Kaart"),
    "carrot": MessageLookupByLibrary.simpleMessage("Wortel"),
    "cart": MessageLookupByLibrary.simpleMessage("Winkelwagen"),
    "cash": MessageLookupByLibrary.simpleMessage("Contant"),
    "cat": MessageLookupByLibrary.simpleMessage("Kat"),
    "caution": MessageLookupByLibrary.simpleMessage("Voorzichtigheid"),
    "centerAlignment": MessageLookupByLibrary.simpleMessage("Middenuitlijning"),
    "changeButton": MessageLookupByLibrary.simpleMessage("Wijzigen"),
    "changePasswordDescription": MessageLookupByLibrary.simpleMessage(
      "Stel een tijdelijk wachtwoord in.",
    ),
    "changePasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord wijzigen",
    ),
    "changeSourceLanguageConfirmMessage": m9,
    "changeSourceLanguageConfirmTitle": m10,
    "changesWillBeLost": MessageLookupByLibrary.simpleMessage(
      "Wijzigingen gaan verloren",
    ),
    "channelFieldCleaning": MessageLookupByLibrary.simpleMessage("Schoonmaak"),
    "channelFieldCommission": MessageLookupByLibrary.simpleMessage("Commissie"),
    "channelFieldCommissionHint": MessageLookupByLibrary.simpleMessage(
      "Wat dit kanaal inhoudt op de boeking.",
    ),
    "channelFieldLinen": MessageLookupByLibrary.simpleMessage("Linnen"),
    "channelFieldMarkup": MessageLookupByLibrary.simpleMessage("Prijsopslag"),
    "channelFieldMarkupHint": MessageLookupByLibrary.simpleMessage(
      "Verhoog de kanaalprijs ten opzichte van je basisprijs.",
    ),
    "channelFieldOther": MessageLookupByLibrary.simpleMessage("Overig"),
    "channelFieldService": MessageLookupByLibrary.simpleMessage("Service"),
    "channelSummaryCommission": m11,
    "check": MessageLookupByLibrary.simpleMessage("Controleren"),
    "cherries": MessageLookupByLibrary.simpleMessage("Kersen"),
    "chicken": MessageLookupByLibrary.simpleMessage("Kip"),
    "christmas": MessageLookupByLibrary.simpleMessage("Kerstmis"),
    "circleFilled": MessageLookupByLibrary.simpleMessage("Cirkel gevuld"),
    "circleOutlined": MessageLookupByLibrary.simpleMessage("Cirkel omlijnd"),
    "cleaning": MessageLookupByLibrary.simpleMessage("Schoonmaken"),
    "clear": MessageLookupByLibrary.simpleMessage("Wissen"),
    "clearSearchTooltip": MessageLookupByLibrary.simpleMessage(
      "Wis zoekopdracht",
    ),
    "clientAppsActiveLabel": MessageLookupByLibrary.simpleMessage("Actief"),
    "clientAppsAddDefaultButton": MessageLookupByLibrary.simpleMessage(
      "Toevoegen",
    ),
    "clientAppsAllowedTemplatesDescription":
        MessageLookupByLibrary.simpleMessage(
          "Kies welke sjablonen deze app mag maken.",
        ),
    "clientAppsAllowedTemplatesLabel": MessageLookupByLibrary.simpleMessage(
      "Toegestane sjablonen",
    ),
    "clientAppsDefaultTemplatesDescription": MessageLookupByLibrary.simpleMessage(
      "Deze sjablonen worden automatisch aangemaakt bij registratie en voorgesteld bij het maken van een nieuwe lijst.",
    ),
    "clientAppsDefaultTemplatesEmpty": MessageLookupByLibrary.simpleMessage(
      "Nog geen standaard sjablonen ingesteld.",
    ),
    "clientAppsDefaultTemplatesLabel": MessageLookupByLibrary.simpleMessage(
      "Standaard sjablonen",
    ),
    "clientAppsDefaultTemplatesRequiresAllowed":
        MessageLookupByLibrary.simpleMessage(
          "Selecteer eerst een toegestane sjabloon om standaard sjablonen te kunnen kiezen.",
        ),
    "clientAppsIdLabel": MessageLookupByLibrary.simpleMessage("Client-app-id"),
    "clientAppsLabel": MessageLookupByLibrary.simpleMessage("Client-apps"),
    "clientAppsMoveDefaultDownTooltip": MessageLookupByLibrary.simpleMessage(
      "Verplaats standaard sjabloon omlaag",
    ),
    "clientAppsMoveDefaultUpTooltip": MessageLookupByLibrary.simpleMessage(
      "Verplaats standaard sjabloon omhoog",
    ),
    "clientAppsNameLabel": MessageLookupByLibrary.simpleMessage("Weergavenaam"),
    "clientAppsNoAppsFound": MessageLookupByLibrary.simpleMessage(
      "Geen client-apps geconfigureerd.",
    ),
    "clientAppsNoSelection": MessageLookupByLibrary.simpleMessage(
      "Selecteer een client-app om te configureren.",
    ),
    "clientAppsRemoveDefaultTooltip": MessageLookupByLibrary.simpleMessage(
      "Standaard sjabloon verwijderen",
    ),
    "clientAppsSelectDefaultLabel": MessageLookupByLibrary.simpleMessage(
      "Kies sjabloon",
    ),
    "clientAppsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Beheer welke lijstsjablonen elke client-app mag gebruiken.",
    ),
    "clientAppsTemplatesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Sjablooncatalogus niet beschikbaar.",
    ),
    "clientAppsTitle": MessageLookupByLibrary.simpleMessage("Client-apps"),
    "clipboardAlert": MessageLookupByLibrary.simpleMessage("Melding"),
    "clipboardCode": MessageLookupByLibrary.simpleMessage("Code"),
    "clipboardContext": MessageLookupByLibrary.simpleMessage("Context"),
    "clipboardDetails": MessageLookupByLibrary.simpleMessage("Details"),
    "clipboardError": MessageLookupByLibrary.simpleMessage("Fout"),
    "clipboardTime": MessageLookupByLibrary.simpleMessage("Tijd"),
    "clock": MessageLookupByLibrary.simpleMessage("Klok"),
    "closeButton": MessageLookupByLibrary.simpleMessage("Sluiten"),
    "clothing": MessageLookupByLibrary.simpleMessage("Kleding"),
    "cmsAddItem": MessageLookupByLibrary.simpleMessage("Item toevoegen"),
    "cmsAreaPageSection": MessageLookupByLibrary.simpleMessage(
      "Omgeving & activiteiten",
    ),
    "cmsBackToSites": MessageLookupByLibrary.simpleMessage("Terug naar sites"),
    "cmsCabinSection": MessageLookupByLibrary.simpleMessage("Chalet details"),
    "cmsContactFormSection": MessageLookupByLibrary.simpleMessage(
      "Contactformulier",
    ),
    "cmsContentTitle": MessageLookupByLibrary.simpleMessage("Website Content"),
    "cmsDiscardButton": MessageLookupByLibrary.simpleMessage("Verwerpen"),
    "cmsHomePageSection": MessageLookupByLibrary.simpleMessage("Homepagina"),
    "cmsLoadFailed": m12,
    "cmsNoContent": MessageLookupByLibrary.simpleMessage(
      "Geen content documenten gevonden voor deze site.",
    ),
    "cmsNoVersions": MessageLookupByLibrary.simpleMessage(
      "Nog geen gepubliceerde versies.",
    ),
    "cmsPracticalPageSection": MessageLookupByLibrary.simpleMessage(
      "Praktische info",
    ),
    "cmsPreviewButton": MessageLookupByLibrary.simpleMessage("Preview website"),
    "cmsPrivacyPageSection": MessageLookupByLibrary.simpleMessage(
      "Privacybeleid",
    ),
    "cmsPublishButton": MessageLookupByLibrary.simpleMessage("Publiceren"),
    "cmsPublishConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Dit maakt de huidige content live op de website. Doorgaan?",
    ),
    "cmsPublishConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Content publiceren",
    ),
    "cmsPublishSuccess": MessageLookupByLibrary.simpleMessage(
      "Content gepubliceerd.",
    ),
    "cmsRemoveItem": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "cmsRestoreButton": MessageLookupByLibrary.simpleMessage("Herstellen"),
    "cmsRestoreConfirmBody": m13,
    "cmsRestoreConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Versie herstellen",
    ),
    "cmsRestoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Versie hersteld als concept.",
    ),
    "cmsSaveDraftButton": MessageLookupByLibrary.simpleMessage(
      "Concept opslaan",
    ),
    "cmsSaveDraftSuccess": MessageLookupByLibrary.simpleMessage(
      "Concept opgeslagen.",
    ),
    "cmsSiteConfigSection": MessageLookupByLibrary.simpleMessage(
      "Site configuratie",
    ),
    "cmsStatusDraft": MessageLookupByLibrary.simpleMessage("Concept"),
    "cmsStatusPublished": MessageLookupByLibrary.simpleMessage("Gepubliceerd"),
    "cmsUnsavedChangesBody": MessageLookupByLibrary.simpleMessage(
      "Je hebt onopgeslagen wijzigingen. Wat wil je doen?",
    ),
    "cmsUnsavedChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Onopgeslagen wijzigingen",
    ),
    "cmsVersionDate": m14,
    "cmsVersionHistory": MessageLookupByLibrary.simpleMessage(
      "Versiegeschiedenis",
    ),
    "cmsVersionLabel": m15,
    "code": MessageLookupByLibrary.simpleMessage("Code"),
    "coffee": MessageLookupByLibrary.simpleMessage("Koffie"),
    "coin": MessageLookupByLibrary.simpleMessage("Munt"),
    "coins": MessageLookupByLibrary.simpleMessage("Munten"),
    "column": MessageLookupByLibrary.simpleMessage("Kolom"),
    "compactSideMenuDescription": MessageLookupByLibrary.simpleMessage(
      "Klap de zijbalk in tot iconen.",
    ),
    "compactSideMenuTitle": MessageLookupByLibrary.simpleMessage(
      "Compact zijmenu",
    ),
    "company": MessageLookupByLibrary.simpleMessage("Bedrijf"),
    "compass": MessageLookupByLibrary.simpleMessage("Kompas"),
    "computer": MessageLookupByLibrary.simpleMessage("Computer"),
    "cone": MessageLookupByLibrary.simpleMessage("Kegel"),
    "configurationInvalid": MessageLookupByLibrary.simpleMessage(
      "Deze actie kan niet worden voltooid omdat de configuratie ongeldig is. Controleer de instellingen en probeer het opnieuw.",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Bevestigen"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord bevestigen",
    ),
    "confirmPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Bevestig wachtwoord",
    ),
    "connectLabel": MessageLookupByLibrary.simpleMessage("Koppelen"),
    "connection": MessageLookupByLibrary.simpleMessage("Verbinding"),
    "connectionStatusConnected": MessageLookupByLibrary.simpleMessage(
      "Gekoppeld",
    ),
    "connectionStatusDisconnected": MessageLookupByLibrary.simpleMessage(
      "Niet gekoppeld",
    ),
    "connectionsSectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Verbind externe platforms met deze property.",
    ),
    "connectionsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Koppelingen",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectiviteit"),
    "contacts": MessageLookupByLibrary.simpleMessage("Contacten"),
    "container": MessageLookupByLibrary.simpleMessage("Container"),
    "contentDocumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Elke pagina, taal en versie wordt opgeslagen als een JSON-document.",
    ),
    "contentDocumentsEmpty": MessageLookupByLibrary.simpleMessage(
      "Geen documenten gevonden.",
    ),
    "contentDocumentsLoadFailed": m16,
    "contentDocumentsPublished": m17,
    "contentDocumentsTitle": MessageLookupByLibrary.simpleMessage(
      "Contentdocumenten",
    ),
    "contentDocumentsUpdated": m18,
    "contentDocumentsVersionLabel": m19,
    "copied": MessageLookupByLibrary.simpleMessage("Gekopieerd"),
    "copy": MessageLookupByLibrary.simpleMessage("Kopiëren"),
    "cost": MessageLookupByLibrary.simpleMessage("Kosten"),
    "costTypePerBooking": MessageLookupByLibrary.simpleMessage("per verblijf"),
    "costTypePerNight": MessageLookupByLibrary.simpleMessage("per nacht"),
    "costTypePerPerson": MessageLookupByLibrary.simpleMessage("per gast"),
    "coverageFollowing": m20,
    "coverageOpenPricingTooltip": m21,
    "coverageOwnValuesAt": MessageLookupByLibrary.simpleMessage(
      "Eigen waarden bij:",
    ),
    "coverageSingleFollows": MessageLookupByLibrary.simpleMessage(
      "Volgt standaard",
    ),
    "coverageSingleOwn": MessageLookupByLibrary.simpleMessage("Eigen waarde"),
    "createUserButton": MessageLookupByLibrary.simpleMessage(
      "Gebruiker aanmaken",
    ),
    "createUserDescription": MessageLookupByLibrary.simpleMessage(
      "Maak een account met e-mailadres en wachtwoord.",
    ),
    "createUserFailed": m22,
    "createUserTitle": MessageLookupByLibrary.simpleMessage(
      "Gebruiker aanmaken",
    ),
    "created": MessageLookupByLibrary.simpleMessage("Aangemaakt"),
    "croissant": MessageLookupByLibrary.simpleMessage("Croissant"),
    "cross": MessageLookupByLibrary.simpleMessage("Kruis"),
    "cube": MessageLookupByLibrary.simpleMessage("Kubus"),
    "cup": MessageLookupByLibrary.simpleMessage("Beker"),
    "currency": MessageLookupByLibrary.simpleMessage("Valuta"),
    "customDomainFailed": MessageLookupByLibrary.simpleMessage(
      "Het domein kon niet worden ingesteld. Probeer het opnieuw.",
    ),
    "customDomainHint": MessageLookupByLibrary.simpleMessage(
      "Het adres waar gasten naartoe gaan, bijv. www.jouwchalet.nl. Bij opslaan wordt ook de DNS geregeld.",
    ),
    "customDomainInvalid": MessageLookupByLibrary.simpleMessage(
      "Dat is geen geldige domeinnaam.",
    ),
    "customDomainSaved": m23,
    "customDomainTaken": MessageLookupByLibrary.simpleMessage(
      "Dat domein hoort al bij een andere website.",
    ),
    "customDomainZoneMissingMessage": m24,
    "customDomainZoneMissingTitle": m25,
    "cylinder": MessageLookupByLibrary.simpleMessage("Cilinder"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Donkere modus"),
    "dash": MessageLookupByLibrary.simpleMessage("Streepje"),
    "data": MessageLookupByLibrary.simpleMessage("Gegevens"),
    "dataCenter": MessageLookupByLibrary.simpleMessage("Datacenter"),
    "date": MessageLookupByLibrary.simpleMessage("Datum"),
    "dateRange": MessageLookupByLibrary.simpleMessage("Datumreeks"),
    "dayToday": MessageLookupByLibrary.simpleMessage("Vandaag"),
    "dayYesterday": MessageLookupByLibrary.simpleMessage("Gisteren"),
    "daylight": MessageLookupByLibrary.simpleMessage("Daglicht"),
    "deadline": MessageLookupByLibrary.simpleMessage("Deadline"),
    "decimalNumber": MessageLookupByLibrary.simpleMessage("Decimaal getal"),
    "defaultLabel": MessageLookupByLibrary.simpleMessage("Standaard"),
    "defaultTabLabel": MessageLookupByLibrary.simpleMessage("Standaard tab"),
    "delete": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "deleteEvent": MessageLookupByLibrary.simpleMessage(
      "Evenement verwijderen",
    ),
    "deleteUserConfirmation": m26,
    "deleteUserDescription": MessageLookupByLibrary.simpleMessage(
      "Verwijder account en toegang permanent.",
    ),
    "deleteUserTitle": MessageLookupByLibrary.simpleMessage(
      "Gebruiker verwijderen",
    ),
    "detailsLabel": MessageLookupByLibrary.simpleMessage("Details"),
    "development": MessageLookupByLibrary.simpleMessage("Ontwikkeling"),
    "developmentAccount": MessageLookupByLibrary.simpleMessage(
      "Development account",
    ),
    "diamond": MessageLookupByLibrary.simpleMessage("Diamant"),
    "direction": MessageLookupByLibrary.simpleMessage("Richting"),
    "directory": MessageLookupByLibrary.simpleMessage("Map"),
    "disability": MessageLookupByLibrary.simpleMessage("Beperking"),
    "disabledLabel": MessageLookupByLibrary.simpleMessage("Uitgeschakeld"),
    "dislike": MessageLookupByLibrary.simpleMessage("Niet leuk vinden"),
    "distance": MessageLookupByLibrary.simpleMessage("Afstand"),
    "divide": MessageLookupByLibrary.simpleMessage("Delen"),
    "document": MessageLookupByLibrary.simpleMessage("Document"),
    "dog": MessageLookupByLibrary.simpleMessage("Hond"),
    "dollar": MessageLookupByLibrary.simpleMessage("Dollar"),
    "dollarCoins": MessageLookupByLibrary.simpleMessage("Dollar munten"),
    "dontHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Nog geen account?",
    ),
    "dot": MessageLookupByLibrary.simpleMessage("Punt"),
    "dots": MessageLookupByLibrary.simpleMessage("Punten"),
    "download": MessageLookupByLibrary.simpleMessage("Downloaden"),
    "drag": MessageLookupByLibrary.simpleMessage("Slepen"),
    "dress": MessageLookupByLibrary.simpleMessage("Jurk"),
    "drinks": MessageLookupByLibrary.simpleMessage("Drankjes"),
    "duration": MessageLookupByLibrary.simpleMessage("Duur"),
    "edit": MessageLookupByLibrary.simpleMessage("Bewerken"),
    "editDetailsAction": MessageLookupByLibrary.simpleMessage(
      "Gegevens wijzigen",
    ),
    "editDetailsDescription": MessageLookupByLibrary.simpleMessage(
      "Pas e-mailadres of gebruikersnaam aan.",
    ),
    "editUserDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Wijzig gebruikersgegevens",
    ),
    "eggplant": MessageLookupByLibrary.simpleMessage("Aubergine"),
    "eggs": MessageLookupByLibrary.simpleMessage("Eieren"),
    "elevator": MessageLookupByLibrary.simpleMessage("Lift"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailInvalid": MessageLookupByLibrary.simpleMessage(
      "Geen geldig e-mailadres.",
    ),
    "emailLabel": MessageLookupByLibrary.simpleMessage("E-mailadres"),
    "emailNotConfirmed": MessageLookupByLibrary.simpleMessage(
      "Bevestig je e-mailadres.",
    ),
    "emailRequired": MessageLookupByLibrary.simpleMessage(
      "Voer een e-mailadres in.",
    ),
    "emailUserOnCreateDescription": MessageLookupByLibrary.simpleMessage(
      "Automatisch een welkomstmail sturen na registratie.",
    ),
    "emailUserOnCreateTitle": MessageLookupByLibrary.simpleMessage(
      "Stuur e-mail bij nieuwe gebruiker",
    ),
    "empty": MessageLookupByLibrary.simpleMessage("Leeg"),
    "enabledLabel": MessageLookupByLibrary.simpleMessage("Ingeschakeld"),
    "enterAValidCode": MessageLookupByLibrary.simpleMessage(
      "Voer een geldige code in",
    ),
    "enterAValidEmail": MessageLookupByLibrary.simpleMessage(
      "Voer een geldig e-mailadres in",
    ),
    "enterMin6Characters": MessageLookupByLibrary.simpleMessage(
      "Voer minimaal 6 karakters in",
    ),
    "enterMinCharacters": m27,
    "enterValidEmail": MessageLookupByLibrary.simpleMessage(
      "Voer een geldig email-adres in",
    ),
    "enterVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Voer verificatiecode in",
    ),
    "enterprise": MessageLookupByLibrary.simpleMessage("Onderneming"),
    "envelop": MessageLookupByLibrary.simpleMessage("Envelop"),
    "error": MessageLookupByLibrary.simpleMessage("Fout"),
    "errorDialogDismiss": MessageLookupByLibrary.simpleMessage("Sluiten"),
    "errorDialogTitle": MessageLookupByLibrary.simpleMessage("Fout"),
    "errorEmailNotConfirmed": MessageLookupByLibrary.simpleMessage(
      "Je e-mailadres is nog niet bevestigd.",
    ),
    "errorEmailSendFailedGeneric": MessageLookupByLibrary.simpleMessage(
      "We konden de e-mail niet versturen. Probeer het later opnieuw.",
    ),
    "errorGeneric": MessageLookupByLibrary.simpleMessage(
      "Er is iets misgegaan. Probeer het opnieuw.",
    ),
    "errorInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Onjuiste e-mail of wachtwoord.",
    ),
    "errorLoginOtpEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We konden de e-mail met inlogcode niet versturen. Probeer het later opnieuw.",
    ),
    "errorPasswordResetEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We konden de e-mail om je wachtwoord te herstellen niet versturen. Probeer het later opnieuw.",
    ),
    "errorRateLimited": MessageLookupByLibrary.simpleMessage(
      "Te veel pogingen. Probeer het later opnieuw.",
    ),
    "errorSavingItem": MessageLookupByLibrary.simpleMessage(
      "Fout bij opslaan van item.",
    ),
    "errorSignUpConfirmationEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We konden de bevestigingsmail niet versturen. Probeer het later opnieuw.",
    ),
    "errorTextDataFetchFailed": MessageLookupByLibrary.simpleMessage(
      "Data kon niet worden opgehaald",
    ),
    "errorTextIncorrectUsernameOrPassword":
        MessageLookupByLibrary.simpleMessage(
          "Onjuiste gebruikersnaam of wachtwoord.",
        ),
    "errorTextInvalidEmailFormat": MessageLookupByLibrary.simpleMessage(
      "Ongeldig e-mailadres formaat.",
    ),
    "errorTextInvalidVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Ongeldige verificatiecode opgegeven, probeer het opnieuw.",
    ),
    "errorTextServerError": MessageLookupByLibrary.simpleMessage(
      "Helaas is er een probleem met de server. Probeer het later opnieuw.",
    ),
    "errorTextUsernameExists": MessageLookupByLibrary.simpleMessage(
      "Er bestaat al een gebruiker met dit e-mailadres.",
    ),
    "errorTitle": MessageLookupByLibrary.simpleMessage("Fout"),
    "errorUserCreatedEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We konden de welkomstmail niet versturen. Probeer het later opnieuw.",
    ),
    "event": MessageLookupByLibrary.simpleMessage("Evenement"),
    "eventPlanner": MessageLookupByLibrary.simpleMessage("Evenementplanner"),
    "events": MessageLookupByLibrary.simpleMessage("Evenementen"),
    "exclamation": MessageLookupByLibrary.simpleMessage("Uitroepteken"),
    "expenses": MessageLookupByLibrary.simpleMessage("Uitgaven"),
    "expiration": MessageLookupByLibrary.simpleMessage("Vervaldatum"),
    "expirationRemindersLabel": MessageLookupByLibrary.simpleMessage(
      "Vervaldatum waarschuwingen",
    ),
    "expired": MessageLookupByLibrary.simpleMessage("Verlopen"),
    "expiry": MessageLookupByLibrary.simpleMessage("Vervaldatum"),
    "exportButton": MessageLookupByLibrary.simpleMessage("Exporteer"),
    "exportColumnsTitle": MessageLookupByLibrary.simpleMessage("Kolommen"),
    "exportLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Taal voor exports",
    ),
    "exportLanguageTitle": MessageLookupByLibrary.simpleMessage("Exporttaal"),
    "exportPdfOrientationLandscape": MessageLookupByLibrary.simpleMessage(
      "Liggend",
    ),
    "exportPdfOrientationPortrait": MessageLookupByLibrary.simpleMessage(
      "Staand",
    ),
    "exportPdfOrientationTitle": MessageLookupByLibrary.simpleMessage(
      "PDF-oriëntatie",
    ),
    "exportSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Exportinstellingen",
    ),
    "failed": MessageLookupByLibrary.simpleMessage("Mislukt"),
    "failedToDeleteImage": MessageLookupByLibrary.simpleMessage(
      "Kan afbeelding niet verwijderen.",
    ),
    "failedToLoadUser": MessageLookupByLibrary.simpleMessage(
      "Kan gebruikersgegevens niet ophalen. Neem contact op met de ontwikkelaar.",
    ),
    "failedToUploadImage": MessageLookupByLibrary.simpleMessage(
      "Afbeelding uploaden mislukt.",
    ),
    "fashion": MessageLookupByLibrary.simpleMessage("Mode"),
    "fastTime": MessageLookupByLibrary.simpleMessage("Snelle tijd"),
    "father": MessageLookupByLibrary.simpleMessage("Vader"),
    "favorite": MessageLookupByLibrary.simpleMessage("Favoriet"),
    "fieldIsLinkedTo": m28,
    "fieldsActionsLabel": MessageLookupByLibrary.simpleMessage("Acties"),
    "fieldsAllPropertiesHelper": MessageLookupByLibrary.simpleMessage(
      "Wijzigingen worden direct toegepast. Gebruik JSON-notatie voor complexe waarden of open de JSON-tab voor geavanceerde bewerkingen.",
    ),
    "fieldsAllPropertiesSection": MessageLookupByLibrary.simpleMessage(
      "Alle eigenschappen",
    ),
    "fieldsApply": MessageLookupByLibrary.simpleMessage("Toepassen"),
    "fieldsColumnFieldType": MessageLookupByLibrary.simpleMessage("Veldtype"),
    "fieldsColumnName": MessageLookupByLibrary.simpleMessage("Weergavenaam"),
    "fieldsColumnProperties": MessageLookupByLibrary.simpleMessage(
      "Properties",
    ),
    "fieldsColumnSubtype": MessageLookupByLibrary.simpleMessage("Veldsubtype"),
    "fieldsDefaultsTab": MessageLookupByLibrary.simpleMessage(
      "Standaardwaarden",
    ),
    "fieldsEditNames": MessageLookupByLibrary.simpleMessage("Namen bewerken"),
    "fieldsEditProperties": MessageLookupByLibrary.simpleMessage(
      "Eigenschappen bewerken",
    ),
    "fieldsEmptyState": MessageLookupByLibrary.simpleMessage(
      "Geen velddefinities beschikbaar.",
    ),
    "fieldsInvalidJson": MessageLookupByLibrary.simpleMessage(
      "Voer geldige JSON in (alleen objecten).",
    ),
    "fieldsInvalidJsonValue": MessageLookupByLibrary.simpleMessage(
      "Voer een geldige JSON-waarde in.",
    ),
    "fieldsInvalidNumber": MessageLookupByLibrary.simpleMessage(
      "Voer een geldig getal in.",
    ),
    "fieldsLabel": MessageLookupByLibrary.simpleMessage("Veldstandaardwaarden"),
    "fieldsNamesDialogHelper": MessageLookupByLibrary.simpleMessage(
      "Werk hieronder de vertaalde namen bij. Laat een veld leeg om terug te vallen op de standaardwaarde.",
    ),
    "fieldsNamesDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Bewerk vertalingen",
    ),
    "fieldsNamesSaved": MessageLookupByLibrary.simpleMessage(
      "Namen bijgewerkt.",
    ),
    "fieldsNoProperties": MessageLookupByLibrary.simpleMessage(
      "Er zijn geen aanpasbare eigenschappen voor dit veldtype.",
    ),
    "fieldsPropertiesDialogHelper": MessageLookupByLibrary.simpleMessage(
      "Gebruik de tabs om de eigenschappen via het formulier of met JSON aan te passen. Wijzigingen worden direct toegepast na het opslaan.",
    ),
    "fieldsPropertiesDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Eigenschappen bewerken",
    ),
    "fieldsPropertiesFormUnavailable": MessageLookupByLibrary.simpleMessage(
      "Voor dit veldtype is nog geen visuele editor beschikbaar. Gebruik de JSON-tab.",
    ),
    "fieldsPropertiesSaved": MessageLookupByLibrary.simpleMessage(
      "Properties bijgewerkt.",
    ),
    "fieldsPropertiesTabForm": MessageLookupByLibrary.simpleMessage(
      "Formulier",
    ),
    "fieldsPropertiesTabJson": MessageLookupByLibrary.simpleMessage("JSON"),
    "fieldsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Beheer de standaardwaarden voor alle veldtypes en veldsubtypes. Wanneer een nieuwe lijst wordt aangemaakt, worden deze waardes gekopieerd en kun je ze daarna per lijst aanpassen. Wijzigingen die je hier opslaat gelden voor nieuwe lijsten; bestaande lijsten behouden hun eigen instellingen.",
    ),
    "fieldsSubtypesSection": MessageLookupByLibrary.simpleMessage(
      "Veldsubtypes",
    ),
    "fieldsTitle": MessageLookupByLibrary.simpleMessage("Veldstandaardwaarden"),
    "fieldsTranslationLabel": m29,
    "fieldsTranslationsDescription": MessageLookupByLibrary.simpleMessage(
      "Stel de weergavenaam voor deze velddefinitie per taal in.",
    ),
    "fieldsTranslationsTab": MessageLookupByLibrary.simpleMessage(
      "Vertalingen",
    ),
    "fieldsTypesSection": MessageLookupByLibrary.simpleMessage("Veldtypes"),
    "fieldsUnsavedJsonWarningMessage": MessageLookupByLibrary.simpleMessage(
      "Je hebt JSON-aanpassingen die nog niet gevalideerd of toegepast zijn. Blijf op de JSON-tab om ze op te slaan of ga verder naar de editor en laat ze vallen.",
    ),
    "fieldsUnsavedJsonWarningTitle": MessageLookupByLibrary.simpleMessage(
      "JSON-wijzigingen wachten",
    ),
    "fieldsUseTypeDefaultsDescription": MessageLookupByLibrary.simpleMessage(
      "Houd dit subtype in sync met de standaardinstellingen van het veldtype. Schakel dit uit om de properties zelf aan te passen.",
    ),
    "fieldsUseTypeDefaultsLabel": MessageLookupByLibrary.simpleMessage(
      "Gebruik veldtype-standaardwaarden",
    ),
    "fieldsUsingTypeDefaults": MessageLookupByLibrary.simpleMessage(
      "Gebruikt veldtype-standaardwaarden",
    ),
    "fieldsUsingTypeDefaultsBody": MessageLookupByLibrary.simpleMessage(
      "Dit subtype gebruikt de standaardwaarden van het veldtype. Zet de schakelaar hierboven uit om eigen properties te beheren.",
    ),
    "fieldsValidateAndApply": MessageLookupByLibrary.simpleMessage(
      "Valideer en toepassen",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Bestand"),
    "files": MessageLookupByLibrary.simpleMessage("Bestanden"),
    "finance": MessageLookupByLibrary.simpleMessage("Financiën"),
    "fish": MessageLookupByLibrary.simpleMessage("Vis"),
    "fix": MessageLookupByLibrary.simpleMessage("Fixen"),
    "flag": MessageLookupByLibrary.simpleMessage("Vlag"),
    "flowers": MessageLookupByLibrary.simpleMessage("Bloemen"),
    "folder": MessageLookupByLibrary.simpleMessage("Map"),
    "folders": MessageLookupByLibrary.simpleMessage("Mappen"),
    "fontColors": MessageLookupByLibrary.simpleMessage("Tekstkleuren"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Lettergrootte"),
    "food": MessageLookupByLibrary.simpleMessage("Eten"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord vergeten?",
    ),
    "forkAndKnife": MessageLookupByLibrary.simpleMessage("Vork en mes"),
    "form": MessageLookupByLibrary.simpleMessage("Formulier"),
    "fries": MessageLookupByLibrary.simpleMessage("Friet"),
    "frozen": MessageLookupByLibrary.simpleMessage("Bevroren"),
    "frozenFries": MessageLookupByLibrary.simpleMessage("Bevroren friet"),
    "fryingPan": MessageLookupByLibrary.simpleMessage("Koekenpan"),
    "gallery": MessageLookupByLibrary.simpleMessage("Galerij"),
    "garbage": MessageLookupByLibrary.simpleMessage("Afval"),
    "garden": MessageLookupByLibrary.simpleMessage("Tuin"),
    "generalSectionTitle": MessageLookupByLibrary.simpleMessage("Algemeen"),
    "glasses": MessageLookupByLibrary.simpleMessage("Brillen"),
    "globe": MessageLookupByLibrary.simpleMessage("Wereldbol"),
    "golf": MessageLookupByLibrary.simpleMessage("Golf"),
    "gravyBoat": MessageLookupByLibrary.simpleMessage("Jus"),
    "heart": MessageLookupByLibrary.simpleMessage("Hart"),
    "height": MessageLookupByLibrary.simpleMessage("Hoogte"),
    "hide": MessageLookupByLibrary.simpleMessage("Verbergen"),
    "hideErrorDetails": MessageLookupByLibrary.simpleMessage("Verberg details"),
    "hideInput": MessageLookupByLibrary.simpleMessage("Invoer verbergen"),
    "hideKeyboard": MessageLookupByLibrary.simpleMessage(
      "Toetsenbord verbergen",
    ),
    "holiday": MessageLookupByLibrary.simpleMessage("Vakantie"),
    "home": MessageLookupByLibrary.simpleMessage("Thuis"),
    "hot": MessageLookupByLibrary.simpleMessage("Heet"),
    "hour": MessageLookupByLibrary.simpleMessage("Uur"),
    "house": MessageLookupByLibrary.simpleMessage("Huis"),
    "human": MessageLookupByLibrary.simpleMessage("Mens"),
    "iceCream": MessageLookupByLibrary.simpleMessage("IJs"),
    "icon": MessageLookupByLibrary.simpleMessage("Pictogram"),
    "inboxArchive": MessageLookupByLibrary.simpleMessage("Archiveren"),
    "inboxEmptyAll": MessageLookupByLibrary.simpleMessage(
      "Nog geen gastberichten voor deze selectie.",
    ),
    "inboxEmptyAllHint": MessageLookupByLibrary.simpleMessage(
      "Zodra een gast reageert op een boeking of aanvraag, staat het gesprek hier.",
    ),
    "inboxEmptyConversation": MessageLookupByLibrary.simpleMessage(
      "Dit gesprek heeft nog geen berichten.",
    ),
    "inboxEmptyFiltered": MessageLookupByLibrary.simpleMessage(
      "Geen gesprekken in deze weergave.",
    ),
    "inboxEmptyFilteredHint": MessageLookupByLibrary.simpleMessage(
      "Pas het filter of de zoekopdracht aan.",
    ),
    "inboxFilterAction": MessageLookupByLibrary.simpleMessage("Actie"),
    "inboxFilterAll": MessageLookupByLibrary.simpleMessage("Alles"),
    "inboxFilterUnread": MessageLookupByLibrary.simpleMessage("Ongelezen"),
    "inboxGuestLanguage": MessageLookupByLibrary.simpleMessage("Taal"),
    "inboxLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Kon de gesprekken niet ophalen",
    ),
    "inboxLoadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "De inbox toont geen gesprekken zolang de bron niet reageert.",
    ),
    "inboxLocalStateNote": m30,
    "inboxMessageNotSent": MessageLookupByLibrary.simpleMessage(
      "Niet verzonden",
    ),
    "inboxNoReservation": MessageLookupByLibrary.simpleMessage(
      "Dit gesprek hangt niet aan een boeking.",
    ),
    "inboxOpenBooking": MessageLookupByLibrary.simpleMessage("Open boeking"),
    "inboxOpenInSource": m31,
    "inboxPreviouslyBooked": MessageLookupByLibrary.simpleMessage(
      "Eerder geboekt",
    ),
    "inboxPreviouslyBookedValue": m32,
    "inboxQuickRepliesLabel": MessageLookupByLibrary.simpleMessage(
      "Snelle antwoorden",
    ),
    "inboxQuickReplyAvailability": MessageLookupByLibrary.simpleMessage(
      "Die datum is nog vrij. Zal ik hem voor je vasthouden?",
    ),
    "inboxQuickReplyCheckIn": MessageLookupByLibrary.simpleMessage(
      "Check-in kan vanaf 16.00 uur. Eerder aankomen kan meestal wel — laat het even weten.",
    ),
    "inboxQuickReplyDirections": MessageLookupByLibrary.simpleMessage(
      "Een paar dagen voor aankomst stuur ik je de routebeschrijving en de sleutelcode.",
    ),
    "inboxQuickReplyThanks": MessageLookupByLibrary.simpleMessage(
      "Dank je voor je bericht. Ik kom er zo snel mogelijk op terug.",
    ),
    "inboxReplyHint": m33,
    "inboxReplyVia": m34,
    "inboxReservationHeader": MessageLookupByLibrary.simpleMessage(
      "Reservering",
    ),
    "inboxResponseTimeNote": MessageLookupByLibrary.simpleMessage(
      "Airbnb rekent de reactietijd mee in je ranking. Dit gesprek wacht nog op jou.",
    ),
    "inboxRetry": MessageLookupByLibrary.simpleMessage("Opnieuw"),
    "inboxSearchHint": MessageLookupByLibrary.simpleMessage(
      "Zoek op gast of bericht",
    ),
    "inboxSend": MessageLookupByLibrary.simpleMessage("Versturen"),
    "inboxSendFailed": MessageLookupByLibrary.simpleMessage(
      "Bericht niet verzonden.",
    ),
    "inboxSendUnsupported": m35,
    "inboxShowOriginal": MessageLookupByLibrary.simpleMessage(
      "Origineel tonen",
    ),
    "inboxSnooze": MessageLookupByLibrary.simpleMessage("Sluimeren"),
    "inboxSnoozeNextWeek": MessageLookupByLibrary.simpleMessage(
      "Tot volgende week",
    ),
    "inboxSnoozeTomorrow": MessageLookupByLibrary.simpleMessage("Tot morgen"),
    "inboxSnoozeWake": MessageLookupByLibrary.simpleMessage("Nu wakker maken"),
    "inboxSnoozedUntil": m36,
    "inboxSyncFailed": MessageLookupByLibrary.simpleMessage(
      "Kon de berichten niet verversen — je ziet nog de vorige stand.",
    ),
    "inboxTagAnswered": MessageLookupByLibrary.simpleMessage("Beantwoord"),
    "inboxTagAwaiting": MessageLookupByLibrary.simpleMessage("Antwoord nodig"),
    "inboxThreadSubtitle": m37,
    "inboxThreadSubtitleNoStay": m38,
    "inboxTitle": MessageLookupByLibrary.simpleMessage("Berichten"),
    "inboxTotal": MessageLookupByLibrary.simpleMessage("Totaal"),
    "inboxTranslate": m39,
    "inboxUnreadTooltip": m40,
    "indicator": MessageLookupByLibrary.simpleMessage("Indicator"),
    "ingredients": MessageLookupByLibrary.simpleMessage("Ingrediënten"),
    "insect": MessageLookupByLibrary.simpleMessage("Insect"),
    "interfaceLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "De taal waarin de HostHub-console wordt getoond. Persoonlijk voor jou.",
    ),
    "interfaceLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Interfacetaal",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "invalidMaxItems": MessageLookupByLibrary.simpleMessage(
      "Voer een geldig aantal items in.",
    ),
    "invalidMaxLists": MessageLookupByLibrary.simpleMessage(
      "Voer een geldig aantal lijsten in.",
    ),
    "invalidUrl": MessageLookupByLibrary.simpleMessage("Ongeldige URL"),
    "inventory": MessageLookupByLibrary.simpleMessage("Voorraad"),
    "invitation": MessageLookupByLibrary.simpleMessage("Uitnodiging"),
    "iron": MessageLookupByLibrary.simpleMessage("Strijkijzer"),
    "island": MessageLookupByLibrary.simpleMessage("Eiland"),
    "itinerary": MessageLookupByLibrary.simpleMessage("Reisplan"),
    "jacket": MessageLookupByLibrary.simpleMessage("Jas"),
    "jar": MessageLookupByLibrary.simpleMessage("Pot"),
    "kanbanBoard": MessageLookupByLibrary.simpleMessage("Kanban-bord"),
    "kettle": MessageLookupByLibrary.simpleMessage("Waterkoker"),
    "kitten": MessageLookupByLibrary.simpleMessage("Kitten"),
    "label": MessageLookupByLibrary.simpleMessage("Label"),
    "lamp": MessageLookupByLibrary.simpleMessage("Lamp"),
    "languagePreferenceDescription": MessageLookupByLibrary.simpleMessage(
      "Taal wijzigen",
    ),
    "languagePreferenceTitle": MessageLookupByLibrary.simpleMessage("Taal"),
    "left": MessageLookupByLibrary.simpleMessage("Links"),
    "leftAlignment": MessageLookupByLibrary.simpleMessage("Links uitlijnen"),
    "legalSectionFooter": MessageLookupByLibrary.simpleMessage(
      "De privacyverklaring staat op je website onder /privacy en wordt met de rest van je content gepubliceerd.",
    ),
    "legalSectionTitle": MessageLookupByLibrary.simpleMessage("Juridisch"),
    "legalSectionWarning": MessageLookupByLibrary.simpleMessage(
      "Dit is een juridische tekst. Pas hem alleen aan als je weet wat er moet staan — laat het bij twijfel controleren.",
    ),
    "letter": MessageLookupByLibrary.simpleMessage("Letter"),
    "letters": MessageLookupByLibrary.simpleMessage("Letters"),
    "library": MessageLookupByLibrary.simpleMessage("Bibliotheek"),
    "light": MessageLookupByLibrary.simpleMessage("Licht"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Lichte modus"),
    "like": MessageLookupByLibrary.simpleMessage("Vind ik leuk"),
    "lineHeight": MessageLookupByLibrary.simpleMessage("Regelhoogte"),
    "list": MessageLookupByLibrary.simpleMessage("Lijst"),
    "listRoleLabel": m41,
    "listSinceDate": m42,
    "listsAddItemMethodsLabel": MessageLookupByLibrary.simpleMessage(
      "Manieren om items toe te voegen",
    ),
    "listsAnalyzerCopied": MessageLookupByLibrary.simpleMessage(
      "Analyzer gekopieerd",
    ),
    "listsAnalyzerDescription": MessageLookupByLibrary.simpleMessage(
      "Gecombineerde analyzer van alle lijstvelden.",
    ),
    "listsAnalyzerIncludeInternalFieldsLabel":
        MessageLookupByLibrary.simpleMessage("Toon interne velden"),
    "listsAnalyzerTab": MessageLookupByLibrary.simpleMessage("Analyzer"),
    "listsBehaviorSection": MessageLookupByLibrary.simpleMessage("Gedrag"),
    "listsCenterFieldsLabel": MessageLookupByLibrary.simpleMessage(
      "Velden centreren in lijstweergave",
    ),
    "listsColumnFields": MessageLookupByLibrary.simpleMessage("Velden"),
    "listsColumnKey": MessageLookupByLibrary.simpleMessage("Sleutel"),
    "listsColumnName": MessageLookupByLibrary.simpleMessage("Lijst"),
    "listsColumnSamples": MessageLookupByLibrary.simpleMessage("Sample-items"),
    "listsColumnStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "listsDataSection": MessageLookupByLibrary.simpleMessage("Data"),
    "listsDemoItemsAddButton": MessageLookupByLibrary.simpleMessage(
      "Demo-item toevoegen",
    ),
    "listsDemoItemsCreateFailureToast": MessageLookupByLibrary.simpleMessage(
      "Kon demo-item niet aanmaken",
    ),
    "listsDemoItemsDeleteButton": MessageLookupByLibrary.simpleMessage(
      "Item verwijderen",
    ),
    "listsDemoItemsDeleteConfirmation": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je dit demo-item wilt verwijderen?",
    ),
    "listsDemoItemsDeleteFailureToast": MessageLookupByLibrary.simpleMessage(
      "Kon demo-item niet verwijderen",
    ),
    "listsDemoItemsDeletedToast": MessageLookupByLibrary.simpleMessage(
      "Demo-item verwijderd",
    ),
    "listsDemoItemsDescription": MessageLookupByLibrary.simpleMessage(
      "Stel de demo-items in die in de previews en nieuwe lijsten verschijnen.",
    ),
    "listsDemoItemsDevLabel": MessageLookupByLibrary.simpleMessage(
      "Alleen dev",
    ),
    "listsDemoItemsFlagsSummaryNone": MessageLookupByLibrary.simpleMessage(
      "Geen context geselecteerd",
    ),
    "listsDemoItemsFlagsTitle": MessageLookupByLibrary.simpleMessage(
      "Demo-contexten",
    ),
    "listsDemoItemsInvalidJsonError": MessageLookupByLibrary.simpleMessage(
      "Ongeldige JSON-payload",
    ),
    "listsDemoItemsJsonDescription": MessageLookupByLibrary.simpleMessage(
      "Laat de demo-itempayloads zien die de previewlijst aandrijven.",
    ),
    "listsDemoItemsLoadFailureToast": MessageLookupByLibrary.simpleMessage(
      "Kon demo-items niet laden",
    ),
    "listsDemoItemsMoveDownTooltip": MessageLookupByLibrary.simpleMessage(
      "Naar beneden",
    ),
    "listsDemoItemsMoveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Kon demo-items niet herordenen",
    ),
    "listsDemoItemsMoveUpTooltip": MessageLookupByLibrary.simpleMessage(
      "Naar boven",
    ),
    "listsDemoItemsNewListLabel": MessageLookupByLibrary.simpleMessage(
      "Nieuw lijst-item",
    ),
    "listsDemoItemsNoItems": MessageLookupByLibrary.simpleMessage(
      "Nog geen demo-items.",
    ),
    "listsDemoItemsOrderLabel": MessageLookupByLibrary.simpleMessage(
      "Volgorde",
    ),
    "listsDemoItemsPreviewLabel": MessageLookupByLibrary.simpleMessage(
      "Preview-item",
    ),
    "listsDemoItemsSaveButton": MessageLookupByLibrary.simpleMessage(
      "Item opslaan",
    ),
    "listsDemoItemsSaveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Kon demo-item niet opslaan",
    ),
    "listsDemoItemsSavedToast": MessageLookupByLibrary.simpleMessage(
      "Demo-item opgeslagen",
    ),
    "listsDemoItemsTab": MessageLookupByLibrary.simpleMessage("Demo-items"),
    "listsDemoItemsTileLabel": MessageLookupByLibrary.simpleMessage(
      "Tegelvoorbeeld",
    ),
    "listsDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Template-instellingen",
    ),
    "listsEditTemplateTitle": m43,
    "listsEmptyState": MessageLookupByLibrary.simpleMessage(
      "Geen lijsttemplates beschikbaar.",
    ),
    "listsFieldNameLabel": m44,
    "listsFieldNamesLabel": MessageLookupByLibrary.simpleMessage("Veldnamen"),
    "listsFieldsLabel": MessageLookupByLibrary.simpleMessage("Velden"),
    "listsFieldsValue": m45,
    "listsGroupByLabel": MessageLookupByLibrary.simpleMessage("Groeperen op"),
    "listsGroupByNone": MessageLookupByLibrary.simpleMessage("Geen groepering"),
    "listsItemHistoryLabel": MessageLookupByLibrary.simpleMessage(
      "Itemhistorie",
    ),
    "listsItemTapLabel": MessageLookupByLibrary.simpleMessage(
      "Gedrag bij tikken",
    ),
    "listsJsonCopied": MessageLookupByLibrary.simpleMessage("JSON gekopieerd"),
    "listsJsonDefaultPathLabel": m46,
    "listsJsonDownloadLabel": MessageLookupByLibrary.simpleMessage(
      "JSON downloaden",
    ),
    "listsJsonSaveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Kan JSON niet opslaan",
    ),
    "listsJsonSaveLabel": MessageLookupByLibrary.simpleMessage("JSON opslaan"),
    "listsJsonSavedToast": m47,
    "listsJsonTab": MessageLookupByLibrary.simpleMessage("JSON-export"),
    "listsLabel": MessageLookupByLibrary.simpleMessage("Lijsttemplates"),
    "listsLayoutTab": MessageLookupByLibrary.simpleMessage("Layout"),
    "listsLocaleLabel": m48,
    "listsLocaleListName": m49,
    "listsLocaleListNamePlural": m50,
    "listsNoFieldsForLocale": MessageLookupByLibrary.simpleMessage(
      "Geen velden voor deze taal.",
    ),
    "listsNoSelection": MessageLookupByLibrary.simpleMessage(
      "Selecteer een template om de instellingen te bekijken.",
    ),
    "listsOverviewSection": MessageLookupByLibrary.simpleMessage("Overzicht"),
    "listsSamplesLabel": MessageLookupByLibrary.simpleMessage("Sample-items"),
    "listsSamplesSingle": m51,
    "listsSamplesSplit": m52,
    "listsSchemeLabel": MessageLookupByLibrary.simpleMessage("Kleurschema"),
    "listsStatusActive": MessageLookupByLibrary.simpleMessage("Actief"),
    "listsStatusBeta": MessageLookupByLibrary.simpleMessage("Beta"),
    "listsStatusDemo": MessageLookupByLibrary.simpleMessage("Demo-data"),
    "listsStatusDev": MessageLookupByLibrary.simpleMessage("Alleen dev"),
    "listsStatusHidden": MessageLookupByLibrary.simpleMessage("Verborgen"),
    "listsStyleLabel": MessageLookupByLibrary.simpleMessage("Stijl"),
    "listsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Bekijk alle lijsttemplates met beschikbaarheid, dev-status en sample-data.",
    ),
    "listsTemplateDeletedToast": MessageLookupByLibrary.simpleMessage(
      "Lijsttemplate verwijderd",
    ),
    "listsTemplateJsonDescription": MessageLookupByLibrary.simpleMessage(
      "Bekijk de opgeschoonde lijsttemplate-JSON die je opnieuw kunt gebruiken voor seeds.",
    ),
    "listsTemplateJsonTab": MessageLookupByLibrary.simpleMessage("Template"),
    "listsTemplatesLabel": MessageLookupByLibrary.simpleMessage("Templates"),
    "listsTileDemoRelativeDatesDescription": MessageLookupByLibrary.simpleMessage(
      "Toon interne tijdstempels ten opzichte van het huidige tijdstip wanneer je het tegelvoorbeeld bekijkt.",
    ),
    "listsTileDemoRelativeDatesLabel": MessageLookupByLibrary.simpleMessage(
      "Gebruik relatieve tegel-data",
    ),
    "listsTitle": MessageLookupByLibrary.simpleMessage("Lijsttemplates"),
    "listsTranslationsDescription": MessageLookupByLibrary.simpleMessage(
      "Beheer de lijstnaam en veldnamen voor alle ondersteunde talen.",
    ),
    "listsTranslationsTab": MessageLookupByLibrary.simpleMessage("Vertalingen"),
    "listsUnknownTemplate": MessageLookupByLibrary.simpleMessage(
      "Deze template is niet gevonden.",
    ),
    "listsViewLabel": MessageLookupByLibrary.simpleMessage("Standaardweergave"),
    "loadUserFailed": m53,
    "loadUserFailedMessage": MessageLookupByLibrary.simpleMessage(
      "Kon gebruiker niet laden.",
    ),
    "loadUsersFailed": m54,
    "location": MessageLookupByLibrary.simpleMessage("Locatie"),
    "locationNotFoundAlertMessage": MessageLookupByLibrary.simpleMessage(
      "Controleer het adres om automatische afstandsberekening mogelijk te maken, of voer de afstand handmatig in.",
    ),
    "locationNotFoundAlertTitle": MessageLookupByLibrary.simpleMessage(
      "Locatie niet gevonden",
    ),
    "lodgifyApiKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Gebruik de API-key van Lodgify om te koppelen.",
    ),
    "lodgifyApiKeyLabel": MessageLookupByLibrary.simpleMessage("API-key"),
    "lodgifyApiKeyRemoveMessage": MessageLookupByLibrary.simpleMessage(
      "De koppeling met Lodgify stopt. Je properties en hun website-content blijven staan.",
    ),
    "lodgifyApiKeyRemoveTitle": MessageLookupByLibrary.simpleMessage(
      "API-key verwijderen?",
    ),
    "lodgifyApiKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Voer een API-key in om te koppelen.",
    ),
    "lodgifyConnectErrorDescription": MessageLookupByLibrary.simpleMessage(
      "Controleer de API-key en probeer opnieuw. Zorg dat de API-key toegang heeft tot Lodgify.",
    ),
    "lodgifyConnectErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Koppelen met Lodgify mislukt",
    ),
    "lodgifyConnectSuccess": MessageLookupByLibrary.simpleMessage(
      "Lodgify gekoppeld.",
    ),
    "lodgifyLastSyncLabel": m55,
    "lodgifyNoNewPropertiesFound": MessageLookupByLibrary.simpleMessage(
      "Geen nieuwe Lodgify properties gevonden.",
    ),
    "lodgifySyncAddAction": MessageLookupByLibrary.simpleMessage("Toevoegen"),
    "lodgifySyncAddAndLinkAction": MessageLookupByLibrary.simpleMessage(
      "Toevoegen en koppelen",
    ),
    "lodgifySyncApplied": m56,
    "lodgifySyncGoToProperties": MessageLookupByLibrary.simpleMessage(
      "Naar Properties",
    ),
    "lodgifySyncLabel": MessageLookupByLibrary.simpleMessage("Synchroniseren"),
    "lodgifySyncLinkAction": MessageLookupByLibrary.simpleMessage("Koppelen"),
    "lodgifySyncLinkSubtitle": m57,
    "lodgifySyncOutcomeLink": m58,
    "lodgifySyncOutcomeNew": m59,
    "lodgifySyncResultTitle": MessageLookupByLibrary.simpleMessage(
      "Wat Lodgify heeft",
    ),
    "lodgifySyncStateLink": MessageLookupByLibrary.simpleMessage("Koppelen"),
    "lodgifySyncStateLinked": MessageLookupByLibrary.simpleMessage(
      "Al gekoppeld",
    ),
    "lodgifySyncStateNew": MessageLookupByLibrary.simpleMessage("Nieuw"),
    "lodgifyTitle": MessageLookupByLibrary.simpleMessage("Lodgify"),
    "login": MessageLookupByLibrary.simpleMessage("Inloggen"),
    "loginDescription": MessageLookupByLibrary.simpleMessage(
      "Log in met je account.",
    ),
    "loginFailed": MessageLookupByLibrary.simpleMessage("Inloggen niet gelukt"),
    "loginFailedCheckDetails": MessageLookupByLibrary.simpleMessage(
      "Inloggen mislukt. Controleer je gegevens.",
    ),
    "loginFailedWithReason": m60,
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Inloggen met Google",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Afmelden"),
    "logoutLabel": MessageLookupByLibrary.simpleMessage("Uitloggen"),
    "longTime": MessageLookupByLibrary.simpleMessage("Lange tijd"),
    "love": MessageLookupByLibrary.simpleMessage("Liefde"),
    "loyaltyCard": MessageLookupByLibrary.simpleMessage("Loyaliteitskaart"),
    "magicLinkSentDescription": m61,
    "magicLinkSentDescriptionFallback": MessageLookupByLibrary.simpleMessage(
      "We hebben een magic link gestuurd. Controleer je inbox en spamfolder.",
    ),
    "magicLinkSentTitle": MessageLookupByLibrary.simpleMessage(
      "Controleer je e-mail",
    ),
    "magicLinkSubtitle": MessageLookupByLibrary.simpleMessage(
      "Voer je e-mailadres in en we sturen je een magic link om in te loggen.",
    ),
    "mail": MessageLookupByLibrary.simpleMessage("E-mail"),
    "maintenance": MessageLookupByLibrary.simpleMessage("Onderhoud"),
    "maintenanceModeDescription": MessageLookupByLibrary.simpleMessage(
      "Toont een onderhoudsbericht in alle apps.",
    ),
    "maintenanceModeTitle": MessageLookupByLibrary.simpleMessage(
      "Onderhoudsmodus",
    ),
    "manageUserAction": MessageLookupByLibrary.simpleMessage(
      "Beheer gebruiker",
    ),
    "mark": MessageLookupByLibrary.simpleMessage("Markeren"),
    "math": MessageLookupByLibrary.simpleMessage("Wiskunde"),
    "maxItemsDescription": MessageLookupByLibrary.simpleMessage(
      "Voorkomt extreem grote lijsten.",
    ),
    "maxItemsTitle": MessageLookupByLibrary.simpleMessage(
      "Max. items per lijst",
    ),
    "maxListsDescription": MessageLookupByLibrary.simpleMessage(
      "Beperkt het aantal aangemaakte lijsten.",
    ),
    "maxListsTitle": MessageLookupByLibrary.simpleMessage(
      "Max. lijsten per gebruiker",
    ),
    "meat": MessageLookupByLibrary.simpleMessage("Vlees"),
    "medal": MessageLookupByLibrary.simpleMessage("Medaille"),
    "meditate": MessageLookupByLibrary.simpleMessage("Meditatie"),
    "menuPricing": MessageLookupByLibrary.simpleMessage("Prijzen"),
    "menuRevenue": MessageLookupByLibrary.simpleMessage("Omzet"),
    "menuTooltip": MessageLookupByLibrary.simpleMessage("Menu"),
    "microwave": MessageLookupByLibrary.simpleMessage("Magnetron"),
    "milk": MessageLookupByLibrary.simpleMessage("Melk"),
    "mobile": MessageLookupByLibrary.simpleMessage("Mobiel"),
    "money": MessageLookupByLibrary.simpleMessage("Geld"),
    "moneyBag": MessageLookupByLibrary.simpleMessage("Geldzak"),
    "mother": MessageLookupByLibrary.simpleMessage("Moeder"),
    "mountain": MessageLookupByLibrary.simpleMessage("Berg"),
    "multiply": MessageLookupByLibrary.simpleMessage("Vermenigvuldigen"),
    "music": MessageLookupByLibrary.simpleMessage("Muziek"),
    "navAccount": MessageLookupByLibrary.simpleMessage("Account"),
    "navAccountDefaults": MessageLookupByLibrary.simpleMessage(
      "Standaardwaarden",
    ),
    "navAccountSettings": MessageLookupByLibrary.simpleMessage(
      "Accountinstellingen",
    ),
    "navBookings": MessageLookupByLibrary.simpleMessage("Boekingen"),
    "navGroupAccount": MessageLookupByLibrary.simpleMessage("Account"),
    "navGroupPortfolio": MessageLookupByLibrary.simpleMessage("Portfolio"),
    "navGroupProperties": MessageLookupByLibrary.simpleMessage("Properties"),
    "navGroupSingleProperty": MessageLookupByLibrary.simpleMessage("Verhuur"),
    "navPropertyOverridesTooltip": MessageLookupByLibrary.simpleMessage(
      "Eigen waarden",
    ),
    "navPropertyOverview": MessageLookupByLibrary.simpleMessage("Overzicht"),
    "navPropertySiteSettings": MessageLookupByLibrary.simpleMessage(
      "Site-instellingen",
    ),
    "navPropertyWebsite": MessageLookupByLibrary.simpleMessage("Website"),
    "navigation": MessageLookupByLibrary.simpleMessage("Navigatie"),
    "navigationLabel": MessageLookupByLibrary.simpleMessage("Navigatie"),
    "network": MessageLookupByLibrary.simpleMessage("Netwerk"),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "Er is een probleem met de verbinding met de server.",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("Nieuw wachtwoord"),
    "newPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Nieuw wachtwoord",
    ),
    "no": MessageLookupByLibrary.simpleMessage("Nee"),
    "noAccountYet": MessageLookupByLibrary.simpleMessage("Nog geen account?"),
    "noAppsFound": MessageLookupByLibrary.simpleMessage("Geen apps gevonden."),
    "noDataFound": MessageLookupByLibrary.simpleMessage(
      "Geen gegevens gevonden.",
    ),
    "noIcon": MessageLookupByLibrary.simpleMessage("Geen pictogram"),
    "noLabel": MessageLookupByLibrary.simpleMessage("Nee"),
    "noOwnedLists": MessageLookupByLibrary.simpleMessage(
      "Geen eigen lijsten gevonden.",
    ),
    "noSharedLists": MessageLookupByLibrary.simpleMessage(
      "Geen gedeelde lijsten gevonden.",
    ),
    "noUsername": MessageLookupByLibrary.simpleMessage("Geen gebruikersnaam"),
    "noUsersFound": MessageLookupByLibrary.simpleMessage(
      "Geen gebruikers gevonden. Probeer een andere zoekopdracht.",
    ),
    "noodles": MessageLookupByLibrary.simpleMessage("Noedels"),
    "notAdminError": MessageLookupByLibrary.simpleMessage(
      "Deze gebruiker heeft geen adminrechten.",
    ),
    "notSet": MessageLookupByLibrary.simpleMessage("Niet ingesteld"),
    "notification": MessageLookupByLibrary.simpleMessage("Melding"),
    "notificationsEnabledLabel": MessageLookupByLibrary.simpleMessage(
      "Notificaties ingeschakeld",
    ),
    "notificationsLabel": MessageLookupByLibrary.simpleMessage("Notificaties"),
    "numberedList": MessageLookupByLibrary.simpleMessage("Genummerde lijst"),
    "numbers": MessageLookupByLibrary.simpleMessage("Nummers"),
    "ok": MessageLookupByLibrary.simpleMessage("Oké"),
    "oopsAproblemOccured": MessageLookupByLibrary.simpleMessage(
      "Oeps, er is een probleem opgetreden. We zijn er mee bezig.",
    ),
    "openPackage": MessageLookupByLibrary.simpleMessage("Pakket openen"),
    "opening": MessageLookupByLibrary.simpleMessage("Openen"),
    "operatorSign": MessageLookupByLibrary.simpleMessage("Operator"),
    "optionalPlaceholder": MessageLookupByLibrary.simpleMessage("Optioneel"),
    "orDivider": MessageLookupByLibrary.simpleMessage("of"),
    "organization": MessageLookupByLibrary.simpleMessage("Organisatie"),
    "origin": MessageLookupByLibrary.simpleMessage("Oorsprong"),
    "oval": MessageLookupByLibrary.simpleMessage("Ovaal"),
    "ownedListsTitle": MessageLookupByLibrary.simpleMessage("Eigen lijsten"),
    "paint": MessageLookupByLibrary.simpleMessage("Verf"),
    "palm": MessageLookupByLibrary.simpleMessage("Palmboom"),
    "pan": MessageLookupByLibrary.simpleMessage("Pan"),
    "parasol": MessageLookupByLibrary.simpleMessage("Parasol"),
    "parsley": MessageLookupByLibrary.simpleMessage("Peterselie"),
    "party": MessageLookupByLibrary.simpleMessage("Feest"),
    "pass": MessageLookupByLibrary.simpleMessage("Pas"),
    "password": MessageLookupByLibrary.simpleMessage("Wachtwoord"),
    "passwordChangeFailed": MessageLookupByLibrary.simpleMessage(
      "Kon wachtwoord niet wijzigen.",
    ),
    "passwordChangeFailedWithReason": m62,
    "passwordChanged": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord gewijzigd.",
    ),
    "passwordConsistOfMin6Characters": MessageLookupByLibrary.simpleMessage(
      "Een wachtwoord moet uit minimaal 6 tekens bestaan",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Minimaal 8 tekens.",
    ),
    "passwordUpdated": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord bijgewerkt",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Wachtwoorden komen niet overeen.",
    ),
    "pasta": MessageLookupByLibrary.simpleMessage("Pasta"),
    "pastaMaker": MessageLookupByLibrary.simpleMessage("Pastamachine"),
    "pen": MessageLookupByLibrary.simpleMessage("Pen"),
    "pencil": MessageLookupByLibrary.simpleMessage("Potlood"),
    "people": MessageLookupByLibrary.simpleMessage("Mensen"),
    "percent": MessageLookupByLibrary.simpleMessage("Percentage"),
    "persons": MessageLookupByLibrary.simpleMessage("Personen"),
    "pest": MessageLookupByLibrary.simpleMessage("Ongedierte"),
    "pestle": MessageLookupByLibrary.simpleMessage("Vijzel"),
    "pet": MessageLookupByLibrary.simpleMessage("Huisdier"),
    "phone": MessageLookupByLibrary.simpleMessage("Telefoon"),
    "photo": MessageLookupByLibrary.simpleMessage("Foto"),
    "pie": MessageLookupByLibrary.simpleMessage("Taart"),
    "pig": MessageLookupByLibrary.simpleMessage("Varken"),
    "pizza": MessageLookupByLibrary.simpleMessage("Pizza"),
    "place": MessageLookupByLibrary.simpleMessage("Plaats"),
    "plate": MessageLookupByLibrary.simpleMessage("Bord"),
    "plus": MessageLookupByLibrary.simpleMessage("Plus"),
    "portfolioColumnProperty": MessageLookupByLibrary.simpleMessage("Property"),
    "portfolioFilterAll": MessageLookupByLibrary.simpleMessage(
      "Alle properties",
    ),
    "portfolioFilterSome": m63,
    "portfolioFilterTooltip": MessageLookupByLibrary.simpleMessage(
      "Kies welke properties meetellen",
    ),
    "position": MessageLookupByLibrary.simpleMessage("Positie"),
    "preferPasswordSignIn": MessageLookupByLibrary.simpleMessage(
      "Liever inloggen met een wachtwoord?",
    ),
    "preferencesSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Voorkeuren",
    ),
    "premium": MessageLookupByLibrary.simpleMessage("Premium"),
    "present": MessageLookupByLibrary.simpleMessage("Cadeau"),
    "pricingChannelSettingsHeader": MessageLookupByLibrary.simpleMessage(
      "Kanaalinstellingen",
    ),
    "pricingCleaningCost": MessageLookupByLibrary.simpleMessage(
      "Schoonmaakkosten",
    ),
    "pricingCommissionDefault": MessageLookupByLibrary.simpleMessage(
      "Leeg = standaard",
    ),
    "pricingCommissionNote": MessageLookupByLibrary.simpleMessage(
      "Commissie: leeg = standaard.",
    ),
    "pricingCommissionOverride": MessageLookupByLibrary.simpleMessage(
      "Commissie override",
    ),
    "pricingCostTypePerBooking": MessageLookupByLibrary.simpleMessage(
      "per boeking",
    ),
    "pricingCostTypePerNight": MessageLookupByLibrary.simpleMessage(
      "per nacht",
    ),
    "pricingCostTypePerPerson": MessageLookupByLibrary.simpleMessage(
      "per persoon",
    ),
    "pricingCurrencyNote": MessageLookupByLibrary.simpleMessage(
      "Alle bedragen in",
    ),
    "pricingLinenCost": MessageLookupByLibrary.simpleMessage("Linnenkosten"),
    "pricingLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Kon de prijsinstellingen niet laden.",
    ),
    "pricingOtherCost": MessageLookupByLibrary.simpleMessage("Overige kosten"),
    "pricingPageHeading": MessageLookupByLibrary.simpleMessage(
      "Kanaal & kosten",
    ),
    "pricingPayoutCommission": m64,
    "pricingPayoutFixedCosts": MessageLookupByLibrary.simpleMessage(
      "Schoonmaak + linnen",
    ),
    "pricingPayoutGross": m65,
    "pricingPayoutHeader": MessageLookupByLibrary.simpleMessage(
      "Voorbeelduitbetaling",
    ),
    "pricingPayoutMarkup": m66,
    "pricingPayoutNet": MessageLookupByLibrary.simpleMessage(
      "Netto uitbetaling",
    ),
    "pricingPayoutNote": MessageLookupByLibrary.simpleMessage(
      "De berekening werkt live mee met de velden links. Klik op een kanaal om het voorbeeld daarvoor te tonen.",
    ),
    "pricingPayoutOther": MessageLookupByLibrary.simpleMessage(
      "Overige kosten",
    ),
    "pricingPayoutService": m67,
    "pricingPayoutSubtitle": m68,
    "pricingRateMarkup": MessageLookupByLibrary.simpleMessage(
      "Prijsopslag op basisprijs",
    ),
    "pricingRateMarkupDescription": MessageLookupByLibrary.simpleMessage(
      "Opslag % die op dit kanaal wordt gehanteerd.",
    ),
    "pricingSaved": MessageLookupByLibrary.simpleMessage(
      "Pricing instellingen opgeslagen.",
    ),
    "pricingServiceCost": MessageLookupByLibrary.simpleMessage("Servicekosten"),
    "print": MessageLookupByLibrary.simpleMessage("Afdrukken"),
    "printer": MessageLookupByLibrary.simpleMessage("Printer"),
    "profileLabel": MessageLookupByLibrary.simpleMessage("Profiel"),
    "profileLoadFailed": m69,
    "profileLoadingLabel": MessageLookupByLibrary.simpleMessage(
      "Profiel wordt geladen...",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profiel"),
    "propertiesEmptyBody": MessageLookupByLibrary.simpleMessage(
      "Haal ze uit Lodgify of maak er zelf een aan om een website op te zetten.",
    ),
    "propertiesListAdd": MessageLookupByLibrary.simpleMessage(
      "Property toevoegen",
    ),
    "propertiesListBookingCount": m70,
    "propertiesListEmpty": MessageLookupByLibrary.simpleMessage(
      "Nog geen properties in dit account.",
    ),
    "propertiesListFollowsAccount": MessageLookupByLibrary.simpleMessage(
      "Volgt account",
    ),
    "propertiesListFooter": MessageLookupByLibrary.simpleMessage(
      "Van Lodgify: naam, prijzen en beschikbaarheid komen daaruit, dus die rij kun je alleen ontkoppelen. Handmatig: helemaal van jou.",
    ),
    "propertiesListHeading": MessageLookupByLibrary.simpleMessage("Properties"),
    "propertiesListOwnValues": m71,
    "propertyDeleteMessage": MessageLookupByLibrary.simpleMessage(
      "De property verdwijnt uit dit account, met de website-content die erop staat.",
    ),
    "propertyDeleteTitle": m72,
    "propertyDeleteTooltip": MessageLookupByLibrary.simpleMessage(
      "Property verwijderen",
    ),
    "propertyDetailsAbsent": MessageLookupByLibrary.simpleMessage("Geen"),
    "propertyDetailsAddons": MessageLookupByLibrary.simpleMessage("Extra\'s"),
    "propertyDetailsAddressCard": MessageLookupByLibrary.simpleMessage("Adres"),
    "propertyDetailsAgreement": MessageLookupByLibrary.simpleMessage(
      "Huurovereenkomst",
    ),
    "propertyDetailsCity": MessageLookupByLibrary.simpleMessage("Plaats"),
    "propertyDetailsConnectionActive": MessageLookupByLibrary.simpleMessage(
      "Actief",
    ),
    "propertyDetailsConnectionMissing": MessageLookupByLibrary.simpleMessage(
      "Aan deze property is geen Lodgify-property gekoppeld.",
    ),
    "propertyDetailsConnectionSummary": m73,
    "propertyDetailsConnectionSummaryNoSync": m74,
    "propertyDetailsCountry": MessageLookupByLibrary.simpleMessage("Land"),
    "propertyDetailsEmpty": MessageLookupByLibrary.simpleMessage(
      "Selecteer een property om details te bekijken.",
    ),
    "propertyDetailsGuestsCount": m75,
    "propertyDetailsLabel": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
    "propertyDetailsOverline": MessageLookupByLibrary.simpleMessage("Property"),
    "propertyDetailsOwnerLanguages": MessageLookupByLibrary.simpleMessage(
      "Talen eigenaar",
    ),
    "propertyDetailsPresent": MessageLookupByLibrary.simpleMessage("Aanwezig"),
    "propertyDetailsPriceRange": MessageLookupByLibrary.simpleMessage(
      "Prijsbereik",
    ),
    "propertyDetailsPriceUnit": MessageLookupByLibrary.simpleMessage(
      "Prijseenheid",
    ),
    "propertyDetailsPriceUnitValue": m76,
    "propertyDetailsRating": MessageLookupByLibrary.simpleMessage(
      "Beoordeling",
    ),
    "propertyDetailsRatingValue": m77,
    "propertyDetailsRawEmpty": MessageLookupByLibrary.simpleMessage(
      "Lodgify heeft nog geen ruwe gegevens voor deze property gestuurd.",
    ),
    "propertyDetailsRawInOut": MessageLookupByLibrary.simpleMessage(
      "In-/uitcheckregels",
    ),
    "propertyDetailsRawSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Abonnementen",
    ),
    "propertyDetailsRawSummary": MessageLookupByLibrary.simpleMessage(
      "In-/uitcheckregels, kamers, abonnementen",
    ),
    "propertyDetailsRawTitle": MessageLookupByLibrary.simpleMessage(
      "Ruwe gegevens uit Lodgify",
    ),
    "propertyDetailsRefresh": MessageLookupByLibrary.simpleMessage(
      "Gegevens verversen",
    ),
    "propertyDetailsRefreshRetry": MessageLookupByLibrary.simpleMessage(
      "Opnieuw proberen",
    ),
    "propertyDetailsRefreshTooltip": MessageLookupByLibrary.simpleMessage(
      "Leest deze property opnieuw. Koppel een Lodgify-property om gegevens te kunnen synchroniseren.",
    ),
    "propertyDetailsRefreshTooltipSynced": m78,
    "propertyDetailsRentalCard": MessageLookupByLibrary.simpleMessage(
      "Verhuur",
    ),
    "propertyDetailsRooms": MessageLookupByLibrary.simpleMessage("Kamers"),
    "propertyDetailsRoomsCount": m79,
    "propertyDetailsSourceNote": MessageLookupByLibrary.simpleMessage(
      "Deze gegevens komen uit Lodgify en worden daar beheerd. Wijzig ze in Lodgify en synchroniseer om ze hier bij te werken.",
    ),
    "propertyDetailsStreet": MessageLookupByLibrary.simpleMessage("Straat"),
    "propertyDetailsSync": MessageLookupByLibrary.simpleMessage(
      "Nu synchroniseren",
    ),
    "propertyDetailsSyncDone": MessageLookupByLibrary.simpleMessage(
      "Gegevens uit Lodgify bijgewerkt.",
    ),
    "propertyDetailsSyncTooltip": MessageLookupByLibrary.simpleMessage(
      "Haalt deze property nu op uit Lodgify. Nog niet eerder gesynchroniseerd.",
    ),
    "propertyDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
    "propertyDetailsZip": MessageLookupByLibrary.simpleMessage("Postcode"),
    "propertyLastSync": MessageLookupByLibrary.simpleMessage(
      "Laatste synchronisatie",
    ),
    "propertyLodgifyLinked": MessageLookupByLibrary.simpleMessage("Gekoppeld"),
    "propertyLodgifyNotLinked": MessageLookupByLibrary.simpleMessage(
      "Niet gekoppeld",
    ),
    "propertyLodgifyStatus": MessageLookupByLibrary.simpleMessage(
      "Lodgify status",
    ),
    "propertyNameLabel": MessageLookupByLibrary.simpleMessage(
      "Naam accommodatie",
    ),
    "propertyNameLodgifyHint": MessageLookupByLibrary.simpleMessage(
      "Om de naam te wijzigen, pas deze aan in Lodgify en synchroniseer.",
    ),
    "propertyOriginLodgify": MessageLookupByLibrary.simpleMessage(
      "Van Lodgify",
    ),
    "propertyOriginManual": MessageLookupByLibrary.simpleMessage("Handmatig"),
    "propertySelectorEmpty": MessageLookupByLibrary.simpleMessage(
      "Geen accommodaties",
    ),
    "propertySelectorLoading": MessageLookupByLibrary.simpleMessage(
      "Accommodaties laden…",
    ),
    "propertySelectorSelect": MessageLookupByLibrary.simpleMessage(
      "Kies accommodatie",
    ),
    "propertySelectorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Accommodaties niet beschikbaar",
    ),
    "propertySwitcherLabel": MessageLookupByLibrary.simpleMessage(
      "Accommodatie",
    ),
    "propertyUnlinkAction": MessageLookupByLibrary.simpleMessage("Ontkoppelen"),
    "propertyUnlinkMessage": MessageLookupByLibrary.simpleMessage(
      "De listing blijft in Lodgify staan. Naam en prijzen worden weer van jou, en een volgende sync werkt deze property niet meer bij.",
    ),
    "propertyUnlinkTitle": m80,
    "propertyUnlinkTooltip": MessageLookupByLibrary.simpleMessage(
      "Ontkoppelen van Lodgify",
    ),
    "publicDomainLabel": MessageLookupByLibrary.simpleMessage("Publiek domein"),
    "puppy": MessageLookupByLibrary.simpleMessage("Puppy"),
    "purse": MessageLookupByLibrary.simpleMessage("Portemonnee"),
    "qr": MessageLookupByLibrary.simpleMessage("QR"),
    "qrCode": MessageLookupByLibrary.simpleMessage("QR-code"),
    "questionMark": MessageLookupByLibrary.simpleMessage("Vraagteken"),
    "ratingStar": MessageLookupByLibrary.simpleMessage("Beoordelingsster"),
    "recipeBook": MessageLookupByLibrary.simpleMessage("Receptenboek"),
    "recipes": MessageLookupByLibrary.simpleMessage("Recepten"),
    "refreshTooltip": MessageLookupByLibrary.simpleMessage("Vernieuwen"),
    "refrigerator": MessageLookupByLibrary.simpleMessage("Koelkast"),
    "register": MessageLookupByLibrary.simpleMessage("Registeren"),
    "registerWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Registreren met Google",
    ),
    "remindersLabel": MessageLookupByLibrary.simpleMessage("Herinneringen"),
    "remove": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "removeLanguageConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Gasten kunnen je website niet meer in deze taal bekijken. Opgeslagen vertalingen blijven bewaard en komen terug als je de taal opnieuw toevoegt.",
    ),
    "removeLanguageConfirmTitle": m81,
    "removeLanguageTooltip": MessageLookupByLibrary.simpleMessage(
      "Taal verwijderen",
    ),
    "repair": MessageLookupByLibrary.simpleMessage("Repareren"),
    "repeat": MessageLookupByLibrary.simpleMessage("Herhalen"),
    "requestNewPasswordEmail": MessageLookupByLibrary.simpleMessage(
      "Nieuwe resetmail aanvragen",
    ),
    "requiredField": MessageLookupByLibrary.simpleMessage(
      "Dit is een verplicht veld",
    ),
    "resendAvailableIn": m82,
    "resendCode": MessageLookupByLibrary.simpleMessage(
      "Code opnieuw verzenden",
    ),
    "reservationAdults": MessageLookupByLibrary.simpleMessage("Volwassenen"),
    "reservationArrival": MessageLookupByLibrary.simpleMessage("Aankomst"),
    "reservationBabyBed": MessageLookupByLibrary.simpleMessage("Babybed"),
    "reservationCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "reservationCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "reservationChildren": MessageLookupByLibrary.simpleMessage("Kinderen"),
    "reservationCloseTooltip": MessageLookupByLibrary.simpleMessage("Sluiten"),
    "reservationCreatedAt": MessageLookupByLibrary.simpleMessage("Aangemaakt"),
    "reservationDeparture": MessageLookupByLibrary.simpleMessage("Vertrek"),
    "reservationEmail": MessageLookupByLibrary.simpleMessage("E-mail"),
    "reservationExportedLabel": MessageLookupByLibrary.simpleMessage(
      "Geëxporteerd",
    ),
    "reservationGross": MessageLookupByLibrary.simpleMessage("Bruto"),
    "reservationGuestTotal": MessageLookupByLibrary.simpleMessage("Totaal"),
    "reservationId": MessageLookupByLibrary.simpleMessage("Reservering-ID"),
    "reservationInfants": MessageLookupByLibrary.simpleMessage("Baby\'s"),
    "reservationListColumnBooked": MessageLookupByLibrary.simpleMessage(
      "Geboekt",
    ),
    "reservationListColumnNew": MessageLookupByLibrary.simpleMessage("Nieuw"),
    "reservationName": MessageLookupByLibrary.simpleMessage("Naam"),
    "reservationNet": MessageLookupByLibrary.simpleMessage("Netto"),
    "reservationNewCount": m83,
    "reservationNights": MessageLookupByLibrary.simpleMessage("Nachten"),
    "reservationNotes": MessageLookupByLibrary.simpleMessage("Notities"),
    "reservationNotesDisabledHint": MessageLookupByLibrary.simpleMessage(
      "Geen reservering-ID — opslaan niet mogelijk",
    ),
    "reservationNotesHint": MessageLookupByLibrary.simpleMessage(
      "Voeg een notitie toe…",
    ),
    "reservationNotesSave": MessageLookupByLibrary.simpleMessage(
      "Opslaan in Lodgify",
    ),
    "reservationOutstanding": MessageLookupByLibrary.simpleMessage(
      "Openstaand",
    ),
    "reservationPhone": MessageLookupByLibrary.simpleMessage("Telefoon"),
    "reservationSectionBooker": MessageLookupByLibrary.simpleMessage("Boeker"),
    "reservationSectionGuests": MessageLookupByLibrary.simpleMessage("Gasten"),
    "reservationSectionOther": MessageLookupByLibrary.simpleMessage("Overig"),
    "reservationSectionPayload": MessageLookupByLibrary.simpleMessage(
      "Volledige payload",
    ),
    "reservationSectionRevenue": MessageLookupByLibrary.simpleMessage(
      "Opbrengsten",
    ),
    "reservationSectionStay": MessageLookupByLibrary.simpleMessage("Verblijf"),
    "reservationSource": MessageLookupByLibrary.simpleMessage("Bron"),
    "reservationStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "reservationUpdatedAt": MessageLookupByLibrary.simpleMessage("Bijgewerkt"),
    "reservations": MessageLookupByLibrary.simpleMessage("Reserveringen"),
    "reservationsBarGuests": m84,
    "reservationsBarNights": m85,
    "reservationsBarSource": m86,
    "reservationsBarStatus": m87,
    "reservationsColumnGuests": MessageLookupByLibrary.simpleMessage("Gasten"),
    "reservationsColumnsTooltip": MessageLookupByLibrary.simpleMessage(
      "Kolommen",
    ),
    "reservationsDensityCompact": MessageLookupByLibrary.simpleMessage(
      "Compact",
    ),
    "reservationsDensityDetailed": MessageLookupByLibrary.simpleMessage(
      "Gedetailleerd",
    ),
    "reservationsEmptyList": MessageLookupByLibrary.simpleMessage(
      "Geen reserveringen gevonden.",
    ),
    "reservationsEmptyPeriod": MessageLookupByLibrary.simpleMessage(
      "Geen reserveringen gevonden voor deze periode.",
    ),
    "reservationsExportLabel": MessageLookupByLibrary.simpleMessage(
      "Exporteren",
    ),
    "reservationsExportPdfDownload": MessageLookupByLibrary.simpleMessage(
      "PDF downloaden",
    ),
    "reservationsExportPdfShare": MessageLookupByLibrary.simpleMessage(
      "PDF delen",
    ),
    "reservationsExportSettings": MessageLookupByLibrary.simpleMessage(
      "Instellingen",
    ),
    "reservationsExportTooltip": MessageLookupByLibrary.simpleMessage(
      "Delen & exporteren",
    ),
    "reservationsFilterHistorical": MessageLookupByLibrary.simpleMessage(
      "Historische boekingen",
    ),
    "reservationsFilterTooltip": MessageLookupByLibrary.simpleMessage("Filter"),
    "reservationsKpiArrivals": MessageLookupByLibrary.simpleMessage(
      "Aankomsten",
    ),
    "reservationsKpiArrivalsCaption": MessageLookupByLibrary.simpleMessage(
      "check-in",
    ),
    "reservationsKpiBookings": MessageLookupByLibrary.simpleMessage(
      "Boekingen",
    ),
    "reservationsKpiBookingsCaption": MessageLookupByLibrary.simpleMessage(
      "deze maand",
    ),
    "reservationsKpiDepartures": MessageLookupByLibrary.simpleMessage(
      "Vertrekken",
    ),
    "reservationsKpiDeparturesCaption": MessageLookupByLibrary.simpleMessage(
      "check-out",
    ),
    "reservationsKpiOccupancy": MessageLookupByLibrary.simpleMessage(
      "Bezetting",
    ),
    "reservationsLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Boekingen konden niet worden geladen.",
    ),
    "reservationsMonthsContinuous": MessageLookupByLibrary.simpleMessage(
      "Doorlopend",
    ),
    "reservationsNoLodgifyId": MessageLookupByLibrary.simpleMessage(
      "Koppel een Lodgify ID aan deze accommodatie om boekingen te laden.",
    ),
    "reservationsOutOfMonthBookedOnly": MessageLookupByLibrary.simpleMessage(
      "Alleen geboekte dagen",
    ),
    "reservationsOutOfMonthHide": MessageLookupByLibrary.simpleMessage(
      "Buiten maand verbergen",
    ),
    "reservationsPageHeading": m88,
    "reservationsPageTitle": MessageLookupByLibrary.simpleMessage(
      "Reserveringen",
    ),
    "reservationsViewList": MessageLookupByLibrary.simpleMessage("Lijst"),
    "reservationsViewTimeline": MessageLookupByLibrary.simpleMessage(
      "Tijdlijn",
    ),
    "reservationsViewTooltip": MessageLookupByLibrary.simpleMessage("Weergave"),
    "resetPassword": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord resetten",
    ),
    "resetPasswordInstructions": MessageLookupByLibrary.simpleMessage(
      "Voer de verificatiecode in die naar je e-mail is gestuurd en kies een nieuw wachtwoord.",
    ),
    "resetPasswordLinkExpired": MessageLookupByLibrary.simpleMessage(
      "De resetlink is verlopen. Vraag een nieuwe aan.",
    ),
    "resource": MessageLookupByLibrary.simpleMessage("Bron"),
    "restRoom": MessageLookupByLibrary.simpleMessage("Toilet"),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Standaardinstellingen",
    ),
    "revenueBreakdownChannelFee": MessageLookupByLibrary.simpleMessage(
      "Kanaal fee (Booking/Airbnb)",
    ),
    "revenueBreakdownCleaning": MessageLookupByLibrary.simpleMessage(
      "Schoonmaakkosten",
    ),
    "revenueBreakdownDeposit": MessageLookupByLibrary.simpleMessage("Borg"),
    "revenueBreakdownDiscounts": MessageLookupByLibrary.simpleMessage(
      "Kortingen",
    ),
    "revenueBreakdownExtraCharges": MessageLookupByLibrary.simpleMessage(
      "Extra kosten",
    ),
    "revenueBreakdownLinen": MessageLookupByLibrary.simpleMessage(
      "Linnen / bedlinnen",
    ),
    "revenueBreakdownOtherCosts": MessageLookupByLibrary.simpleMessage(
      "Overige vaste kosten",
    ),
    "revenueBreakdownRent": MessageLookupByLibrary.simpleMessage(
      "Huur / nachttarief",
    ),
    "revenueBreakdownServiceCosts": MessageLookupByLibrary.simpleMessage(
      "Servicekosten",
    ),
    "revenueBreakdownTax": MessageLookupByLibrary.simpleMessage(
      "Belasting / btw",
    ),
    "revenueChannelSplitTitle": MessageLookupByLibrary.simpleMessage(
      "Omzet per kanaal",
    ),
    "revenueChartLegendGross": MessageLookupByLibrary.simpleMessage("Bruto"),
    "revenueChartLegendNet": MessageLookupByLibrary.simpleMessage("Netto"),
    "revenueChartTitle": MessageLookupByLibrary.simpleMessage(
      "Omzet per maand",
    ),
    "revenueChartTooltip": m89,
    "revenueColumnBooker": MessageLookupByLibrary.simpleMessage("Boeker"),
    "revenueColumnCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "revenueColumnCommission": MessageLookupByLibrary.simpleMessage(
      "Commissie",
    ),
    "revenueColumnCosts": MessageLookupByLibrary.simpleMessage("Kosten"),
    "revenueColumnGross": MessageLookupByLibrary.simpleMessage("Bruto"),
    "revenueColumnNet": MessageLookupByLibrary.simpleMessage("Netto"),
    "revenueColumnNightlyRate": MessageLookupByLibrary.simpleMessage(
      "Nachtprijs",
    ),
    "revenueColumnNights": MessageLookupByLibrary.simpleMessage("Nachten"),
    "revenueFees": MessageLookupByLibrary.simpleMessage("Fees"),
    "revenueHeading": m90,
    "revenueKpiAdr": MessageLookupByLibrary.simpleMessage("Gem. nachtprijs"),
    "revenueKpiAdrCaption": m91,
    "revenueKpiGross": MessageLookupByLibrary.simpleMessage("Bruto omzet"),
    "revenueKpiGrossCaption": m92,
    "revenueKpiNet": MessageLookupByLibrary.simpleMessage("Netto omzet"),
    "revenueKpiNetCaption": MessageLookupByLibrary.simpleMessage("na kosten"),
    "revenueKpiOccupancy": MessageLookupByLibrary.simpleMessage("Bezetting"),
    "revenueKpiOccupancyCaption": MessageLookupByLibrary.simpleMessage(
      "van periode",
    ),
    "revenueLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Opbrengsten konden niet worden geladen.",
    ),
    "revenueNetRevenue": MessageLookupByLibrary.simpleMessage("Netto omzet"),
    "revenueNoBookedStaysInPeriod": MessageLookupByLibrary.simpleMessage(
      "Geen geboekte verblijven gevonden in deze periode.",
    ),
    "revenueNoLodgifyId": MessageLookupByLibrary.simpleMessage(
      "Koppel een Lodgify ID aan deze accommodatie om opbrengsten te laden.",
    ),
    "revenueOverviewHeader": MessageLookupByLibrary.simpleMessage(
      "Overzicht actuele periode",
    ),
    "revenuePeriodMonth": MessageLookupByLibrary.simpleMessage("Maand"),
    "revenuePeriodQuarter": MessageLookupByLibrary.simpleMessage("Kwartaal"),
    "revenuePeriodYear": MessageLookupByLibrary.simpleMessage("Jaar"),
    "revenueQuarterLabel": m93,
    "revenueRefreshTooltip": MessageLookupByLibrary.simpleMessage("Vernieuwen"),
    "revenueServiceCosts": MessageLookupByLibrary.simpleMessage(
      "Servicekosten",
    ),
    "revenueTotalBookings": MessageLookupByLibrary.simpleMessage(
      "Totaal boekingen",
    ),
    "revenueTotalRevenue": MessageLookupByLibrary.simpleMessage("Totale omzet"),
    "revenueTotalsRowLabel": MessageLookupByLibrary.simpleMessage("Totaal"),
    "revenueUnknownBooker": MessageLookupByLibrary.simpleMessage(
      "Onbekende boeker",
    ),
    "revenueUnknownProperty": MessageLookupByLibrary.simpleMessage(
      "Onbekende accommodatie",
    ),
    "right": MessageLookupByLibrary.simpleMessage("Rechts"),
    "rightAlignment": MessageLookupByLibrary.simpleMessage("Rechts uitlijnen"),
    "roleAdmin": MessageLookupByLibrary.simpleMessage("Admin"),
    "roleLabel": MessageLookupByLibrary.simpleMessage("Rol"),
    "roleUser": MessageLookupByLibrary.simpleMessage("Gebruiker"),
    "romantic": MessageLookupByLibrary.simpleMessage("Romantisch"),
    "roundNumber": MessageLookupByLibrary.simpleMessage("Afgerond getal"),
    "route": MessageLookupByLibrary.simpleMessage("Route"),
    "rugby": MessageLookupByLibrary.simpleMessage("Rugby"),
    "santaClaus": MessageLookupByLibrary.simpleMessage("Kerstman"),
    "sauce": MessageLookupByLibrary.simpleMessage("Saus"),
    "sauceBoat": MessageLookupByLibrary.simpleMessage("Jus"),
    "sauceBottle": MessageLookupByLibrary.simpleMessage("Sausfles"),
    "save": MessageLookupByLibrary.simpleMessage("Opslaan"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Opslaan"),
    "savedLabel": MessageLookupByLibrary.simpleMessage("Opgeslagen"),
    "savings": MessageLookupByLibrary.simpleMessage("Besparingen"),
    "scale": MessageLookupByLibrary.simpleMessage("Schaal"),
    "scan": MessageLookupByLibrary.simpleMessage("Scannen"),
    "scanBarcode": MessageLookupByLibrary.simpleMessage("Barcode scannen"),
    "searchEmailHint": MessageLookupByLibrary.simpleMessage(
      "Zoek op e-mailadres",
    ),
    "searchIcon": MessageLookupByLibrary.simpleMessage("Zoekpictogram"),
    "secureInput": MessageLookupByLibrary.simpleMessage("Veilige invoer"),
    "seededUser": MessageLookupByLibrary.simpleMessage("Seeded gebruiker"),
    "sendMagicLink": MessageLookupByLibrary.simpleMessage(
      "Magic link versturen",
    ),
    "sendResetLink": MessageLookupByLibrary.simpleMessage(
      "Resetlink versturen",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serverSettingsTitle": MessageLookupByLibrary.simpleMessage("Admin opties"),
    "setPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "Welkom! Stel een wachtwoord in om je account te activeren.",
    ),
    "setPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord instellen",
    ),
    "settingsLabel": MessageLookupByLibrary.simpleMessage("Instellingen"),
    "settingsSaved": MessageLookupByLibrary.simpleMessage(
      "Instellingen opgeslagen.",
    ),
    "sharedListsTitle": MessageLookupByLibrary.simpleMessage(
      "Gedeelde lijsten",
    ),
    "shop": MessageLookupByLibrary.simpleMessage("Winkel"),
    "shopping": MessageLookupByLibrary.simpleMessage("Winkelen"),
    "shoppingBag": MessageLookupByLibrary.simpleMessage("Winkelzak"),
    "shoppingBasket": MessageLookupByLibrary.simpleMessage("Winkelmandje"),
    "shoppingCart": MessageLookupByLibrary.simpleMessage("Winkelwagen"),
    "show": MessageLookupByLibrary.simpleMessage("Weergeven"),
    "showCalendarTabLabel": MessageLookupByLibrary.simpleMessage(
      "Kalender tab zichtbaar",
    ),
    "showErrorDetails": MessageLookupByLibrary.simpleMessage("Toon details"),
    "showStartTabLabel": MessageLookupByLibrary.simpleMessage(
      "Start tab zichtbaar",
    ),
    "sidebarCollapseTooltip": MessageLookupByLibrary.simpleMessage(
      "Menu inklappen",
    ),
    "sidebarExpandTooltip": MessageLookupByLibrary.simpleMessage(
      "Menu-labels tonen",
    ),
    "sidebarPinTooltip": MessageLookupByLibrary.simpleMessage(
      "Menu vastzetten",
    ),
    "signInWithMagicLink": MessageLookupByLibrary.simpleMessage(
      "Inloggen met magic link",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Registreren"),
    "signUpFailed": MessageLookupByLibrary.simpleMessage(
      "Aanmelden niet gelukt",
    ),
    "siteDetailsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Sitegegevens",
    ),
    "siteSettingsBookingSection": MessageLookupByLibrary.simpleMessage(
      "Boeken (Lodgify)",
    ),
    "siteSettingsContactEmailHint": MessageLookupByLibrary.simpleMessage(
      "Waar berichten van het contactformulier heen gaan.",
    ),
    "siteSettingsContactEmailLabel": MessageLookupByLibrary.simpleMessage(
      "Ontvanger contactformulier",
    ),
    "siteSettingsContactSection": MessageLookupByLibrary.simpleMessage(
      "Contact",
    ),
    "siteSettingsEmailFromNameHint": MessageLookupByLibrary.simpleMessage(
      "Getoond als afzender van website-e-mails (standaard de sitenaam).",
    ),
    "siteSettingsEmailFromNameLabel": MessageLookupByLibrary.simpleMessage(
      "Afzendernaam e-mail",
    ),
    "siteSettingsLodgifyPropertyIdLabel": MessageLookupByLibrary.simpleMessage(
      "Lodgify property-ID",
    ),
    "siteSettingsLodgifyRoomTypeIdLabel": MessageLookupByLibrary.simpleMessage(
      "Lodgify room type-ID",
    ),
    "siteSettingsSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Kon website-instellingen niet opslaan",
    ),
    "siteSettingsSaved": MessageLookupByLibrary.simpleMessage(
      "Website-instellingen opgeslagen",
    ),
    "siteSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Website-instellingen",
    ),
    "sitesCreateButton": MessageLookupByLibrary.simpleMessage("Site aanmaken"),
    "sitesDefaultLocaleHint": MessageLookupByLibrary.simpleMessage("en"),
    "sitesDefaultLocaleLabel": MessageLookupByLibrary.simpleMessage(
      "Standaardtaal",
    ),
    "sitesEmpty": MessageLookupByLibrary.simpleMessage(
      "Nog geen sites ingesteld.",
    ),
    "sitesLoadFailed": m94,
    "sitesLocaleSummary": m95,
    "sitesNameHint": MessageLookupByLibrary.simpleMessage("Trysil Panorama"),
    "sitesNameLabel": MessageLookupByLibrary.simpleMessage("Sitenaam"),
    "sitesNewEntryTitle": MessageLookupByLibrary.simpleMessage("Nieuwe site"),
    "sitesTitle": MessageLookupByLibrary.simpleMessage("Property website"),
    "small": MessageLookupByLibrary.simpleMessage("Klein"),
    "smallCaps": MessageLookupByLibrary.simpleMessage("Kleine letters"),
    "snowflake": MessageLookupByLibrary.simpleMessage("Sneeuwvlok"),
    "software": MessageLookupByLibrary.simpleMessage("Software"),
    "sound": MessageLookupByLibrary.simpleMessage("Geluid"),
    "soundLabel": MessageLookupByLibrary.simpleMessage("Geluid"),
    "soup": MessageLookupByLibrary.simpleMessage("Soep"),
    "source": MessageLookupByLibrary.simpleMessage("Bron"),
    "sourceBadgeLabel": MessageLookupByLibrary.simpleMessage("Bron"),
    "sourceLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Taal waarin je de website-inhoud invoert",
    ),
    "sourceLanguageFooter": MessageLookupByLibrary.simpleMessage(
      "Al het andere wordt bij publiceren automatisch vanuit je brontaal vertaald. Vergrendelde velden behouden jouw tekst.",
    ),
    "sourceLanguageLabel": MessageLookupByLibrary.simpleMessage("Brontaal"),
    "sourceLanguageUnavailable": MessageLookupByLibrary.simpleMessage(
      "Geen website gekoppeld",
    ),
    "spaghetti": MessageLookupByLibrary.simpleMessage("Spaghetti"),
    "sport": MessageLookupByLibrary.simpleMessage("Sport"),
    "sportCar": MessageLookupByLibrary.simpleMessage("Sportauto"),
    "square": MessageLookupByLibrary.simpleMessage("Vierkant"),
    "stacktraceHeader": MessageLookupByLibrary.simpleMessage("Stacktrace"),
    "standardUser": MessageLookupByLibrary.simpleMessage("Standaard gebruiker"),
    "star": MessageLookupByLibrary.simpleMessage("Ster"),
    "starInverse": MessageLookupByLibrary.simpleMessage("Omgekeerde ster"),
    "statistic": MessageLookupByLibrary.simpleMessage("Statistiek"),
    "steak": MessageLookupByLibrary.simpleMessage("Biefstuk"),
    "store": MessageLookupByLibrary.simpleMessage("Winkel"),
    "subscriptionChipLabel": m96,
    "subscriptionLabel": MessageLookupByLibrary.simpleMessage("Abonnement"),
    "subtract": MessageLookupByLibrary.simpleMessage("Aftrekken"),
    "suitcase": MessageLookupByLibrary.simpleMessage("Koffer"),
    "sum": MessageLookupByLibrary.simpleMessage("Som"),
    "sun": MessageLookupByLibrary.simpleMessage("Zon"),
    "sunlight": MessageLookupByLibrary.simpleMessage("Zonlicht"),
    "supabaseTableMissing": m97,
    "switchPropertyTitle": MessageLookupByLibrary.simpleMessage(
      "Kies een property",
    ),
    "symbol": MessageLookupByLibrary.simpleMessage("Symbool"),
    "systemSetting": MessageLookupByLibrary.simpleMessage("Systeeminstelling"),
    "tShirt": MessageLookupByLibrary.simpleMessage("T-shirt"),
    "table": MessageLookupByLibrary.simpleMessage("Tabel"),
    "tableOfContent": MessageLookupByLibrary.simpleMessage("Inhoudsopgave"),
    "tag": MessageLookupByLibrary.simpleMessage("Tag"),
    "taxi": MessageLookupByLibrary.simpleMessage("Taxi"),
    "teamActionsColumn": MessageLookupByLibrary.simpleMessage("Acties"),
    "teamCancelInvitation": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "teamEmailColumn": MessageLookupByLibrary.simpleMessage("E-mail"),
    "teamEmailPlaceholder": MessageLookupByLibrary.simpleMessage("E-mailadres"),
    "teamInvitationFailed": MessageLookupByLibrary.simpleMessage(
      "Uitnodiging mislukt",
    ),
    "teamInvitationResent": MessageLookupByLibrary.simpleMessage(
      "Uitnodiging opnieuw verstuurd",
    ),
    "teamInvitationSent": MessageLookupByLibrary.simpleMessage(
      "Uitnodiging verstuurd",
    ),
    "teamInviteMemberButton": MessageLookupByLibrary.simpleMessage(
      "Lid uitnodigen",
    ),
    "teamInviteMemberTitle": MessageLookupByLibrary.simpleMessage(
      "Lid uitnodigen",
    ),
    "teamInviteSiteDescription": m98,
    "teamInviteUserDescription": MessageLookupByLibrary.simpleMessage(
      "Nodig een gebruiker uit om samen je properties te beheren.",
    ),
    "teamInviteUserTitle": MessageLookupByLibrary.simpleMessage(
      "Gebruiker uitnodigen",
    ),
    "teamMembersSection": MessageLookupByLibrary.simpleMessage("Leden"),
    "teamNoMembers": MessageLookupByLibrary.simpleMessage(
      "Geen leden gevonden.",
    ),
    "teamNoPendingInvitations": MessageLookupByLibrary.simpleMessage(
      "Geen openstaande uitnodigingen.",
    ),
    "teamPendingInvitations": MessageLookupByLibrary.simpleMessage(
      "Openstaande uitnodigingen",
    ),
    "teamRemoveMember": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "teamRemoveMemberConfirm": m99,
    "teamRemoveMemberTitle": MessageLookupByLibrary.simpleMessage(
      "Lid verwijderen",
    ),
    "teamResendInvitation": MessageLookupByLibrary.simpleMessage(
      "Opnieuw versturen",
    ),
    "teamRoleColumn": MessageLookupByLibrary.simpleMessage("Rol"),
    "teamSendInvitation": MessageLookupByLibrary.simpleMessage(
      "Uitnodiging versturen",
    ),
    "teamTitle": MessageLookupByLibrary.simpleMessage("Team"),
    "teamUserColumn": MessageLookupByLibrary.simpleMessage("Gebruiker"),
    "text": MessageLookupByLibrary.simpleMessage("Tekst"),
    "thai": MessageLookupByLibrary.simpleMessage("Thais"),
    "theme": MessageLookupByLibrary.simpleMessage("Thema"),
    "thumb": MessageLookupByLibrary.simpleMessage("Duim"),
    "time": MessageLookupByLibrary.simpleMessage("Tijd"),
    "timer": MessageLookupByLibrary.simpleMessage("Timer"),
    "todoList": MessageLookupByLibrary.simpleMessage("Takenlijst"),
    "toggle": MessageLookupByLibrary.simpleMessage("Schakelen"),
    "toggleAdminFailed": m100,
    "tomato": MessageLookupByLibrary.simpleMessage("Tomaat"),
    "tooManyAttempts": MessageLookupByLibrary.simpleMessage("Te veel pogingen"),
    "trash": MessageLookupByLibrary.simpleMessage("Afval"),
    "travel": MessageLookupByLibrary.simpleMessage("Reizen"),
    "travelItinerary": MessageLookupByLibrary.simpleMessage("Reisroute"),
    "tree": MessageLookupByLibrary.simpleMessage("Boom"),
    "trophy": MessageLookupByLibrary.simpleMessage("Trofee"),
    "tryAgainLater": MessageLookupByLibrary.simpleMessage(
      "Probeer het later opnieuw",
    ),
    "unbox": MessageLookupByLibrary.simpleMessage("Uitpakken"),
    "underline": MessageLookupByLibrary.simpleMessage("Onderstrepen"),
    "untitledList": MessageLookupByLibrary.simpleMessage("Naamloos"),
    "updateAdminRightsFailed": MessageLookupByLibrary.simpleMessage(
      "Kon adminrechten niet bijwerken. Probeer opnieuw.",
    ),
    "updateButton": MessageLookupByLibrary.simpleMessage("Wijzigen"),
    "updateProfileFailed": m101,
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "userCreated": MessageLookupByLibrary.simpleMessage(
      "Gebruiker aangemaakt.",
    ),
    "userDeleteFailed": MessageLookupByLibrary.simpleMessage(
      "Kon gebruiker niet verwijderen.",
    ),
    "userDeleteFailedWithReason": m102,
    "userDeleted": MessageLookupByLibrary.simpleMessage(
      "Gebruiker verwijderd.",
    ),
    "userIdLabel": MessageLookupByLibrary.simpleMessage("Gebruikers-ID"),
    "userSettingsAction": MessageLookupByLibrary.simpleMessage(
      "Gebruikersinstellingen",
    ),
    "userUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "Kon gebruiker niet bijwerken.",
    ),
    "userUpdated": MessageLookupByLibrary.simpleMessage(
      "Gebruiker bijgewerkt.",
    ),
    "usernameLabel": MessageLookupByLibrary.simpleMessage("Gebruikersnaam"),
    "usersLabel": MessageLookupByLibrary.simpleMessage("Gebruikers"),
    "usersSubtitle": MessageLookupByLibrary.simpleMessage(
      "Zoek, bekijk en beheer toegang tot de console.",
    ),
    "usersTitle": MessageLookupByLibrary.simpleMessage("Gebruikers"),
    "vacationTime": MessageLookupByLibrary.simpleMessage("Vakantietijd"),
    "vegetables": MessageLookupByLibrary.simpleMessage("Groenten"),
    "vegetarian": MessageLookupByLibrary.simpleMessage("Vegetarisch"),
    "verificationCode": MessageLookupByLibrary.simpleMessage("Verificatiecode"),
    "verificationCodeSentText": m103,
    "verify": MessageLookupByLibrary.simpleMessage("Verifiëren"),
    "versionFooter": m104,
    "verticalLine": MessageLookupByLibrary.simpleMessage("Verticale lijn"),
    "walking": MessageLookupByLibrary.simpleMessage("Lopen"),
    "wallet": MessageLookupByLibrary.simpleMessage("Portemonnee"),
    "warning": MessageLookupByLibrary.simpleMessage("Waarschuwing"),
    "waste": MessageLookupByLibrary.simpleMessage("Afval"),
    "watch": MessageLookupByLibrary.simpleMessage("Horloge"),
    "weAddHighlight": MessageLookupByLibrary.simpleMessage(
      "Hoogtepunt toevoegen",
    ),
    "weAddPhoto": MessageLookupByLibrary.simpleMessage("Toevoegen"),
    "weAiTranslation": MessageLookupByLibrary.simpleMessage("AI-vertaling"),
    "weBannerEditingBody": m105,
    "weBannerEditingTitle": m106,
    "weBannerUnpublishedBody": m107,
    "weBannerUnpublishedTitle": MessageLookupByLibrary.simpleMessage(
      "Niet-gepubliceerde wijzigingen",
    ),
    "weBannerWritingBody": MessageLookupByLibrary.simpleMessage(
      "Andere talen vertalen automatisch bij publiceren — behalve velden die je vergrendelt.",
    ),
    "weBannerWritingTitle": m108,
    "weBreadcrumbWebsite": MessageLookupByLibrary.simpleMessage("Website"),
    "weCardAgreements": MessageLookupByLibrary.simpleMessage(
      "Afspraken & betaling",
    ),
    "weCardAmenities": MessageLookupByLibrary.simpleMessage("Voorzieningen"),
    "weCardAmenitiesSub": MessageLookupByLibrary.simpleMessage(
      "Groepen met items.",
    ),
    "weCardAreaIntro": MessageLookupByLibrary.simpleMessage("Introductie"),
    "weCardAreaIntroSub": MessageLookupByLibrary.simpleMessage(
      "Staat als ondertitel onder de paginatitel.",
    ),
    "weCardAreaSections": MessageLookupByLibrary.simpleMessage("Secties"),
    "weCardAreaSectionsSub": MessageLookupByLibrary.simpleMessage(
      "Elke sectie is een kaart met titel, tekst en regels.",
    ),
    "weCardArrival": MessageLookupByLibrary.simpleMessage("Aankomst & toegang"),
    "weCardContact": MessageLookupByLibrary.simpleMessage("Contact"),
    "weCardContactHelp": MessageLookupByLibrary.simpleMessage("Contact & hulp"),
    "weCardContactSub": MessageLookupByLibrary.simpleMessage(
      "Onderaan de homepage. De vier velden staan vast — alleen de teksten zijn van jou.",
    ),
    "weCardContent": MessageLookupByLibrary.simpleMessage("Pagina-inhoud"),
    "weCardDescription": MessageLookupByLibrary.simpleMessage("Beschrijving"),
    "weCardGalleryAll": MessageLookupByLibrary.simpleMessage("Alle foto\'s"),
    "weCardGalleryAllSub": MessageLookupByLibrary.simpleMessage(
      "De volledige set op /gallery. De homepage toont hier een selectie uit.",
    ),
    "weCardGalleryHeaderSub": MessageLookupByLibrary.simpleMessage(
      "De paginatitel komt uit de interfacetaal; de regel eronder is van jou.",
    ),
    "weCardGoodToKnow": MessageLookupByLibrary.simpleMessage(
      "Goed om te weten",
    ),
    "weCardHeader": MessageLookupByLibrary.simpleMessage("Kop"),
    "weCardHero": MessageLookupByLibrary.simpleMessage("Hero"),
    "weCardHeroSub": MessageLookupByLibrary.simpleMessage(
      "Titel, locatieregel en de wisselende hero-foto\'s.",
    ),
    "weCardHighlights": MessageLookupByLibrary.simpleMessage("Hoogtepunten"),
    "weCardHighlightsSub": MessageLookupByLibrary.simpleMessage(
      "Kaarten met foto onderaan de homepage.",
    ),
    "weCardHomeGallery": MessageLookupByLibrary.simpleMessage(
      "Galerij op de homepage",
    ),
    "weCardHomeGallerySub": MessageLookupByLibrary.simpleMessage(
      "Een selectie uit de bibliotheek; de volledige set staat op de tab Galerij.",
    ),
    "weCardHouseRules": MessageLookupByLibrary.simpleMessage("Huisregels"),
    "weCardHouseRulesSub": MessageLookupByLibrary.simpleMessage(
      "Staat als sectie op de homepage.",
    ),
    "weCardKeyFacts": MessageLookupByLibrary.simpleMessage("Kerncijfers"),
    "weCardKeyFactsSub": MessageLookupByLibrary.simpleMessage(
      "De tegels direct onder de hero.",
    ),
    "weCardLayout": MessageLookupByLibrary.simpleMessage(
      "Indeling & faciliteiten",
    ),
    "weCardLayoutSub": MessageLookupByLibrary.simpleMessage(
      "Secties met een korte inleiding en regels.",
    ),
    "weCardLocation": MessageLookupByLibrary.simpleMessage(
      "Locatie & afstanden",
    ),
    "weCardParking": MessageLookupByLibrary.simpleMessage("Parkeren & laden"),
    "weCardPrivacy": MessageLookupByLibrary.simpleMessage("Privacyverklaring"),
    "weCardQuickFacts": MessageLookupByLibrary.simpleMessage("Snel overzicht"),
    "weCardQuickFactsSub": MessageLookupByLibrary.simpleMessage(
      "De strip bovenaan de pagina.",
    ),
    "weCardSiteChrome": MessageLookupByLibrary.simpleMessage("Sitenaam"),
    "weCardSiteChromeSub": MessageLookupByLibrary.simpleMessage(
      "Zichtbaar in de header, de browsertab en de footer van elke pagina.",
    ),
    "weCardSourceLodgify": MessageLookupByLibrary.simpleMessage("Uit Lodgify"),
    "weCardTransport": MessageLookupByLibrary.simpleMessage(
      "Aankomst & vervoer",
    ),
    "weCardTransportSub": MessageLookupByLibrary.simpleMessage(
      "Vaste kolommen met reisopties.",
    ),
    "weChipAuto": MessageLookupByLibrary.simpleMessage("Auto"),
    "weChipLocked": MessageLookupByLibrary.simpleMessage("Vergrendeld"),
    "weChipNew": MessageLookupByLibrary.simpleMessage("Nieuw"),
    "weChipShared": MessageLookupByLibrary.simpleMessage("gedeeld"),
    "weChipTooltipAuto": MessageLookupByLibrary.simpleMessage(
      "Volgt de bron — klik om je eigen tekst te behouden",
    ),
    "weChipTooltipLocked": MessageLookupByLibrary.simpleMessage(
      "Jouw tekst — klik om de bron weer te volgen",
    ),
    "weColumnAirports": MessageLookupByLibrary.simpleMessage("Vliegvelden"),
    "weColumnCar": MessageLookupByLibrary.simpleMessage("Met de auto"),
    "weColumnNotes": MessageLookupByLibrary.simpleMessage("Let op"),
    "weColumnParking": MessageLookupByLibrary.simpleMessage("Parkeren"),
    "weColumnPublicTransport": MessageLookupByLibrary.simpleMessage(
      "Openbaar vervoer",
    ),
    "weDeviceMobile": MessageLookupByLibrary.simpleMessage("Mobiel"),
    "weDeviceWeb": MessageLookupByLibrary.simpleMessage("Web"),
    "weDiscard": MessageLookupByLibrary.simpleMessage("Verwerpen"),
    "weDiscardCancel": MessageLookupByLibrary.simpleMessage("Verder bewerken"),
    "weDiscardConfirm": MessageLookupByLibrary.simpleMessage("Verwerpen"),
    "weDiscardMessage": MessageLookupByLibrary.simpleMessage(
      "Elke taal gaat terug naar wat je het laatst hebt opgeslagen. Dit kun je niet ongedaan maken.",
    ),
    "weDiscardTitle": MessageLookupByLibrary.simpleMessage(
      "Niet-opgeslagen wijzigingen verwerpen?",
    ),
    "weEditingChip": m109,
    "weErrorLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Kon de website-inhoud niet laden",
    ),
    "weErrorPublishFailed": MessageLookupByLibrary.simpleMessage(
      "Publiceren mislukt — je wijzigingen blijven als concept bewaard",
    ),
    "weErrorResetFailed": MessageLookupByLibrary.simpleMessage(
      "Kon dit veld niet terugzetten naar AI",
    ),
    "weErrorSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Kon je wijzigingen niet opslaan — ze blijven in de editor staan",
    ),
    "weErrorTranslateFailed": MessageLookupByLibrary.simpleMessage(
      "Kon de vertaling niet verversen — de laatste goede versie blijft staan",
    ),
    "weExternalLodgifyNote": MessageLookupByLibrary.simpleMessage(
      "Betalingsschema, annulering en borg komen uit je Lodgify-instellingen. De console is niet de bron voor boekingsvoorwaarden — pas ze daar aan.",
    ),
    "weFieldAlt": MessageLookupByLibrary.simpleMessage("Alt-tekst"),
    "weFieldAltSummary": MessageLookupByLibrary.simpleMessage(
      "Alt-tekst (samenvattend)",
    ),
    "weFieldCallout": MessageLookupByLibrary.simpleMessage(
      "Uitgelichte waarschuwing",
    ),
    "weFieldCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "weFieldCheckInNote": MessageLookupByLibrary.simpleMessage(
      "Toelichting inchecken",
    ),
    "weFieldCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "weFieldCleaningNote": MessageLookupByLibrary.simpleMessage(
      "Schoonmaak en linnen",
    ),
    "weFieldError": MessageLookupByLibrary.simpleMessage("Mislukt"),
    "weFieldExperience": m110,
    "weFieldHeadline": MessageLookupByLibrary.simpleMessage("Titel"),
    "weFieldHeroPhotos": MessageLookupByLibrary.simpleMessage("Hero-foto\'s"),
    "weFieldHighlight": m111,
    "weFieldIntro": MessageLookupByLibrary.simpleMessage("Intro"),
    "weFieldLocationLine": MessageLookupByLibrary.simpleMessage("Locatieregel"),
    "weFieldMapEmbedUrl": MessageLookupByLibrary.simpleMessage(
      "Insluitlink kaart",
    ),
    "weFieldMapLinkUrl": MessageLookupByLibrary.simpleMessage(
      "Link \'open in kaarten\'",
    ),
    "weFieldMapQuery": MessageLookupByLibrary.simpleMessage(
      "Zoekterm voor de kaart",
    ),
    "weFieldPrivacyIntro": MessageLookupByLibrary.simpleMessage("Inleiding"),
    "weFieldSearchName": MessageLookupByLibrary.simpleMessage(
      "Naam voor zoekmachines",
    ),
    "weFieldSiteLocation": MessageLookupByLibrary.simpleMessage("Locatieregel"),
    "weFieldSiteName": MessageLookupByLibrary.simpleMessage("Naam"),
    "weFieldSubline": MessageLookupByLibrary.simpleMessage("Onderregel"),
    "weFieldSubmit": MessageLookupByLibrary.simpleMessage("Knop"),
    "weFieldSubtitle": MessageLookupByLibrary.simpleMessage("Ondertitel"),
    "weFieldSuccess": MessageLookupByLibrary.simpleMessage("Gelukt"),
    "weFieldTitle": MessageLookupByLibrary.simpleMessage("Titel"),
    "weFieldWifiNote": MessageLookupByLibrary.simpleMessage("Wifi"),
    "weFilterOnlyChanged": MessageLookupByLibrary.simpleMessage(
      "Alleen gewijzigd",
    ),
    "weFixedColumnsMeta": MessageLookupByLibrary.simpleMessage(
      "vaste kolommen",
    ),
    "weFormFieldEmail": MessageLookupByLibrary.simpleMessage("E-mail"),
    "weFormFieldMessage": MessageLookupByLibrary.simpleMessage("Bericht"),
    "weFormFieldName": MessageLookupByLibrary.simpleMessage("Naam"),
    "weFormFieldPeriod": MessageLookupByLibrary.simpleMessage(
      "Gewenste periode",
    ),
    "weFreshNotice": MessageLookupByLibrary.simpleMessage(
      "Nieuw concept, komt overeen met je laatste bron.",
    ),
    "weGroupIntro": m112,
    "weHidePreview": MessageLookupByLibrary.simpleMessage(
      "Voorbeeld verbergen",
    ),
    "weHintMap": MessageLookupByLibrary.simpleMessage(
      "Bepaalt waar de speld op de kaart staat; wordt niet als tekst gelezen.",
    ),
    "weHintSeo": MessageLookupByLibrary.simpleMessage(
      "Dit veld staat niet in de pagina: het is de titel in de browsertab en de omschrijving in Google.",
    ),
    "weHintStateError": MessageLookupByLibrary.simpleMessage(
      "Alleen zichtbaar bij een fout in het formulier.",
    ),
    "weHintStateSuccess": MessageLookupByLibrary.simpleMessage(
      "Alleen zichtbaar na het versturen van het formulier.",
    ),
    "weItemAmenity": MessageLookupByLibrary.simpleMessage("Voorziening"),
    "weItemColumn": MessageLookupByLibrary.simpleMessage("Kolom"),
    "weItemDistance": MessageLookupByLibrary.simpleMessage("Afstand"),
    "weItemFact": MessageLookupByLibrary.simpleMessage("Feit"),
    "weItemFormField": MessageLookupByLibrary.simpleMessage("Veld"),
    "weItemGroup": MessageLookupByLibrary.simpleMessage("Groep"),
    "weItemHighlight": MessageLookupByLibrary.simpleMessage("Hoogtepunt"),
    "weItemKeyFact": MessageLookupByLibrary.simpleMessage("Kerncijfer"),
    "weItemLine": MessageLookupByLibrary.simpleMessage("Regel"),
    "weItemParagraph": MessageLookupByLibrary.simpleMessage("Alinea"),
    "weItemSection": MessageLookupByLibrary.simpleMessage("Sectie"),
    "weItemTime": MessageLookupByLibrary.simpleMessage("Tijd"),
    "weLaneChanged": m113,
    "weLangDutch": MessageLookupByLibrary.simpleMessage("Nederlands"),
    "weLangEnglish": MessageLookupByLibrary.simpleMessage("Engels"),
    "weLangNorwegian": MessageLookupByLibrary.simpleMessage("Noors"),
    "weLeaveCancel": MessageLookupByLibrary.simpleMessage("Blijven"),
    "weLeaveConfirm": MessageLookupByLibrary.simpleMessage("Toch weggaan"),
    "weLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "Er is nog niets naar de site geschreven. Als je weggaat blijven je wijzigingen hier staan, maar bij het sluiten van het tabblad ben je ze kwijt.",
    ),
    "weLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "Je hebt niet-opgeslagen wijzigingen",
    ),
    "weListAdd": m114,
    "weListColumns": MessageLookupByLibrary.simpleMessage("Kolommen"),
    "weListCounter": m115,
    "weListDistances": MessageLookupByLibrary.simpleMessage("Afstanden"),
    "weListEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Deze lijst verschijnt pas op de website als er iets in staat.",
    ),
    "weListEmptyTitle": m116,
    "weListFacts": MessageLookupByLibrary.simpleMessage("Feiten"),
    "weListFormFields": MessageLookupByLibrary.simpleMessage("Velden"),
    "weListGroups": MessageLookupByLibrary.simpleMessage("Groepen"),
    "weListKeyFacts": MessageLookupByLibrary.simpleMessage("Kerncijfers"),
    "weListLines": MessageLookupByLibrary.simpleMessage("Regels"),
    "weListMaxReached": m117,
    "weListMaxReason": MessageLookupByLibrary.simpleMessage(
      "Verwijder eerst een rij",
    ),
    "weListMinReason": m118,
    "weListParagraphs": MessageLookupByLibrary.simpleMessage("Alinea\'s"),
    "weListSections": MessageLookupByLibrary.simpleMessage("Secties"),
    "weListTimes": MessageLookupByLibrary.simpleMessage(
      "Check-in en check-out",
    ),
    "weLivePreview": MessageLookupByLibrary.simpleMessage("Live voorbeeld"),
    "weLoadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "De editor toont geen velden zolang de inhoud van deze website niet geladen is.",
    ),
    "weLoadFailedRetry": MessageLookupByLibrary.simpleMessage(
      "Opnieuw proberen",
    ),
    "weLocaleSourceBadge": MessageLookupByLibrary.simpleMessage("bron"),
    "weLockedCounter": m119,
    "weMediaAdd": m120,
    "weMediaCancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "weMediaChoose": MessageLookupByLibrary.simpleMessage("Kiezen"),
    "weMediaEmptyBody": MessageLookupByLibrary.simpleMessage(
      "Upload je eerste foto\'s via het tabblad Uploaden.",
    ),
    "weMediaEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Nog geen foto\'s",
    ),
    "weMediaFirst": MessageLookupByLibrary.simpleMessage("Eerste"),
    "weMediaFootnote": m121,
    "weMediaMinReached": m122,
    "weMediaPending": m123,
    "weMediaPickerHint": m124,
    "weMediaPickerSingleHint": MessageLookupByLibrary.simpleMessage(
      "Kies één foto uit de bibliotheek of upload een nieuwe. Kiezen vervangt de huidige.",
    ),
    "weMediaReplace": MessageLookupByLibrary.simpleMessage("Vervangen"),
    "weMediaTabLibrary": MessageLookupByLibrary.simpleMessage("Bibliotheek"),
    "weMediaTabUpload": MessageLookupByLibrary.simpleMessage("Uploaden"),
    "weMediaTitleGallery": MessageLookupByLibrary.simpleMessage("Alle foto\'s"),
    "weMediaTitleHero": MessageLookupByLibrary.simpleMessage("Hero-foto\'s"),
    "weMediaTitleHomeGallery": MessageLookupByLibrary.simpleMessage(
      "Uitgelichte foto\'s",
    ),
    "weMediaTitleRowImage": MessageLookupByLibrary.simpleMessage("Afbeelding"),
    "weMediaUnused": MessageLookupByLibrary.simpleMessage("Ongebruikt"),
    "wePageArea": MessageLookupByLibrary.simpleMessage("Omgeving"),
    "wePageGallery": MessageLookupByLibrary.simpleMessage("Galerij"),
    "wePageHome": MessageLookupByLibrary.simpleMessage("Home"),
    "wePageLegal": MessageLookupByLibrary.simpleMessage("Juridisch"),
    "wePagePractical": MessageLookupByLibrary.simpleMessage("Praktisch"),
    "wePairDistance": MessageLookupByLibrary.simpleMessage("Afstand"),
    "wePairLabel": MessageLookupByLibrary.simpleMessage("Label"),
    "wePairPlaceholder": MessageLookupByLibrary.simpleMessage("Placeholder"),
    "wePairTime": MessageLookupByLibrary.simpleMessage("Tijd"),
    "wePairValue": MessageLookupByLibrary.simpleMessage("Waarde"),
    "wePairWhat": MessageLookupByLibrary.simpleMessage("Wat"),
    "wePreviewLabel": m125,
    "wePreviewLatest": MessageLookupByLibrary.simpleMessage(
      "Nieuwste bekijken",
    ),
    "wePreviewNoDomain": MessageLookupByLibrary.simpleMessage(
      "jouw-site.example",
    ),
    "wePreviewTranslation": MessageLookupByLibrary.simpleMessage(
      "Vertaling bekijken",
    ),
    "wePublish": MessageLookupByLibrary.simpleMessage("Publiceren"),
    "wePublishAll": MessageLookupByLibrary.simpleMessage(
      "Alle talen publiceren",
    ),
    "wePublishCancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "wePublishConfirm": m126,
    "wePublishDraft": MessageLookupByLibrary.simpleMessage(
      "Concept — nog niet nagekeken",
    ),
    "wePublishDraftTranslatesNow": MessageLookupByLibrary.simpleMessage(
      "Nog niet nagekeken · wordt nu vertaald",
    ),
    "wePublishFooter": m127,
    "wePublishModalTitle": MessageLookupByLibrary.simpleMessage(
      "Wat gaat live",
    ),
    "wePublishNeedsSave": MessageLookupByLibrary.simpleMessage(
      "Sla je wijzigingen eerst op",
    ),
    "wePublishNotSeen": MessageLookupByLibrary.simpleMessage("Niet bekeken"),
    "wePublishNothingChanged": MessageLookupByLibrary.simpleMessage(
      "Niets gewijzigd",
    ),
    "wePublishOpen": MessageLookupByLibrary.simpleMessage("Openen"),
    "wePublishPageSeen": m128,
    "wePublishPageUnseen": m129,
    "wePublishPartlySeen": m130,
    "wePublishPerPage": MessageLookupByLibrary.simpleMessage("Per pagina"),
    "wePublishReady": MessageLookupByLibrary.simpleMessage("Klaar"),
    "wePublishReadyNote": MessageLookupByLibrary.simpleMessage(
      "Gepubliceerd zoals geschreven",
    ),
    "wePublishRetranslate": MessageLookupByLibrary.simpleMessage(
      "Opnieuw vertalen",
    ),
    "wePublishRetranslateNote": MessageLookupByLibrary.simpleMessage(
      "Verouderd — wordt vernieuwd",
    ),
    "wePublishReviewed": MessageLookupByLibrary.simpleMessage("Nagekeken"),
    "wePublishSeen": MessageLookupByLibrary.simpleMessage("Bekeken"),
    "wePublishSkipped": MessageLookupByLibrary.simpleMessage("Overgeslagen"),
    "wePublishSkippedNote": MessageLookupByLibrary.simpleMessage(
      "blijft staan zoals hij nu live is",
    ),
    "wePublishSourceDelta": m131,
    "wePublishSourceOnly": m132,
    "wePublishSourceRole": m133,
    "wePublishSubtitle": m134,
    "wePublishTargetDelta": m135,
    "wePublishTitle": MessageLookupByLibrary.simpleMessage(
      "Alle talen publiceren",
    ),
    "weResetToAi": MessageLookupByLibrary.simpleMessage("Terug naar AI"),
    "weRibbonDraft": MessageLookupByLibrary.simpleMessage(
      "Conceptvertaling — alleen voor jou zichtbaar tot je publiceert.",
    ),
    "weRibbonStale": MessageLookupByLibrary.simpleMessage(
      "Eerder voorbeeld — wordt automatisch bijgewerkt bij publiceren.",
    ),
    "weRowDeleted": MessageLookupByLibrary.simpleMessage("Regel verwijderd."),
    "weRowMediaPending": MessageLookupByLibrary.simpleMessage(
      "Eén afbeelding per rij. De mediakiezer komt met het beeldbeheer.",
    ),
    "weSave": MessageLookupByLibrary.simpleMessage("Wijzigingen opslaan"),
    "weSaveDirty": MessageLookupByLibrary.simpleMessage(
      "Niet-gepubliceerde wijzigingen · vertaalt automatisch bij publiceren",
    ),
    "weSavePublished": MessageLookupByLibrary.simpleMessage(
      "Gepubliceerd · alle talen",
    ),
    "weSharedPhotosNote": MessageLookupByLibrary.simpleMessage(
      "Foto\'s worden gedeeld over alle talen — bewerk ze in de bron.",
    ),
    "weSharedValueMeta": MessageLookupByLibrary.simpleMessage(
      "waarde is gedeeld over talen",
    ),
    "weShowPreview": MessageLookupByLibrary.simpleMessage("Voorbeeld tonen"),
    "weSourceChip": m136,
    "weStaleNotice": MessageLookupByLibrary.simpleMessage(
      "Voorbeeld toont een eerdere bronwijziging.",
    ),
    "weStatusCleanBody": m137,
    "weStatusCleanTitle": MessageLookupByLibrary.simpleMessage(
      "Alles gepubliceerd",
    ),
    "weStatusSavedBody": m138,
    "weStatusSavedTitle": MessageLookupByLibrary.simpleMessage(
      "Opgeslagen · niet gepubliceerd",
    ),
    "weStatusUnsavedBody": MessageLookupByLibrary.simpleMessage(
      "Er wordt niets bewaard tot je op Wijzigingen opslaan klikt",
    ),
    "weStatusUnsavedTitle": MessageLookupByLibrary.simpleMessage(
      "Niet-opgeslagen wijzigingen",
    ),
    "weStructureLocked": m139,
    "weUndo": MessageLookupByLibrary.simpleMessage("Ongedaan maken"),
    "weUndoSwitchNotice": m140,
    "weUploadDone": m141,
    "weUploadDropTitle": MessageLookupByLibrary.simpleMessage(
      "Sleep foto\'s hierheen of kies bestanden",
    ),
    "weUploadFailed": MessageLookupByLibrary.simpleMessage(
      "Uploaden is mislukt. Probeer het opnieuw.",
    ),
    "weUploadInProgress": MessageLookupByLibrary.simpleMessage("Uploaden…"),
    "weUploadRejectedPortrait": MessageLookupByLibrary.simpleMessage(
      "Staand formaat. Gebruik een liggende foto.",
    ),
    "weUploadRejectedTooLarge": MessageLookupByLibrary.simpleMessage(
      "Te groot. Maximaal 8 MB.",
    ),
    "weUploadRejectedTooSmall": m142,
    "weUploadRejectedType": MessageLookupByLibrary.simpleMessage(
      "Dit bestandstype wordt niet ondersteund. Exporteer als JPG of WebP.",
    ),
    "weUploadRequirements": MessageLookupByLibrary.simpleMessage(
      "JPG of WebP · minimaal 1600 × 1200 · maximaal 8 MB · liggend",
    ),
    "weUploadResizeNote": MessageLookupByLibrary.simpleMessage(
      "Grote bestanden worden automatisch verkleind voor de website.",
    ),
    "wealth": MessageLookupByLibrary.simpleMessage("Welvaart"),
    "websiteLanguagesFooter": MessageLookupByLibrary.simpleMessage(
      "De talen die je publieke website aan gasten aanbiedt. Voeg talen toe of verwijder ze.",
    ),
    "websiteLanguagesSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Websitetalen",
    ),
    "weight": MessageLookupByLibrary.simpleMessage("Gewicht"),
    "welcome": MessageLookupByLibrary.simpleMessage("Welkom"),
    "width": MessageLookupByLibrary.simpleMessage("Breedte"),
    "wifi": MessageLookupByLibrary.simpleMessage("WiFi"),
    "wine": MessageLookupByLibrary.simpleMessage("Wijn"),
    "wineAndGlass": MessageLookupByLibrary.simpleMessage("Wijn en glas"),
    "wineBottle": MessageLookupByLibrary.simpleMessage("Wijnfles"),
    "wineList": MessageLookupByLibrary.simpleMessage("Wijnlijst"),
    "wishlist": MessageLookupByLibrary.simpleMessage("Verlanglijst"),
    "wok": MessageLookupByLibrary.simpleMessage("Wok"),
    "woman": MessageLookupByLibrary.simpleMessage("Vrouw"),
    "write": MessageLookupByLibrary.simpleMessage("Schrijven"),
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
    "yesLabel": MessageLookupByLibrary.simpleMessage("Ja"),
  };
}
