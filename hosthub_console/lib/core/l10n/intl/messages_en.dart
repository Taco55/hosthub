// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, one: 'Monthly · 1 property', other: 'Monthly · ${count} properties')}";

  static String m1(count) =>
      "${Intl.plural(count, one: '1 property gets this value', other: '${count} properties get this value')}";

  static String m2(count) =>
      "${Intl.plural(count, one: '1 property with its own value stays unchanged.', other: '${count} properties with their own values stay unchanged.')}";

  static String m3(name) => "Remove ${name}?";

  static String m4(language) =>
      "One-time action: sets the source language to ${language}.";

  static String m5(version, environment) =>
      "Version ${version} · ${environment}";

  static String m6(language) =>
      "You\'ll write your website in ${language} from now on. The other languages are re-translated from the new source on publish; locked fields keep your wording.";

  static String m7(language) => "Change the source language to ${language}?";

  static String m8(percentage) => "Commission ${percentage}%";

  static String m9(error) => "Failed to load content: ${error}";

  static String m10(version) =>
      "Replace current content with version ${version}? The restored content will be saved as a draft for review.";

  static String m11(date) => "Published ${date}";

  static String m12(version) => "Version ${version}";

  static String m13(error) => "Failed to load content documents: ${error}";

  static String m14(publishedAt) => "Published ${publishedAt}";

  static String m15(status, updatedAt) => "${status} • updated ${updatedAt}";

  static String m16(slug, version) => "${slug} (v${version})";

  static String m17(following, total) =>
      "${Intl.plural(following, zero: 'No property follows', other: '${following} of ${total} follow')}";

  static String m18(property) =>
      "${property} has its own values — open Pricing";

  static String m19(error) => "Couldn\'t create user: ${error}";

  static String m20(email) =>
      "Are you sure you want to delete ${email}? This also removes the account\'s contents and cannot be undone.";

  static String m21(count) => "At least ${count} characters";

  static String m22(fieldType) =>
      "Field is linked to field of type \'${fieldType}\'";

  static String m23(locale) => "Display name (${locale})";

  static String m24(source) =>
      "Read, snoozed and archived are kept by HostHub itself. ${source} knows nothing about them.";

  static String m25(source) => "Open in ${source}";

  static String m26(count) =>
      "${Intl.plural(count, zero: 'First booking', one: '1 earlier booking', other: '${count} earlier bookings')}";

  static String m27(guest, channel) => "Reply to ${guest} via ${channel}…";

  static String m28(channel) => "Your reply goes out through ${channel}";

  static String m29(source) => "Replying still happens in ${source}.";

  static String m30(date) => "Snoozed until ${date}";

  static String m31(property, dates, channel) =>
      "${property} · ${dates} · via ${channel}";

  static String m32(property, channel) => "${property} · via ${channel}";

  static String m33(language) => "Translate to ${language}";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 unread conversation', other: '${count} unread conversations')}";

  static String m35(role) => "Role: ${role}";

  static String m36(date) => "Since ${date}";

  static String m37(name) => "Edit template details ${name}";

  static String m38(code) => "Field name (${code})";

  static String m39(count) =>
      "${count} ${Intl.plural(count, one: 'field', other: 'fields')}";

  static String m40(path) => "Default seed directory: ${path}";

  static String m41(path) => "JSON saved to ${path}";

  static String m42(code) => "Locale ${code}";

  static String m43(code) => "List name (${code})";

  static String m44(code) => "Plural name (${code})";

  static String m45(count) =>
      "${count} sample ${Intl.plural(count, one: 'item', other: 'items')}";

  static String m46(prod, dev) => "${prod} prod / ${dev} dev";

  static String m47(error) => "Couldn\'t load user: ${error}";

  static String m48(error) => "Couldn\'t load users: ${error}";

  static String m49(time) => "last sync ${time}";

  static String m50(count) =>
      "${Intl.plural(count, one: '1 listing brought over', other: '${count} listings brought over')}";

  static String m51(name) =>
      "Links to ${name}. The website content already on it stays.";

  static String m52(count) =>
      "${Intl.plural(count, one: '1 links to a property you created yourself', other: '${count} link to properties you created yourself')}";

  static String m53(count) =>
      "${Intl.plural(count, one: '1 new listing', other: '${count} new listings')}";

  static String m54(error) => "Login failed: ${error}";

  static String m55(email) =>
      "We sent a magic link to ${email}. Check your inbox and spam folder.";

  static String m56(error) => "Couldn\'t update the password: ${error}";

  static String m57(count, total) =>
      "${count} of ${Intl.plural(total, one: '1 property', other: '${total} properties')}";

  static String m58(percentage) => "Commission ${percentage}%";

  static String m59(nights, rate) => "Gross (${nights} × ${rate})";

  static String m60(percentage) => "Rate markup ${percentage}%";

  static String m61(guests) => "Service (${guests} guests)";

  static String m62(nights, guests, rate, channel) =>
      "${nights}-night stay · ${guests} guests · base rate ${rate}/night via ${channel}";

  static String m63(error) => "Couldn\'t load profile: ${error}";

  static String m64(count) =>
      "${Intl.plural(count, one: '1 booking', other: '${count} bookings')}";

  static String m65(count) =>
      "${Intl.plural(count, one: '1 own value', other: '${count} own values')}";

  static String m66(name) => "Delete ${name}?";

  static String m67(lodgifyId, lastSync) =>
      "Linked · ID ${lodgifyId} · last sync ${lastSync}";

  static String m68(lodgifyId) => "Linked · ID ${lodgifyId} · never synced";

  static String m69(count) =>
      "${Intl.plural(count, one: '1 guest', other: '${count} guests')}";

  static String m70(days) =>
      "${Intl.plural(days, one: 'Per night', other: 'Per ${days} nights')}";

  static String m71(rating) => "${rating} out of 5";

  static String m72(lastSync) =>
      "Last sync with Lodgify: ${lastSync}. Fetches the data again now.";

  static String m73(count) =>
      "${Intl.plural(count, one: '1 room', other: '${count} rooms')}";

  static String m74(name) => "Unlink ${name}?";

  static String m75(language) => "Remove ${language}?";

  static String m76(seconds) => "Resend available in ${seconds} s";

  static String m77(count) => "${count} new";

  static String m78(guests) => "Guests: ${guests}";

  static String m79(nights) => "${nights} nights";

  static String m80(source) => "Source: ${source}";

  static String m81(status) => "Status: ${status}";

  static String m82(property) => "Bookings · ${property}";

  static String m83(month, gross, net) =>
      "${month}: ${gross} gross · ${net} net";

  static String m84(propertyName) => "Revenue · ${propertyName}";

  static String m85(nights) => "${nights} nights";

  static String m86(count) => "${count} bookings";

  static String m87(quarter, year) => "Quarter ${quarter} ${year}";

  static String m88(error) => "Failed to load sites: ${error}";

  static String m89(defaultLocale, locales) =>
      "Locale: ${defaultLocale} • Locales: ${locales}";

  static String m90(status) => "Subscription: ${status}";

  static String m91(table) =>
      "Can’t load data because Supabase couldn’t find the \"${table}\" table. Deploy the latest database migrations and refresh the schema cache.";

  static String m92(siteName) =>
      "Invite someone to collaborate on \"${siteName}\".";

  static String m93(name) => "Are you sure you want to remove ${name}?";

  static String m94(error) => "Couldn\'t update admin access: ${error}";

  static String m95(error) => "Couldn\'t update profile: ${error}";

  static String m96(error) => "Couldn\'t delete user: ${error}";

  static String m97(email) => "Verification code sent to ${email}";

  static String m98(version) => "v${version}";

  static String m99(source) =>
      "Type over any field to lock it; untouched fields stay auto and follow the ${source} source.";

  static String m100(language) => "You are editing the ${language} translation";

  static String m101(languages) =>
      "${languages} update automatically on publish. Locked fields keep your wording.";

  static String m102(language) => "You\'re writing in ${language}";

  static String m103(lang) => "Editing · ${lang}";

  static String m104(number) => "Experience ${number}";

  static String m105(number) => "Highlight ${number}";

  static String m106(number) => "Introduction of section ${number}";

  static String m107(count) => "${count} changed";

  static String m108(item) => "Add ${item}";

  static String m109(count, max) => "${count} of ${max}";

  static String m110(item) => "No ${item} yet";

  static String m111(max) => "Maximum of ${max} reached";

  static String m112(min) => "There must be at least ${min}";

  static String m113(locked, total) =>
      "${locked} of ${total} fields in your own words";

  static String m114(count) => "Add ${count}";

  static String m115(count, max, min) =>
      "${count} of at most ${max} · at least ${min}";

  static String m116(min) => "There must be at least ${min} photos";

  static String m117(min, max) =>
      "${min} to ${max} photos. The media picker arrives with image management.";

  static String m118(remaining) =>
      "Choose photos from the library or upload new ones. ${remaining} left to choose.";

  static String m119(language) => "${language} preview";

  static String m120(count) => "Publish ${count} languages";

  static String m121(count) =>
      "${count} changed fields · locked fields keep your words";

  static String m122(count) => "${count} changed fields · reviewed";

  static String m123(count) => "${count} changed fields · not reviewed yet";

  static String m124(seen, total) => "${seen} of ${total} reviewed";

  static String m125(count) => "${count} fields changed since the last publish";

  static String m126(source) => "Publish ${source} only";

  static String m127(language) => "${language} · source";

  static String m128(source) =>
      "Your ${source} content publishes as-is. The other languages are re-translated by AI, keeping anything you\'ve locked.";

  static String m129(count, pages) =>
      "${count} changed fields on ${pages} pages";

  static String m130(lang) => "Source · ${lang}";

  static String m131(source, count) =>
      "${source} + ${count} translations are live";

  static String m132(languages) =>
      "${languages} translate when you open them, or on publish";

  static String m133(language) => "You change rows in the source (${language})";

  static String m134(source) => "Now following the ${source} source.";

  static String m135(width, height) => "${width} × ${height}";

  static String m136(width, height) =>
      "Too small (${width} × ${height}). At least 1600 × 1200.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountBillingExternalNotice": MessageLookupByLibrary.simpleMessage(
      "Payment method and invoices are managed at our payment provider. That link is still to come.",
    ),
    "accountBillingHeader": MessageLookupByLibrary.simpleMessage(
      "Subscription & billing",
    ),
    "accountBillingInvoices": MessageLookupByLibrary.simpleMessage("Invoices"),
    "accountBillingInvoicesValue": MessageLookupByLibrary.simpleMessage(
      "View and download your invoices",
    ),
    "accountBillingPaymentMethod": MessageLookupByLibrary.simpleMessage(
      "Payment method",
    ),
    "accountBillingPlan": MessageLookupByLibrary.simpleMessage("Subscription"),
    "accountBillingPlanPro": MessageLookupByLibrary.simpleMessage("Pro"),
    "accountBillingPlanSubtitle": m0,
    "accountBillingVatHint": MessageLookupByLibrary.simpleMessage(
      "Fill this in if your invoice has to be addressed to a company.",
    ),
    "accountBillingVatNumber": MessageLookupByLibrary.simpleMessage(
      "VAT or company number",
    ),
    "accountConnectionNeverSynced": MessageLookupByLibrary.simpleMessage(
      "never synced",
    ),
    "accountConnectionScope": MessageLookupByLibrary.simpleMessage(
      "Bookings, prices and availability",
    ),
    "accountConnectionsFooter": MessageLookupByLibrary.simpleMessage(
      "Payment schedule, cancellation and deposit stay in Lodgify. HostHub only reads them.",
    ),
    "accountConnectionsHeader": MessageLookupByLibrary.simpleMessage(
      "Connections",
    ),
    "accountDefaultsApplied": MessageLookupByLibrary.simpleMessage(
      "Defaults applied.",
    ),
    "accountDefaultsApply": MessageLookupByLibrary.simpleMessage("Apply"),
    "accountDefaultsChannelsHeader": MessageLookupByLibrary.simpleMessage(
      "Channels & costs",
    ),
    "accountDefaultsImpactNone": MessageLookupByLibrary.simpleMessage(
      "No property follows this default",
    ),
    "accountDefaultsImpactNotYetApplied": MessageLookupByLibrary.simpleMessage(
      "Nothing changes until you apply.",
    ),
    "accountDefaultsImpactSingleProperty": MessageLookupByLibrary.simpleMessage(
      "This changes your property",
    ),
    "accountDefaultsImpactSome": m1,
    "accountDefaultsImpactUnchanged": m2,
    "accountDefaultsLanguagesFooter": MessageLookupByLibrary.simpleMessage(
      "This is the starting point for your next property. Existing websites do not change here.",
    ),
    "accountDefaultsLanguagesHeader": MessageLookupByLibrary.simpleMessage(
      "Languages",
    ),
    "accountDefaultsReadOnlyNotice": MessageLookupByLibrary.simpleMessage(
      "Only the account owner can change defaults. Deviating per property is still possible.",
    ),
    "accountDefaultsSubtitle": MessageLookupByLibrary.simpleMessage(
      "What every property inherits, unless that property says otherwise.",
    ),
    "accountDefaultsTitle": MessageLookupByLibrary.simpleMessage("Defaults"),
    "accountInviteMember": MessageLookupByLibrary.simpleMessage(
      "Invite a member",
    ),
    "accountMemberInvited": MessageLookupByLibrary.simpleMessage("· invited"),
    "accountPreferencesMovedFooter": MessageLookupByLibrary.simpleMessage(
      "Interface language and the compact side menu are yours, not the account\'s. They live with your profile at the bottom of the sidebar.",
    ),
    "accountRemoveMemberMessage": MessageLookupByLibrary.simpleMessage(
      "This user loses access to all of your properties.",
    ),
    "accountRemoveMemberTitle": m3,
    "accountRoleAdmin": MessageLookupByLibrary.simpleMessage("Manager"),
    "accountRoleAdminDescription": MessageLookupByLibrary.simpleMessage(
      "Content, pricing and per-property deviations. No billing, no members.",
    ),
    "accountRoleOwner": MessageLookupByLibrary.simpleMessage("Owner"),
    "accountRoleOwnerDescription": MessageLookupByLibrary.simpleMessage(
      "Everything, including billing and members.",
    ),
    "accountRoleViewer": MessageLookupByLibrary.simpleMessage("Read only"),
    "accountRoleViewerDescription": MessageLookupByLibrary.simpleMessage(
      "Can look, cannot change.",
    ),
    "accountTitle": MessageLookupByLibrary.simpleMessage("Account"),
    "accountUsersFooter": MessageLookupByLibrary.simpleMessage(
      "A role applies to the whole account, so to all of your properties. The owner handles everything; a manager handles content and prices, but not billing.",
    ),
    "accountUsersHeader": MessageLookupByLibrary.simpleMessage("Users & roles"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addLanguageAction": MessageLookupByLibrary.simpleMessage("Add language"),
    "addPropertyFooter": MessageLookupByLibrary.simpleMessage(
      "From Lodgify is the normal route. Manual is there for setting up a website before Lodgify is ready.",
    ),
    "addPropertyFromLodgifyBody": MessageLookupByLibrary.simpleMessage(
      "Fetches your listings and shows what is new.",
    ),
    "addPropertyFromLodgifyTitle": MessageLookupByLibrary.simpleMessage(
      "Bring over from Lodgify",
    ),
    "addPropertyLodgifyNotConnected": MessageLookupByLibrary.simpleMessage(
      "Connect Lodgify on Account first.",
    ),
    "addPropertyManualAction": MessageLookupByLibrary.simpleMessage("Create"),
    "addPropertyManualBody": MessageLookupByLibrary.simpleMessage(
      "Just a name. The rest you fill in from the website editor.",
    ),
    "addPropertyManualTitle": MessageLookupByLibrary.simpleMessage(
      "Create manually",
    ),
    "addPropertyNameLabel": MessageLookupByLibrary.simpleMessage(
      "Property name",
    ),
    "addressBook": MessageLookupByLibrary.simpleMessage("Address Book"),
    "adminOnlyBadge": MessageLookupByLibrary.simpleMessage("Admins only"),
    "adminOptionsSectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Settings for the whole environment, not for this account.",
    ),
    "adminRightsActive": MessageLookupByLibrary.simpleMessage(
      "Admin rights enabled",
    ),
    "adminRightsDescription": MessageLookupByLibrary.simpleMessage(
      "Determines whether this user can access the console.",
    ),
    "adminRightsDisabled": MessageLookupByLibrary.simpleMessage(
      "Admin rights disabled.",
    ),
    "adminRightsEnabled": MessageLookupByLibrary.simpleMessage(
      "Admin rights enabled.",
    ),
    "adminRightsTitle": MessageLookupByLibrary.simpleMessage("Admin rights"),
    "adminSettingsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Preferences for your console experience.",
    ),
    "adminSettingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "adoptInterfaceLanguageSubtitle": m4,
    "adoptInterfaceLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Use my interface language",
    ),
    "airplane": MessageLookupByLibrary.simpleMessage("Airplane"),
    "alarm": MessageLookupByLibrary.simpleMessage("Alarm"),
    "alarmClock": MessageLookupByLibrary.simpleMessage("Alarm Clock"),
    "alert": MessageLookupByLibrary.simpleMessage("Alert"),
    "alreadyAnAccount": MessageLookupByLibrary.simpleMessage(
      "Already an account?",
    ),
    "amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "anUnknownErrorOccurred": MessageLookupByLibrary.simpleMessage(
      "An unknown error occurred.",
    ),
    "analysis": MessageLookupByLibrary.simpleMessage("Analysis"),
    "analytics": MessageLookupByLibrary.simpleMessage("Analytics"),
    "appInfoTileTitle": MessageLookupByLibrary.simpleMessage("App information"),
    "appInfoTileValue": m5,
    "appName": MessageLookupByLibrary.simpleMessage("HostHub"),
    "appTitle": MessageLookupByLibrary.simpleMessage("HostHub"),
    "appsTitle": MessageLookupByLibrary.simpleMessage("Apps"),
    "arrow": MessageLookupByLibrary.simpleMessage("Arrow"),
    "arrowsUpDown": MessageLookupByLibrary.simpleMessage("Arrows Up Down"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "authWelcome": MessageLookupByLibrary.simpleMessage("Welcome"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "avocado": MessageLookupByLibrary.simpleMessage("Avocado"),
    "baby": MessageLookupByLibrary.simpleMessage("Baby"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Back to login"),
    "backToOverview": MessageLookupByLibrary.simpleMessage("Back to overview"),
    "balance": MessageLookupByLibrary.simpleMessage("Balance"),
    "balloon": MessageLookupByLibrary.simpleMessage("Balloon"),
    "banner": MessageLookupByLibrary.simpleMessage("Banner"),
    "barcode": MessageLookupByLibrary.simpleMessage("Barcode"),
    "bauble": MessageLookupByLibrary.simpleMessage("Bauble"),
    "beach": MessageLookupByLibrary.simpleMessage("Beach"),
    "beachUmbrella": MessageLookupByLibrary.simpleMessage("Beach Umbrella"),
    "beer": MessageLookupByLibrary.simpleMessage("Beer"),
    "bell": MessageLookupByLibrary.simpleMessage("Bell"),
    "beta": MessageLookupByLibrary.simpleMessage("Beta"),
    "bike": MessageLookupByLibrary.simpleMessage("Bike"),
    "birthday": MessageLookupByLibrary.simpleMessage("Birthday"),
    "blank": MessageLookupByLibrary.simpleMessage("Blank"),
    "blender": MessageLookupByLibrary.simpleMessage("Blender"),
    "bookingLinkLabel": MessageLookupByLibrary.simpleMessage("Booking link"),
    "bookmarks": MessageLookupByLibrary.simpleMessage("Bookmarks"),
    "bottle": MessageLookupByLibrary.simpleMessage("Bottle"),
    "bowlAndChopsticks": MessageLookupByLibrary.simpleMessage(
      "Bowl and Chopsticks",
    ),
    "braces": MessageLookupByLibrary.simpleMessage("Braces"),
    "bread": MessageLookupByLibrary.simpleMessage("Bread"),
    "broccoli": MessageLookupByLibrary.simpleMessage("Broccoli"),
    "brush": MessageLookupByLibrary.simpleMessage("Brush"),
    "budget": MessageLookupByLibrary.simpleMessage("Budget"),
    "bug": MessageLookupByLibrary.simpleMessage("Bug"),
    "bulb": MessageLookupByLibrary.simpleMessage("Bulb"),
    "bulletLists": MessageLookupByLibrary.simpleMessage("Bullet Lists"),
    "bus": MessageLookupByLibrary.simpleMessage("Bus"),
    "business": MessageLookupByLibrary.simpleMessage("Business"),
    "calendar": MessageLookupByLibrary.simpleMessage("Calendar"),
    "call": MessageLookupByLibrary.simpleMessage("Call"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotAddList": MessageLookupByLibrary.simpleMessage("Cannot add list."),
    "cannotDeleteAllUserData": MessageLookupByLibrary.simpleMessage(
      "Cannot delete all user data.",
    ),
    "cannotDeleteField": MessageLookupByLibrary.simpleMessage(
      "Cannot delete field",
    ),
    "cannotLoadLinkData": MessageLookupByLibrary.simpleMessage(
      "Cannot load data from link",
    ),
    "cannotOpenLink": MessageLookupByLibrary.simpleMessage("Cannot open link"),
    "car": MessageLookupByLibrary.simpleMessage("Car"),
    "card": MessageLookupByLibrary.simpleMessage("Card"),
    "carrot": MessageLookupByLibrary.simpleMessage("Carrot"),
    "cart": MessageLookupByLibrary.simpleMessage("Cart"),
    "cash": MessageLookupByLibrary.simpleMessage("Cash"),
    "cat": MessageLookupByLibrary.simpleMessage("Cat"),
    "caution": MessageLookupByLibrary.simpleMessage("Caution"),
    "centerAlignment": MessageLookupByLibrary.simpleMessage("Center Alignment"),
    "changeButton": MessageLookupByLibrary.simpleMessage("Change"),
    "changePasswordDescription": MessageLookupByLibrary.simpleMessage(
      "Set a temporary password.",
    ),
    "changePasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Change password",
    ),
    "changeSourceLanguageConfirmMessage": m6,
    "changeSourceLanguageConfirmTitle": m7,
    "changesWillBeLost": MessageLookupByLibrary.simpleMessage(
      "Changes will be lost",
    ),
    "channelFieldCleaning": MessageLookupByLibrary.simpleMessage("Cleaning"),
    "channelFieldCommission": MessageLookupByLibrary.simpleMessage(
      "Commission",
    ),
    "channelFieldCommissionHint": MessageLookupByLibrary.simpleMessage(
      "What this channel keeps from the booking.",
    ),
    "channelFieldLinen": MessageLookupByLibrary.simpleMessage("Linen"),
    "channelFieldMarkup": MessageLookupByLibrary.simpleMessage("Price markup"),
    "channelFieldMarkupHint": MessageLookupByLibrary.simpleMessage(
      "Raise the channel price relative to your base price.",
    ),
    "channelFieldOther": MessageLookupByLibrary.simpleMessage("Other"),
    "channelFieldService": MessageLookupByLibrary.simpleMessage("Service"),
    "channelSummaryCommission": m8,
    "check": MessageLookupByLibrary.simpleMessage("Check"),
    "cherries": MessageLookupByLibrary.simpleMessage("Cherries"),
    "chicken": MessageLookupByLibrary.simpleMessage("Chicken"),
    "christmas": MessageLookupByLibrary.simpleMessage("Christmas"),
    "circleFilled": MessageLookupByLibrary.simpleMessage("Circle Filled"),
    "circleOutlined": MessageLookupByLibrary.simpleMessage("Circle Outlined"),
    "cleaning": MessageLookupByLibrary.simpleMessage("Cleaning"),
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearSearchTooltip": MessageLookupByLibrary.simpleMessage("Clear search"),
    "clientAppsActiveLabel": MessageLookupByLibrary.simpleMessage("Active"),
    "clientAppsAddDefaultButton": MessageLookupByLibrary.simpleMessage("Add"),
    "clientAppsAllowedTemplatesDescription":
        MessageLookupByLibrary.simpleMessage(
          "Choose the templates that this app can create.",
        ),
    "clientAppsAllowedTemplatesLabel": MessageLookupByLibrary.simpleMessage(
      "Allowed templates",
    ),
    "clientAppsDefaultTemplatesDescription": MessageLookupByLibrary.simpleMessage(
      "Templates that are created during registration and suggested when a new list is created.",
    ),
    "clientAppsDefaultTemplatesEmpty": MessageLookupByLibrary.simpleMessage(
      "No default templates configured yet.",
    ),
    "clientAppsDefaultTemplatesLabel": MessageLookupByLibrary.simpleMessage(
      "Default templates",
    ),
    "clientAppsDefaultTemplatesRequiresAllowed":
        MessageLookupByLibrary.simpleMessage(
          "Select at least one allowed template to choose defaults.",
        ),
    "clientAppsIdLabel": MessageLookupByLibrary.simpleMessage("Client app ID"),
    "clientAppsLabel": MessageLookupByLibrary.simpleMessage("Client apps"),
    "clientAppsMoveDefaultDownTooltip": MessageLookupByLibrary.simpleMessage(
      "Move default template down",
    ),
    "clientAppsMoveDefaultUpTooltip": MessageLookupByLibrary.simpleMessage(
      "Move default template up",
    ),
    "clientAppsNameLabel": MessageLookupByLibrary.simpleMessage("Display name"),
    "clientAppsNoAppsFound": MessageLookupByLibrary.simpleMessage(
      "No client apps configured.",
    ),
    "clientAppsNoSelection": MessageLookupByLibrary.simpleMessage(
      "Select a client app to configure.",
    ),
    "clientAppsRemoveDefaultTooltip": MessageLookupByLibrary.simpleMessage(
      "Remove default template",
    ),
    "clientAppsSelectDefaultLabel": MessageLookupByLibrary.simpleMessage(
      "Pick a template",
    ),
    "clientAppsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Manage which list templates each client app can use.",
    ),
    "clientAppsTemplatesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Template catalog unavailable.",
    ),
    "clientAppsTitle": MessageLookupByLibrary.simpleMessage("Client apps"),
    "clipboardAlert": MessageLookupByLibrary.simpleMessage("Alert"),
    "clipboardCode": MessageLookupByLibrary.simpleMessage("Code"),
    "clipboardContext": MessageLookupByLibrary.simpleMessage("Context"),
    "clipboardDetails": MessageLookupByLibrary.simpleMessage("Details"),
    "clipboardError": MessageLookupByLibrary.simpleMessage("Error"),
    "clipboardTime": MessageLookupByLibrary.simpleMessage("Time"),
    "clock": MessageLookupByLibrary.simpleMessage("Clock"),
    "closeButton": MessageLookupByLibrary.simpleMessage("Close"),
    "clothing": MessageLookupByLibrary.simpleMessage("Clothing"),
    "cmsAddItem": MessageLookupByLibrary.simpleMessage("Add item"),
    "cmsAreaPageSection": MessageLookupByLibrary.simpleMessage(
      "Area & Activities",
    ),
    "cmsBackToSites": MessageLookupByLibrary.simpleMessage("Back to sites"),
    "cmsCabinSection": MessageLookupByLibrary.simpleMessage("Cabin Details"),
    "cmsContactFormSection": MessageLookupByLibrary.simpleMessage(
      "Contact Form",
    ),
    "cmsContentTitle": MessageLookupByLibrary.simpleMessage("Website Content"),
    "cmsDiscardButton": MessageLookupByLibrary.simpleMessage("Discard"),
    "cmsHomePageSection": MessageLookupByLibrary.simpleMessage("Home Page"),
    "cmsLoadFailed": m9,
    "cmsNoContent": MessageLookupByLibrary.simpleMessage(
      "No content documents found for this site.",
    ),
    "cmsNoVersions": MessageLookupByLibrary.simpleMessage(
      "No published versions yet.",
    ),
    "cmsPracticalPageSection": MessageLookupByLibrary.simpleMessage(
      "Practical Info",
    ),
    "cmsPreviewButton": MessageLookupByLibrary.simpleMessage("Preview Website"),
    "cmsPrivacyPageSection": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy",
    ),
    "cmsPublishButton": MessageLookupByLibrary.simpleMessage("Publish"),
    "cmsPublishConfirmBody": MessageLookupByLibrary.simpleMessage(
      "This will make the current content live on the website. Continue?",
    ),
    "cmsPublishConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Publish content",
    ),
    "cmsPublishSuccess": MessageLookupByLibrary.simpleMessage(
      "Content published.",
    ),
    "cmsRemoveItem": MessageLookupByLibrary.simpleMessage("Remove"),
    "cmsRestoreButton": MessageLookupByLibrary.simpleMessage("Restore"),
    "cmsRestoreConfirmBody": m10,
    "cmsRestoreConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Restore version",
    ),
    "cmsRestoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Version restored as draft.",
    ),
    "cmsSaveDraftButton": MessageLookupByLibrary.simpleMessage("Save Draft"),
    "cmsSaveDraftSuccess": MessageLookupByLibrary.simpleMessage("Draft saved."),
    "cmsSiteConfigSection": MessageLookupByLibrary.simpleMessage(
      "Site Configuration",
    ),
    "cmsStatusDraft": MessageLookupByLibrary.simpleMessage("Draft"),
    "cmsStatusPublished": MessageLookupByLibrary.simpleMessage("Published"),
    "cmsUnsavedChangesBody": MessageLookupByLibrary.simpleMessage(
      "You have unsaved changes. What would you like to do?",
    ),
    "cmsUnsavedChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Unsaved changes",
    ),
    "cmsVersionDate": m11,
    "cmsVersionHistory": MessageLookupByLibrary.simpleMessage(
      "Version History",
    ),
    "cmsVersionLabel": m12,
    "code": MessageLookupByLibrary.simpleMessage("Code"),
    "coffee": MessageLookupByLibrary.simpleMessage("Coffee"),
    "coin": MessageLookupByLibrary.simpleMessage("Coin"),
    "coins": MessageLookupByLibrary.simpleMessage("Coins"),
    "column": MessageLookupByLibrary.simpleMessage("Column"),
    "compactSideMenuDescription": MessageLookupByLibrary.simpleMessage(
      "Collapse the sidebar to icons.",
    ),
    "compactSideMenuTitle": MessageLookupByLibrary.simpleMessage(
      "Compact side menu",
    ),
    "company": MessageLookupByLibrary.simpleMessage("Company"),
    "compass": MessageLookupByLibrary.simpleMessage("Compass"),
    "computer": MessageLookupByLibrary.simpleMessage("Computer"),
    "cone": MessageLookupByLibrary.simpleMessage("Cone"),
    "configurationInvalid": MessageLookupByLibrary.simpleMessage(
      "We can\'t complete this action because the configuration is invalid. Check the settings and try again.",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm password"),
    "confirmPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Confirm password",
    ),
    "connectLabel": MessageLookupByLibrary.simpleMessage("Connect"),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connectionStatusConnected": MessageLookupByLibrary.simpleMessage(
      "Connected",
    ),
    "connectionStatusDisconnected": MessageLookupByLibrary.simpleMessage(
      "Not connected",
    ),
    "connectionsSectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Connect external platforms to this property.",
    ),
    "connectionsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Connections",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity"),
    "contacts": MessageLookupByLibrary.simpleMessage("Contacts"),
    "container": MessageLookupByLibrary.simpleMessage("Container"),
    "contentDocumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Each page, locale, and version is stored as a JSON document.",
    ),
    "contentDocumentsEmpty": MessageLookupByLibrary.simpleMessage(
      "No documents found.",
    ),
    "contentDocumentsLoadFailed": m13,
    "contentDocumentsPublished": m14,
    "contentDocumentsTitle": MessageLookupByLibrary.simpleMessage(
      "Content documents",
    ),
    "contentDocumentsUpdated": m15,
    "contentDocumentsVersionLabel": m16,
    "copied": MessageLookupByLibrary.simpleMessage("Copied"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "cost": MessageLookupByLibrary.simpleMessage("Cost"),
    "costTypePerBooking": MessageLookupByLibrary.simpleMessage("per stay"),
    "costTypePerNight": MessageLookupByLibrary.simpleMessage("per night"),
    "costTypePerPerson": MessageLookupByLibrary.simpleMessage("per guest"),
    "coverageFollowing": m17,
    "coverageOpenPricingTooltip": m18,
    "coverageOwnValuesAt": MessageLookupByLibrary.simpleMessage(
      "Own values at:",
    ),
    "coverageSingleFollows": MessageLookupByLibrary.simpleMessage(
      "Follows the default",
    ),
    "coverageSingleOwn": MessageLookupByLibrary.simpleMessage("Own value"),
    "createUserButton": MessageLookupByLibrary.simpleMessage("Create user"),
    "createUserDescription": MessageLookupByLibrary.simpleMessage(
      "Create a password-based account for a new user.",
    ),
    "createUserFailed": m19,
    "createUserTitle": MessageLookupByLibrary.simpleMessage("Create user"),
    "created": MessageLookupByLibrary.simpleMessage("Created"),
    "croissant": MessageLookupByLibrary.simpleMessage("Croissant"),
    "cross": MessageLookupByLibrary.simpleMessage("Cross"),
    "cube": MessageLookupByLibrary.simpleMessage("Cube"),
    "cup": MessageLookupByLibrary.simpleMessage("Cup"),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "cylinder": MessageLookupByLibrary.simpleMessage("Cylinder"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark mode"),
    "dash": MessageLookupByLibrary.simpleMessage("Dash"),
    "data": MessageLookupByLibrary.simpleMessage("Data"),
    "dataCenter": MessageLookupByLibrary.simpleMessage("Data Center"),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "dateRange": MessageLookupByLibrary.simpleMessage("Date Range"),
    "dayToday": MessageLookupByLibrary.simpleMessage("Today"),
    "dayYesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "daylight": MessageLookupByLibrary.simpleMessage("Daylight"),
    "deadline": MessageLookupByLibrary.simpleMessage("Deadline"),
    "decimalNumber": MessageLookupByLibrary.simpleMessage("Decimal Number"),
    "defaultLabel": MessageLookupByLibrary.simpleMessage("Default"),
    "defaultTabLabel": MessageLookupByLibrary.simpleMessage("Default tab"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteEvent": MessageLookupByLibrary.simpleMessage("Delete Event"),
    "deleteUserConfirmation": m20,
    "deleteUserDescription": MessageLookupByLibrary.simpleMessage(
      "Permanently remove the account and access.",
    ),
    "deleteUserTitle": MessageLookupByLibrary.simpleMessage("Delete user"),
    "detailsLabel": MessageLookupByLibrary.simpleMessage("Details"),
    "development": MessageLookupByLibrary.simpleMessage("Development"),
    "developmentAccount": MessageLookupByLibrary.simpleMessage(
      "Development account",
    ),
    "diamond": MessageLookupByLibrary.simpleMessage("Diamond"),
    "direction": MessageLookupByLibrary.simpleMessage("Direction"),
    "directory": MessageLookupByLibrary.simpleMessage("Directory"),
    "disability": MessageLookupByLibrary.simpleMessage("Disability"),
    "disabledLabel": MessageLookupByLibrary.simpleMessage("Disabled"),
    "dislike": MessageLookupByLibrary.simpleMessage("Dislike"),
    "distance": MessageLookupByLibrary.simpleMessage("Distance"),
    "divide": MessageLookupByLibrary.simpleMessage("Divide"),
    "document": MessageLookupByLibrary.simpleMessage("Document"),
    "dog": MessageLookupByLibrary.simpleMessage("Dog"),
    "dollar": MessageLookupByLibrary.simpleMessage("Dollar"),
    "dollarCoins": MessageLookupByLibrary.simpleMessage("Dollar Coins"),
    "dontHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "dot": MessageLookupByLibrary.simpleMessage("Dot"),
    "dots": MessageLookupByLibrary.simpleMessage("Dots"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "drag": MessageLookupByLibrary.simpleMessage("Drag"),
    "dress": MessageLookupByLibrary.simpleMessage("Dress"),
    "drinks": MessageLookupByLibrary.simpleMessage("Drinks"),
    "duration": MessageLookupByLibrary.simpleMessage("Duration"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editDetailsAction": MessageLookupByLibrary.simpleMessage("Edit details"),
    "editDetailsDescription": MessageLookupByLibrary.simpleMessage(
      "Update the email address or username.",
    ),
    "editUserDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Edit user details",
    ),
    "eggplant": MessageLookupByLibrary.simpleMessage("Eggplant"),
    "eggs": MessageLookupByLibrary.simpleMessage("Eggs"),
    "elevator": MessageLookupByLibrary.simpleMessage("Elevator"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address.",
    ),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email address"),
    "emailNotConfirmed": MessageLookupByLibrary.simpleMessage(
      "Please confirm your email.",
    ),
    "emailRequired": MessageLookupByLibrary.simpleMessage(
      "Enter an email address.",
    ),
    "emailUserOnCreateDescription": MessageLookupByLibrary.simpleMessage(
      "Automatically send a welcome email after registration.",
    ),
    "emailUserOnCreateTitle": MessageLookupByLibrary.simpleMessage(
      "Email new users",
    ),
    "empty": MessageLookupByLibrary.simpleMessage("Empty"),
    "enabledLabel": MessageLookupByLibrary.simpleMessage("Enabled"),
    "enterAValidCode": MessageLookupByLibrary.simpleMessage(
      "Enter a valid code",
    ),
    "enterAValidEmail": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address",
    ),
    "enterMin6Characters": MessageLookupByLibrary.simpleMessage(
      "Enter minimal 6 characters",
    ),
    "enterMinCharacters": m21,
    "enterValidEmail": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email",
    ),
    "enterVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Enter verification code",
    ),
    "enterprise": MessageLookupByLibrary.simpleMessage("Enterprise"),
    "envelop": MessageLookupByLibrary.simpleMessage("Envelop"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorDialogDismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
    "errorDialogTitle": MessageLookupByLibrary.simpleMessage("Error"),
    "errorEmailNotConfirmed": MessageLookupByLibrary.simpleMessage(
      "Your email address is not confirmed yet.",
    ),
    "errorEmailSendFailedGeneric": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t send the email. Please try again later.",
    ),
    "errorGeneric": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Please try again.",
    ),
    "errorInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Incorrect email or password.",
    ),
    "errorLoginOtpEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t send the sign-in code email. Please try again later.",
    ),
    "errorPasswordResetEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t send the password reset email. Please try again later.",
    ),
    "errorRateLimited": MessageLookupByLibrary.simpleMessage(
      "Too many attempts. Please try again later.",
    ),
    "errorSavingItem": MessageLookupByLibrary.simpleMessage(
      "Error saving item.",
    ),
    "errorSignUpConfirmationEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t send the confirmation email. Please try again later.",
    ),
    "errorTextDataFetchFailed": MessageLookupByLibrary.simpleMessage(
      "Data could not be fetched",
    ),
    "errorTextIncorrectUsernameOrPassword":
        MessageLookupByLibrary.simpleMessage("Incorrect username or password."),
    "errorTextInvalidEmailFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid email address format.",
    ),
    "errorTextInvalidVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Invalid verification code provided, please try again.",
    ),
    "errorTextServerError": MessageLookupByLibrary.simpleMessage(
      "Unfortunately, there is a problem with the server. Please try again later.",
    ),
    "errorTextUsernameExists": MessageLookupByLibrary.simpleMessage(
      "There is already a user with this email address.",
    ),
    "errorTitle": MessageLookupByLibrary.simpleMessage("Error"),
    "errorUserCreatedEmailFailed": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t send the welcome email. Please try again later.",
    ),
    "event": MessageLookupByLibrary.simpleMessage("Event"),
    "eventPlanner": MessageLookupByLibrary.simpleMessage("Event Planner"),
    "events": MessageLookupByLibrary.simpleMessage("Events"),
    "exclamation": MessageLookupByLibrary.simpleMessage("Exclamation"),
    "expenses": MessageLookupByLibrary.simpleMessage("Expenses"),
    "expiration": MessageLookupByLibrary.simpleMessage("Expiration"),
    "expirationRemindersLabel": MessageLookupByLibrary.simpleMessage(
      "Expiration alerts",
    ),
    "expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "expiry": MessageLookupByLibrary.simpleMessage("Expiry"),
    "exportButton": MessageLookupByLibrary.simpleMessage("Export"),
    "exportColumnsTitle": MessageLookupByLibrary.simpleMessage("Columns"),
    "exportLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Language used for exports",
    ),
    "exportLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Export language",
    ),
    "exportPdfOrientationLandscape": MessageLookupByLibrary.simpleMessage(
      "Landscape",
    ),
    "exportPdfOrientationPortrait": MessageLookupByLibrary.simpleMessage(
      "Portrait",
    ),
    "exportPdfOrientationTitle": MessageLookupByLibrary.simpleMessage(
      "PDF orientation",
    ),
    "exportSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Export settings",
    ),
    "failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "failedToDeleteImage": MessageLookupByLibrary.simpleMessage(
      "Failed to delete image.",
    ),
    "failedToLoadUser": MessageLookupByLibrary.simpleMessage(
      "Unable to load user data. Please contact support.",
    ),
    "failedToUploadImage": MessageLookupByLibrary.simpleMessage(
      "Failed to upload image.",
    ),
    "fashion": MessageLookupByLibrary.simpleMessage("Fashion"),
    "fastTime": MessageLookupByLibrary.simpleMessage("Fast Time"),
    "father": MessageLookupByLibrary.simpleMessage("Father"),
    "favorite": MessageLookupByLibrary.simpleMessage("Favorite"),
    "fieldIsLinkedTo": m22,
    "fieldsActionsLabel": MessageLookupByLibrary.simpleMessage("Actions"),
    "fieldsAllPropertiesHelper": MessageLookupByLibrary.simpleMessage(
      "Changes save immediately. Use JSON syntax for complex values or switch to the JSON tab for advanced edits.",
    ),
    "fieldsAllPropertiesSection": MessageLookupByLibrary.simpleMessage(
      "All properties",
    ),
    "fieldsApply": MessageLookupByLibrary.simpleMessage("Apply"),
    "fieldsColumnFieldType": MessageLookupByLibrary.simpleMessage("Field type"),
    "fieldsColumnName": MessageLookupByLibrary.simpleMessage("Display name"),
    "fieldsColumnProperties": MessageLookupByLibrary.simpleMessage(
      "Properties",
    ),
    "fieldsColumnSubtype": MessageLookupByLibrary.simpleMessage(
      "Field subtype",
    ),
    "fieldsDefaultsTab": MessageLookupByLibrary.simpleMessage("Default values"),
    "fieldsEditNames": MessageLookupByLibrary.simpleMessage("Edit names"),
    "fieldsEditProperties": MessageLookupByLibrary.simpleMessage(
      "Edit properties",
    ),
    "fieldsEmptyState": MessageLookupByLibrary.simpleMessage(
      "No field definitions available.",
    ),
    "fieldsInvalidJson": MessageLookupByLibrary.simpleMessage(
      "Enter valid JSON (object only).",
    ),
    "fieldsInvalidJsonValue": MessageLookupByLibrary.simpleMessage(
      "Enter a valid JSON value.",
    ),
    "fieldsInvalidNumber": MessageLookupByLibrary.simpleMessage(
      "Enter a valid number.",
    ),
    "fieldsLabel": MessageLookupByLibrary.simpleMessage("Field defaults"),
    "fieldsNamesDialogHelper": MessageLookupByLibrary.simpleMessage(
      "Update the localized names below. Leave a field empty to fall back to the default.",
    ),
    "fieldsNamesDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Edit localized names",
    ),
    "fieldsNamesSaved": MessageLookupByLibrary.simpleMessage("Names updated."),
    "fieldsNoProperties": MessageLookupByLibrary.simpleMessage(
      "No editable properties are available for this field type.",
    ),
    "fieldsPropertiesDialogHelper": MessageLookupByLibrary.simpleMessage(
      "Use the tabs to update the properties via the form or with JSON. Changes are applied instantly after saving.",
    ),
    "fieldsPropertiesDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Edit properties",
    ),
    "fieldsPropertiesFormUnavailable": MessageLookupByLibrary.simpleMessage(
      "A visual editor is not available for this field type yet. Use the JSON tab instead.",
    ),
    "fieldsPropertiesSaved": MessageLookupByLibrary.simpleMessage(
      "Properties updated.",
    ),
    "fieldsPropertiesTabForm": MessageLookupByLibrary.simpleMessage("Form"),
    "fieldsPropertiesTabJson": MessageLookupByLibrary.simpleMessage("JSON"),
    "fieldsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Configure the default values for every field type and subtype. When a new list is created it starts with these defaults, which can still be customized afterwards. Changes saved here update the defaults used for future lists; existing lists keep their current configuration.",
    ),
    "fieldsSubtypesSection": MessageLookupByLibrary.simpleMessage(
      "Field subtypes",
    ),
    "fieldsTitle": MessageLookupByLibrary.simpleMessage("Field defaults"),
    "fieldsTranslationLabel": m23,
    "fieldsTranslationsDescription": MessageLookupByLibrary.simpleMessage(
      "Set the display name for this field subtype for each supported locale.",
    ),
    "fieldsTranslationsTab": MessageLookupByLibrary.simpleMessage(
      "Translations",
    ),
    "fieldsTypesSection": MessageLookupByLibrary.simpleMessage("Field types"),
    "fieldsUnsavedJsonWarningMessage": MessageLookupByLibrary.simpleMessage(
      "You haven’t validated or applied your JSON edits yet. Switch back to the JSON tab to do so, or continue to the editor and discard them.",
    ),
    "fieldsUnsavedJsonWarningTitle": MessageLookupByLibrary.simpleMessage(
      "JSON changes pending",
    ),
    "fieldsUseTypeDefaultsDescription": MessageLookupByLibrary.simpleMessage(
      "Keep this subtype in sync with the field type defaults. Turn this off to customize the properties.",
    ),
    "fieldsUseTypeDefaultsLabel": MessageLookupByLibrary.simpleMessage(
      "Use field type defaults",
    ),
    "fieldsUsingTypeDefaults": MessageLookupByLibrary.simpleMessage(
      "Inherits field type defaults",
    ),
    "fieldsUsingTypeDefaultsBody": MessageLookupByLibrary.simpleMessage(
      "This subtype inherits the field type defaults. Turn off the toggle above to customize its properties.",
    ),
    "fieldsValidateAndApply": MessageLookupByLibrary.simpleMessage(
      "Validate and apply",
    ),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "files": MessageLookupByLibrary.simpleMessage("Files"),
    "finance": MessageLookupByLibrary.simpleMessage("Finance"),
    "fish": MessageLookupByLibrary.simpleMessage("Fish"),
    "fix": MessageLookupByLibrary.simpleMessage("Fix"),
    "flag": MessageLookupByLibrary.simpleMessage("Flag"),
    "flowers": MessageLookupByLibrary.simpleMessage("Flowers"),
    "folder": MessageLookupByLibrary.simpleMessage("Folder"),
    "folders": MessageLookupByLibrary.simpleMessage("Folders"),
    "fontColors": MessageLookupByLibrary.simpleMessage("Font Colors"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Font Size"),
    "food": MessageLookupByLibrary.simpleMessage("Food"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "forkAndKnife": MessageLookupByLibrary.simpleMessage("Fork and Knife"),
    "form": MessageLookupByLibrary.simpleMessage("Form"),
    "fries": MessageLookupByLibrary.simpleMessage("Fries"),
    "frozen": MessageLookupByLibrary.simpleMessage("Frozen"),
    "frozenFries": MessageLookupByLibrary.simpleMessage("Frozen Fries"),
    "fryingPan": MessageLookupByLibrary.simpleMessage("Frying Pan"),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "garbage": MessageLookupByLibrary.simpleMessage("Garbage"),
    "garden": MessageLookupByLibrary.simpleMessage("Garden"),
    "generalSectionTitle": MessageLookupByLibrary.simpleMessage("General"),
    "glasses": MessageLookupByLibrary.simpleMessage("Glasses"),
    "globe": MessageLookupByLibrary.simpleMessage("Globe"),
    "golf": MessageLookupByLibrary.simpleMessage("Golf"),
    "gravyBoat": MessageLookupByLibrary.simpleMessage("Gravy Boat"),
    "heart": MessageLookupByLibrary.simpleMessage("Heart"),
    "height": MessageLookupByLibrary.simpleMessage("Height"),
    "hide": MessageLookupByLibrary.simpleMessage("Hide"),
    "hideErrorDetails": MessageLookupByLibrary.simpleMessage("Hide details"),
    "hideInput": MessageLookupByLibrary.simpleMessage("Hide Input"),
    "hideKeyboard": MessageLookupByLibrary.simpleMessage("Hide Keyboard"),
    "holiday": MessageLookupByLibrary.simpleMessage("Holiday"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "hot": MessageLookupByLibrary.simpleMessage("Hot"),
    "hour": MessageLookupByLibrary.simpleMessage("Hour"),
    "house": MessageLookupByLibrary.simpleMessage("House"),
    "human": MessageLookupByLibrary.simpleMessage("Human"),
    "iceCream": MessageLookupByLibrary.simpleMessage("Ice Cream"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "inboxArchive": MessageLookupByLibrary.simpleMessage("Archive"),
    "inboxEmptyAll": MessageLookupByLibrary.simpleMessage(
      "No guest messages for this selection yet.",
    ),
    "inboxEmptyAllHint": MessageLookupByLibrary.simpleMessage(
      "As soon as a guest replies to a booking or an enquiry, the conversation lands here.",
    ),
    "inboxEmptyConversation": MessageLookupByLibrary.simpleMessage(
      "This conversation has no messages yet.",
    ),
    "inboxEmptyFiltered": MessageLookupByLibrary.simpleMessage(
      "No conversations in this view.",
    ),
    "inboxEmptyFilteredHint": MessageLookupByLibrary.simpleMessage(
      "Change the filter or the search.",
    ),
    "inboxFilterAction": MessageLookupByLibrary.simpleMessage("Action"),
    "inboxFilterAll": MessageLookupByLibrary.simpleMessage("All"),
    "inboxFilterUnread": MessageLookupByLibrary.simpleMessage("Unread"),
    "inboxGuestLanguage": MessageLookupByLibrary.simpleMessage("Language"),
    "inboxLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not load the conversations",
    ),
    "inboxLoadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "The inbox shows no conversations while the source is unreachable.",
    ),
    "inboxLocalStateNote": m24,
    "inboxMessageNotSent": MessageLookupByLibrary.simpleMessage("Not sent"),
    "inboxNoReservation": MessageLookupByLibrary.simpleMessage(
      "This conversation is not attached to a booking.",
    ),
    "inboxOpenBooking": MessageLookupByLibrary.simpleMessage("Open booking"),
    "inboxOpenInSource": m25,
    "inboxPreviouslyBooked": MessageLookupByLibrary.simpleMessage(
      "Booked before",
    ),
    "inboxPreviouslyBookedValue": m26,
    "inboxQuickRepliesLabel": MessageLookupByLibrary.simpleMessage(
      "Quick replies",
    ),
    "inboxQuickReplyAvailability": MessageLookupByLibrary.simpleMessage(
      "That date is still free. Shall I hold it for you?",
    ),
    "inboxQuickReplyCheckIn": MessageLookupByLibrary.simpleMessage(
      "Check-in is from 4pm. Arriving earlier is usually fine — just let me know.",
    ),
    "inboxQuickReplyDirections": MessageLookupByLibrary.simpleMessage(
      "A few days before you arrive I\'ll send you the directions and the key code.",
    ),
    "inboxQuickReplyThanks": MessageLookupByLibrary.simpleMessage(
      "Thanks for your message. I\'ll get back to you as soon as I can.",
    ),
    "inboxReplyHint": m27,
    "inboxReplyVia": m28,
    "inboxReservationHeader": MessageLookupByLibrary.simpleMessage("Booking"),
    "inboxResponseTimeNote": MessageLookupByLibrary.simpleMessage(
      "Airbnb counts your response time towards your ranking. This conversation is still waiting on you.",
    ),
    "inboxRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "inboxSearchHint": MessageLookupByLibrary.simpleMessage(
      "Search by guest or message",
    ),
    "inboxSend": MessageLookupByLibrary.simpleMessage("Send"),
    "inboxSendFailed": MessageLookupByLibrary.simpleMessage(
      "Message not sent.",
    ),
    "inboxSendUnsupported": m29,
    "inboxShowOriginal": MessageLookupByLibrary.simpleMessage("Show original"),
    "inboxSnooze": MessageLookupByLibrary.simpleMessage("Snooze"),
    "inboxSnoozeNextWeek": MessageLookupByLibrary.simpleMessage(
      "Until next week",
    ),
    "inboxSnoozeTomorrow": MessageLookupByLibrary.simpleMessage(
      "Until tomorrow",
    ),
    "inboxSnoozeWake": MessageLookupByLibrary.simpleMessage("Wake now"),
    "inboxSnoozedUntil": m30,
    "inboxSyncFailed": MessageLookupByLibrary.simpleMessage(
      "Could not refresh the messages — you are still seeing the previous state.",
    ),
    "inboxTagAnswered": MessageLookupByLibrary.simpleMessage("Answered"),
    "inboxTagAwaiting": MessageLookupByLibrary.simpleMessage("Needs a reply"),
    "inboxThreadSubtitle": m31,
    "inboxThreadSubtitleNoStay": m32,
    "inboxTitle": MessageLookupByLibrary.simpleMessage("Messages"),
    "inboxTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "inboxTranslate": m33,
    "inboxUnreadTooltip": m34,
    "indicator": MessageLookupByLibrary.simpleMessage("Indicator"),
    "ingredients": MessageLookupByLibrary.simpleMessage("Ingredients"),
    "insect": MessageLookupByLibrary.simpleMessage("Insect"),
    "interfaceLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "The language the HostHub console is shown in. Personal to you.",
    ),
    "interfaceLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Interface language",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "invalidMaxItems": MessageLookupByLibrary.simpleMessage(
      "Enter a valid number of items.",
    ),
    "invalidMaxLists": MessageLookupByLibrary.simpleMessage(
      "Enter a valid number of lists.",
    ),
    "invalidUrl": MessageLookupByLibrary.simpleMessage("Invalid URL"),
    "inventory": MessageLookupByLibrary.simpleMessage("Inventory"),
    "invitation": MessageLookupByLibrary.simpleMessage("Invitation"),
    "iron": MessageLookupByLibrary.simpleMessage("Iron"),
    "island": MessageLookupByLibrary.simpleMessage("Island"),
    "itinerary": MessageLookupByLibrary.simpleMessage("Itinerary"),
    "jacket": MessageLookupByLibrary.simpleMessage("Jacket"),
    "jar": MessageLookupByLibrary.simpleMessage("Jar"),
    "kanbanBoard": MessageLookupByLibrary.simpleMessage("Kanban Board"),
    "kettle": MessageLookupByLibrary.simpleMessage("Kettle"),
    "kitten": MessageLookupByLibrary.simpleMessage("Kitten"),
    "label": MessageLookupByLibrary.simpleMessage("Label"),
    "lamp": MessageLookupByLibrary.simpleMessage("Lamp"),
    "languagePreferenceDescription": MessageLookupByLibrary.simpleMessage(
      "Change language",
    ),
    "languagePreferenceTitle": MessageLookupByLibrary.simpleMessage("Language"),
    "left": MessageLookupByLibrary.simpleMessage("Left"),
    "leftAlignment": MessageLookupByLibrary.simpleMessage("Left Alignment"),
    "legalSectionFooter": MessageLookupByLibrary.simpleMessage(
      "The privacy statement lives on your website at /privacy and is published together with the rest of your content.",
    ),
    "legalSectionTitle": MessageLookupByLibrary.simpleMessage("Legal"),
    "legalSectionWarning": MessageLookupByLibrary.simpleMessage(
      "This is a legal text. Only change it if you know what it has to say — have it checked if you are unsure.",
    ),
    "letter": MessageLookupByLibrary.simpleMessage("Letter"),
    "letters": MessageLookupByLibrary.simpleMessage("Letters"),
    "library": MessageLookupByLibrary.simpleMessage("Library"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Light mode"),
    "like": MessageLookupByLibrary.simpleMessage("Like"),
    "lineHeight": MessageLookupByLibrary.simpleMessage("Line Height"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listRoleLabel": m35,
    "listSinceDate": m36,
    "listsAddItemMethodsLabel": MessageLookupByLibrary.simpleMessage(
      "Add item methods",
    ),
    "listsAnalyzerCopied": MessageLookupByLibrary.simpleMessage(
      "Analyzer copied",
    ),
    "listsAnalyzerDescription": MessageLookupByLibrary.simpleMessage(
      "Combined analyzer of all list fields.",
    ),
    "listsAnalyzerIncludeInternalFieldsLabel":
        MessageLookupByLibrary.simpleMessage("Include internal fields"),
    "listsAnalyzerTab": MessageLookupByLibrary.simpleMessage("Analyzer"),
    "listsBehaviorSection": MessageLookupByLibrary.simpleMessage("Behavior"),
    "listsCenterFieldsLabel": MessageLookupByLibrary.simpleMessage(
      "Center fields in list view",
    ),
    "listsColumnFields": MessageLookupByLibrary.simpleMessage("Fields"),
    "listsColumnKey": MessageLookupByLibrary.simpleMessage("Key"),
    "listsColumnName": MessageLookupByLibrary.simpleMessage("List"),
    "listsColumnSamples": MessageLookupByLibrary.simpleMessage("Sample items"),
    "listsColumnStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "listsDataSection": MessageLookupByLibrary.simpleMessage("Data"),
    "listsDemoItemsAddButton": MessageLookupByLibrary.simpleMessage(
      "Add demo item",
    ),
    "listsDemoItemsCreateFailureToast": MessageLookupByLibrary.simpleMessage(
      "Unable to create demo item",
    ),
    "listsDemoItemsDeleteButton": MessageLookupByLibrary.simpleMessage(
      "Delete item",
    ),
    "listsDemoItemsDeleteConfirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this demo item?",
    ),
    "listsDemoItemsDeleteFailureToast": MessageLookupByLibrary.simpleMessage(
      "Unable to delete demo item",
    ),
    "listsDemoItemsDeletedToast": MessageLookupByLibrary.simpleMessage(
      "Demo item deleted",
    ),
    "listsDemoItemsDescription": MessageLookupByLibrary.simpleMessage(
      "Configure the demo items that appear in previews and new lists.",
    ),
    "listsDemoItemsDevLabel": MessageLookupByLibrary.simpleMessage("Dev only"),
    "listsDemoItemsFlagsSummaryNone": MessageLookupByLibrary.simpleMessage(
      "No contexts selected",
    ),
    "listsDemoItemsFlagsTitle": MessageLookupByLibrary.simpleMessage(
      "Demo contexts",
    ),
    "listsDemoItemsInvalidJsonError": MessageLookupByLibrary.simpleMessage(
      "Invalid JSON payload",
    ),
    "listsDemoItemsJsonDescription": MessageLookupByLibrary.simpleMessage(
      "Shows the demo item payloads that power the preview list.",
    ),
    "listsDemoItemsLoadFailureToast": MessageLookupByLibrary.simpleMessage(
      "Unable to load demo items",
    ),
    "listsDemoItemsMoveDownTooltip": MessageLookupByLibrary.simpleMessage(
      "Move down",
    ),
    "listsDemoItemsMoveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Unable to reorder demo items",
    ),
    "listsDemoItemsMoveUpTooltip": MessageLookupByLibrary.simpleMessage(
      "Move up",
    ),
    "listsDemoItemsNewListLabel": MessageLookupByLibrary.simpleMessage(
      "New list item",
    ),
    "listsDemoItemsNoItems": MessageLookupByLibrary.simpleMessage(
      "No demo items yet.",
    ),
    "listsDemoItemsOrderLabel": MessageLookupByLibrary.simpleMessage("Order"),
    "listsDemoItemsPreviewLabel": MessageLookupByLibrary.simpleMessage(
      "Preview item",
    ),
    "listsDemoItemsSaveButton": MessageLookupByLibrary.simpleMessage(
      "Save item",
    ),
    "listsDemoItemsSaveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Unable to save demo item",
    ),
    "listsDemoItemsSavedToast": MessageLookupByLibrary.simpleMessage(
      "Demo item saved",
    ),
    "listsDemoItemsTab": MessageLookupByLibrary.simpleMessage("Item demos"),
    "listsDemoItemsTileLabel": MessageLookupByLibrary.simpleMessage(
      "Tile example",
    ),
    "listsDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Template settings",
    ),
    "listsEditTemplateTitle": m37,
    "listsEmptyState": MessageLookupByLibrary.simpleMessage(
      "No list templates available.",
    ),
    "listsFieldNameLabel": m38,
    "listsFieldNamesLabel": MessageLookupByLibrary.simpleMessage("Field names"),
    "listsFieldsLabel": MessageLookupByLibrary.simpleMessage("Fields"),
    "listsFieldsValue": m39,
    "listsGroupByLabel": MessageLookupByLibrary.simpleMessage("Group by"),
    "listsGroupByNone": MessageLookupByLibrary.simpleMessage("No grouping"),
    "listsItemHistoryLabel": MessageLookupByLibrary.simpleMessage(
      "Item history",
    ),
    "listsItemTapLabel": MessageLookupByLibrary.simpleMessage(
      "Item tap behavior",
    ),
    "listsJsonCopied": MessageLookupByLibrary.simpleMessage("JSON copied"),
    "listsJsonDefaultPathLabel": m40,
    "listsJsonDownloadLabel": MessageLookupByLibrary.simpleMessage(
      "Download JSON",
    ),
    "listsJsonSaveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Unable to save JSON",
    ),
    "listsJsonSaveLabel": MessageLookupByLibrary.simpleMessage("Save JSON"),
    "listsJsonSavedToast": m41,
    "listsJsonTab": MessageLookupByLibrary.simpleMessage("JSON export"),
    "listsLabel": MessageLookupByLibrary.simpleMessage("List templates"),
    "listsLayoutTab": MessageLookupByLibrary.simpleMessage("Layout"),
    "listsLocaleLabel": m42,
    "listsLocaleListName": m43,
    "listsLocaleListNamePlural": m44,
    "listsNoFieldsForLocale": MessageLookupByLibrary.simpleMessage(
      "No fields for this locale.",
    ),
    "listsNoSelection": MessageLookupByLibrary.simpleMessage(
      "Select a template to review settings.",
    ),
    "listsOverviewSection": MessageLookupByLibrary.simpleMessage("Overview"),
    "listsSamplesLabel": MessageLookupByLibrary.simpleMessage("Sample items"),
    "listsSamplesSingle": m45,
    "listsSamplesSplit": m46,
    "listsSchemeLabel": MessageLookupByLibrary.simpleMessage("Color scheme"),
    "listsStatusActive": MessageLookupByLibrary.simpleMessage("Active"),
    "listsStatusBeta": MessageLookupByLibrary.simpleMessage("Beta"),
    "listsStatusDemo": MessageLookupByLibrary.simpleMessage("Demo data"),
    "listsStatusDev": MessageLookupByLibrary.simpleMessage("Dev only"),
    "listsStatusHidden": MessageLookupByLibrary.simpleMessage("Hidden"),
    "listsStyleLabel": MessageLookupByLibrary.simpleMessage("Style"),
    "listsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Browse every list template, including availability, dev flags, and seeded sample data.",
    ),
    "listsTemplateDeletedToast": MessageLookupByLibrary.simpleMessage(
      "Template deleted",
    ),
    "listsTemplateJsonDescription": MessageLookupByLibrary.simpleMessage(
      "View the cleaned list template JSON that you can reuse for list seeds.",
    ),
    "listsTemplateJsonTab": MessageLookupByLibrary.simpleMessage("Template"),
    "listsTemplatesLabel": MessageLookupByLibrary.simpleMessage("Templates"),
    "listsTileDemoRelativeDatesDescription": MessageLookupByLibrary.simpleMessage(
      "Evaluate internal timestamps relative to the current time when previewing the tile example.",
    ),
    "listsTileDemoRelativeDatesLabel": MessageLookupByLibrary.simpleMessage(
      "Use relative tile demo dates",
    ),
    "listsTitle": MessageLookupByLibrary.simpleMessage("List templates"),
    "listsTranslationsDescription": MessageLookupByLibrary.simpleMessage(
      "Manage the list name and field names for every supported locale.",
    ),
    "listsTranslationsTab": MessageLookupByLibrary.simpleMessage(
      "Translations",
    ),
    "listsUnknownTemplate": MessageLookupByLibrary.simpleMessage(
      "This template could not be found.",
    ),
    "listsViewLabel": MessageLookupByLibrary.simpleMessage("Default view"),
    "loadUserFailed": m47,
    "loadUserFailedMessage": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load user.",
    ),
    "loadUsersFailed": m48,
    "location": MessageLookupByLibrary.simpleMessage("Location"),
    "locationNotFoundAlertMessage": MessageLookupByLibrary.simpleMessage(
      "Please check the address to enable automatic distance calculation, or enter the distance manually.",
    ),
    "locationNotFoundAlertTitle": MessageLookupByLibrary.simpleMessage(
      "Location not found",
    ),
    "lodgifyApiKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Use the API key from Lodgify to connect.",
    ),
    "lodgifyApiKeyLabel": MessageLookupByLibrary.simpleMessage("API key"),
    "lodgifyApiKeyRemoveMessage": MessageLookupByLibrary.simpleMessage(
      "The Lodgify connection stops. Your properties and their website content stay.",
    ),
    "lodgifyApiKeyRemoveTitle": MessageLookupByLibrary.simpleMessage(
      "Remove the API key?",
    ),
    "lodgifyApiKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Enter an API key to connect.",
    ),
    "lodgifyConnectErrorDescription": MessageLookupByLibrary.simpleMessage(
      "Check the API key and try again. Make sure the key has access to Lodgify.",
    ),
    "lodgifyConnectErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Lodgify connection failed",
    ),
    "lodgifyConnectSuccess": MessageLookupByLibrary.simpleMessage(
      "Lodgify connected.",
    ),
    "lodgifyLastSyncLabel": m49,
    "lodgifyNoNewPropertiesFound": MessageLookupByLibrary.simpleMessage(
      "No new Lodgify properties found.",
    ),
    "lodgifySyncAddAction": MessageLookupByLibrary.simpleMessage("Add"),
    "lodgifySyncAddAndLinkAction": MessageLookupByLibrary.simpleMessage(
      "Add and link",
    ),
    "lodgifySyncApplied": m50,
    "lodgifySyncGoToProperties": MessageLookupByLibrary.simpleMessage(
      "Go to Properties",
    ),
    "lodgifySyncLabel": MessageLookupByLibrary.simpleMessage("Sync"),
    "lodgifySyncLinkAction": MessageLookupByLibrary.simpleMessage("Link"),
    "lodgifySyncLinkSubtitle": m51,
    "lodgifySyncOutcomeLink": m52,
    "lodgifySyncOutcomeNew": m53,
    "lodgifySyncResultTitle": MessageLookupByLibrary.simpleMessage(
      "What Lodgify has",
    ),
    "lodgifySyncStateLink": MessageLookupByLibrary.simpleMessage("Link"),
    "lodgifySyncStateLinked": MessageLookupByLibrary.simpleMessage(
      "Already linked",
    ),
    "lodgifySyncStateNew": MessageLookupByLibrary.simpleMessage("New"),
    "lodgifyTitle": MessageLookupByLibrary.simpleMessage("Lodgify"),
    "login": MessageLookupByLibrary.simpleMessage("Log in"),
    "loginDescription": MessageLookupByLibrary.simpleMessage(
      "Sign in with your account.",
    ),
    "loginFailed": MessageLookupByLibrary.simpleMessage("Login failed"),
    "loginFailedCheckDetails": MessageLookupByLibrary.simpleMessage(
      "Login failed. Check your information.",
    ),
    "loginFailedWithReason": m54,
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Log in with Google",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "logoutLabel": MessageLookupByLibrary.simpleMessage("Sign out"),
    "longTime": MessageLookupByLibrary.simpleMessage("Long Time"),
    "love": MessageLookupByLibrary.simpleMessage("Love"),
    "loyaltyCard": MessageLookupByLibrary.simpleMessage("Loyalty Card"),
    "magicLinkSentDescription": m55,
    "magicLinkSentDescriptionFallback": MessageLookupByLibrary.simpleMessage(
      "We sent a magic link. Check your inbox and spam folder.",
    ),
    "magicLinkSentTitle": MessageLookupByLibrary.simpleMessage(
      "Check your email",
    ),
    "magicLinkSubtitle": MessageLookupByLibrary.simpleMessage(
      "Enter your email and we\'ll send you a magic link to sign in.",
    ),
    "mail": MessageLookupByLibrary.simpleMessage("Mail"),
    "maintenance": MessageLookupByLibrary.simpleMessage("Maintenance"),
    "maintenanceModeDescription": MessageLookupByLibrary.simpleMessage(
      "Shows a maintenance message in every app.",
    ),
    "maintenanceModeTitle": MessageLookupByLibrary.simpleMessage(
      "Maintenance mode",
    ),
    "manageUserAction": MessageLookupByLibrary.simpleMessage("Manage user"),
    "mark": MessageLookupByLibrary.simpleMessage("Mark"),
    "math": MessageLookupByLibrary.simpleMessage("Math"),
    "maxItemsDescription": MessageLookupByLibrary.simpleMessage(
      "Prevents extremely large lists.",
    ),
    "maxItemsTitle": MessageLookupByLibrary.simpleMessage("Max items per list"),
    "maxListsDescription": MessageLookupByLibrary.simpleMessage(
      "Limits how many lists a user can create.",
    ),
    "maxListsTitle": MessageLookupByLibrary.simpleMessage("Max lists per user"),
    "meat": MessageLookupByLibrary.simpleMessage("Meat"),
    "medal": MessageLookupByLibrary.simpleMessage("Medal"),
    "meditate": MessageLookupByLibrary.simpleMessage("Meditate"),
    "menuPricing": MessageLookupByLibrary.simpleMessage("Pricing"),
    "menuRevenue": MessageLookupByLibrary.simpleMessage("Revenue"),
    "menuTooltip": MessageLookupByLibrary.simpleMessage("Menu"),
    "microwave": MessageLookupByLibrary.simpleMessage("Microwave"),
    "milk": MessageLookupByLibrary.simpleMessage("Milk"),
    "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
    "money": MessageLookupByLibrary.simpleMessage("Money"),
    "moneyBag": MessageLookupByLibrary.simpleMessage("Money Bag"),
    "mother": MessageLookupByLibrary.simpleMessage("Mother"),
    "mountain": MessageLookupByLibrary.simpleMessage("Mountain"),
    "multiply": MessageLookupByLibrary.simpleMessage("Multiply"),
    "music": MessageLookupByLibrary.simpleMessage("Music"),
    "navAccount": MessageLookupByLibrary.simpleMessage("Account"),
    "navAccountDefaults": MessageLookupByLibrary.simpleMessage("Defaults"),
    "navAccountSettings": MessageLookupByLibrary.simpleMessage(
      "Account settings",
    ),
    "navBookings": MessageLookupByLibrary.simpleMessage("Bookings"),
    "navGroupAccount": MessageLookupByLibrary.simpleMessage("Account"),
    "navGroupPortfolio": MessageLookupByLibrary.simpleMessage("Portfolio"),
    "navGroupProperties": MessageLookupByLibrary.simpleMessage("Properties"),
    "navGroupSingleProperty": MessageLookupByLibrary.simpleMessage("Rental"),
    "navPropertyOverridesTooltip": MessageLookupByLibrary.simpleMessage(
      "Own values",
    ),
    "navPropertyOverview": MessageLookupByLibrary.simpleMessage("Overview"),
    "navPropertySiteSettings": MessageLookupByLibrary.simpleMessage(
      "Site settings",
    ),
    "navPropertyWebsite": MessageLookupByLibrary.simpleMessage("Website"),
    "navigation": MessageLookupByLibrary.simpleMessage("Navigation"),
    "navigationLabel": MessageLookupByLibrary.simpleMessage("Navigation"),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "There was a problem connecting to the server.",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("New password"),
    "newPasswordLabel": MessageLookupByLibrary.simpleMessage("New password"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noAccountYet": MessageLookupByLibrary.simpleMessage("No account yet?"),
    "noAppsFound": MessageLookupByLibrary.simpleMessage("No apps found."),
    "noDataFound": MessageLookupByLibrary.simpleMessage("No data found."),
    "noIcon": MessageLookupByLibrary.simpleMessage("No Icon"),
    "noLabel": MessageLookupByLibrary.simpleMessage("No"),
    "noOwnedLists": MessageLookupByLibrary.simpleMessage(
      "No owned lists found.",
    ),
    "noSharedLists": MessageLookupByLibrary.simpleMessage(
      "No shared lists found.",
    ),
    "noUsername": MessageLookupByLibrary.simpleMessage("No username"),
    "noUsersFound": MessageLookupByLibrary.simpleMessage(
      "No users found. Try a different search.",
    ),
    "noodles": MessageLookupByLibrary.simpleMessage("Noodles"),
    "notAdminError": MessageLookupByLibrary.simpleMessage(
      "This user does not have admin access.",
    ),
    "notSet": MessageLookupByLibrary.simpleMessage("Not set"),
    "notification": MessageLookupByLibrary.simpleMessage("Notification"),
    "notificationsEnabledLabel": MessageLookupByLibrary.simpleMessage(
      "Notifications enabled",
    ),
    "notificationsLabel": MessageLookupByLibrary.simpleMessage("Notifications"),
    "numberedList": MessageLookupByLibrary.simpleMessage("Numbered List"),
    "numbers": MessageLookupByLibrary.simpleMessage("Numbers"),
    "ok": MessageLookupByLibrary.simpleMessage("Ok"),
    "oopsAproblemOccured": MessageLookupByLibrary.simpleMessage(
      "Oops, a problem occorred. We are working on it.",
    ),
    "openPackage": MessageLookupByLibrary.simpleMessage("Open Package"),
    "opening": MessageLookupByLibrary.simpleMessage("Opening"),
    "operatorSign": MessageLookupByLibrary.simpleMessage("Operator"),
    "optionalPlaceholder": MessageLookupByLibrary.simpleMessage("Optional"),
    "orDivider": MessageLookupByLibrary.simpleMessage("or"),
    "organization": MessageLookupByLibrary.simpleMessage("Organization"),
    "origin": MessageLookupByLibrary.simpleMessage("Origin"),
    "oval": MessageLookupByLibrary.simpleMessage("Oval"),
    "ownedListsTitle": MessageLookupByLibrary.simpleMessage("Owned lists"),
    "paint": MessageLookupByLibrary.simpleMessage("Paint"),
    "palm": MessageLookupByLibrary.simpleMessage("Palm"),
    "pan": MessageLookupByLibrary.simpleMessage("Pan"),
    "parasol": MessageLookupByLibrary.simpleMessage("Parasol"),
    "parsley": MessageLookupByLibrary.simpleMessage("Parsley"),
    "party": MessageLookupByLibrary.simpleMessage("Party"),
    "pass": MessageLookupByLibrary.simpleMessage("Pass"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordChangeFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t update the password.",
    ),
    "passwordChangeFailedWithReason": m56,
    "passwordChanged": MessageLookupByLibrary.simpleMessage(
      "Password updated.",
    ),
    "passwordConsistOfMin6Characters": MessageLookupByLibrary.simpleMessage(
      "A password must contain minimal 6 characters",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "At least 8 characters.",
    ),
    "passwordUpdated": MessageLookupByLibrary.simpleMessage("Password updated"),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match.",
    ),
    "pasta": MessageLookupByLibrary.simpleMessage("Pasta"),
    "pastaMaker": MessageLookupByLibrary.simpleMessage("Pasta Maker"),
    "pen": MessageLookupByLibrary.simpleMessage("Pen"),
    "pencil": MessageLookupByLibrary.simpleMessage("Pencil"),
    "people": MessageLookupByLibrary.simpleMessage("People"),
    "percent": MessageLookupByLibrary.simpleMessage("Percent"),
    "persons": MessageLookupByLibrary.simpleMessage("Persons"),
    "pest": MessageLookupByLibrary.simpleMessage("Pest"),
    "pestle": MessageLookupByLibrary.simpleMessage("Pestle"),
    "pet": MessageLookupByLibrary.simpleMessage("Pet"),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "photo": MessageLookupByLibrary.simpleMessage("Photo"),
    "pie": MessageLookupByLibrary.simpleMessage("Pie"),
    "pig": MessageLookupByLibrary.simpleMessage("Pig"),
    "pizza": MessageLookupByLibrary.simpleMessage("Pizza"),
    "place": MessageLookupByLibrary.simpleMessage("Place"),
    "plate": MessageLookupByLibrary.simpleMessage("Plate"),
    "plus": MessageLookupByLibrary.simpleMessage("Plus"),
    "portfolioColumnProperty": MessageLookupByLibrary.simpleMessage("Property"),
    "portfolioFilterAll": MessageLookupByLibrary.simpleMessage(
      "All properties",
    ),
    "portfolioFilterSome": m57,
    "portfolioFilterTooltip": MessageLookupByLibrary.simpleMessage(
      "Choose which properties count",
    ),
    "position": MessageLookupByLibrary.simpleMessage("Position"),
    "preferPasswordSignIn": MessageLookupByLibrary.simpleMessage(
      "Prefer signing in with a password?",
    ),
    "preferencesSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Preferences",
    ),
    "premium": MessageLookupByLibrary.simpleMessage("Premium"),
    "present": MessageLookupByLibrary.simpleMessage("Present"),
    "pricingChannelSettingsHeader": MessageLookupByLibrary.simpleMessage(
      "Channel settings",
    ),
    "pricingCleaningCost": MessageLookupByLibrary.simpleMessage(
      "Cleaning costs",
    ),
    "pricingCommissionDefault": MessageLookupByLibrary.simpleMessage(
      "Empty = default",
    ),
    "pricingCommissionNote": MessageLookupByLibrary.simpleMessage(
      "Commission: empty = default.",
    ),
    "pricingCommissionOverride": MessageLookupByLibrary.simpleMessage(
      "Commission override",
    ),
    "pricingCostTypePerBooking": MessageLookupByLibrary.simpleMessage(
      "per booking",
    ),
    "pricingCostTypePerNight": MessageLookupByLibrary.simpleMessage(
      "per night",
    ),
    "pricingCostTypePerPerson": MessageLookupByLibrary.simpleMessage(
      "per person",
    ),
    "pricingCurrencyNote": MessageLookupByLibrary.simpleMessage(
      "All amounts in",
    ),
    "pricingLinenCost": MessageLookupByLibrary.simpleMessage("Linen costs"),
    "pricingLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not load the pricing settings.",
    ),
    "pricingOtherCost": MessageLookupByLibrary.simpleMessage("Other costs"),
    "pricingPageHeading": MessageLookupByLibrary.simpleMessage(
      "Channels & costs",
    ),
    "pricingPayoutCommission": m58,
    "pricingPayoutFixedCosts": MessageLookupByLibrary.simpleMessage(
      "Cleaning + linen",
    ),
    "pricingPayoutGross": m59,
    "pricingPayoutHeader": MessageLookupByLibrary.simpleMessage(
      "Example payout",
    ),
    "pricingPayoutMarkup": m60,
    "pricingPayoutNet": MessageLookupByLibrary.simpleMessage("Net payout"),
    "pricingPayoutNote": MessageLookupByLibrary.simpleMessage(
      "The calculation follows the fields on the left. Open a channel to preview that one.",
    ),
    "pricingPayoutOther": MessageLookupByLibrary.simpleMessage("Other costs"),
    "pricingPayoutService": m61,
    "pricingPayoutSubtitle": m62,
    "pricingRateMarkup": MessageLookupByLibrary.simpleMessage(
      "Rate markup on base price",
    ),
    "pricingRateMarkupDescription": MessageLookupByLibrary.simpleMessage(
      "Markup % applied on this channel.",
    ),
    "pricingSaved": MessageLookupByLibrary.simpleMessage(
      "Pricing settings saved.",
    ),
    "pricingServiceCost": MessageLookupByLibrary.simpleMessage("Service costs"),
    "print": MessageLookupByLibrary.simpleMessage("Print"),
    "printer": MessageLookupByLibrary.simpleMessage("Printer"),
    "profileLabel": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileLoadFailed": m63,
    "profileLoadingLabel": MessageLookupByLibrary.simpleMessage(
      "Loading profile...",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "propertiesEmptyBody": MessageLookupByLibrary.simpleMessage(
      "Bring them over from Lodgify, or create one yourself to start building a website.",
    ),
    "propertiesListAdd": MessageLookupByLibrary.simpleMessage("Add property"),
    "propertiesListBookingCount": m64,
    "propertiesListEmpty": MessageLookupByLibrary.simpleMessage(
      "No properties in this account yet.",
    ),
    "propertiesListFollowsAccount": MessageLookupByLibrary.simpleMessage(
      "Follows account",
    ),
    "propertiesListFooter": MessageLookupByLibrary.simpleMessage(
      "From Lodgify: name, prices and availability come from there, so that row can only be unlinked. Manual: entirely yours.",
    ),
    "propertiesListHeading": MessageLookupByLibrary.simpleMessage("Properties"),
    "propertiesListOwnValues": m65,
    "propertyDeleteMessage": MessageLookupByLibrary.simpleMessage(
      "The property disappears from this account, along with the website content on it.",
    ),
    "propertyDeleteTitle": m66,
    "propertyDeleteTooltip": MessageLookupByLibrary.simpleMessage(
      "Delete property",
    ),
    "propertyDetailsAbsent": MessageLookupByLibrary.simpleMessage("None"),
    "propertyDetailsAddons": MessageLookupByLibrary.simpleMessage("Extras"),
    "propertyDetailsAddressCard": MessageLookupByLibrary.simpleMessage(
      "Address",
    ),
    "propertyDetailsAgreement": MessageLookupByLibrary.simpleMessage(
      "Rental agreement",
    ),
    "propertyDetailsCity": MessageLookupByLibrary.simpleMessage("City"),
    "propertyDetailsConnectionActive": MessageLookupByLibrary.simpleMessage(
      "Active",
    ),
    "propertyDetailsConnectionMissing": MessageLookupByLibrary.simpleMessage(
      "No Lodgify property is linked to this property.",
    ),
    "propertyDetailsConnectionSummary": m67,
    "propertyDetailsConnectionSummaryNoSync": m68,
    "propertyDetailsCountry": MessageLookupByLibrary.simpleMessage("Country"),
    "propertyDetailsEmpty": MessageLookupByLibrary.simpleMessage(
      "Select a property to see its details.",
    ),
    "propertyDetailsGuestsCount": m69,
    "propertyDetailsLabel": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
    "propertyDetailsOverline": MessageLookupByLibrary.simpleMessage("Property"),
    "propertyDetailsOwnerLanguages": MessageLookupByLibrary.simpleMessage(
      "Owner languages",
    ),
    "propertyDetailsPresent": MessageLookupByLibrary.simpleMessage("Available"),
    "propertyDetailsPriceRange": MessageLookupByLibrary.simpleMessage(
      "Price range",
    ),
    "propertyDetailsPriceUnit": MessageLookupByLibrary.simpleMessage(
      "Price unit",
    ),
    "propertyDetailsPriceUnitValue": m70,
    "propertyDetailsRating": MessageLookupByLibrary.simpleMessage("Rating"),
    "propertyDetailsRatingValue": m71,
    "propertyDetailsRawEmpty": MessageLookupByLibrary.simpleMessage(
      "Lodgify has not sent any raw data for this property yet.",
    ),
    "propertyDetailsRawInOut": MessageLookupByLibrary.simpleMessage(
      "Check-in/out rules",
    ),
    "propertyDetailsRawSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Subscriptions",
    ),
    "propertyDetailsRawSummary": MessageLookupByLibrary.simpleMessage(
      "Check-in/out rules, rooms, subscriptions",
    ),
    "propertyDetailsRawTitle": MessageLookupByLibrary.simpleMessage(
      "Raw data from Lodgify",
    ),
    "propertyDetailsRefresh": MessageLookupByLibrary.simpleMessage(
      "Refresh data",
    ),
    "propertyDetailsRefreshRetry": MessageLookupByLibrary.simpleMessage(
      "Try again",
    ),
    "propertyDetailsRefreshTooltip": MessageLookupByLibrary.simpleMessage(
      "Reads this property again. Link a Lodgify property to be able to sync its data.",
    ),
    "propertyDetailsRefreshTooltipSynced": m72,
    "propertyDetailsRentalCard": MessageLookupByLibrary.simpleMessage("Rental"),
    "propertyDetailsRooms": MessageLookupByLibrary.simpleMessage("Rooms"),
    "propertyDetailsRoomsCount": m73,
    "propertyDetailsSourceNote": MessageLookupByLibrary.simpleMessage(
      "This data comes from Lodgify and is managed there. Change it in Lodgify and sync to update it here.",
    ),
    "propertyDetailsStreet": MessageLookupByLibrary.simpleMessage("Street"),
    "propertyDetailsSync": MessageLookupByLibrary.simpleMessage("Sync now"),
    "propertyDetailsSyncDone": MessageLookupByLibrary.simpleMessage(
      "Data from Lodgify updated.",
    ),
    "propertyDetailsSyncTooltip": MessageLookupByLibrary.simpleMessage(
      "Fetches this property from Lodgify now. Never synced before.",
    ),
    "propertyDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
    "propertyDetailsZip": MessageLookupByLibrary.simpleMessage("Postal code"),
    "propertyLastSync": MessageLookupByLibrary.simpleMessage("Last sync"),
    "propertyLodgifyLinked": MessageLookupByLibrary.simpleMessage("Linked"),
    "propertyLodgifyNotLinked": MessageLookupByLibrary.simpleMessage(
      "Not linked",
    ),
    "propertyLodgifyStatus": MessageLookupByLibrary.simpleMessage(
      "Lodgify status",
    ),
    "propertyNameLabel": MessageLookupByLibrary.simpleMessage("Property name"),
    "propertyNameLodgifyHint": MessageLookupByLibrary.simpleMessage(
      "To change the property name, update it in Lodgify and sync.",
    ),
    "propertyOriginLodgify": MessageLookupByLibrary.simpleMessage(
      "From Lodgify",
    ),
    "propertyOriginManual": MessageLookupByLibrary.simpleMessage("Manual"),
    "propertySelectorEmpty": MessageLookupByLibrary.simpleMessage(
      "No properties",
    ),
    "propertySelectorLoading": MessageLookupByLibrary.simpleMessage(
      "Loading properties…",
    ),
    "propertySelectorSelect": MessageLookupByLibrary.simpleMessage(
      "Select property",
    ),
    "propertySelectorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Properties unavailable",
    ),
    "propertySwitcherLabel": MessageLookupByLibrary.simpleMessage("Property"),
    "propertyUnlinkAction": MessageLookupByLibrary.simpleMessage("Unlink"),
    "propertyUnlinkMessage": MessageLookupByLibrary.simpleMessage(
      "The listing stays in Lodgify. Its name and prices become yours again, and the next sync no longer updates this property.",
    ),
    "propertyUnlinkTitle": m74,
    "propertyUnlinkTooltip": MessageLookupByLibrary.simpleMessage(
      "Unlink from Lodgify",
    ),
    "publicDomainLabel": MessageLookupByLibrary.simpleMessage("Public domain"),
    "puppy": MessageLookupByLibrary.simpleMessage("Puppy"),
    "purse": MessageLookupByLibrary.simpleMessage("Purse"),
    "qr": MessageLookupByLibrary.simpleMessage("QR"),
    "qrCode": MessageLookupByLibrary.simpleMessage("QR Code"),
    "questionMark": MessageLookupByLibrary.simpleMessage("Question Mark"),
    "ratingStar": MessageLookupByLibrary.simpleMessage("Rating Star"),
    "recipeBook": MessageLookupByLibrary.simpleMessage("Recipe Book"),
    "recipes": MessageLookupByLibrary.simpleMessage("Recipes"),
    "refreshTooltip": MessageLookupByLibrary.simpleMessage("Refresh"),
    "refrigerator": MessageLookupByLibrary.simpleMessage("Refrigerator"),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "registerWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Register with Google",
    ),
    "remindersLabel": MessageLookupByLibrary.simpleMessage("Reminders"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "removeLanguageConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Guests can no longer view your website in this language. Saved translations are kept and come back if you re-add it.",
    ),
    "removeLanguageConfirmTitle": m75,
    "removeLanguageTooltip": MessageLookupByLibrary.simpleMessage(
      "Remove language",
    ),
    "repair": MessageLookupByLibrary.simpleMessage("Repair"),
    "repeat": MessageLookupByLibrary.simpleMessage("Repeat"),
    "requestNewPasswordEmail": MessageLookupByLibrary.simpleMessage(
      "Request new reset email",
    ),
    "requiredField": MessageLookupByLibrary.simpleMessage(
      "This is a required field",
    ),
    "resendAvailableIn": m76,
    "resendCode": MessageLookupByLibrary.simpleMessage("Resend code"),
    "reservationAdults": MessageLookupByLibrary.simpleMessage("Adults"),
    "reservationArrival": MessageLookupByLibrary.simpleMessage("Arrival"),
    "reservationBabyBed": MessageLookupByLibrary.simpleMessage("Baby bed"),
    "reservationCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "reservationCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "reservationChildren": MessageLookupByLibrary.simpleMessage("Children"),
    "reservationCloseTooltip": MessageLookupByLibrary.simpleMessage("Close"),
    "reservationCreatedAt": MessageLookupByLibrary.simpleMessage("Created"),
    "reservationDeparture": MessageLookupByLibrary.simpleMessage("Departure"),
    "reservationEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "reservationExportedLabel": MessageLookupByLibrary.simpleMessage(
      "Exported",
    ),
    "reservationGross": MessageLookupByLibrary.simpleMessage("Gross"),
    "reservationGuestTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "reservationId": MessageLookupByLibrary.simpleMessage("Reservation ID"),
    "reservationInfants": MessageLookupByLibrary.simpleMessage("Infants"),
    "reservationListColumnBooked": MessageLookupByLibrary.simpleMessage(
      "Booked",
    ),
    "reservationListColumnNew": MessageLookupByLibrary.simpleMessage("New"),
    "reservationName": MessageLookupByLibrary.simpleMessage("Name"),
    "reservationNet": MessageLookupByLibrary.simpleMessage("Net"),
    "reservationNewCount": m77,
    "reservationNights": MessageLookupByLibrary.simpleMessage("Nights"),
    "reservationNotes": MessageLookupByLibrary.simpleMessage("Notes"),
    "reservationNotesDisabledHint": MessageLookupByLibrary.simpleMessage(
      "No reservation ID — saving is not possible",
    ),
    "reservationNotesHint": MessageLookupByLibrary.simpleMessage("Add a note…"),
    "reservationNotesSave": MessageLookupByLibrary.simpleMessage(
      "Save to Lodgify",
    ),
    "reservationOutstanding": MessageLookupByLibrary.simpleMessage(
      "Outstanding",
    ),
    "reservationPhone": MessageLookupByLibrary.simpleMessage("Phone"),
    "reservationSectionBooker": MessageLookupByLibrary.simpleMessage("Booker"),
    "reservationSectionGuests": MessageLookupByLibrary.simpleMessage("Guests"),
    "reservationSectionOther": MessageLookupByLibrary.simpleMessage("Other"),
    "reservationSectionPayload": MessageLookupByLibrary.simpleMessage(
      "Full payload",
    ),
    "reservationSectionRevenue": MessageLookupByLibrary.simpleMessage(
      "Revenue",
    ),
    "reservationSectionStay": MessageLookupByLibrary.simpleMessage("Stay"),
    "reservationSource": MessageLookupByLibrary.simpleMessage("Source"),
    "reservationStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "reservationUpdatedAt": MessageLookupByLibrary.simpleMessage("Updated"),
    "reservations": MessageLookupByLibrary.simpleMessage("Reservations"),
    "reservationsBarGuests": m78,
    "reservationsBarNights": m79,
    "reservationsBarSource": m80,
    "reservationsBarStatus": m81,
    "reservationsColumnGuests": MessageLookupByLibrary.simpleMessage("Guests"),
    "reservationsColumnsTooltip": MessageLookupByLibrary.simpleMessage(
      "Columns",
    ),
    "reservationsDensityCompact": MessageLookupByLibrary.simpleMessage(
      "Compact",
    ),
    "reservationsDensityDetailed": MessageLookupByLibrary.simpleMessage(
      "Detailed",
    ),
    "reservationsEmptyList": MessageLookupByLibrary.simpleMessage(
      "No reservations found.",
    ),
    "reservationsEmptyPeriod": MessageLookupByLibrary.simpleMessage(
      "No reservations found for this period.",
    ),
    "reservationsExportLabel": MessageLookupByLibrary.simpleMessage("Export"),
    "reservationsExportPdfDownload": MessageLookupByLibrary.simpleMessage(
      "Download PDF",
    ),
    "reservationsExportPdfShare": MessageLookupByLibrary.simpleMessage(
      "Share PDF",
    ),
    "reservationsExportSettings": MessageLookupByLibrary.simpleMessage(
      "Settings",
    ),
    "reservationsExportTooltip": MessageLookupByLibrary.simpleMessage(
      "Share & export",
    ),
    "reservationsFilterHistorical": MessageLookupByLibrary.simpleMessage(
      "Past bookings",
    ),
    "reservationsFilterTooltip": MessageLookupByLibrary.simpleMessage("Filter"),
    "reservationsKpiArrivals": MessageLookupByLibrary.simpleMessage("Arrivals"),
    "reservationsKpiArrivalsCaption": MessageLookupByLibrary.simpleMessage(
      "check-in",
    ),
    "reservationsKpiBookings": MessageLookupByLibrary.simpleMessage("Bookings"),
    "reservationsKpiBookingsCaption": MessageLookupByLibrary.simpleMessage(
      "this month",
    ),
    "reservationsKpiDepartures": MessageLookupByLibrary.simpleMessage(
      "Departures",
    ),
    "reservationsKpiDeparturesCaption": MessageLookupByLibrary.simpleMessage(
      "check-out",
    ),
    "reservationsKpiOccupancy": MessageLookupByLibrary.simpleMessage(
      "Occupancy",
    ),
    "reservationsLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Bookings could not be loaded.",
    ),
    "reservationsMonthsContinuous": MessageLookupByLibrary.simpleMessage(
      "Continuous",
    ),
    "reservationsNoLodgifyId": MessageLookupByLibrary.simpleMessage(
      "Link a Lodgify ID to this property to load bookings.",
    ),
    "reservationsOutOfMonthBookedOnly": MessageLookupByLibrary.simpleMessage(
      "Booked days only",
    ),
    "reservationsOutOfMonthHide": MessageLookupByLibrary.simpleMessage(
      "Hide days outside the month",
    ),
    "reservationsPageHeading": m82,
    "reservationsPageTitle": MessageLookupByLibrary.simpleMessage(
      "Reservations",
    ),
    "reservationsViewList": MessageLookupByLibrary.simpleMessage("List"),
    "reservationsViewTimeline": MessageLookupByLibrary.simpleMessage(
      "Timeline",
    ),
    "reservationsViewTooltip": MessageLookupByLibrary.simpleMessage("View"),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset password"),
    "resetPasswordInstructions": MessageLookupByLibrary.simpleMessage(
      "Enter the verification code sent to your email and choose a new password.",
    ),
    "resetPasswordLinkExpired": MessageLookupByLibrary.simpleMessage(
      "The reset link has expired. Request a new one.",
    ),
    "resource": MessageLookupByLibrary.simpleMessage("Resource"),
    "restRoom": MessageLookupByLibrary.simpleMessage("Rest Room"),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage("Restore defaults"),
    "revenueBreakdownChannelFee": MessageLookupByLibrary.simpleMessage(
      "Channel fee (Booking/Airbnb)",
    ),
    "revenueBreakdownCleaning": MessageLookupByLibrary.simpleMessage(
      "Cleaning costs",
    ),
    "revenueBreakdownDeposit": MessageLookupByLibrary.simpleMessage("Deposit"),
    "revenueBreakdownDiscounts": MessageLookupByLibrary.simpleMessage(
      "Discounts",
    ),
    "revenueBreakdownExtraCharges": MessageLookupByLibrary.simpleMessage(
      "Extra charges",
    ),
    "revenueBreakdownLinen": MessageLookupByLibrary.simpleMessage(
      "Linen / bed linen",
    ),
    "revenueBreakdownOtherCosts": MessageLookupByLibrary.simpleMessage(
      "Other fixed costs",
    ),
    "revenueBreakdownRent": MessageLookupByLibrary.simpleMessage(
      "Rent / nightly rate",
    ),
    "revenueBreakdownServiceCosts": MessageLookupByLibrary.simpleMessage(
      "Service costs",
    ),
    "revenueBreakdownTax": MessageLookupByLibrary.simpleMessage("Tax / VAT"),
    "revenueChannelSplitTitle": MessageLookupByLibrary.simpleMessage(
      "Revenue per channel",
    ),
    "revenueChartLegendGross": MessageLookupByLibrary.simpleMessage("Gross"),
    "revenueChartLegendNet": MessageLookupByLibrary.simpleMessage("Net"),
    "revenueChartTitle": MessageLookupByLibrary.simpleMessage(
      "Revenue per month",
    ),
    "revenueChartTooltip": m83,
    "revenueColumnBooker": MessageLookupByLibrary.simpleMessage("Booker"),
    "revenueColumnCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "revenueColumnCommission": MessageLookupByLibrary.simpleMessage(
      "Commission",
    ),
    "revenueColumnCosts": MessageLookupByLibrary.simpleMessage("Costs"),
    "revenueColumnGross": MessageLookupByLibrary.simpleMessage("Gross"),
    "revenueColumnNet": MessageLookupByLibrary.simpleMessage("Net"),
    "revenueColumnNightlyRate": MessageLookupByLibrary.simpleMessage(
      "Nightly rate",
    ),
    "revenueColumnNights": MessageLookupByLibrary.simpleMessage("Nights"),
    "revenueFees": MessageLookupByLibrary.simpleMessage("Fees"),
    "revenueHeading": m84,
    "revenueKpiAdr": MessageLookupByLibrary.simpleMessage("Avg. nightly rate"),
    "revenueKpiAdrCaption": m85,
    "revenueKpiGross": MessageLookupByLibrary.simpleMessage("Gross revenue"),
    "revenueKpiGrossCaption": m86,
    "revenueKpiNet": MessageLookupByLibrary.simpleMessage("Net revenue"),
    "revenueKpiNetCaption": MessageLookupByLibrary.simpleMessage("after costs"),
    "revenueKpiOccupancy": MessageLookupByLibrary.simpleMessage("Occupancy"),
    "revenueKpiOccupancyCaption": MessageLookupByLibrary.simpleMessage(
      "of the period",
    ),
    "revenueLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Revenue could not be loaded.",
    ),
    "revenueNetRevenue": MessageLookupByLibrary.simpleMessage("Net revenue"),
    "revenueNoBookedStaysInPeriod": MessageLookupByLibrary.simpleMessage(
      "No booked stays found in this period.",
    ),
    "revenueNoLodgifyId": MessageLookupByLibrary.simpleMessage(
      "Link a Lodgify ID to this property to load revenue.",
    ),
    "revenueOverviewHeader": MessageLookupByLibrary.simpleMessage(
      "Current period overview",
    ),
    "revenuePeriodMonth": MessageLookupByLibrary.simpleMessage("Month"),
    "revenuePeriodQuarter": MessageLookupByLibrary.simpleMessage("Quarter"),
    "revenuePeriodYear": MessageLookupByLibrary.simpleMessage("Year"),
    "revenueQuarterLabel": m87,
    "revenueRefreshTooltip": MessageLookupByLibrary.simpleMessage("Refresh"),
    "revenueServiceCosts": MessageLookupByLibrary.simpleMessage(
      "Service costs",
    ),
    "revenueTotalBookings": MessageLookupByLibrary.simpleMessage(
      "Total bookings",
    ),
    "revenueTotalRevenue": MessageLookupByLibrary.simpleMessage(
      "Total revenue",
    ),
    "revenueTotalsRowLabel": MessageLookupByLibrary.simpleMessage("Total"),
    "revenueUnknownBooker": MessageLookupByLibrary.simpleMessage(
      "Unknown booker",
    ),
    "revenueUnknownProperty": MessageLookupByLibrary.simpleMessage(
      "Unknown property",
    ),
    "right": MessageLookupByLibrary.simpleMessage("Right"),
    "rightAlignment": MessageLookupByLibrary.simpleMessage("Right Alignment"),
    "roleAdmin": MessageLookupByLibrary.simpleMessage("Admin"),
    "roleLabel": MessageLookupByLibrary.simpleMessage("Role"),
    "roleUser": MessageLookupByLibrary.simpleMessage("User"),
    "romantic": MessageLookupByLibrary.simpleMessage("Romantic"),
    "roundNumber": MessageLookupByLibrary.simpleMessage("Round Number"),
    "route": MessageLookupByLibrary.simpleMessage("Route"),
    "rugby": MessageLookupByLibrary.simpleMessage("Rugby"),
    "santaClaus": MessageLookupByLibrary.simpleMessage("Santa Claus"),
    "sauce": MessageLookupByLibrary.simpleMessage("Sauce"),
    "sauceBoat": MessageLookupByLibrary.simpleMessage("Sauce Boat"),
    "sauceBottle": MessageLookupByLibrary.simpleMessage("Sauce Bottle"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Save"),
    "savedLabel": MessageLookupByLibrary.simpleMessage("Saved"),
    "savings": MessageLookupByLibrary.simpleMessage("Savings"),
    "scale": MessageLookupByLibrary.simpleMessage("Scale"),
    "scan": MessageLookupByLibrary.simpleMessage("Scan"),
    "scanBarcode": MessageLookupByLibrary.simpleMessage("Scan Barcode"),
    "searchEmailHint": MessageLookupByLibrary.simpleMessage(
      "Search by email address",
    ),
    "searchIcon": MessageLookupByLibrary.simpleMessage("Search icon"),
    "secureInput": MessageLookupByLibrary.simpleMessage("Secure Input"),
    "seededUser": MessageLookupByLibrary.simpleMessage("Seeded user"),
    "sendMagicLink": MessageLookupByLibrary.simpleMessage("Send magic link"),
    "sendResetLink": MessageLookupByLibrary.simpleMessage("Send reset link"),
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serverSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Admin options",
    ),
    "setPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "Welcome! Set a password to activate your account.",
    ),
    "setPasswordTitle": MessageLookupByLibrary.simpleMessage("Set password"),
    "settingsLabel": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsSaved": MessageLookupByLibrary.simpleMessage("Settings saved."),
    "sharedListsTitle": MessageLookupByLibrary.simpleMessage("Shared lists"),
    "shop": MessageLookupByLibrary.simpleMessage("Shop"),
    "shopping": MessageLookupByLibrary.simpleMessage("Shopping"),
    "shoppingBag": MessageLookupByLibrary.simpleMessage("Shopping Bag"),
    "shoppingBasket": MessageLookupByLibrary.simpleMessage("Shopping Basket"),
    "shoppingCart": MessageLookupByLibrary.simpleMessage("Shopping Cart"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showCalendarTabLabel": MessageLookupByLibrary.simpleMessage(
      "Show calendar tab",
    ),
    "showErrorDetails": MessageLookupByLibrary.simpleMessage("Show details"),
    "showStartTabLabel": MessageLookupByLibrary.simpleMessage("Show start tab"),
    "sidebarCollapseTooltip": MessageLookupByLibrary.simpleMessage(
      "Collapse menu",
    ),
    "sidebarExpandTooltip": MessageLookupByLibrary.simpleMessage(
      "Show menu labels",
    ),
    "sidebarPinTooltip": MessageLookupByLibrary.simpleMessage("Pin menu"),
    "signInWithMagicLink": MessageLookupByLibrary.simpleMessage(
      "Sign in with magic link",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
    "signUpFailed": MessageLookupByLibrary.simpleMessage("Sign up failed"),
    "siteDetailsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Site details",
    ),
    "siteSettingsBookingSection": MessageLookupByLibrary.simpleMessage(
      "Booking (Lodgify)",
    ),
    "siteSettingsContactEmailHint": MessageLookupByLibrary.simpleMessage(
      "Where contact form messages are sent.",
    ),
    "siteSettingsContactEmailLabel": MessageLookupByLibrary.simpleMessage(
      "Contact form recipient",
    ),
    "siteSettingsContactSection": MessageLookupByLibrary.simpleMessage(
      "Contact",
    ),
    "siteSettingsEmailFromNameHint": MessageLookupByLibrary.simpleMessage(
      "Shown as the sender of website emails (defaults to the site name).",
    ),
    "siteSettingsEmailFromNameLabel": MessageLookupByLibrary.simpleMessage(
      "Email sender name",
    ),
    "siteSettingsLodgifyPropertyIdLabel": MessageLookupByLibrary.simpleMessage(
      "Lodgify property ID",
    ),
    "siteSettingsLodgifyRoomTypeIdLabel": MessageLookupByLibrary.simpleMessage(
      "Lodgify room type ID",
    ),
    "siteSettingsSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Could not save website settings",
    ),
    "siteSettingsSaved": MessageLookupByLibrary.simpleMessage(
      "Website settings saved",
    ),
    "siteSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Website settings",
    ),
    "sitesCreateButton": MessageLookupByLibrary.simpleMessage("Create site"),
    "sitesDefaultLocaleHint": MessageLookupByLibrary.simpleMessage("en"),
    "sitesDefaultLocaleLabel": MessageLookupByLibrary.simpleMessage(
      "Default locale",
    ),
    "sitesEmpty": MessageLookupByLibrary.simpleMessage(
      "No sites configured yet.",
    ),
    "sitesLoadFailed": m88,
    "sitesLocaleSummary": m89,
    "sitesNameHint": MessageLookupByLibrary.simpleMessage("Trysil Panorama"),
    "sitesNameLabel": MessageLookupByLibrary.simpleMessage("Site name"),
    "sitesNewEntryTitle": MessageLookupByLibrary.simpleMessage(
      "New site entry",
    ),
    "sitesTitle": MessageLookupByLibrary.simpleMessage("Property website"),
    "small": MessageLookupByLibrary.simpleMessage("Small"),
    "smallCaps": MessageLookupByLibrary.simpleMessage("Small Caps"),
    "snowflake": MessageLookupByLibrary.simpleMessage("Snowflake"),
    "software": MessageLookupByLibrary.simpleMessage("Software"),
    "sound": MessageLookupByLibrary.simpleMessage("Sound"),
    "soundLabel": MessageLookupByLibrary.simpleMessage("Sound"),
    "soup": MessageLookupByLibrary.simpleMessage("Soup"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceBadgeLabel": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "The language you enter your website content in",
    ),
    "sourceLanguageFooter": MessageLookupByLibrary.simpleMessage(
      "Everything else is AI-translated from your source language on publish. Fields you lock keep your wording.",
    ),
    "sourceLanguageLabel": MessageLookupByLibrary.simpleMessage(
      "Source language",
    ),
    "sourceLanguageUnavailable": MessageLookupByLibrary.simpleMessage(
      "No website linked",
    ),
    "spaghetti": MessageLookupByLibrary.simpleMessage("Spaghetti"),
    "sport": MessageLookupByLibrary.simpleMessage("Sport"),
    "sportCar": MessageLookupByLibrary.simpleMessage("Sport Car"),
    "square": MessageLookupByLibrary.simpleMessage("Square"),
    "stacktraceHeader": MessageLookupByLibrary.simpleMessage("Stacktrace"),
    "standardUser": MessageLookupByLibrary.simpleMessage("Standard user"),
    "star": MessageLookupByLibrary.simpleMessage("Star"),
    "starInverse": MessageLookupByLibrary.simpleMessage("Star Inverse"),
    "statistic": MessageLookupByLibrary.simpleMessage("Statistic"),
    "steak": MessageLookupByLibrary.simpleMessage("Steak"),
    "store": MessageLookupByLibrary.simpleMessage("Store"),
    "subscriptionChipLabel": m90,
    "subscriptionLabel": MessageLookupByLibrary.simpleMessage("Subscription"),
    "subtract": MessageLookupByLibrary.simpleMessage("Subtract"),
    "suitcase": MessageLookupByLibrary.simpleMessage("Suitcase"),
    "sum": MessageLookupByLibrary.simpleMessage("Sum"),
    "sun": MessageLookupByLibrary.simpleMessage("Sun"),
    "sunlight": MessageLookupByLibrary.simpleMessage("Sunlight"),
    "supabaseTableMissing": m91,
    "switchPropertyTitle": MessageLookupByLibrary.simpleMessage(
      "Pick a property",
    ),
    "symbol": MessageLookupByLibrary.simpleMessage("Symbol"),
    "systemSetting": MessageLookupByLibrary.simpleMessage("System setting"),
    "tShirt": MessageLookupByLibrary.simpleMessage("T-shirt"),
    "table": MessageLookupByLibrary.simpleMessage("Table"),
    "tableOfContent": MessageLookupByLibrary.simpleMessage("Table of Content"),
    "tag": MessageLookupByLibrary.simpleMessage("Tag"),
    "taxi": MessageLookupByLibrary.simpleMessage("Taxi"),
    "teamActionsColumn": MessageLookupByLibrary.simpleMessage("Actions"),
    "teamCancelInvitation": MessageLookupByLibrary.simpleMessage("Cancel"),
    "teamEmailColumn": MessageLookupByLibrary.simpleMessage("Email"),
    "teamEmailPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Email address",
    ),
    "teamInvitationFailed": MessageLookupByLibrary.simpleMessage(
      "Invitation failed",
    ),
    "teamInvitationResent": MessageLookupByLibrary.simpleMessage(
      "Invitation resent",
    ),
    "teamInvitationSent": MessageLookupByLibrary.simpleMessage(
      "Invitation sent",
    ),
    "teamInviteMemberButton": MessageLookupByLibrary.simpleMessage(
      "Invite member",
    ),
    "teamInviteMemberTitle": MessageLookupByLibrary.simpleMessage(
      "Invite member",
    ),
    "teamInviteSiteDescription": m92,
    "teamInviteUserDescription": MessageLookupByLibrary.simpleMessage(
      "Invite a user to manage your properties together.",
    ),
    "teamInviteUserTitle": MessageLookupByLibrary.simpleMessage("Invite user"),
    "teamMembersSection": MessageLookupByLibrary.simpleMessage("Members"),
    "teamNoMembers": MessageLookupByLibrary.simpleMessage("No members found."),
    "teamNoPendingInvitations": MessageLookupByLibrary.simpleMessage(
      "No pending invitations.",
    ),
    "teamPendingInvitations": MessageLookupByLibrary.simpleMessage(
      "Pending invitations",
    ),
    "teamRemoveMember": MessageLookupByLibrary.simpleMessage("Remove"),
    "teamRemoveMemberConfirm": m93,
    "teamRemoveMemberTitle": MessageLookupByLibrary.simpleMessage(
      "Remove member",
    ),
    "teamResendInvitation": MessageLookupByLibrary.simpleMessage("Resend"),
    "teamRoleColumn": MessageLookupByLibrary.simpleMessage("Role"),
    "teamSendInvitation": MessageLookupByLibrary.simpleMessage(
      "Send invitation",
    ),
    "teamTitle": MessageLookupByLibrary.simpleMessage("Team"),
    "teamUserColumn": MessageLookupByLibrary.simpleMessage("User"),
    "text": MessageLookupByLibrary.simpleMessage("Text"),
    "thai": MessageLookupByLibrary.simpleMessage("Thai"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "thumb": MessageLookupByLibrary.simpleMessage("Thumb"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timer": MessageLookupByLibrary.simpleMessage("Timer"),
    "todoList": MessageLookupByLibrary.simpleMessage("Todo List"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "toggleAdminFailed": m94,
    "tomato": MessageLookupByLibrary.simpleMessage("Tomato"),
    "tooManyAttempts": MessageLookupByLibrary.simpleMessage(
      "Too many attempts",
    ),
    "trash": MessageLookupByLibrary.simpleMessage("Trash"),
    "travel": MessageLookupByLibrary.simpleMessage("Travel"),
    "travelItinerary": MessageLookupByLibrary.simpleMessage("Travel Itinerary"),
    "tree": MessageLookupByLibrary.simpleMessage("Tree"),
    "trophy": MessageLookupByLibrary.simpleMessage("Trophy"),
    "tryAgainLater": MessageLookupByLibrary.simpleMessage("Try again later"),
    "unbox": MessageLookupByLibrary.simpleMessage("Unbox"),
    "underline": MessageLookupByLibrary.simpleMessage("Underline"),
    "untitledList": MessageLookupByLibrary.simpleMessage("Untitled"),
    "updateAdminRightsFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t update admin rights. Try again.",
    ),
    "updateButton": MessageLookupByLibrary.simpleMessage("Update"),
    "updateProfileFailed": m95,
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "userCreated": MessageLookupByLibrary.simpleMessage("User created."),
    "userDeleteFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t delete user.",
    ),
    "userDeleteFailedWithReason": m96,
    "userDeleted": MessageLookupByLibrary.simpleMessage("User deleted."),
    "userIdLabel": MessageLookupByLibrary.simpleMessage("User ID"),
    "userSettingsAction": MessageLookupByLibrary.simpleMessage("User settings"),
    "userUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t update user.",
    ),
    "userUpdated": MessageLookupByLibrary.simpleMessage("User updated."),
    "usernameLabel": MessageLookupByLibrary.simpleMessage("Username"),
    "usersLabel": MessageLookupByLibrary.simpleMessage("Users"),
    "usersSubtitle": MessageLookupByLibrary.simpleMessage(
      "Search, review, and manage access to the console.",
    ),
    "usersTitle": MessageLookupByLibrary.simpleMessage("Users"),
    "vacationTime": MessageLookupByLibrary.simpleMessage("Vacation Time"),
    "vegetables": MessageLookupByLibrary.simpleMessage("Vegetables"),
    "vegetarian": MessageLookupByLibrary.simpleMessage("Vegetarian"),
    "verificationCode": MessageLookupByLibrary.simpleMessage(
      "Verification code",
    ),
    "verificationCodeSentText": m97,
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "versionFooter": m98,
    "verticalLine": MessageLookupByLibrary.simpleMessage("Vertical Line"),
    "walking": MessageLookupByLibrary.simpleMessage("Walking"),
    "wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "waste": MessageLookupByLibrary.simpleMessage("Waste"),
    "watch": MessageLookupByLibrary.simpleMessage("Watch"),
    "weAddHighlight": MessageLookupByLibrary.simpleMessage("Add highlight"),
    "weAddPhoto": MessageLookupByLibrary.simpleMessage("Add"),
    "weAiTranslation": MessageLookupByLibrary.simpleMessage("AI translation"),
    "weBannerEditingBody": m99,
    "weBannerEditingTitle": m100,
    "weBannerUnpublishedBody": m101,
    "weBannerUnpublishedTitle": MessageLookupByLibrary.simpleMessage(
      "Unpublished changes",
    ),
    "weBannerWritingBody": MessageLookupByLibrary.simpleMessage(
      "Other languages translate automatically on publish — except fields you lock.",
    ),
    "weBannerWritingTitle": m102,
    "weBreadcrumbWebsite": MessageLookupByLibrary.simpleMessage("Website"),
    "weCardAgreements": MessageLookupByLibrary.simpleMessage("Terms & payment"),
    "weCardAmenities": MessageLookupByLibrary.simpleMessage("Amenities"),
    "weCardAmenitiesSub": MessageLookupByLibrary.simpleMessage(
      "Groups with items.",
    ),
    "weCardAreaIntro": MessageLookupByLibrary.simpleMessage("Introduction"),
    "weCardAreaIntroSub": MessageLookupByLibrary.simpleMessage(
      "Renders as the subtitle under the page title.",
    ),
    "weCardAreaSections": MessageLookupByLibrary.simpleMessage("Sections"),
    "weCardAreaSectionsSub": MessageLookupByLibrary.simpleMessage(
      "Each section is a card with a title, text and lines.",
    ),
    "weCardArrival": MessageLookupByLibrary.simpleMessage("Arrival & access"),
    "weCardContact": MessageLookupByLibrary.simpleMessage("Contact"),
    "weCardContactHelp": MessageLookupByLibrary.simpleMessage("Contact & help"),
    "weCardContactSub": MessageLookupByLibrary.simpleMessage(
      "At the bottom of the homepage. The four fields are fixed — only the copy is yours.",
    ),
    "weCardContent": MessageLookupByLibrary.simpleMessage("Page content"),
    "weCardDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "weCardGalleryAll": MessageLookupByLibrary.simpleMessage("All photos"),
    "weCardGalleryAllSub": MessageLookupByLibrary.simpleMessage(
      "The full set on /gallery. The homepage shows a selection from it.",
    ),
    "weCardGalleryHeaderSub": MessageLookupByLibrary.simpleMessage(
      "The page title comes from the interface language; the line below it is yours.",
    ),
    "weCardGoodToKnow": MessageLookupByLibrary.simpleMessage("Good to know"),
    "weCardHeader": MessageLookupByLibrary.simpleMessage("Header"),
    "weCardHero": MessageLookupByLibrary.simpleMessage("Hero"),
    "weCardHeroSub": MessageLookupByLibrary.simpleMessage(
      "Title, location line and the rotating hero photos.",
    ),
    "weCardHighlights": MessageLookupByLibrary.simpleMessage("Highlights"),
    "weCardHighlightsSub": MessageLookupByLibrary.simpleMessage(
      "Cards with a photo at the bottom of the homepage.",
    ),
    "weCardHomeGallery": MessageLookupByLibrary.simpleMessage(
      "Gallery on the homepage",
    ),
    "weCardHomeGallerySub": MessageLookupByLibrary.simpleMessage(
      "A selection from the library; the full set is on the Gallery tab.",
    ),
    "weCardHouseRules": MessageLookupByLibrary.simpleMessage("House rules"),
    "weCardHouseRulesSub": MessageLookupByLibrary.simpleMessage(
      "Renders as a section on the homepage.",
    ),
    "weCardKeyFacts": MessageLookupByLibrary.simpleMessage("Key facts"),
    "weCardKeyFactsSub": MessageLookupByLibrary.simpleMessage(
      "The tiles right below the hero.",
    ),
    "weCardLayout": MessageLookupByLibrary.simpleMessage("Layout & facilities"),
    "weCardLayoutSub": MessageLookupByLibrary.simpleMessage(
      "Sections with a short introduction and lines.",
    ),
    "weCardLocation": MessageLookupByLibrary.simpleMessage(
      "Location & distances",
    ),
    "weCardParking": MessageLookupByLibrary.simpleMessage("Parking & charging"),
    "weCardPrivacy": MessageLookupByLibrary.simpleMessage("Privacy statement"),
    "weCardQuickFacts": MessageLookupByLibrary.simpleMessage("Quick overview"),
    "weCardQuickFactsSub": MessageLookupByLibrary.simpleMessage(
      "The strip at the top of the page.",
    ),
    "weCardSourceLodgify": MessageLookupByLibrary.simpleMessage("From Lodgify"),
    "weCardTransport": MessageLookupByLibrary.simpleMessage("Getting here"),
    "weCardTransportSub": MessageLookupByLibrary.simpleMessage(
      "Fixed columns with travel options.",
    ),
    "weChipAuto": MessageLookupByLibrary.simpleMessage("Auto"),
    "weChipLocked": MessageLookupByLibrary.simpleMessage("Locked"),
    "weChipNew": MessageLookupByLibrary.simpleMessage("New"),
    "weChipShared": MessageLookupByLibrary.simpleMessage("shared"),
    "weChipTooltipAuto": MessageLookupByLibrary.simpleMessage(
      "Following the source — click to keep your own wording",
    ),
    "weChipTooltipLocked": MessageLookupByLibrary.simpleMessage(
      "Your wording — click to follow the source again",
    ),
    "weColumnAirports": MessageLookupByLibrary.simpleMessage("Airports"),
    "weColumnCar": MessageLookupByLibrary.simpleMessage("By car"),
    "weColumnNotes": MessageLookupByLibrary.simpleMessage("Note"),
    "weColumnParking": MessageLookupByLibrary.simpleMessage("Parking"),
    "weColumnPublicTransport": MessageLookupByLibrary.simpleMessage(
      "Public transport",
    ),
    "weDeviceMobile": MessageLookupByLibrary.simpleMessage("Mobile"),
    "weDeviceWeb": MessageLookupByLibrary.simpleMessage("Web"),
    "weDiscard": MessageLookupByLibrary.simpleMessage("Discard"),
    "weDiscardCancel": MessageLookupByLibrary.simpleMessage("Keep editing"),
    "weDiscardConfirm": MessageLookupByLibrary.simpleMessage("Discard"),
    "weDiscardMessage": MessageLookupByLibrary.simpleMessage(
      "Every language goes back to what was last saved. This cannot be undone.",
    ),
    "weDiscardTitle": MessageLookupByLibrary.simpleMessage(
      "Discard your unsaved changes?",
    ),
    "weEditingChip": m103,
    "weErrorLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load the website content",
    ),
    "weErrorPublishFailed": MessageLookupByLibrary.simpleMessage(
      "Publishing failed — your changes are kept as drafts",
    ),
    "weErrorResetFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t reset this field to AI",
    ),
    "weErrorSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t save your changes — they are kept in the editor",
    ),
    "weErrorTranslateFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t refresh the translation — the last good version is kept",
    ),
    "weExternalLodgifyNote": MessageLookupByLibrary.simpleMessage(
      "Payment schedule, cancellation and deposit come from your Lodgify settings. The console is not the source for booking terms — change them there.",
    ),
    "weFieldAlt": MessageLookupByLibrary.simpleMessage("Alt text"),
    "weFieldAltSummary": MessageLookupByLibrary.simpleMessage(
      "Alt text (summarizing)",
    ),
    "weFieldCallout": MessageLookupByLibrary.simpleMessage(
      "Highlighted warning",
    ),
    "weFieldCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "weFieldCheckInNote": MessageLookupByLibrary.simpleMessage("Check-in note"),
    "weFieldCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "weFieldCleaningNote": MessageLookupByLibrary.simpleMessage(
      "Cleaning and linen",
    ),
    "weFieldError": MessageLookupByLibrary.simpleMessage("Failure"),
    "weFieldExperience": m104,
    "weFieldHeadline": MessageLookupByLibrary.simpleMessage("Headline"),
    "weFieldHeroPhotos": MessageLookupByLibrary.simpleMessage("Hero photos"),
    "weFieldHighlight": m105,
    "weFieldIntro": MessageLookupByLibrary.simpleMessage("Intro"),
    "weFieldLocationLine": MessageLookupByLibrary.simpleMessage(
      "Location line",
    ),
    "weFieldMapQuery": MessageLookupByLibrary.simpleMessage("Map search term"),
    "weFieldPrivacyIntro": MessageLookupByLibrary.simpleMessage("Introduction"),
    "weFieldSearchName": MessageLookupByLibrary.simpleMessage(
      "Name for search engines",
    ),
    "weFieldSubline": MessageLookupByLibrary.simpleMessage("Subline"),
    "weFieldSubmit": MessageLookupByLibrary.simpleMessage("Button"),
    "weFieldSubtitle": MessageLookupByLibrary.simpleMessage("Subtitle"),
    "weFieldSuccess": MessageLookupByLibrary.simpleMessage("Success"),
    "weFieldTitle": MessageLookupByLibrary.simpleMessage("Title"),
    "weFieldWifiNote": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
    "weFilterOnlyChanged": MessageLookupByLibrary.simpleMessage("Only changed"),
    "weFixedColumnsMeta": MessageLookupByLibrary.simpleMessage("fixed columns"),
    "weFormFieldEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "weFormFieldMessage": MessageLookupByLibrary.simpleMessage("Message"),
    "weFormFieldName": MessageLookupByLibrary.simpleMessage("Name"),
    "weFormFieldPeriod": MessageLookupByLibrary.simpleMessage(
      "Preferred dates",
    ),
    "weFreshNotice": MessageLookupByLibrary.simpleMessage(
      "Fresh draft, matches your latest source.",
    ),
    "weGroupIntro": m106,
    "weHidePreview": MessageLookupByLibrary.simpleMessage("Hide preview"),
    "weHintMap": MessageLookupByLibrary.simpleMessage(
      "Decides where the pin sits on the map; it is not read as text.",
    ),
    "weHintSeo": MessageLookupByLibrary.simpleMessage(
      "This field is not on the page: it is the title in the browser tab and the description in Google.",
    ),
    "weHintStateError": MessageLookupByLibrary.simpleMessage(
      "Only visible when the form fails.",
    ),
    "weHintStateSuccess": MessageLookupByLibrary.simpleMessage(
      "Only visible after the form has been submitted.",
    ),
    "weItemAmenity": MessageLookupByLibrary.simpleMessage("Amenity"),
    "weItemColumn": MessageLookupByLibrary.simpleMessage("Column"),
    "weItemDistance": MessageLookupByLibrary.simpleMessage("Distance"),
    "weItemFact": MessageLookupByLibrary.simpleMessage("Fact"),
    "weItemFormField": MessageLookupByLibrary.simpleMessage("Field"),
    "weItemGroup": MessageLookupByLibrary.simpleMessage("Group"),
    "weItemHighlight": MessageLookupByLibrary.simpleMessage("Highlight"),
    "weItemKeyFact": MessageLookupByLibrary.simpleMessage("Key fact"),
    "weItemLine": MessageLookupByLibrary.simpleMessage("Line"),
    "weItemParagraph": MessageLookupByLibrary.simpleMessage("Paragraph"),
    "weItemSection": MessageLookupByLibrary.simpleMessage("Section"),
    "weItemTime": MessageLookupByLibrary.simpleMessage("Time"),
    "weLaneChanged": m107,
    "weLangDutch": MessageLookupByLibrary.simpleMessage("Dutch"),
    "weLangEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "weLangNorwegian": MessageLookupByLibrary.simpleMessage("Norwegian"),
    "weLeaveCancel": MessageLookupByLibrary.simpleMessage("Stay"),
    "weLeaveConfirm": MessageLookupByLibrary.simpleMessage("Leave anyway"),
    "weLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "Nothing has been written to the site yet. Leaving keeps your edits here for now, but closing the tab loses them.",
    ),
    "weLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "You have unsaved changes",
    ),
    "weListAdd": m108,
    "weListColumns": MessageLookupByLibrary.simpleMessage("Columns"),
    "weListCounter": m109,
    "weListDistances": MessageLookupByLibrary.simpleMessage("Distances"),
    "weListEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "This list only appears on the website once it holds something.",
    ),
    "weListEmptyTitle": m110,
    "weListFacts": MessageLookupByLibrary.simpleMessage("Facts"),
    "weListFormFields": MessageLookupByLibrary.simpleMessage("Fields"),
    "weListGroups": MessageLookupByLibrary.simpleMessage("Groups"),
    "weListKeyFacts": MessageLookupByLibrary.simpleMessage("Key facts"),
    "weListLines": MessageLookupByLibrary.simpleMessage("Lines"),
    "weListMaxReached": m111,
    "weListMaxReason": MessageLookupByLibrary.simpleMessage(
      "Remove a row first",
    ),
    "weListMinReason": m112,
    "weListParagraphs": MessageLookupByLibrary.simpleMessage("Paragraphs"),
    "weListSections": MessageLookupByLibrary.simpleMessage("Sections"),
    "weListTimes": MessageLookupByLibrary.simpleMessage(
      "Check-in and check-out",
    ),
    "weLivePreview": MessageLookupByLibrary.simpleMessage("Live preview"),
    "weLoadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "The editor shows no fields until this website\'s content has loaded.",
    ),
    "weLoadFailedRetry": MessageLookupByLibrary.simpleMessage("Try again"),
    "weLocaleSourceBadge": MessageLookupByLibrary.simpleMessage("source"),
    "weLockedCounter": m113,
    "weMediaAdd": m114,
    "weMediaCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "weMediaChoose": MessageLookupByLibrary.simpleMessage("Choose"),
    "weMediaEmptyBody": MessageLookupByLibrary.simpleMessage(
      "Upload your first photos on the Upload tab.",
    ),
    "weMediaEmptyTitle": MessageLookupByLibrary.simpleMessage("No photos yet"),
    "weMediaFirst": MessageLookupByLibrary.simpleMessage("First"),
    "weMediaFootnote": m115,
    "weMediaMinReached": m116,
    "weMediaPending": m117,
    "weMediaPickerHint": m118,
    "weMediaPickerSingleHint": MessageLookupByLibrary.simpleMessage(
      "Choose one photo from the library or upload a new one. Choosing replaces the current one.",
    ),
    "weMediaReplace": MessageLookupByLibrary.simpleMessage("Replace"),
    "weMediaTabLibrary": MessageLookupByLibrary.simpleMessage("Library"),
    "weMediaTabUpload": MessageLookupByLibrary.simpleMessage("Upload"),
    "weMediaTitleGallery": MessageLookupByLibrary.simpleMessage("All photos"),
    "weMediaTitleHero": MessageLookupByLibrary.simpleMessage("Hero photos"),
    "weMediaTitleHomeGallery": MessageLookupByLibrary.simpleMessage(
      "Featured photos",
    ),
    "weMediaTitleRowImage": MessageLookupByLibrary.simpleMessage("Image"),
    "weMediaUnused": MessageLookupByLibrary.simpleMessage("Unused"),
    "wePageArea": MessageLookupByLibrary.simpleMessage("Area"),
    "wePageGallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "wePageHome": MessageLookupByLibrary.simpleMessage("Home"),
    "wePageLegal": MessageLookupByLibrary.simpleMessage("Legal"),
    "wePagePractical": MessageLookupByLibrary.simpleMessage("Practical"),
    "wePairDistance": MessageLookupByLibrary.simpleMessage("Distance"),
    "wePairLabel": MessageLookupByLibrary.simpleMessage("Label"),
    "wePairPlaceholder": MessageLookupByLibrary.simpleMessage("Placeholder"),
    "wePairTime": MessageLookupByLibrary.simpleMessage("Time"),
    "wePairValue": MessageLookupByLibrary.simpleMessage("Value"),
    "wePairWhat": MessageLookupByLibrary.simpleMessage("What"),
    "wePreviewLabel": m119,
    "wePreviewLatest": MessageLookupByLibrary.simpleMessage("Preview latest"),
    "wePreviewTranslation": MessageLookupByLibrary.simpleMessage(
      "Preview translation",
    ),
    "wePublish": MessageLookupByLibrary.simpleMessage("Publish"),
    "wePublishAll": MessageLookupByLibrary.simpleMessage(
      "Publish all languages",
    ),
    "wePublishCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "wePublishConfirm": m120,
    "wePublishDraft": MessageLookupByLibrary.simpleMessage(
      "Draft — not reviewed yet",
    ),
    "wePublishDraftTranslatesNow": MessageLookupByLibrary.simpleMessage(
      "Not reviewed yet · translates now",
    ),
    "wePublishFooter": m121,
    "wePublishModalTitle": MessageLookupByLibrary.simpleMessage(
      "What goes live",
    ),
    "wePublishNeedsSave": MessageLookupByLibrary.simpleMessage(
      "Save your changes first",
    ),
    "wePublishNotSeen": MessageLookupByLibrary.simpleMessage("Not reviewed"),
    "wePublishNothingChanged": MessageLookupByLibrary.simpleMessage(
      "Nothing changed",
    ),
    "wePublishOpen": MessageLookupByLibrary.simpleMessage("Open"),
    "wePublishPageSeen": m122,
    "wePublishPageUnseen": m123,
    "wePublishPartlySeen": m124,
    "wePublishPerPage": MessageLookupByLibrary.simpleMessage("Per page"),
    "wePublishReady": MessageLookupByLibrary.simpleMessage("Ready"),
    "wePublishReadyNote": MessageLookupByLibrary.simpleMessage(
      "Published as written",
    ),
    "wePublishRetranslate": MessageLookupByLibrary.simpleMessage(
      "Re-translate",
    ),
    "wePublishRetranslateNote": MessageLookupByLibrary.simpleMessage(
      "Out of date — will refresh",
    ),
    "wePublishReviewed": MessageLookupByLibrary.simpleMessage("Reviewed"),
    "wePublishSeen": MessageLookupByLibrary.simpleMessage("Reviewed"),
    "wePublishSkipped": MessageLookupByLibrary.simpleMessage("Skipped"),
    "wePublishSkippedNote": MessageLookupByLibrary.simpleMessage(
      "stays as it is live now",
    ),
    "wePublishSourceDelta": m125,
    "wePublishSourceOnly": m126,
    "wePublishSourceRole": m127,
    "wePublishSubtitle": m128,
    "wePublishTargetDelta": m129,
    "wePublishTitle": MessageLookupByLibrary.simpleMessage(
      "Publish all languages",
    ),
    "weResetToAi": MessageLookupByLibrary.simpleMessage("Reset to AI"),
    "weRibbonDraft": MessageLookupByLibrary.simpleMessage(
      "Draft translation — visible only to you until you publish.",
    ),
    "weRibbonStale": MessageLookupByLibrary.simpleMessage(
      "Earlier preview — updates automatically on publish.",
    ),
    "weRowDeleted": MessageLookupByLibrary.simpleMessage("Row deleted."),
    "weRowMediaPending": MessageLookupByLibrary.simpleMessage(
      "One image per row. The media picker arrives with image management.",
    ),
    "weSave": MessageLookupByLibrary.simpleMessage("Save changes"),
    "weSaveDirty": MessageLookupByLibrary.simpleMessage(
      "Unpublished changes · auto-translates on publish",
    ),
    "weSavePublished": MessageLookupByLibrary.simpleMessage(
      "Published · all languages",
    ),
    "weSharedPhotosNote": MessageLookupByLibrary.simpleMessage(
      "Photos are shared across all languages — edit them in the source.",
    ),
    "weSharedValueMeta": MessageLookupByLibrary.simpleMessage(
      "value is shared across languages",
    ),
    "weShowPreview": MessageLookupByLibrary.simpleMessage("Show preview"),
    "weSourceChip": m130,
    "weStaleNotice": MessageLookupByLibrary.simpleMessage(
      "Preview reflects an earlier source edit.",
    ),
    "weStatusCleanBody": m131,
    "weStatusCleanTitle": MessageLookupByLibrary.simpleMessage(
      "Everything published",
    ),
    "weStatusSavedBody": m132,
    "weStatusSavedTitle": MessageLookupByLibrary.simpleMessage(
      "Saved · not published",
    ),
    "weStatusUnsavedBody": MessageLookupByLibrary.simpleMessage(
      "Nothing is saved until you press Save changes",
    ),
    "weStatusUnsavedTitle": MessageLookupByLibrary.simpleMessage(
      "Unsaved changes",
    ),
    "weStructureLocked": m133,
    "weUndo": MessageLookupByLibrary.simpleMessage("Undo"),
    "weUndoSwitchNotice": m134,
    "weUploadDone": m135,
    "weUploadDropTitle": MessageLookupByLibrary.simpleMessage(
      "Drag photos here or choose files",
    ),
    "weUploadFailed": MessageLookupByLibrary.simpleMessage(
      "The upload failed. Try again.",
    ),
    "weUploadInProgress": MessageLookupByLibrary.simpleMessage("Uploading…"),
    "weUploadRejectedPortrait": MessageLookupByLibrary.simpleMessage(
      "Portrait orientation. Use a landscape photo.",
    ),
    "weUploadRejectedTooLarge": MessageLookupByLibrary.simpleMessage(
      "Too large. At most 8 MB.",
    ),
    "weUploadRejectedTooSmall": m136,
    "weUploadRejectedType": MessageLookupByLibrary.simpleMessage(
      "This file type is not supported. Export as JPG or WebP.",
    ),
    "weUploadRequirements": MessageLookupByLibrary.simpleMessage(
      "JPG or WebP · at least 1600 × 1200 · at most 8 MB · landscape",
    ),
    "weUploadResizeNote": MessageLookupByLibrary.simpleMessage(
      "Large files are resized automatically for the website.",
    ),
    "wealth": MessageLookupByLibrary.simpleMessage("Wealth"),
    "websiteLanguagesFooter": MessageLookupByLibrary.simpleMessage(
      "The languages your public website offers to guests. Add or remove any language.",
    ),
    "websiteLanguagesSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Website languages",
    ),
    "weight": MessageLookupByLibrary.simpleMessage("Weight"),
    "welcome": MessageLookupByLibrary.simpleMessage("Welcome"),
    "width": MessageLookupByLibrary.simpleMessage("Width"),
    "wifi": MessageLookupByLibrary.simpleMessage("WiFi"),
    "wine": MessageLookupByLibrary.simpleMessage("Wine"),
    "wineAndGlass": MessageLookupByLibrary.simpleMessage("Wine and Glass"),
    "wineBottle": MessageLookupByLibrary.simpleMessage("Wine Bottle"),
    "wineList": MessageLookupByLibrary.simpleMessage("Wine List"),
    "wishlist": MessageLookupByLibrary.simpleMessage("Wishlist"),
    "wok": MessageLookupByLibrary.simpleMessage("Wok"),
    "woman": MessageLookupByLibrary.simpleMessage("Woman"),
    "write": MessageLookupByLibrary.simpleMessage("Write"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "yesLabel": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
