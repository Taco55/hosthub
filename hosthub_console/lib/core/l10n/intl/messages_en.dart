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

  static String m0(error) => "Failed to load content: ${error}";

  static String m1(version) =>
      "Replace current content with version ${version}? The restored content will be saved as a draft for review.";

  static String m2(date) => "Published ${date}";

  static String m3(version) => "Version ${version}";

  static String m4(error) => "Failed to load content documents: ${error}";

  static String m5(publishedAt) => "Published ${publishedAt}";

  static String m6(status, updatedAt) => "${status} • updated ${updatedAt}";

  static String m7(slug, version) => "${slug} (v${version})";

  static String m8(error) => "Couldn\'t create user: ${error}";

  static String m9(email) =>
      "Are you sure you want to delete ${email}? This also removes the account\'s contents and cannot be undone.";

  static String m10(count) => "At least ${count} characters";

  static String m11(fieldType) =>
      "Field is linked to field of type \'${fieldType}\'";

  static String m12(locale) => "Display name (${locale})";

  static String m13(role) => "Role: ${role}";

  static String m14(date) => "Since ${date}";

  static String m15(name) => "Edit template details ${name}";

  static String m16(code) => "Field name (${code})";

  static String m17(count) =>
      "${count} ${Intl.plural(count, one: 'field', other: 'fields')}";

  static String m18(path) => "Default seed directory: ${path}";

  static String m19(path) => "JSON saved to ${path}";

  static String m20(code) => "Locale ${code}";

  static String m21(code) => "List name (${code})";

  static String m22(code) => "Plural name (${code})";

  static String m23(count) =>
      "${count} sample ${Intl.plural(count, one: 'item', other: 'items')}";

  static String m24(prod, dev) => "${prod} prod / ${dev} dev";

  static String m25(error) => "Couldn\'t load user: ${error}";

  static String m26(error) => "Couldn\'t load users: ${error}";

  static String m27(time) => "Last sync: ${time}";

  static String m28(error) => "Login failed: ${error}";

  static String m29(email) =>
      "We sent a magic link to ${email}. Check your inbox and spam folder.";

  static String m30(error) => "Couldn\'t update the password: ${error}";

  static String m31(error) => "Couldn\'t load profile: ${error}";

  static String m32(seconds) => "Resend available in ${seconds} s";

  static String m33(propertyName) =>
      "Revenue for ${propertyName} from Lodgify bookings.";

  static String m34(quarter, year) => "Quarter ${quarter} ${year}";

  static String m35(error) => "Failed to load sites: ${error}";

  static String m36(defaultLocale, locales) =>
      "Locale: ${defaultLocale} • Locales: ${locales}";

  static String m37(status) => "Subscription: ${status}";

  static String m38(table) =>
      "Can’t load data because Supabase couldn’t find the \"${table}\" table. Deploy the latest database migrations and refresh the schema cache.";

  static String m39(siteName) =>
      "Invite someone to collaborate on \"${siteName}\".";

  static String m40(name) => "Are you sure you want to remove ${name}?";

  static String m41(error) => "Couldn\'t update admin access: ${error}";

  static String m42(error) => "Couldn\'t update profile: ${error}";

  static String m43(error) => "Couldn\'t delete user: ${error}";

  static String m44(email) => "Verification code sent to ${email}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addressBook": MessageLookupByLibrary.simpleMessage("Address Book"),
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
    "appName": MessageLookupByLibrary.simpleMessage("HostHub"),
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
    "changePasswordDescription": MessageLookupByLibrary.simpleMessage(
      "Set a temporary password.",
    ),
    "changePasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Change password",
    ),
    "changesWillBeLost": MessageLookupByLibrary.simpleMessage(
      "Changes will be lost",
    ),
    "channelFeeDefaultsDescription": MessageLookupByLibrary.simpleMessage(
      "Default commission percentages used when no override is set per property.",
    ),
    "channelFeeDefaultsHeader": MessageLookupByLibrary.simpleMessage(
      "Channel fee defaults (%)",
    ),
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
    "cmsContentDescription": MessageLookupByLibrary.simpleMessage(
      "View and manage all website content for this site.",
    ),
    "cmsContentTitle": MessageLookupByLibrary.simpleMessage("Website Content"),
    "cmsDiscardButton": MessageLookupByLibrary.simpleMessage("Discard"),
    "cmsHomePageSection": MessageLookupByLibrary.simpleMessage("Home Page"),
    "cmsLoadFailed": m0,
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
    "cmsRestoreConfirmBody": m1,
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
    "cmsVersionDate": m2,
    "cmsVersionHistory": MessageLookupByLibrary.simpleMessage(
      "Version History",
    ),
    "cmsVersionLabel": m3,
    "code": MessageLookupByLibrary.simpleMessage("Code"),
    "coffee": MessageLookupByLibrary.simpleMessage("Coffee"),
    "coin": MessageLookupByLibrary.simpleMessage("Coin"),
    "coins": MessageLookupByLibrary.simpleMessage("Coins"),
    "column": MessageLookupByLibrary.simpleMessage("Column"),
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
    "contentDocumentsLoadFailed": m4,
    "contentDocumentsPublished": m5,
    "contentDocumentsTitle": MessageLookupByLibrary.simpleMessage(
      "Content documents",
    ),
    "contentDocumentsUpdated": m6,
    "contentDocumentsVersionLabel": m7,
    "copied": MessageLookupByLibrary.simpleMessage("Copied"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "cost": MessageLookupByLibrary.simpleMessage("Cost"),
    "createUserButton": MessageLookupByLibrary.simpleMessage("Create user"),
    "createUserDescription": MessageLookupByLibrary.simpleMessage(
      "Create a password-based account for a new user.",
    ),
    "createUserFailed": m8,
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
    "daylight": MessageLookupByLibrary.simpleMessage("Daylight"),
    "deadline": MessageLookupByLibrary.simpleMessage("Deadline"),
    "decimalNumber": MessageLookupByLibrary.simpleMessage("Decimal Number"),
    "defaultLabel": MessageLookupByLibrary.simpleMessage("Default"),
    "defaultTabLabel": MessageLookupByLibrary.simpleMessage("Default tab"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteEvent": MessageLookupByLibrary.simpleMessage("Delete Event"),
    "deleteUserConfirmation": m9,
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
    "enterMinCharacters": m10,
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
    "fieldIsLinkedTo": m11,
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
    "fieldsTranslationLabel": m12,
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
    "indicator": MessageLookupByLibrary.simpleMessage("Indicator"),
    "ingredients": MessageLookupByLibrary.simpleMessage("Ingredients"),
    "insect": MessageLookupByLibrary.simpleMessage("Insect"),
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
    "letter": MessageLookupByLibrary.simpleMessage("Letter"),
    "letters": MessageLookupByLibrary.simpleMessage("Letters"),
    "library": MessageLookupByLibrary.simpleMessage("Library"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Light mode"),
    "like": MessageLookupByLibrary.simpleMessage("Like"),
    "lineHeight": MessageLookupByLibrary.simpleMessage("Line Height"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listRoleLabel": m13,
    "listSinceDate": m14,
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
    "listsEditTemplateTitle": m15,
    "listsEmptyState": MessageLookupByLibrary.simpleMessage(
      "No list templates available.",
    ),
    "listsFieldNameLabel": m16,
    "listsFieldNamesLabel": MessageLookupByLibrary.simpleMessage("Field names"),
    "listsFieldsLabel": MessageLookupByLibrary.simpleMessage("Fields"),
    "listsFieldsValue": m17,
    "listsGroupByLabel": MessageLookupByLibrary.simpleMessage("Group by"),
    "listsGroupByNone": MessageLookupByLibrary.simpleMessage("No grouping"),
    "listsItemHistoryLabel": MessageLookupByLibrary.simpleMessage(
      "Item history",
    ),
    "listsItemTapLabel": MessageLookupByLibrary.simpleMessage(
      "Item tap behavior",
    ),
    "listsJsonCopied": MessageLookupByLibrary.simpleMessage("JSON copied"),
    "listsJsonDefaultPathLabel": m18,
    "listsJsonDownloadLabel": MessageLookupByLibrary.simpleMessage(
      "Download JSON",
    ),
    "listsJsonSaveFailureToast": MessageLookupByLibrary.simpleMessage(
      "Unable to save JSON",
    ),
    "listsJsonSaveLabel": MessageLookupByLibrary.simpleMessage("Save JSON"),
    "listsJsonSavedToast": m19,
    "listsJsonTab": MessageLookupByLibrary.simpleMessage("JSON export"),
    "listsLabel": MessageLookupByLibrary.simpleMessage("List templates"),
    "listsLayoutTab": MessageLookupByLibrary.simpleMessage("Layout"),
    "listsLocaleLabel": m20,
    "listsLocaleListName": m21,
    "listsLocaleListNamePlural": m22,
    "listsNoFieldsForLocale": MessageLookupByLibrary.simpleMessage(
      "No fields for this locale.",
    ),
    "listsNoSelection": MessageLookupByLibrary.simpleMessage(
      "Select a template to review settings.",
    ),
    "listsOverviewSection": MessageLookupByLibrary.simpleMessage("Overview"),
    "listsSamplesLabel": MessageLookupByLibrary.simpleMessage("Sample items"),
    "listsSamplesSingle": m23,
    "listsSamplesSplit": m24,
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
    "loadUserFailed": m25,
    "loadUserFailedMessage": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load user.",
    ),
    "loadUsersFailed": m26,
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
    "lodgifyApiKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Enter an API key to connect.",
    ),
    "lodgifyApiKeySaveFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to save the Lodgify API key.",
    ),
    "lodgifyConnectErrorDescription": MessageLookupByLibrary.simpleMessage(
      "Check the API key and try again. Make sure the key has access to Lodgify.",
    ),
    "lodgifyConnectErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Lodgify connection failed",
    ),
    "lodgifyConnectFailed": MessageLookupByLibrary.simpleMessage(
      "Could not connect Lodgify.",
    ),
    "lodgifyConnectSuccess": MessageLookupByLibrary.simpleMessage(
      "Lodgify connected.",
    ),
    "lodgifyLastSyncLabel": m27,
    "lodgifyMissingPropertiesAddAction": MessageLookupByLibrary.simpleMessage(
      "Add to database",
    ),
    "lodgifyMissingPropertiesTitle": MessageLookupByLibrary.simpleMessage(
      "Lodgify properties found",
    ),
    "lodgifyNoNewPropertiesFound": MessageLookupByLibrary.simpleMessage(
      "No new Lodgify properties found.",
    ),
    "lodgifySyncCompleted": MessageLookupByLibrary.simpleMessage(
      "Lodgify sync completed.",
    ),
    "lodgifySyncFailed": MessageLookupByLibrary.simpleMessage(
      "Lodgify sync failed.",
    ),
    "lodgifySyncLabel": MessageLookupByLibrary.simpleMessage("Sync"),
    "lodgifyTitle": MessageLookupByLibrary.simpleMessage("Lodgify"),
    "login": MessageLookupByLibrary.simpleMessage("Log in"),
    "loginDescription": MessageLookupByLibrary.simpleMessage(
      "Sign in with your account.",
    ),
    "loginFailed": MessageLookupByLibrary.simpleMessage("Login failed"),
    "loginFailedCheckDetails": MessageLookupByLibrary.simpleMessage(
      "Login failed. Check your information.",
    ),
    "loginFailedWithReason": m28,
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Log in with Google",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "logoutLabel": MessageLookupByLibrary.simpleMessage("Sign out"),
    "longTime": MessageLookupByLibrary.simpleMessage("Long Time"),
    "love": MessageLookupByLibrary.simpleMessage("Love"),
    "loyaltyCard": MessageLookupByLibrary.simpleMessage("Loyalty Card"),
    "magicLinkSentDescription": m29,
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
    "passwordChangeFailedWithReason": m30,
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
    "position": MessageLookupByLibrary.simpleMessage("Position"),
    "preferPasswordSignIn": MessageLookupByLibrary.simpleMessage(
      "Prefer signing in with a password?",
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
    "pricingCurrencyNote": MessageLookupByLibrary.simpleMessage(
      "All amounts in",
    ),
    "pricingDescription": MessageLookupByLibrary.simpleMessage(
      "Per-property channel pricing settings.",
    ),
    "pricingLinenCost": MessageLookupByLibrary.simpleMessage("Linen costs"),
    "pricingOtherCost": MessageLookupByLibrary.simpleMessage("Other costs"),
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
    "profileLoadFailed": m31,
    "profileLoadingLabel": MessageLookupByLibrary.simpleMessage(
      "Loading profile...",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "propertyDetailsDescription": MessageLookupByLibrary.simpleMessage(
      "Read-only overview of the selected property.",
    ),
    "propertyDetailsEmpty": MessageLookupByLibrary.simpleMessage(
      "Select a property to see its details.",
    ),
    "propertyDetailsLabel": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
    "propertyDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Property details",
    ),
    "propertyLastSync": MessageLookupByLibrary.simpleMessage("Last sync"),
    "propertyLodgifyLinked": MessageLookupByLibrary.simpleMessage("Linked"),
    "propertyLodgifyNotLinked": MessageLookupByLibrary.simpleMessage(
      "Not linked",
    ),
    "propertyLodgifyStatus": MessageLookupByLibrary.simpleMessage(
      "Lodgify status",
    ),
    "propertyNameLodgifyHint": MessageLookupByLibrary.simpleMessage(
      "To change the property name, update it in Lodgify and sync.",
    ),
    "propertySetupConnectBody": MessageLookupByLibrary.simpleMessage(
      "Go to Settings to add your Lodgify API key and connect your account.",
    ),
    "propertySetupConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Connect Lodgify to import your properties.",
    ),
    "propertySetupConnectTitle": MessageLookupByLibrary.simpleMessage(
      "Connect Lodgify",
    ),
    "propertySetupGoToSettings": MessageLookupByLibrary.simpleMessage(
      "Go to Settings",
    ),
    "propertySetupManualBody": MessageLookupByLibrary.simpleMessage(
      "Add a property without Lodgify connection.",
    ),
    "propertySetupManualButton": MessageLookupByLibrary.simpleMessage(
      "Create property",
    ),
    "propertySetupManualNameLabel": MessageLookupByLibrary.simpleMessage(
      "Property name",
    ),
    "propertySetupManualNameRequired": MessageLookupByLibrary.simpleMessage(
      "Enter a property name.",
    ),
    "propertySetupManualTitle": MessageLookupByLibrary.simpleMessage(
      "Create manually",
    ),
    "propertySetupOrDivider": MessageLookupByLibrary.simpleMessage("or"),
    "propertySetupSyncBody": MessageLookupByLibrary.simpleMessage(
      "Lodgify is connected. Sync your properties from Lodgify to get started.",
    ),
    "propertySetupSyncDescription": MessageLookupByLibrary.simpleMessage(
      "Sync your properties from Lodgify.",
    ),
    "propertySetupSyncTitle": MessageLookupByLibrary.simpleMessage(
      "Sync properties",
    ),
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
    "repair": MessageLookupByLibrary.simpleMessage("Repair"),
    "repeat": MessageLookupByLibrary.simpleMessage("Repeat"),
    "requestNewPasswordEmail": MessageLookupByLibrary.simpleMessage(
      "Request new reset email",
    ),
    "requiredField": MessageLookupByLibrary.simpleMessage(
      "This is a required field",
    ),
    "resendAvailableIn": m32,
    "resendCode": MessageLookupByLibrary.simpleMessage("Resend code"),
    "reservationAdults": MessageLookupByLibrary.simpleMessage("Adults"),
    "reservationCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "reservationCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "reservationChildren": MessageLookupByLibrary.simpleMessage("Children"),
    "reservationCloseTooltip": MessageLookupByLibrary.simpleMessage("Close"),
    "reservationCreatedAt": MessageLookupByLibrary.simpleMessage("Created"),
    "reservationEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "reservationGross": MessageLookupByLibrary.simpleMessage("Gross"),
    "reservationGuestTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "reservationId": MessageLookupByLibrary.simpleMessage("Reservation ID"),
    "reservationInfants": MessageLookupByLibrary.simpleMessage("Infants"),
    "reservationName": MessageLookupByLibrary.simpleMessage("Name"),
    "reservationNet": MessageLookupByLibrary.simpleMessage("Net"),
    "reservationNights": MessageLookupByLibrary.simpleMessage("Nights"),
    "reservationNotes": MessageLookupByLibrary.simpleMessage("Notes"),
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
    "revenueColumnBooker": MessageLookupByLibrary.simpleMessage("Booker"),
    "revenueColumnChannelFee": MessageLookupByLibrary.simpleMessage(
      "Channel\nfee",
    ),
    "revenueColumnCheckIn": MessageLookupByLibrary.simpleMessage("Check-in"),
    "revenueColumnCheckOut": MessageLookupByLibrary.simpleMessage("Check-out"),
    "revenueColumnFixedCosts": MessageLookupByLibrary.simpleMessage(
      "Fixed\ncosts",
    ),
    "revenueColumnNet": MessageLookupByLibrary.simpleMessage("Net"),
    "revenueColumnNightlyRate": MessageLookupByLibrary.simpleMessage(
      "Nightly\nrate",
    ),
    "revenueColumnNights": MessageLookupByLibrary.simpleMessage("Nights"),
    "revenueColumnTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "revenueDescription": m33,
    "revenueFees": MessageLookupByLibrary.simpleMessage("Fees"),
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
    "revenueQuarterLabel": m34,
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
    "serverSettingsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Admin settings that apply to all users.",
    ),
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
    "showCalendarTabLabel": MessageLookupByLibrary.simpleMessage(
      "Show calendar tab",
    ),
    "showErrorDetails": MessageLookupByLibrary.simpleMessage("Show details"),
    "showStartTabLabel": MessageLookupByLibrary.simpleMessage("Show start tab"),
    "signInWithMagicLink": MessageLookupByLibrary.simpleMessage(
      "Sign in with magic link",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
    "signUpFailed": MessageLookupByLibrary.simpleMessage("Sign up failed"),
    "sitesCreateButton": MessageLookupByLibrary.simpleMessage("Create site"),
    "sitesDefaultLocaleHint": MessageLookupByLibrary.simpleMessage("en"),
    "sitesDefaultLocaleLabel": MessageLookupByLibrary.simpleMessage(
      "Default locale",
    ),
    "sitesDescription": MessageLookupByLibrary.simpleMessage(
      "Each website is scoped to a workspace with locales and domains.",
    ),
    "sitesEmpty": MessageLookupByLibrary.simpleMessage(
      "No sites configured yet.",
    ),
    "sitesLoadFailed": m35,
    "sitesLocaleSummary": m36,
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
    "subscriptionChipLabel": m37,
    "subscriptionLabel": MessageLookupByLibrary.simpleMessage("Subscription"),
    "subtract": MessageLookupByLibrary.simpleMessage("Subtract"),
    "suitcase": MessageLookupByLibrary.simpleMessage("Suitcase"),
    "sum": MessageLookupByLibrary.simpleMessage("Sum"),
    "sun": MessageLookupByLibrary.simpleMessage("Sun"),
    "sunlight": MessageLookupByLibrary.simpleMessage("Sunlight"),
    "supabaseTableMissing": m38,
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
    "teamInviteSiteDescription": m39,
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
    "teamRemoveMemberConfirm": m40,
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
    "toggleAdminFailed": m41,
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
    "updateProfileFailed": m42,
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "userCreated": MessageLookupByLibrary.simpleMessage("User created."),
    "userDeleteFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t delete user.",
    ),
    "userDeleteFailedWithReason": m43,
    "userDeleted": MessageLookupByLibrary.simpleMessage("User deleted."),
    "userIdLabel": MessageLookupByLibrary.simpleMessage("User ID"),
    "userSettingsAction": MessageLookupByLibrary.simpleMessage("User settings"),
    "userSettingsLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not load user settings.",
    ),
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
    "verificationCodeSentText": m44,
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "verticalLine": MessageLookupByLibrary.simpleMessage("Vertical Line"),
    "walking": MessageLookupByLibrary.simpleMessage("Walking"),
    "wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "waste": MessageLookupByLibrary.simpleMessage("Waste"),
    "watch": MessageLookupByLibrary.simpleMessage("Watch"),
    "wealth": MessageLookupByLibrary.simpleMessage("Wealth"),
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
