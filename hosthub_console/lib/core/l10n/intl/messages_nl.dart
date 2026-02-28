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

  static String m0(error) => "Content laden mislukt: ${error}";

  static String m1(version) =>
      "Huidige content vervangen door versie ${version}? De herstelde content wordt opgeslagen als concept ter controle.";

  static String m2(date) => "Gepubliceerd ${date}";

  static String m3(version) => "Versie ${version}";

  static String m4(error) => "Contentdocumenten laden mislukt: ${error}";

  static String m5(publishedAt) => "Gepubliceerd ${publishedAt}";

  static String m6(status, updatedAt) => "${status} • bijgewerkt ${updatedAt}";

  static String m7(slug, version) => "${slug} (v${version})";

  static String m8(error) => "Gebruiker kon niet worden aangemaakt: ${error}";

  static String m9(email) =>
      "Weet je zeker dat je ${email} wilt verwijderen? Dit verwijdert ook de inhoud van dit account en kan niet ongedaan worden gemaakt.";

  static String m10(count) => "Minimaal ${count} tekens";

  static String m11(fieldType) =>
      "Veld is gekoppeld aan veld van type \'${fieldType}\'";

  static String m12(locale) => "Weergavenaam (${locale})";

  static String m13(role) => "Rol: ${role}";

  static String m14(date) => "Sinds ${date}";

  static String m15(name) => "Wijzig template-gegevens ${name}";

  static String m16(code) => "Veldnaam (${code})";

  static String m17(count) =>
      "${count} veld${Intl.plural(count, one: '', other: 'en')}";

  static String m18(path) => "Standaard seed-map: ${path}";

  static String m19(path) => "JSON opgeslagen in ${path}";

  static String m20(code) => "Taal ${code}";

  static String m21(code) => "Lijstnaam (${code})";

  static String m22(code) => "Meervoudige naam (${code})";

  static String m23(count) =>
      "${count} voorbeeld${Intl.plural(count, one: 'item', other: 'items')}";

  static String m24(prod, dev) => "${prod} prod / ${dev} dev";

  static String m25(error) => "Kon gebruiker niet laden: ${error}";

  static String m26(error) => "Kon gebruikers niet laden: ${error}";

  static String m27(time) => "Laatste sync: ${time}";

  static String m28(error) => "Inloggen mislukt: ${error}";

  static String m29(email) =>
      "We hebben een magic link gestuurd naar ${email}. Controleer je inbox en spamfolder.";

  static String m30(error) => "Kon wachtwoord niet wijzigen: ${error}";

  static String m31(error) => "Kon profiel niet laden: ${error}";

  static String m32(seconds) => "Opnieuw verzenden over ${seconds} s";

  static String m33(propertyName) =>
      "Opbrengsten voor ${propertyName} uit Lodgify boekingen.";

  static String m34(quarter, year) => "Kwartaal ${quarter} ${year}";

  static String m35(error) => "Sites laden mislukt: ${error}";

  static String m36(defaultLocale, locales) =>
      "Taal: ${defaultLocale} • Talen: ${locales}";

  static String m37(status) => "Abonnement: ${status}";

  static String m38(table) =>
      "Kan de gegevens niet laden omdat Supabase de tabel \"${table}\" niet kan vinden. Voer de nieuwste database-migraties uit en vernieuw de schema-cache.";

  static String m39(error) => "Kan adminrechten niet wijzigen: ${error}";

  static String m40(error) => "Kon profiel niet bijwerken: ${error}";

  static String m41(error) => "Kon gebruiker niet verwijderen: ${error}";

  static String m42(email) => "Verificatiecode verstuurd naar ${email}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add": MessageLookupByLibrary.simpleMessage("Toevoegen"),
    "addressBook": MessageLookupByLibrary.simpleMessage("Adresboek"),
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
    "appName": MessageLookupByLibrary.simpleMessage("HostHub"),
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
    "changePasswordDescription": MessageLookupByLibrary.simpleMessage(
      "Stel een tijdelijk wachtwoord in.",
    ),
    "changePasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord wijzigen",
    ),
    "changesWillBeLost": MessageLookupByLibrary.simpleMessage(
      "Wijzigingen gaan verloren",
    ),
    "channelFeeDefaultsDescription": MessageLookupByLibrary.simpleMessage(
      "Standaard commissiepercentages wanneer er geen override per property is ingesteld.",
    ),
    "channelFeeDefaultsHeader": MessageLookupByLibrary.simpleMessage(
      "Kanaal fee standaard (%)",
    ),
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
    "cmsContentDescription": MessageLookupByLibrary.simpleMessage(
      "Bekijk en beheer alle websitecontent voor deze site.",
    ),
    "cmsContentTitle": MessageLookupByLibrary.simpleMessage("Website Content"),
    "cmsDiscardButton": MessageLookupByLibrary.simpleMessage("Verwerpen"),
    "cmsHomePageSection": MessageLookupByLibrary.simpleMessage("Homepagina"),
    "cmsLoadFailed": m0,
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
    "cmsRestoreConfirmBody": m1,
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
    "cmsVersionDate": m2,
    "cmsVersionHistory": MessageLookupByLibrary.simpleMessage(
      "Versiegeschiedenis",
    ),
    "cmsVersionLabel": m3,
    "code": MessageLookupByLibrary.simpleMessage("Code"),
    "coffee": MessageLookupByLibrary.simpleMessage("Koffie"),
    "coin": MessageLookupByLibrary.simpleMessage("Munt"),
    "coins": MessageLookupByLibrary.simpleMessage("Munten"),
    "column": MessageLookupByLibrary.simpleMessage("Kolom"),
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
    "connectLabel": MessageLookupByLibrary.simpleMessage("Koppel"),
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
    "contentDocumentsLoadFailed": m4,
    "contentDocumentsPublished": m5,
    "contentDocumentsTitle": MessageLookupByLibrary.simpleMessage(
      "Contentdocumenten",
    ),
    "contentDocumentsUpdated": m6,
    "contentDocumentsVersionLabel": m7,
    "copied": MessageLookupByLibrary.simpleMessage("Gekopieerd"),
    "copy": MessageLookupByLibrary.simpleMessage("Kopiëren"),
    "cost": MessageLookupByLibrary.simpleMessage("Kosten"),
    "createUserButton": MessageLookupByLibrary.simpleMessage(
      "Gebruiker aanmaken",
    ),
    "createUserDescription": MessageLookupByLibrary.simpleMessage(
      "Maak een account met e-mailadres en wachtwoord.",
    ),
    "createUserFailed": m8,
    "createUserTitle": MessageLookupByLibrary.simpleMessage(
      "Gebruiker aanmaken",
    ),
    "created": MessageLookupByLibrary.simpleMessage("Aangemaakt"),
    "croissant": MessageLookupByLibrary.simpleMessage("Croissant"),
    "cross": MessageLookupByLibrary.simpleMessage("Kruis"),
    "cube": MessageLookupByLibrary.simpleMessage("Kubus"),
    "cup": MessageLookupByLibrary.simpleMessage("Beker"),
    "currency": MessageLookupByLibrary.simpleMessage("Valuta"),
    "cylinder": MessageLookupByLibrary.simpleMessage("Cilinder"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Donkere modus"),
    "dash": MessageLookupByLibrary.simpleMessage("Streepje"),
    "data": MessageLookupByLibrary.simpleMessage("Gegevens"),
    "dataCenter": MessageLookupByLibrary.simpleMessage("Datacenter"),
    "date": MessageLookupByLibrary.simpleMessage("Datum"),
    "dateRange": MessageLookupByLibrary.simpleMessage("Datumreeks"),
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
    "deleteUserConfirmation": m9,
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
    "enterMinCharacters": m10,
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
    "fieldIsLinkedTo": m11,
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
    "fieldsTranslationLabel": m12,
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
    "indicator": MessageLookupByLibrary.simpleMessage("Indicator"),
    "ingredients": MessageLookupByLibrary.simpleMessage("Ingrediënten"),
    "insect": MessageLookupByLibrary.simpleMessage("Insect"),
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
    "letter": MessageLookupByLibrary.simpleMessage("Letter"),
    "letters": MessageLookupByLibrary.simpleMessage("Letters"),
    "library": MessageLookupByLibrary.simpleMessage("Bibliotheek"),
    "light": MessageLookupByLibrary.simpleMessage("Licht"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Lichte modus"),
    "like": MessageLookupByLibrary.simpleMessage("Vind ik leuk"),
    "lineHeight": MessageLookupByLibrary.simpleMessage("Regelhoogte"),
    "list": MessageLookupByLibrary.simpleMessage("Lijst"),
    "listRoleLabel": m13,
    "listSinceDate": m14,
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
    "listsEditTemplateTitle": m15,
    "listsEmptyState": MessageLookupByLibrary.simpleMessage(
      "Geen lijsttemplates beschikbaar.",
    ),
    "listsFieldNameLabel": m16,
    "listsFieldNamesLabel": MessageLookupByLibrary.simpleMessage("Veldnamen"),
    "listsFieldsLabel": MessageLookupByLibrary.simpleMessage("Velden"),
    "listsFieldsValue": m17,
    "listsGroupByLabel": MessageLookupByLibrary.simpleMessage("Groeperen op"),
    "listsGroupByNone": MessageLookupByLibrary.simpleMessage("Geen groepering"),
    "listsItemHistoryLabel": MessageLookupByLibrary.simpleMessage(
      "Itemhistorie",
    ),
    "listsItemTapLabel": MessageLookupByLibrary.simpleMessage(
      "Gedrag bij tikken",
    ),
    "listsJsonCopied": MessageLookupByLibrary.simpleMessage("JSON gekopieerd"),
    "listsJsonDefaultPathLabel": m18,
    "listsJsonDownloadLabel": MessageLookupByLibrary.simpleMessage(
      "JSON downloaden",
    ),
    "listsJsonSaveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Kan JSON niet opslaan",
    ),
    "listsJsonSaveLabel": MessageLookupByLibrary.simpleMessage("JSON opslaan"),
    "listsJsonSavedToast": m19,
    "listsJsonTab": MessageLookupByLibrary.simpleMessage("JSON-export"),
    "listsLabel": MessageLookupByLibrary.simpleMessage("Lijsttemplates"),
    "listsLayoutTab": MessageLookupByLibrary.simpleMessage("Layout"),
    "listsLocaleLabel": m20,
    "listsLocaleListName": m21,
    "listsLocaleListNamePlural": m22,
    "listsNoFieldsForLocale": MessageLookupByLibrary.simpleMessage(
      "Geen velden voor deze taal.",
    ),
    "listsNoSelection": MessageLookupByLibrary.simpleMessage(
      "Selecteer een template om de instellingen te bekijken.",
    ),
    "listsOverviewSection": MessageLookupByLibrary.simpleMessage("Overzicht"),
    "listsSamplesLabel": MessageLookupByLibrary.simpleMessage("Sample-items"),
    "listsSamplesSingle": m23,
    "listsSamplesSplit": m24,
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
    "loadUserFailed": m25,
    "loadUserFailedMessage": MessageLookupByLibrary.simpleMessage(
      "Kon gebruiker niet laden.",
    ),
    "loadUsersFailed": m26,
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
    "lodgifyApiKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Voer een API-key in om te koppelen.",
    ),
    "lodgifyApiKeySaveFailed": MessageLookupByLibrary.simpleMessage(
      "Opslaan van de Lodgify API-key mislukt.",
    ),
    "lodgifyConnectErrorDescription": MessageLookupByLibrary.simpleMessage(
      "Controleer de API-key en probeer opnieuw. Zorg dat de API-key toegang heeft tot Lodgify.",
    ),
    "lodgifyConnectErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Koppelen met Lodgify mislukt",
    ),
    "lodgifyConnectFailed": MessageLookupByLibrary.simpleMessage(
      "Koppelen met Lodgify mislukt.",
    ),
    "lodgifyConnectSuccess": MessageLookupByLibrary.simpleMessage(
      "Lodgify gekoppeld.",
    ),
    "lodgifyLastSyncLabel": m27,
    "lodgifyMissingPropertiesAddAction": MessageLookupByLibrary.simpleMessage(
      "Toevoegen",
    ),
    "lodgifyMissingPropertiesTitle": MessageLookupByLibrary.simpleMessage(
      "Lodgify properties gevonden",
    ),
    "lodgifyNoNewPropertiesFound": MessageLookupByLibrary.simpleMessage(
      "Geen nieuwe Lodgify properties gevonden.",
    ),
    "lodgifySyncCompleted": MessageLookupByLibrary.simpleMessage(
      "Lodgify-synchronisatie voltooid.",
    ),
    "lodgifySyncFailed": MessageLookupByLibrary.simpleMessage(
      "Lodgify-synchronisatie mislukt.",
    ),
    "lodgifySyncLabel": MessageLookupByLibrary.simpleMessage("Sync"),
    "lodgifyTitle": MessageLookupByLibrary.simpleMessage("Lodgify"),
    "login": MessageLookupByLibrary.simpleMessage("Inloggen"),
    "loginDescription": MessageLookupByLibrary.simpleMessage(
      "Log in met je account.",
    ),
    "loginFailed": MessageLookupByLibrary.simpleMessage("Inloggen niet gelukt"),
    "loginFailedCheckDetails": MessageLookupByLibrary.simpleMessage(
      "Inloggen mislukt. Controleer je gegevens.",
    ),
    "loginFailedWithReason": m28,
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Inloggen met Google",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Afmelden"),
    "logoutLabel": MessageLookupByLibrary.simpleMessage("Uitloggen"),
    "longTime": MessageLookupByLibrary.simpleMessage("Lange tijd"),
    "love": MessageLookupByLibrary.simpleMessage("Liefde"),
    "loyaltyCard": MessageLookupByLibrary.simpleMessage("Loyaliteitskaart"),
    "magicLinkSentDescription": m29,
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
    "menuPricing": MessageLookupByLibrary.simpleMessage("Tarieven"),
    "menuRevenue": MessageLookupByLibrary.simpleMessage("Opbrengsten"),
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
    "passwordChangeFailedWithReason": m30,
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
    "position": MessageLookupByLibrary.simpleMessage("Positie"),
    "preferPasswordSignIn": MessageLookupByLibrary.simpleMessage(
      "Liever inloggen met een wachtwoord?",
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
    "pricingCurrencyNote": MessageLookupByLibrary.simpleMessage(
      "Alle bedragen in",
    ),
    "pricingDescription": MessageLookupByLibrary.simpleMessage(
      "Kanaal pricing instellingen per property.",
    ),
    "pricingLinenCost": MessageLookupByLibrary.simpleMessage("Linnenkosten"),
    "pricingOtherCost": MessageLookupByLibrary.simpleMessage("Overige kosten"),
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
    "profileLoadFailed": m31,
    "profileLoadingLabel": MessageLookupByLibrary.simpleMessage(
      "Profiel wordt geladen...",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profiel"),
    "propertyDetailsDescription": MessageLookupByLibrary.simpleMessage(
      "Alleen-lezen overzicht van de geselecteerde property.",
    ),
    "propertyDetailsEmpty": MessageLookupByLibrary.simpleMessage(
      "Selecteer een property om details te bekijken.",
    ),
    "propertyDetailsLabel": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
    "propertyDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
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
    "propertyNameLodgifyHint": MessageLookupByLibrary.simpleMessage(
      "Om de naam te wijzigen, pas deze aan in Lodgify en synchroniseer.",
    ),
    "propertySetupConnectBody": MessageLookupByLibrary.simpleMessage(
      "Ga naar Instellingen om je Lodgify API-sleutel toe te voegen en te verbinden.",
    ),
    "propertySetupConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Verbind Lodgify om je accommodaties te importeren.",
    ),
    "propertySetupConnectTitle": MessageLookupByLibrary.simpleMessage(
      "Verbind Lodgify",
    ),
    "propertySetupGoToSettings": MessageLookupByLibrary.simpleMessage(
      "Ga naar Instellingen",
    ),
    "propertySetupManualBody": MessageLookupByLibrary.simpleMessage(
      "Voeg een property toe zonder Lodgify-koppeling.",
    ),
    "propertySetupManualButton": MessageLookupByLibrary.simpleMessage(
      "Property aanmaken",
    ),
    "propertySetupManualNameLabel": MessageLookupByLibrary.simpleMessage(
      "Property naam",
    ),
    "propertySetupManualNameRequired": MessageLookupByLibrary.simpleMessage(
      "Vul een property naam in.",
    ),
    "propertySetupManualTitle": MessageLookupByLibrary.simpleMessage(
      "Handmatig aanmaken",
    ),
    "propertySetupOrDivider": MessageLookupByLibrary.simpleMessage("of"),
    "propertySetupSyncBody": MessageLookupByLibrary.simpleMessage(
      "Lodgify is verbonden. Synchroniseer je accommodaties vanuit Lodgify om te beginnen.",
    ),
    "propertySetupSyncDescription": MessageLookupByLibrary.simpleMessage(
      "Synchroniseer je accommodaties vanuit Lodgify.",
    ),
    "propertySetupSyncTitle": MessageLookupByLibrary.simpleMessage(
      "Synchroniseer accommodaties",
    ),
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
    "repair": MessageLookupByLibrary.simpleMessage("Repareren"),
    "repeat": MessageLookupByLibrary.simpleMessage("Herhalen"),
    "requestNewPasswordEmail": MessageLookupByLibrary.simpleMessage(
      "Nieuwe resetmail aanvragen",
    ),
    "requiredField": MessageLookupByLibrary.simpleMessage(
      "Dit is een verplicht veld",
    ),
    "resendAvailableIn": m32,
    "resendCode": MessageLookupByLibrary.simpleMessage(
      "Code opnieuw verzenden",
    ),
    "reservationAdults": MessageLookupByLibrary.simpleMessage("Volwassenen"),
    "reservationCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "reservationCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "reservationChildren": MessageLookupByLibrary.simpleMessage("Kinderen"),
    "reservationCloseTooltip": MessageLookupByLibrary.simpleMessage("Sluiten"),
    "reservationCreatedAt": MessageLookupByLibrary.simpleMessage("Aangemaakt"),
    "reservationEmail": MessageLookupByLibrary.simpleMessage("E-mail"),
    "reservationGross": MessageLookupByLibrary.simpleMessage("Bruto"),
    "reservationGuestTotal": MessageLookupByLibrary.simpleMessage("Totaal"),
    "reservationId": MessageLookupByLibrary.simpleMessage("Reservering-ID"),
    "reservationInfants": MessageLookupByLibrary.simpleMessage("Baby\'s"),
    "reservationName": MessageLookupByLibrary.simpleMessage("Naam"),
    "reservationNet": MessageLookupByLibrary.simpleMessage("Netto"),
    "reservationNights": MessageLookupByLibrary.simpleMessage("Nachten"),
    "reservationNotes": MessageLookupByLibrary.simpleMessage("Notities"),
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
    "revenueColumnBooker": MessageLookupByLibrary.simpleMessage("Boeker"),
    "revenueColumnChannelFee": MessageLookupByLibrary.simpleMessage(
      "Kanaal\nfee",
    ),
    "revenueColumnCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "revenueColumnCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "revenueColumnFixedCosts": MessageLookupByLibrary.simpleMessage(
      "Vaste\nkosten",
    ),
    "revenueColumnNet": MessageLookupByLibrary.simpleMessage("Netto"),
    "revenueColumnNightlyRate": MessageLookupByLibrary.simpleMessage(
      "Nacht\ntarief",
    ),
    "revenueColumnNights": MessageLookupByLibrary.simpleMessage("Nachten"),
    "revenueColumnTotal": MessageLookupByLibrary.simpleMessage("Totaal"),
    "revenueDescription": m33,
    "revenueFees": MessageLookupByLibrary.simpleMessage("Fees"),
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
    "revenueQuarterLabel": m34,
    "revenueRefreshTooltip": MessageLookupByLibrary.simpleMessage("Vernieuwen"),
    "revenueServiceCosts": MessageLookupByLibrary.simpleMessage(
      "Servicekosten",
    ),
    "revenueTotalBookings": MessageLookupByLibrary.simpleMessage(
      "Totaal boekingen",
    ),
    "revenueTotalRevenue": MessageLookupByLibrary.simpleMessage("Totale omzet"),
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
    "serverSettingsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Admin-instellingen die voor alle gebruikers gelden.",
    ),
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
    "showCalendarTabLabel": MessageLookupByLibrary.simpleMessage(
      "Kalender tab zichtbaar",
    ),
    "showErrorDetails": MessageLookupByLibrary.simpleMessage("Toon details"),
    "showStartTabLabel": MessageLookupByLibrary.simpleMessage(
      "Start tab zichtbaar",
    ),
    "signInWithMagicLink": MessageLookupByLibrary.simpleMessage(
      "Inloggen met magic link",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Registreren"),
    "signUpFailed": MessageLookupByLibrary.simpleMessage(
      "Aanmelden niet gelukt",
    ),
    "sitesCreateButton": MessageLookupByLibrary.simpleMessage("Site aanmaken"),
    "sitesDefaultLocaleHint": MessageLookupByLibrary.simpleMessage("en"),
    "sitesDefaultLocaleLabel": MessageLookupByLibrary.simpleMessage(
      "Standaardtaal",
    ),
    "sitesDescription": MessageLookupByLibrary.simpleMessage(
      "Elke website is gekoppeld aan een workspace met talen en domeinen.",
    ),
    "sitesEmpty": MessageLookupByLibrary.simpleMessage(
      "Nog geen sites ingesteld.",
    ),
    "sitesLoadFailed": m35,
    "sitesLocaleSummary": m36,
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
    "subscriptionChipLabel": m37,
    "subscriptionLabel": MessageLookupByLibrary.simpleMessage("Abonnement"),
    "subtract": MessageLookupByLibrary.simpleMessage("Aftrekken"),
    "suitcase": MessageLookupByLibrary.simpleMessage("Koffer"),
    "sum": MessageLookupByLibrary.simpleMessage("Som"),
    "sun": MessageLookupByLibrary.simpleMessage("Zon"),
    "sunlight": MessageLookupByLibrary.simpleMessage("Zonlicht"),
    "supabaseTableMissing": m38,
    "symbol": MessageLookupByLibrary.simpleMessage("Symbool"),
    "systemSetting": MessageLookupByLibrary.simpleMessage("Systeeminstelling"),
    "tShirt": MessageLookupByLibrary.simpleMessage("T-shirt"),
    "table": MessageLookupByLibrary.simpleMessage("Tabel"),
    "tableOfContent": MessageLookupByLibrary.simpleMessage("Inhoudsopgave"),
    "tag": MessageLookupByLibrary.simpleMessage("Tag"),
    "taxi": MessageLookupByLibrary.simpleMessage("Taxi"),
    "text": MessageLookupByLibrary.simpleMessage("Tekst"),
    "thai": MessageLookupByLibrary.simpleMessage("Thais"),
    "theme": MessageLookupByLibrary.simpleMessage("Thema"),
    "thumb": MessageLookupByLibrary.simpleMessage("Duim"),
    "time": MessageLookupByLibrary.simpleMessage("Tijd"),
    "timer": MessageLookupByLibrary.simpleMessage("Timer"),
    "todoList": MessageLookupByLibrary.simpleMessage("Takenlijst"),
    "toggle": MessageLookupByLibrary.simpleMessage("Schakelen"),
    "toggleAdminFailed": m39,
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
    "updateProfileFailed": m40,
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "userCreated": MessageLookupByLibrary.simpleMessage(
      "Gebruiker aangemaakt.",
    ),
    "userDeleteFailed": MessageLookupByLibrary.simpleMessage(
      "Kon gebruiker niet verwijderen.",
    ),
    "userDeleteFailedWithReason": m41,
    "userDeleted": MessageLookupByLibrary.simpleMessage(
      "Gebruiker verwijderd.",
    ),
    "userIdLabel": MessageLookupByLibrary.simpleMessage("Gebruikers-ID"),
    "userSettingsAction": MessageLookupByLibrary.simpleMessage(
      "Gebruikersinstellingen",
    ),
    "userSettingsLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Gebruikersinstellingen laden mislukt.",
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
    "verificationCodeSentText": m42,
    "verify": MessageLookupByLibrary.simpleMessage("Verifiëren"),
    "verticalLine": MessageLookupByLibrary.simpleMessage("Verticale lijn"),
    "walking": MessageLookupByLibrary.simpleMessage("Lopen"),
    "wallet": MessageLookupByLibrary.simpleMessage("Portemonnee"),
    "warning": MessageLookupByLibrary.simpleMessage("Waarschuwing"),
    "waste": MessageLookupByLibrary.simpleMessage("Afval"),
    "watch": MessageLookupByLibrary.simpleMessage("Horloge"),
    "wealth": MessageLookupByLibrary.simpleMessage("Welvaart"),
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
    "yesLabel": MessageLookupByLibrary.simpleMessage("Ja"),
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
    "no": MessageLookupByLibrary.simpleMessage("Nee"),
  };
}
