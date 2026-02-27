// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings saved.`
  String get settingsSaved {
    return Intl.message(
      'Settings saved.',
      name: 'settingsSaved',
      desc: '',
      args: [],
    );
  }

  /// `Admin options`
  String get serverSettingsTitle {
    return Intl.message(
      'Admin options',
      name: 'serverSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Admin settings that apply to all users.`
  String get serverSettingsSubtitle {
    return Intl.message(
      'Admin settings that apply to all users.',
      name: 'serverSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get adminSettingsTitle {
    return Intl.message(
      'Settings',
      name: 'adminSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Preferences for your console experience.`
  String get adminSettingsSubtitle {
    return Intl.message(
      'Preferences for your console experience.',
      name: 'adminSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get languagePreferenceTitle {
    return Intl.message(
      'Language',
      name: 'languagePreferenceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Change language`
  String get languagePreferenceDescription {
    return Intl.message(
      'Change language',
      name: 'languagePreferenceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Export language`
  String get exportLanguageTitle {
    return Intl.message(
      'Export language',
      name: 'exportLanguageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Language used for exports`
  String get exportLanguageDescription {
    return Intl.message(
      'Language used for exports',
      name: 'exportLanguageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Export settings`
  String get exportSettingsTitle {
    return Intl.message(
      'Export settings',
      name: 'exportSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Columns`
  String get exportColumnsTitle {
    return Intl.message(
      'Columns',
      name: 'exportColumnsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get exportButton {
    return Intl.message('Export', name: 'exportButton', desc: '', args: []);
  }

  /// `General`
  String get generalSectionTitle {
    return Intl.message(
      'General',
      name: 'generalSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveButton {
    return Intl.message('Save', name: 'saveButton', desc: '', args: []);
  }

  /// `Restore defaults`
  String get restoreDefaults {
    return Intl.message(
      'Restore defaults',
      name: 'restoreDefaults',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menuTooltip {
    return Intl.message('Menu', name: 'menuTooltip', desc: '', args: []);
  }

  /// `Navigation`
  String get navigationLabel {
    return Intl.message(
      'Navigation',
      name: 'navigationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileLabel {
    return Intl.message('Profile', name: 'profileLabel', desc: '', args: []);
  }

  /// `Users`
  String get usersLabel {
    return Intl.message('Users', name: 'usersLabel', desc: '', args: []);
  }

  /// `List templates`
  String get listsLabel {
    return Intl.message(
      'List templates',
      name: 'listsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsLabel {
    return Intl.message('Settings', name: 'settingsLabel', desc: '', args: []);
  }

  /// `Client apps`
  String get clientAppsLabel {
    return Intl.message(
      'Client apps',
      name: 'clientAppsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Client apps`
  String get clientAppsTitle {
    return Intl.message(
      'Client apps',
      name: 'clientAppsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Manage which list templates each client app can use.`
  String get clientAppsSubtitle {
    return Intl.message(
      'Manage which list templates each client app can use.',
      name: 'clientAppsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No client apps configured.`
  String get clientAppsNoAppsFound {
    return Intl.message(
      'No client apps configured.',
      name: 'clientAppsNoAppsFound',
      desc: '',
      args: [],
    );
  }

  /// `Select a client app to configure.`
  String get clientAppsNoSelection {
    return Intl.message(
      'Select a client app to configure.',
      name: 'clientAppsNoSelection',
      desc: '',
      args: [],
    );
  }

  /// `Display name`
  String get clientAppsNameLabel {
    return Intl.message(
      'Display name',
      name: 'clientAppsNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Client app ID`
  String get clientAppsIdLabel {
    return Intl.message(
      'Client app ID',
      name: 'clientAppsIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get clientAppsActiveLabel {
    return Intl.message(
      'Active',
      name: 'clientAppsActiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Allowed templates`
  String get clientAppsAllowedTemplatesLabel {
    return Intl.message(
      'Allowed templates',
      name: 'clientAppsAllowedTemplatesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Choose the templates that this app can create.`
  String get clientAppsAllowedTemplatesDescription {
    return Intl.message(
      'Choose the templates that this app can create.',
      name: 'clientAppsAllowedTemplatesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Default templates`
  String get clientAppsDefaultTemplatesLabel {
    return Intl.message(
      'Default templates',
      name: 'clientAppsDefaultTemplatesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Templates that are created during registration and suggested when a new list is created.`
  String get clientAppsDefaultTemplatesDescription {
    return Intl.message(
      'Templates that are created during registration and suggested when a new list is created.',
      name: 'clientAppsDefaultTemplatesDescription',
      desc: '',
      args: [],
    );
  }

  /// `No default templates configured yet.`
  String get clientAppsDefaultTemplatesEmpty {
    return Intl.message(
      'No default templates configured yet.',
      name: 'clientAppsDefaultTemplatesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Pick a template`
  String get clientAppsSelectDefaultLabel {
    return Intl.message(
      'Pick a template',
      name: 'clientAppsSelectDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get clientAppsAddDefaultButton {
    return Intl.message(
      'Add',
      name: 'clientAppsAddDefaultButton',
      desc: '',
      args: [],
    );
  }

  /// `Template catalog unavailable.`
  String get clientAppsTemplatesUnavailable {
    return Intl.message(
      'Template catalog unavailable.',
      name: 'clientAppsTemplatesUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Remove default template`
  String get clientAppsRemoveDefaultTooltip {
    return Intl.message(
      'Remove default template',
      name: 'clientAppsRemoveDefaultTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Move default template up`
  String get clientAppsMoveDefaultUpTooltip {
    return Intl.message(
      'Move default template up',
      name: 'clientAppsMoveDefaultUpTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Move default template down`
  String get clientAppsMoveDefaultDownTooltip {
    return Intl.message(
      'Move default template down',
      name: 'clientAppsMoveDefaultDownTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one allowed template to choose defaults.`
  String get clientAppsDefaultTemplatesRequiresAllowed {
    return Intl.message(
      'Select at least one allowed template to choose defaults.',
      name: 'clientAppsDefaultTemplatesRequiresAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get logoutLabel {
    return Intl.message('Sign out', name: 'logoutLabel', desc: '', args: []);
  }

  /// `Details`
  String get detailsLabel {
    return Intl.message('Details', name: 'detailsLabel', desc: '', args: []);
  }

  /// `Property details`
  String get propertyDetailsLabel {
    return Intl.message(
      'Property details',
      name: 'propertyDetailsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Property details`
  String get propertyDetailsTitle {
    return Intl.message(
      'Property details',
      name: 'propertyDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Read-only overview of the selected property.`
  String get propertyDetailsDescription {
    return Intl.message(
      'Read-only overview of the selected property.',
      name: 'propertyDetailsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Select a property to see its details.`
  String get propertyDetailsEmpty {
    return Intl.message(
      'Select a property to see its details.',
      name: 'propertyDetailsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Connections`
  String get connectionsSectionTitle {
    return Intl.message(
      'Connections',
      name: 'connectionsSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect external platforms to this property.`
  String get connectionsSectionSubtitle {
    return Intl.message(
      'Connect external platforms to this property.',
      name: 'connectionsSectionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Lodgify`
  String get lodgifyTitle {
    return Intl.message('Lodgify', name: 'lodgifyTitle', desc: '', args: []);
  }

  /// `API key`
  String get lodgifyApiKeyLabel {
    return Intl.message(
      'API key',
      name: 'lodgifyApiKeyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Use the API key from Lodgify to connect.`
  String get lodgifyApiKeyDescription {
    return Intl.message(
      'Use the API key from Lodgify to connect.',
      name: 'lodgifyApiKeyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get connectLabel {
    return Intl.message('Connect', name: 'connectLabel', desc: '', args: []);
  }

  /// `Connected`
  String get connectionStatusConnected {
    return Intl.message(
      'Connected',
      name: 'connectionStatusConnected',
      desc: '',
      args: [],
    );
  }

  /// `Not connected`
  String get connectionStatusDisconnected {
    return Intl.message(
      'Not connected',
      name: 'connectionStatusDisconnected',
      desc: '',
      args: [],
    );
  }

  /// `Enter an API key to connect.`
  String get lodgifyApiKeyRequired {
    return Intl.message(
      'Enter an API key to connect.',
      name: 'lodgifyApiKeyRequired',
      desc: '',
      args: [],
    );
  }

  /// `Lodgify connected.`
  String get lodgifyConnectSuccess {
    return Intl.message(
      'Lodgify connected.',
      name: 'lodgifyConnectSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Could not connect Lodgify.`
  String get lodgifyConnectFailed {
    return Intl.message(
      'Could not connect Lodgify.',
      name: 'lodgifyConnectFailed',
      desc: '',
      args: [],
    );
  }

  /// `Lodgify connection failed`
  String get lodgifyConnectErrorTitle {
    return Intl.message(
      'Lodgify connection failed',
      name: 'lodgifyConnectErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Check the API key and try again. Make sure the key has access to Lodgify.`
  String get lodgifyConnectErrorDescription {
    return Intl.message(
      'Check the API key and try again. Make sure the key has access to Lodgify.',
      name: 'lodgifyConnectErrorDescription',
      desc: '',
      args: [],
    );
  }

  /// `Unable to save the Lodgify API key.`
  String get lodgifyApiKeySaveFailed {
    return Intl.message(
      'Unable to save the Lodgify API key.',
      name: 'lodgifyApiKeySaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Sync`
  String get lodgifySyncLabel {
    return Intl.message('Sync', name: 'lodgifySyncLabel', desc: '', args: []);
  }

  /// `Lodgify sync completed.`
  String get lodgifySyncCompleted {
    return Intl.message(
      'Lodgify sync completed.',
      name: 'lodgifySyncCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Lodgify sync failed.`
  String get lodgifySyncFailed {
    return Intl.message(
      'Lodgify sync failed.',
      name: 'lodgifySyncFailed',
      desc: '',
      args: [],
    );
  }

  /// `No new Lodgify properties found.`
  String get lodgifyNoNewPropertiesFound {
    return Intl.message(
      'No new Lodgify properties found.',
      name: 'lodgifyNoNewPropertiesFound',
      desc: '',
      args: [],
    );
  }

  /// `Last sync: {time}`
  String lodgifyLastSyncLabel(Object time) {
    return Intl.message(
      'Last sync: $time',
      name: 'lodgifyLastSyncLabel',
      desc: '',
      args: [time],
    );
  }

  /// `Lodgify properties found`
  String get lodgifyMissingPropertiesTitle {
    return Intl.message(
      'Lodgify properties found',
      name: 'lodgifyMissingPropertiesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add to database`
  String get lodgifyMissingPropertiesAddAction {
    return Intl.message(
      'Add to database',
      name: 'lodgifyMissingPropertiesAddAction',
      desc: '',
      args: [],
    );
  }

  /// `Could not load user settings.`
  String get userSettingsLoadFailed {
    return Intl.message(
      'Could not load user settings.',
      name: 'userSettingsLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Loading profile...`
  String get profileLoadingLabel {
    return Intl.message(
      'Loading profile...',
      name: 'profileLoadingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance mode`
  String get maintenanceModeTitle {
    return Intl.message(
      'Maintenance mode',
      name: 'maintenanceModeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Shows a maintenance message in every app.`
  String get maintenanceModeDescription {
    return Intl.message(
      'Shows a maintenance message in every app.',
      name: 'maintenanceModeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Email new users`
  String get emailUserOnCreateTitle {
    return Intl.message(
      'Email new users',
      name: 'emailUserOnCreateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Automatically send a welcome email after registration.`
  String get emailUserOnCreateDescription {
    return Intl.message(
      'Automatically send a welcome email after registration.',
      name: 'emailUserOnCreateDescription',
      desc: '',
      args: [],
    );
  }

  /// `Max lists per user`
  String get maxListsTitle {
    return Intl.message(
      'Max lists per user',
      name: 'maxListsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Limits how many lists a user can create.`
  String get maxListsDescription {
    return Intl.message(
      'Limits how many lists a user can create.',
      name: 'maxListsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Max items per list`
  String get maxItemsTitle {
    return Intl.message(
      'Max items per list',
      name: 'maxItemsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Prevents extremely large lists.`
  String get maxItemsDescription {
    return Intl.message(
      'Prevents extremely large lists.',
      name: 'maxItemsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid number of lists.`
  String get invalidMaxLists {
    return Intl.message(
      'Enter a valid number of lists.',
      name: 'invalidMaxLists',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid number of items.`
  String get invalidMaxItems {
    return Intl.message(
      'Enter a valid number of items.',
      name: 'invalidMaxItems',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with your account.`
  String get loginDescription {
    return Intl.message(
      'Sign in with your account.',
      name: 'loginDescription',
      desc: '',
      args: [],
    );
  }

  /// `Login failed. Check your information.`
  String get loginFailedCheckDetails {
    return Intl.message(
      'Login failed. Check your information.',
      name: 'loginFailedCheckDetails',
      desc: '',
      args: [],
    );
  }

  /// `Login failed: {error}`
  String loginFailedWithReason(String error) {
    return Intl.message(
      'Login failed: $error',
      name: 'loginFailedWithReason',
      desc: '',
      args: [error],
    );
  }

  /// `This user does not have admin access.`
  String get notAdminError {
    return Intl.message(
      'This user does not have admin access.',
      name: 'notAdminError',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load profile: {error}`
  String profileLoadFailed(String error) {
    return Intl.message(
      'Couldn\'t load profile: $error',
      name: 'profileLoadFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Users`
  String get usersTitle {
    return Intl.message('Users', name: 'usersTitle', desc: '', args: []);
  }

  /// `Search, review, and manage access to the console.`
  String get usersSubtitle {
    return Intl.message(
      'Search, review, and manage access to the console.',
      name: 'usersSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Create user`
  String get createUserButton {
    return Intl.message(
      'Create user',
      name: 'createUserButton',
      desc: '',
      args: [],
    );
  }

  /// `Create user`
  String get createUserTitle {
    return Intl.message(
      'Create user',
      name: 'createUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create a password-based account for a new user.`
  String get createUserDescription {
    return Intl.message(
      'Create a password-based account for a new user.',
      name: 'createUserDescription',
      desc: '',
      args: [],
    );
  }

  /// `User created.`
  String get userCreated {
    return Intl.message(
      'User created.',
      name: 'userCreated',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't create user: {error}`
  String createUserFailed(String error) {
    return Intl.message(
      'Couldn\'t create user: $error',
      name: 'createUserFailed',
      desc: 'Shown when creating a user fails.',
      args: [error],
    );
  }

  /// `List templates`
  String get listsTitle {
    return Intl.message(
      'List templates',
      name: 'listsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Browse every list template, including availability, dev flags, and seeded sample data.`
  String get listsSubtitle {
    return Intl.message(
      'Browse every list template, including availability, dev flags, and seeded sample data.',
      name: 'listsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Template deleted`
  String get listsTemplateDeletedToast {
    return Intl.message(
      'Template deleted',
      name: 'listsTemplateDeletedToast',
      desc: 'Toast message shown after a list template is deleted.',
      args: [],
    );
  }

  /// `No list templates available.`
  String get listsEmptyState {
    return Intl.message(
      'No list templates available.',
      name: 'listsEmptyState',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get listsStatusActive {
    return Intl.message(
      'Active',
      name: 'listsStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `Hidden`
  String get listsStatusHidden {
    return Intl.message(
      'Hidden',
      name: 'listsStatusHidden',
      desc: '',
      args: [],
    );
  }

  /// `Beta`
  String get listsStatusBeta {
    return Intl.message('Beta', name: 'listsStatusBeta', desc: '', args: []);
  }

  /// `Dev only`
  String get listsStatusDev {
    return Intl.message('Dev only', name: 'listsStatusDev', desc: '', args: []);
  }

  /// `Demo data`
  String get listsStatusDemo {
    return Intl.message(
      'Demo data',
      name: 'listsStatusDemo',
      desc: '',
      args: [],
    );
  }

  /// `Style`
  String get listsStyleLabel {
    return Intl.message('Style', name: 'listsStyleLabel', desc: '', args: []);
  }

  /// `Layout`
  String get listsLayoutTab {
    return Intl.message('Layout', name: 'listsLayoutTab', desc: '', args: []);
  }

  /// `Default view`
  String get listsViewLabel {
    return Intl.message(
      'Default view',
      name: 'listsViewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sample items`
  String get listsSamplesLabel {
    return Intl.message(
      'Sample items',
      name: 'listsSamplesLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count} sample {count, plural, one {item} other {items}}`
  String listsSamplesSingle(int count) {
    return Intl.message(
      '$count sample ${Intl.plural(count, one: 'item', other: 'items')}',
      name: 'listsSamplesSingle',
      desc: '',
      args: [count],
    );
  }

  /// `{prod} prod / {dev} dev`
  String listsSamplesSplit(int prod, int dev) {
    return Intl.message(
      '$prod prod / $dev dev',
      name: 'listsSamplesSplit',
      desc: '',
      args: [prod, dev],
    );
  }

  /// `Fields`
  String get listsFieldsLabel {
    return Intl.message('Fields', name: 'listsFieldsLabel', desc: '', args: []);
  }

  /// `{count} {count, plural, one {field} other {fields}}`
  String listsFieldsValue(int count) {
    return Intl.message(
      '$count ${Intl.plural(count, one: 'field', other: 'fields')}',
      name: 'listsFieldsValue',
      desc: '',
      args: [count],
    );
  }

  /// `Add item methods`
  String get listsAddItemMethodsLabel {
    return Intl.message(
      'Add item methods',
      name: 'listsAddItemMethodsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Item tap behavior`
  String get listsItemTapLabel {
    return Intl.message(
      'Item tap behavior',
      name: 'listsItemTapLabel',
      desc: '',
      args: [],
    );
  }

  /// `Item history`
  String get listsItemHistoryLabel {
    return Intl.message(
      'Item history',
      name: 'listsItemHistoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Center fields in list view`
  String get listsCenterFieldsLabel {
    return Intl.message(
      'Center fields in list view',
      name: 'listsCenterFieldsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Group by`
  String get listsGroupByLabel {
    return Intl.message(
      'Group by',
      name: 'listsGroupByLabel',
      desc: '',
      args: [],
    );
  }

  /// `No grouping`
  String get listsGroupByNone {
    return Intl.message(
      'No grouping',
      name: 'listsGroupByNone',
      desc: '',
      args: [],
    );
  }

  /// `Color scheme`
  String get listsSchemeLabel {
    return Intl.message(
      'Color scheme',
      name: 'listsSchemeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Field names`
  String get listsFieldNamesLabel {
    return Intl.message(
      'Field names',
      name: 'listsFieldNamesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Templates`
  String get listsTemplatesLabel {
    return Intl.message(
      'Templates',
      name: 'listsTemplatesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Template settings`
  String get listsDetailsTitle {
    return Intl.message(
      'Template settings',
      name: 'listsDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select a template to review settings.`
  String get listsNoSelection {
    return Intl.message(
      'Select a template to review settings.',
      name: 'listsNoSelection',
      desc: '',
      args: [],
    );
  }

  /// `List`
  String get listsColumnName {
    return Intl.message('List', name: 'listsColumnName', desc: '', args: []);
  }

  /// `Status`
  String get listsColumnStatus {
    return Intl.message(
      'Status',
      name: 'listsColumnStatus',
      desc: '',
      args: [],
    );
  }

  /// `Key`
  String get listsColumnKey {
    return Intl.message('Key', name: 'listsColumnKey', desc: '', args: []);
  }

  /// `Fields`
  String get listsColumnFields {
    return Intl.message(
      'Fields',
      name: 'listsColumnFields',
      desc: '',
      args: [],
    );
  }

  /// `Sample items`
  String get listsColumnSamples {
    return Intl.message(
      'Sample items',
      name: 'listsColumnSamples',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get listsOverviewSection {
    return Intl.message(
      'Overview',
      name: 'listsOverviewSection',
      desc: '',
      args: [],
    );
  }

  /// `Behavior`
  String get listsBehaviorSection {
    return Intl.message(
      'Behavior',
      name: 'listsBehaviorSection',
      desc: '',
      args: [],
    );
  }

  /// `Data`
  String get listsDataSection {
    return Intl.message('Data', name: 'listsDataSection', desc: '', args: []);
  }

  /// `This template could not be found.`
  String get listsUnknownTemplate {
    return Intl.message(
      'This template could not be found.',
      name: 'listsUnknownTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Translations`
  String get listsTranslationsTab {
    return Intl.message(
      'Translations',
      name: 'listsTranslationsTab',
      desc: '',
      args: [],
    );
  }

  /// `Manage the list name and field names for every supported locale.`
  String get listsTranslationsDescription {
    return Intl.message(
      'Manage the list name and field names for every supported locale.',
      name: 'listsTranslationsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Analyzer`
  String get listsAnalyzerTab {
    return Intl.message(
      'Analyzer',
      name: 'listsAnalyzerTab',
      desc: '',
      args: [],
    );
  }

  /// `Combined analyzer of all list fields.`
  String get listsAnalyzerDescription {
    return Intl.message(
      'Combined analyzer of all list fields.',
      name: 'listsAnalyzerDescription',
      desc: '',
      args: [],
    );
  }

  /// `Template`
  String get listsTemplateJsonTab {
    return Intl.message(
      'Template',
      name: 'listsTemplateJsonTab',
      desc: '',
      args: [],
    );
  }

  /// `View the cleaned list template JSON that you can reuse for list seeds.`
  String get listsTemplateJsonDescription {
    return Intl.message(
      'View the cleaned list template JSON that you can reuse for list seeds.',
      name: 'listsTemplateJsonDescription',
      desc: '',
      args: [],
    );
  }

  /// `JSON export`
  String get listsJsonTab {
    return Intl.message(
      'JSON export',
      name: 'listsJsonTab',
      desc: '',
      args: [],
    );
  }

  /// `JSON copied`
  String get listsJsonCopied {
    return Intl.message(
      'JSON copied',
      name: 'listsJsonCopied',
      desc: '',
      args: [],
    );
  }

  /// `Download JSON`
  String get listsJsonDownloadLabel {
    return Intl.message(
      'Download JSON',
      name: 'listsJsonDownloadLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save JSON`
  String get listsJsonSaveLabel {
    return Intl.message(
      'Save JSON',
      name: 'listsJsonSaveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Default seed directory: {path}`
  String listsJsonDefaultPathLabel(Object path) {
    return Intl.message(
      'Default seed directory: $path',
      name: 'listsJsonDefaultPathLabel',
      desc: 'Label showing where exported JSON files land by default.',
      args: [path],
    );
  }

  /// `JSON saved to {path}`
  String listsJsonSavedToast(Object path) {
    return Intl.message(
      'JSON saved to $path',
      name: 'listsJsonSavedToast',
      desc: 'Toast shown after a JSON file was saved locally.',
      args: [path],
    );
  }

  /// `Unable to save JSON`
  String get listsJsonSaveFailureToast {
    return Intl.message(
      'Unable to save JSON',
      name: 'listsJsonSaveFailureToast',
      desc: '',
      args: [],
    );
  }

  /// `Analyzer copied`
  String get listsAnalyzerCopied {
    return Intl.message(
      'Analyzer copied',
      name: 'listsAnalyzerCopied',
      desc: '',
      args: [],
    );
  }

  /// `Include internal fields`
  String get listsAnalyzerIncludeInternalFieldsLabel {
    return Intl.message(
      'Include internal fields',
      name: 'listsAnalyzerIncludeInternalFieldsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Use relative tile demo dates`
  String get listsTileDemoRelativeDatesLabel {
    return Intl.message(
      'Use relative tile demo dates',
      name: 'listsTileDemoRelativeDatesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Evaluate internal timestamps relative to the current time when previewing the tile example.`
  String get listsTileDemoRelativeDatesDescription {
    return Intl.message(
      'Evaluate internal timestamps relative to the current time when previewing the tile example.',
      name: 'listsTileDemoRelativeDatesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Item demos`
  String get listsDemoItemsTab {
    return Intl.message(
      'Item demos',
      name: 'listsDemoItemsTab',
      desc: '',
      args: [],
    );
  }

  /// `Configure the demo items that appear in previews and new lists.`
  String get listsDemoItemsDescription {
    return Intl.message(
      'Configure the demo items that appear in previews and new lists.',
      name: 'listsDemoItemsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add demo item`
  String get listsDemoItemsAddButton {
    return Intl.message(
      'Add demo item',
      name: 'listsDemoItemsAddButton',
      desc: '',
      args: [],
    );
  }

  /// `Preview item`
  String get listsDemoItemsPreviewLabel {
    return Intl.message(
      'Preview item',
      name: 'listsDemoItemsPreviewLabel',
      desc: '',
      args: [],
    );
  }

  /// `New list item`
  String get listsDemoItemsNewListLabel {
    return Intl.message(
      'New list item',
      name: 'listsDemoItemsNewListLabel',
      desc: '',
      args: [],
    );
  }

  /// `Dev only`
  String get listsDemoItemsDevLabel {
    return Intl.message(
      'Dev only',
      name: 'listsDemoItemsDevLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tile example`
  String get listsDemoItemsTileLabel {
    return Intl.message(
      'Tile example',
      name: 'listsDemoItemsTileLabel',
      desc: '',
      args: [],
    );
  }

  /// `Demo contexts`
  String get listsDemoItemsFlagsTitle {
    return Intl.message(
      'Demo contexts',
      name: 'listsDemoItemsFlagsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No contexts selected`
  String get listsDemoItemsFlagsSummaryNone {
    return Intl.message(
      'No contexts selected',
      name: 'listsDemoItemsFlagsSummaryNone',
      desc: '',
      args: [],
    );
  }

  /// `Order`
  String get listsDemoItemsOrderLabel {
    return Intl.message(
      'Order',
      name: 'listsDemoItemsOrderLabel',
      desc: '',
      args: [],
    );
  }

  /// `Shows the demo item payloads that power the preview list.`
  String get listsDemoItemsJsonDescription {
    return Intl.message(
      'Shows the demo item payloads that power the preview list.',
      name: 'listsDemoItemsJsonDescription',
      desc: '',
      args: [],
    );
  }

  /// `No demo items yet.`
  String get listsDemoItemsNoItems {
    return Intl.message(
      'No demo items yet.',
      name: 'listsDemoItemsNoItems',
      desc: '',
      args: [],
    );
  }

  /// `Save item`
  String get listsDemoItemsSaveButton {
    return Intl.message(
      'Save item',
      name: 'listsDemoItemsSaveButton',
      desc: '',
      args: [],
    );
  }

  /// `Delete item`
  String get listsDemoItemsDeleteButton {
    return Intl.message(
      'Delete item',
      name: 'listsDemoItemsDeleteButton',
      desc: '',
      args: [],
    );
  }

  /// `Move up`
  String get listsDemoItemsMoveUpTooltip {
    return Intl.message(
      'Move up',
      name: 'listsDemoItemsMoveUpTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Move down`
  String get listsDemoItemsMoveDownTooltip {
    return Intl.message(
      'Move down',
      name: 'listsDemoItemsMoveDownTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Demo item saved`
  String get listsDemoItemsSavedToast {
    return Intl.message(
      'Demo item saved',
      name: 'listsDemoItemsSavedToast',
      desc: '',
      args: [],
    );
  }

  /// `Demo item deleted`
  String get listsDemoItemsDeletedToast {
    return Intl.message(
      'Demo item deleted',
      name: 'listsDemoItemsDeletedToast',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load demo items`
  String get listsDemoItemsLoadFailureToast {
    return Intl.message(
      'Unable to load demo items',
      name: 'listsDemoItemsLoadFailureToast',
      desc: '',
      args: [],
    );
  }

  /// `Unable to save demo item`
  String get listsDemoItemsSaveFailureToast {
    return Intl.message(
      'Unable to save demo item',
      name: 'listsDemoItemsSaveFailureToast',
      desc: '',
      args: [],
    );
  }

  /// `Unable to delete demo item`
  String get listsDemoItemsDeleteFailureToast {
    return Intl.message(
      'Unable to delete demo item',
      name: 'listsDemoItemsDeleteFailureToast',
      desc: '',
      args: [],
    );
  }

  /// `Unable to create demo item`
  String get listsDemoItemsCreateFailureToast {
    return Intl.message(
      'Unable to create demo item',
      name: 'listsDemoItemsCreateFailureToast',
      desc: '',
      args: [],
    );
  }

  /// `Unable to reorder demo items`
  String get listsDemoItemsMoveFailureToast {
    return Intl.message(
      'Unable to reorder demo items',
      name: 'listsDemoItemsMoveFailureToast',
      desc: '',
      args: [],
    );
  }

  /// `Invalid JSON payload`
  String get listsDemoItemsInvalidJsonError {
    return Intl.message(
      'Invalid JSON payload',
      name: 'listsDemoItemsInvalidJsonError',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this demo item?`
  String get listsDemoItemsDeleteConfirmation {
    return Intl.message(
      'Are you sure you want to delete this demo item?',
      name: 'listsDemoItemsDeleteConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Locale {code}`
  String listsLocaleLabel(Object code) {
    return Intl.message(
      'Locale $code',
      name: 'listsLocaleLabel',
      desc: '',
      args: [code],
    );
  }

  /// `List name ({code})`
  String listsLocaleListName(Object code) {
    return Intl.message(
      'List name ($code)',
      name: 'listsLocaleListName',
      desc: '',
      args: [code],
    );
  }

  /// `Plural name ({code})`
  String listsLocaleListNamePlural(Object code) {
    return Intl.message(
      'Plural name ($code)',
      name: 'listsLocaleListNamePlural',
      desc: '',
      args: [code],
    );
  }

  /// `No fields for this locale.`
  String get listsNoFieldsForLocale {
    return Intl.message(
      'No fields for this locale.',
      name: 'listsNoFieldsForLocale',
      desc: '',
      args: [],
    );
  }

  /// `Field name ({code})`
  String listsFieldNameLabel(Object code) {
    return Intl.message(
      'Field name ($code)',
      name: 'listsFieldNameLabel',
      desc: '',
      args: [code],
    );
  }

  /// `Edit template details {name}`
  String listsEditTemplateTitle(Object name) {
    return Intl.message(
      'Edit template details $name',
      name: 'listsEditTemplateTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Field defaults`
  String get fieldsLabel {
    return Intl.message(
      'Field defaults',
      name: 'fieldsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Field defaults`
  String get fieldsTitle {
    return Intl.message(
      'Field defaults',
      name: 'fieldsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Configure the default values for every field type and subtype. When a new list is created it starts with these defaults, which can still be customized afterwards. Changes saved here update the defaults used for future lists; existing lists keep their current configuration.`
  String get fieldsSubtitle {
    return Intl.message(
      'Configure the default values for every field type and subtype. When a new list is created it starts with these defaults, which can still be customized afterwards. Changes saved here update the defaults used for future lists; existing lists keep their current configuration.',
      name: 'fieldsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No field definitions available.`
  String get fieldsEmptyState {
    return Intl.message(
      'No field definitions available.',
      name: 'fieldsEmptyState',
      desc: '',
      args: [],
    );
  }

  /// `Default values`
  String get fieldsDefaultsTab {
    return Intl.message(
      'Default values',
      name: 'fieldsDefaultsTab',
      desc: '',
      args: [],
    );
  }

  /// `Translations`
  String get fieldsTranslationsTab {
    return Intl.message(
      'Translations',
      name: 'fieldsTranslationsTab',
      desc: '',
      args: [],
    );
  }

  /// `Set the display name for this field subtype for each supported locale.`
  String get fieldsTranslationsDescription {
    return Intl.message(
      'Set the display name for this field subtype for each supported locale.',
      name: 'fieldsTranslationsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Display name ({locale})`
  String fieldsTranslationLabel(Object locale) {
    return Intl.message(
      'Display name ($locale)',
      name: 'fieldsTranslationLabel',
      desc: '',
      args: [locale],
    );
  }

  /// `Field types`
  String get fieldsTypesSection {
    return Intl.message(
      'Field types',
      name: 'fieldsTypesSection',
      desc: '',
      args: [],
    );
  }

  /// `Field subtypes`
  String get fieldsSubtypesSection {
    return Intl.message(
      'Field subtypes',
      name: 'fieldsSubtypesSection',
      desc: '',
      args: [],
    );
  }

  /// `Field type`
  String get fieldsColumnFieldType {
    return Intl.message(
      'Field type',
      name: 'fieldsColumnFieldType',
      desc: '',
      args: [],
    );
  }

  /// `Field subtype`
  String get fieldsColumnSubtype {
    return Intl.message(
      'Field subtype',
      name: 'fieldsColumnSubtype',
      desc: '',
      args: [],
    );
  }

  /// `Display name`
  String get fieldsColumnName {
    return Intl.message(
      'Display name',
      name: 'fieldsColumnName',
      desc: '',
      args: [],
    );
  }

  /// `Properties`
  String get fieldsColumnProperties {
    return Intl.message(
      'Properties',
      name: 'fieldsColumnProperties',
      desc: '',
      args: [],
    );
  }

  /// `Actions`
  String get fieldsActionsLabel {
    return Intl.message(
      'Actions',
      name: 'fieldsActionsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Edit properties`
  String get fieldsPropertiesDialogTitle {
    return Intl.message(
      'Edit properties',
      name: 'fieldsPropertiesDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use the tabs to update the properties via the form or with JSON. Changes are applied instantly after saving.`
  String get fieldsPropertiesDialogHelper {
    return Intl.message(
      'Use the tabs to update the properties via the form or with JSON. Changes are applied instantly after saving.',
      name: 'fieldsPropertiesDialogHelper',
      desc: '',
      args: [],
    );
  }

  /// `Form`
  String get fieldsPropertiesTabForm {
    return Intl.message(
      'Form',
      name: 'fieldsPropertiesTabForm',
      desc: '',
      args: [],
    );
  }

  /// `JSON`
  String get fieldsPropertiesTabJson {
    return Intl.message(
      'JSON',
      name: 'fieldsPropertiesTabJson',
      desc: '',
      args: [],
    );
  }

  /// `A visual editor is not available for this field type yet. Use the JSON tab instead.`
  String get fieldsPropertiesFormUnavailable {
    return Intl.message(
      'A visual editor is not available for this field type yet. Use the JSON tab instead.',
      name: 'fieldsPropertiesFormUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `All properties`
  String get fieldsAllPropertiesSection {
    return Intl.message(
      'All properties',
      name: 'fieldsAllPropertiesSection',
      desc: '',
      args: [],
    );
  }

  /// `Changes save immediately. Use JSON syntax for complex values or switch to the JSON tab for advanced edits.`
  String get fieldsAllPropertiesHelper {
    return Intl.message(
      'Changes save immediately. Use JSON syntax for complex values or switch to the JSON tab for advanced edits.',
      name: 'fieldsAllPropertiesHelper',
      desc: '',
      args: [],
    );
  }

  /// `No editable properties are available for this field type.`
  String get fieldsNoProperties {
    return Intl.message(
      'No editable properties are available for this field type.',
      name: 'fieldsNoProperties',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid JSON value.`
  String get fieldsInvalidJsonValue {
    return Intl.message(
      'Enter a valid JSON value.',
      name: 'fieldsInvalidJsonValue',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid number.`
  String get fieldsInvalidNumber {
    return Intl.message(
      'Enter a valid number.',
      name: 'fieldsInvalidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter valid JSON (object only).`
  String get fieldsInvalidJson {
    return Intl.message(
      'Enter valid JSON (object only).',
      name: 'fieldsInvalidJson',
      desc: '',
      args: [],
    );
  }

  /// `Properties updated.`
  String get fieldsPropertiesSaved {
    return Intl.message(
      'Properties updated.',
      name: 'fieldsPropertiesSaved',
      desc: '',
      args: [],
    );
  }

  /// `Validate and apply`
  String get fieldsValidateAndApply {
    return Intl.message(
      'Validate and apply',
      name: 'fieldsValidateAndApply',
      desc: '',
      args: [],
    );
  }

  /// `JSON changes pending`
  String get fieldsUnsavedJsonWarningTitle {
    return Intl.message(
      'JSON changes pending',
      name: 'fieldsUnsavedJsonWarningTitle',
      desc: '',
      args: [],
    );
  }

  /// `You haven’t validated or applied your JSON edits yet. Switch back to the JSON tab to do so, or continue to the editor and discard them.`
  String get fieldsUnsavedJsonWarningMessage {
    return Intl.message(
      'You haven’t validated or applied your JSON edits yet. Switch back to the JSON tab to do so, or continue to the editor and discard them.',
      name: 'fieldsUnsavedJsonWarningMessage',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get fieldsApply {
    return Intl.message('Apply', name: 'fieldsApply', desc: '', args: []);
  }

  /// `Edit localized names`
  String get fieldsNamesDialogTitle {
    return Intl.message(
      'Edit localized names',
      name: 'fieldsNamesDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Update the localized names below. Leave a field empty to fall back to the default.`
  String get fieldsNamesDialogHelper {
    return Intl.message(
      'Update the localized names below. Leave a field empty to fall back to the default.',
      name: 'fieldsNamesDialogHelper',
      desc: '',
      args: [],
    );
  }

  /// `Names updated.`
  String get fieldsNamesSaved {
    return Intl.message(
      'Names updated.',
      name: 'fieldsNamesSaved',
      desc: '',
      args: [],
    );
  }

  /// `Edit names`
  String get fieldsEditNames {
    return Intl.message(
      'Edit names',
      name: 'fieldsEditNames',
      desc: '',
      args: [],
    );
  }

  /// `Edit properties`
  String get fieldsEditProperties {
    return Intl.message(
      'Edit properties',
      name: 'fieldsEditProperties',
      desc: '',
      args: [],
    );
  }

  /// `Use field type defaults`
  String get fieldsUseTypeDefaultsLabel {
    return Intl.message(
      'Use field type defaults',
      name: 'fieldsUseTypeDefaultsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Keep this subtype in sync with the field type defaults. Turn this off to customize the properties.`
  String get fieldsUseTypeDefaultsDescription {
    return Intl.message(
      'Keep this subtype in sync with the field type defaults. Turn this off to customize the properties.',
      name: 'fieldsUseTypeDefaultsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Inherits field type defaults`
  String get fieldsUsingTypeDefaults {
    return Intl.message(
      'Inherits field type defaults',
      name: 'fieldsUsingTypeDefaults',
      desc: '',
      args: [],
    );
  }

  /// `This subtype inherits the field type defaults. Turn off the toggle above to customize its properties.`
  String get fieldsUsingTypeDefaultsBody {
    return Intl.message(
      'This subtype inherits the field type defaults. Turn off the toggle above to customize its properties.',
      name: 'fieldsUsingTypeDefaultsBody',
      desc: '',
      args: [],
    );
  }

  /// `Email address`
  String get emailLabel {
    return Intl.message(
      'Email address',
      name: 'emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get usernameLabel {
    return Intl.message('Username', name: 'usernameLabel', desc: '', args: []);
  }

  /// `Subscription`
  String get subscriptionLabel {
    return Intl.message(
      'Subscription',
      name: 'subscriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get roleLabel {
    return Intl.message('Role', name: 'roleLabel', desc: '', args: []);
  }

  /// `No username`
  String get noUsername {
    return Intl.message('No username', name: 'noUsername', desc: '', args: []);
  }

  /// `Admin`
  String get roleAdmin {
    return Intl.message('Admin', name: 'roleAdmin', desc: '', args: []);
  }

  /// `User`
  String get roleUser {
    return Intl.message('User', name: 'roleUser', desc: '', args: []);
  }

  /// `Search by email address`
  String get searchEmailHint {
    return Intl.message(
      'Search by email address',
      name: 'searchEmailHint',
      desc: '',
      args: [],
    );
  }

  /// `Clear search`
  String get clearSearchTooltip {
    return Intl.message(
      'Clear search',
      name: 'clearSearchTooltip',
      desc: '',
      args: [],
    );
  }

  /// `No users found. Try a different search.`
  String get noUsersFound {
    return Intl.message(
      'No users found. Try a different search.',
      name: 'noUsersFound',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load users: {error}`
  String loadUsersFailed(String error) {
    return Intl.message(
      'Couldn\'t load users: $error',
      name: 'loadUsersFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Couldn't update admin access: {error}`
  String toggleAdminFailed(String error) {
    return Intl.message(
      'Couldn\'t update admin access: $error',
      name: 'toggleAdminFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Couldn't load user: {error}`
  String loadUserFailed(String error) {
    return Intl.message(
      'Couldn\'t load user: $error',
      name: 'loadUserFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Couldn't load user.`
  String get loadUserFailedMessage {
    return Intl.message(
      'Couldn\'t load user.',
      name: 'loadUserFailedMessage',
      desc: '',
      args: [],
    );
  }

  /// `No data found.`
  String get noDataFound {
    return Intl.message(
      'No data found.',
      name: 'noDataFound',
      desc: '',
      args: [],
    );
  }

  /// `No booked stays found in this period.`
  String get revenueNoBookedStaysInPeriod {
    return Intl.message(
      'No booked stays found in this period.',
      name: 'revenueNoBookedStaysInPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Manage user`
  String get manageUserAction {
    return Intl.message(
      'Manage user',
      name: 'manageUserAction',
      desc: '',
      args: [],
    );
  }

  /// `User settings`
  String get userSettingsAction {
    return Intl.message(
      'User settings',
      name: 'userSettingsAction',
      desc: '',
      args: [],
    );
  }

  /// `Owned lists`
  String get ownedListsTitle {
    return Intl.message(
      'Owned lists',
      name: 'ownedListsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No owned lists found.`
  String get noOwnedLists {
    return Intl.message(
      'No owned lists found.',
      name: 'noOwnedLists',
      desc: '',
      args: [],
    );
  }

  /// `Shared lists`
  String get sharedListsTitle {
    return Intl.message(
      'Shared lists',
      name: 'sharedListsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No shared lists found.`
  String get noSharedLists {
    return Intl.message(
      'No shared lists found.',
      name: 'noSharedLists',
      desc: '',
      args: [],
    );
  }

  /// `Back to overview`
  String get backToOverview {
    return Intl.message(
      'Back to overview',
      name: 'backToOverview',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refreshTooltip {
    return Intl.message('Refresh', name: 'refreshTooltip', desc: '', args: []);
  }

  /// `Admin rights`
  String get adminRightsTitle {
    return Intl.message(
      'Admin rights',
      name: 'adminRightsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Determines whether this user can access the console.`
  String get adminRightsDescription {
    return Intl.message(
      'Determines whether this user can access the console.',
      name: 'adminRightsDescription',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get userIdLabel {
    return Intl.message('User ID', name: 'userIdLabel', desc: '', args: []);
  }

  /// `Apps`
  String get appsTitle {
    return Intl.message('Apps', name: 'appsTitle', desc: '', args: []);
  }

  /// `No apps found.`
  String get noAppsFound {
    return Intl.message(
      'No apps found.',
      name: 'noAppsFound',
      desc: '',
      args: [],
    );
  }

  /// `Since {date}`
  String listSinceDate(String date) {
    return Intl.message(
      'Since $date',
      name: 'listSinceDate',
      desc: '',
      args: [date],
    );
  }

  /// `Role: {role}`
  String listRoleLabel(String role) {
    return Intl.message(
      'Role: $role',
      name: 'listRoleLabel',
      desc: '',
      args: [role],
    );
  }

  /// `Admin rights enabled.`
  String get adminRightsEnabled {
    return Intl.message(
      'Admin rights enabled.',
      name: 'adminRightsEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Admin rights disabled.`
  String get adminRightsDisabled {
    return Intl.message(
      'Admin rights disabled.',
      name: 'adminRightsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't update admin rights. Try again.`
  String get updateAdminRightsFailed {
    return Intl.message(
      'Couldn\'t update admin rights. Try again.',
      name: 'updateAdminRightsFailed',
      desc: '',
      args: [],
    );
  }

  /// `User updated.`
  String get userUpdated {
    return Intl.message(
      'User updated.',
      name: 'userUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't update user.`
  String get userUpdateFailed {
    return Intl.message(
      'Couldn\'t update user.',
      name: 'userUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Password updated.`
  String get passwordChanged {
    return Intl.message(
      'Password updated.',
      name: 'passwordChanged',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't update the password.`
  String get passwordChangeFailed {
    return Intl.message(
      'Couldn\'t update the password.',
      name: 'passwordChangeFailed',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't update the password: {error}`
  String passwordChangeFailedWithReason(String error) {
    return Intl.message(
      'Couldn\'t update the password: $error',
      name: 'passwordChangeFailedWithReason',
      desc: '',
      args: [error],
    );
  }

  /// `User deleted.`
  String get userDeleted {
    return Intl.message(
      'User deleted.',
      name: 'userDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't delete user.`
  String get userDeleteFailed {
    return Intl.message(
      'Couldn\'t delete user.',
      name: 'userDeleteFailed',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't delete user: {error}`
  String userDeleteFailedWithReason(String error) {
    return Intl.message(
      'Couldn\'t delete user: $error',
      name: 'userDeleteFailedWithReason',
      desc: '',
      args: [error],
    );
  }

  /// `Edit user details`
  String get editUserDialogTitle {
    return Intl.message(
      'Edit user details',
      name: 'editUserDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter an email address.`
  String get emailRequired {
    return Intl.message(
      'Enter an email address.',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address.`
  String get emailInvalid {
    return Intl.message(
      'Enter a valid email address.',
      name: 'emailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get changePasswordTitle {
    return Intl.message(
      'Change password',
      name: 'changePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set a temporary password.`
  String get changePasswordDescription {
    return Intl.message(
      'Set a temporary password.',
      name: 'changePasswordDescription',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get newPasswordLabel {
    return Intl.message(
      'New password',
      name: 'newPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `At least 8 characters.`
  String get passwordMinLength {
    return Intl.message(
      'At least 8 characters.',
      name: 'passwordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPasswordLabel {
    return Intl.message(
      'Confirm password',
      name: 'confirmPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match.`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match.',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get updateButton {
    return Intl.message('Update', name: 'updateButton', desc: '', args: []);
  }

  /// `Delete user`
  String get deleteUserTitle {
    return Intl.message(
      'Delete user',
      name: 'deleteUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `Permanently remove the account and access.`
  String get deleteUserDescription {
    return Intl.message(
      'Permanently remove the account and access.',
      name: 'deleteUserDescription',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete {email}? This also removes the account's contents and cannot be undone.`
  String deleteUserConfirmation(String email) {
    return Intl.message(
      'Are you sure you want to delete $email? This also removes the account\'s contents and cannot be undone.',
      name: 'deleteUserConfirmation',
      desc: '',
      args: [email],
    );
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message('Delete', name: 'deleteButton', desc: '', args: []);
  }

  /// `Edit details`
  String get editDetailsAction {
    return Intl.message(
      'Edit details',
      name: 'editDetailsAction',
      desc: '',
      args: [],
    );
  }

  /// `Update the email address or username.`
  String get editDetailsDescription {
    return Intl.message(
      'Update the email address or username.',
      name: 'editDetailsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Notifications enabled`
  String get notificationsEnabledLabel {
    return Intl.message(
      'Notifications enabled',
      name: 'notificationsEnabledLabel',
      desc: '',
      args: [],
    );
  }

  /// `Reminders`
  String get remindersLabel {
    return Intl.message(
      'Reminders',
      name: 'remindersLabel',
      desc: '',
      args: [],
    );
  }

  /// `Expiration alerts`
  String get expirationRemindersLabel {
    return Intl.message(
      'Expiration alerts',
      name: 'expirationRemindersLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sound`
  String get soundLabel {
    return Intl.message('Sound', name: 'soundLabel', desc: '', args: []);
  }

  /// `Default`
  String get defaultLabel {
    return Intl.message('Default', name: 'defaultLabel', desc: '', args: []);
  }

  /// `Close`
  String get closeButton {
    return Intl.message('Close', name: 'closeButton', desc: '', args: []);
  }

  /// `Admin rights enabled`
  String get adminRightsActive {
    return Intl.message(
      'Admin rights enabled',
      name: 'adminRightsActive',
      desc: '',
      args: [],
    );
  }

  /// `Standard user`
  String get standardUser {
    return Intl.message(
      'Standard user',
      name: 'standardUser',
      desc: '',
      args: [],
    );
  }

  /// `Subscription: {status}`
  String subscriptionChipLabel(String status) {
    return Intl.message(
      'Subscription: $status',
      name: 'subscriptionChipLabel',
      desc: '',
      args: [status],
    );
  }

  /// `Development account`
  String get developmentAccount {
    return Intl.message(
      'Development account',
      name: 'developmentAccount',
      desc: '',
      args: [],
    );
  }

  /// `Seeded user`
  String get seededUser {
    return Intl.message('Seeded user', name: 'seededUser', desc: '', args: []);
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle', desc: '', args: []);
  }

  /// `Default tab`
  String get defaultTabLabel {
    return Intl.message(
      'Default tab',
      name: 'defaultTabLabel',
      desc: '',
      args: [],
    );
  }

  /// `Show start tab`
  String get showStartTabLabel {
    return Intl.message(
      'Show start tab',
      name: 'showStartTabLabel',
      desc: '',
      args: [],
    );
  }

  /// `Show calendar tab`
  String get showCalendarTabLabel {
    return Intl.message(
      'Show calendar tab',
      name: 'showCalendarTabLabel',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notificationsLabel {
    return Intl.message(
      'Notifications',
      name: 'notificationsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yesLabel {
    return Intl.message('Yes', name: 'yesLabel', desc: '', args: []);
  }

  /// `No`
  String get noLabel {
    return Intl.message('No', name: 'noLabel', desc: '', args: []);
  }

  /// `Enabled`
  String get enabledLabel {
    return Intl.message('Enabled', name: 'enabledLabel', desc: '', args: []);
  }

  /// `Disabled`
  String get disabledLabel {
    return Intl.message('Disabled', name: 'disabledLabel', desc: '', args: []);
  }

  /// `Couldn't update profile: {error}`
  String updateProfileFailed(String error) {
    return Intl.message(
      'Couldn\'t update profile: $error',
      name: 'updateProfileFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message('Cancel', name: 'cancelButton', desc: '', args: []);
  }

  /// `Untitled`
  String get untitledList {
    return Intl.message('Untitled', name: 'untitledList', desc: '', args: []);
  }

  /// `Beta`
  String get beta {
    return Intl.message('Beta', name: 'beta', desc: '', args: []);
  }

  /// `Bookmarks`
  String get bookmarks {
    return Intl.message('Bookmarks', name: 'bookmarks', desc: '', args: []);
  }

  /// `Hide`
  String get hide {
    return Intl.message('Hide', name: 'hide', desc: '', args: []);
  }

  /// `Dollar`
  String get dollar {
    return Intl.message('Dollar', name: 'dollar', desc: '', args: []);
  }

  /// `Shopping`
  String get shopping {
    return Intl.message('Shopping', name: 'shopping', desc: '', args: []);
  }

  /// `Print`
  String get print {
    return Intl.message('Print', name: 'print', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Pen`
  String get pen {
    return Intl.message('Pen', name: 'pen', desc: '', args: []);
  }

  /// `Alarm Clock`
  String get alarmClock {
    return Intl.message('Alarm Clock', name: 'alarmClock', desc: '', args: []);
  }

  /// `Purse`
  String get purse {
    return Intl.message('Purse', name: 'purse', desc: '', args: []);
  }

  /// `Wallet`
  String get wallet {
    return Intl.message('Wallet', name: 'wallet', desc: '', args: []);
  }

  /// `Folder`
  String get folder {
    return Intl.message('Folder', name: 'folder', desc: '', args: []);
  }

  /// `Shopping Cart`
  String get shoppingCart {
    return Intl.message(
      'Shopping Cart',
      name: 'shoppingCart',
      desc: '',
      args: [],
    );
  }

  /// `QR Code`
  String get qrCode {
    return Intl.message('QR Code', name: 'qrCode', desc: '', args: []);
  }

  /// `Expiry`
  String get expiry {
    return Intl.message('Expiry', name: 'expiry', desc: '', args: []);
  }

  /// `Open Package`
  String get openPackage {
    return Intl.message(
      'Open Package',
      name: 'openPackage',
      desc: '',
      args: [],
    );
  }

  /// `Printer`
  String get printer {
    return Intl.message('Printer', name: 'printer', desc: '', args: []);
  }

  /// `Scale`
  String get scale {
    return Intl.message('Scale', name: 'scale', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `WiFi`
  String get wifi {
    return Intl.message('WiFi', name: 'wifi', desc: '', args: []);
  }

  /// `Clock`
  String get clock {
    return Intl.message('Clock', name: 'clock', desc: '', args: []);
  }

  /// `Source`
  String get source {
    return Intl.message('Source', name: 'source', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Warning`
  String get warning {
    return Intl.message('Warning', name: 'warning', desc: '', args: []);
  }

  /// `Analytics`
  String get analytics {
    return Intl.message('Analytics', name: 'analytics', desc: '', args: []);
  }

  /// `Business`
  String get business {
    return Intl.message('Business', name: 'business', desc: '', args: []);
  }

  /// `Money`
  String get money {
    return Intl.message('Money', name: 'money', desc: '', args: []);
  }

  /// `Money Bag`
  String get moneyBag {
    return Intl.message('Money Bag', name: 'moneyBag', desc: '', args: []);
  }

  /// `Coins`
  String get coins {
    return Intl.message('Coins', name: 'coins', desc: '', args: []);
  }

  /// `Coin`
  String get coin {
    return Intl.message('Coin', name: 'coin', desc: '', args: []);
  }

  /// `Server`
  String get server {
    return Intl.message('Server', name: 'server', desc: '', args: []);
  }

  /// `Network`
  String get network {
    return Intl.message('Network', name: 'network', desc: '', args: []);
  }

  /// `Insect`
  String get insect {
    return Intl.message('Insect', name: 'insect', desc: '', args: []);
  }

  /// `Lamp`
  String get lamp {
    return Intl.message('Lamp', name: 'lamp', desc: '', args: []);
  }

  /// `Bell`
  String get bell {
    return Intl.message('Bell', name: 'bell', desc: '', args: []);
  }

  /// `Compass`
  String get compass {
    return Intl.message('Compass', name: 'compass', desc: '', args: []);
  }

  /// `Hide Input`
  String get hideInput {
    return Intl.message('Hide Input', name: 'hideInput', desc: '', args: []);
  }

  /// `Search icon`
  String get searchIcon {
    return Intl.message('Search icon', name: 'searchIcon', desc: '', args: []);
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Label`
  String get label {
    return Intl.message('Label', name: 'label', desc: '', args: []);
  }

  /// `Indicator`
  String get indicator {
    return Intl.message('Indicator', name: 'indicator', desc: '', args: []);
  }

  /// `Distance`
  String get distance {
    return Intl.message('Distance', name: 'distance', desc: '', args: []);
  }

  /// `Route`
  String get route {
    return Intl.message('Route', name: 'route', desc: '', args: []);
  }

  /// `Navigation`
  String get navigation {
    return Intl.message('Navigation', name: 'navigation', desc: '', args: []);
  }

  /// `Mark`
  String get mark {
    return Intl.message('Mark', name: 'mark', desc: '', args: []);
  }

  /// `Tag`
  String get tag {
    return Intl.message('Tag', name: 'tag', desc: '', args: []);
  }

  /// `Arrow`
  String get arrow {
    return Intl.message('Arrow', name: 'arrow', desc: '', args: []);
  }

  /// `Right`
  String get right {
    return Intl.message('Right', name: 'right', desc: '', args: []);
  }

  /// `Left`
  String get left {
    return Intl.message('Left', name: 'left', desc: '', args: []);
  }

  /// `Numbers`
  String get numbers {
    return Intl.message('Numbers', name: 'numbers', desc: '', args: []);
  }

  /// `Exclamation`
  String get exclamation {
    return Intl.message('Exclamation', name: 'exclamation', desc: '', args: []);
  }

  /// `Toggle`
  String get toggle {
    return Intl.message('Toggle', name: 'toggle', desc: '', args: []);
  }

  /// `Check`
  String get check {
    return Intl.message('Check', name: 'check', desc: '', args: []);
  }

  /// `Bullet Lists`
  String get bulletLists {
    return Intl.message(
      'Bullet Lists',
      name: 'bulletLists',
      desc: '',
      args: [],
    );
  }

  /// `Round Number`
  String get roundNumber {
    return Intl.message(
      'Round Number',
      name: 'roundNumber',
      desc: '',
      args: [],
    );
  }

  /// `Decimal Number`
  String get decimalNumber {
    return Intl.message(
      'Decimal Number',
      name: 'decimalNumber',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get text {
    return Intl.message('Text', name: 'text', desc: '', args: []);
  }

  /// `Letter`
  String get letter {
    return Intl.message('Letter', name: 'letter', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Store`
  String get store {
    return Intl.message('Store', name: 'store', desc: '', args: []);
  }

  /// `Small Caps`
  String get smallCaps {
    return Intl.message('Small Caps', name: 'smallCaps', desc: '', args: []);
  }

  /// `Letters`
  String get letters {
    return Intl.message('Letters', name: 'letters', desc: '', args: []);
  }

  /// `Height`
  String get height {
    return Intl.message('Height', name: 'height', desc: '', args: []);
  }

  /// `Column`
  String get column {
    return Intl.message('Column', name: 'column', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Dash`
  String get dash {
    return Intl.message('Dash', name: 'dash', desc: '', args: []);
  }

  /// `Vertical Line`
  String get verticalLine {
    return Intl.message(
      'Vertical Line',
      name: 'verticalLine',
      desc: '',
      args: [],
    );
  }

  /// `Drag`
  String get drag {
    return Intl.message('Drag', name: 'drag', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Pencil`
  String get pencil {
    return Intl.message('Pencil', name: 'pencil', desc: '', args: []);
  }

  /// `Font Colors`
  String get fontColors {
    return Intl.message('Font Colors', name: 'fontColors', desc: '', args: []);
  }

  /// `Underline`
  String get underline {
    return Intl.message('Underline', name: 'underline', desc: '', args: []);
  }

  /// `Font Size`
  String get fontSize {
    return Intl.message('Font Size', name: 'fontSize', desc: '', args: []);
  }

  /// `Form`
  String get form {
    return Intl.message('Form', name: 'form', desc: '', args: []);
  }

  /// `Line Height`
  String get lineHeight {
    return Intl.message('Line Height', name: 'lineHeight', desc: '', args: []);
  }

  /// `Numbered List`
  String get numberedList {
    return Intl.message(
      'Numbered List',
      name: 'numberedList',
      desc: '',
      args: [],
    );
  }

  /// `Width`
  String get width {
    return Intl.message('Width', name: 'width', desc: '', args: []);
  }

  /// `Table`
  String get table {
    return Intl.message('Table', name: 'table', desc: '', args: []);
  }

  /// `Table of Content`
  String get tableOfContent {
    return Intl.message(
      'Table of Content',
      name: 'tableOfContent',
      desc: '',
      args: [],
    );
  }

  /// `Percent`
  String get percent {
    return Intl.message('Percent', name: 'percent', desc: '', args: []);
  }

  /// `Subtract`
  String get subtract {
    return Intl.message('Subtract', name: 'subtract', desc: '', args: []);
  }

  /// `Operator`
  String get operatorSign {
    return Intl.message('Operator', name: 'operatorSign', desc: '', args: []);
  }

  /// `Math`
  String get math {
    return Intl.message('Math', name: 'math', desc: '', args: []);
  }

  /// `Multiply`
  String get multiply {
    return Intl.message('Multiply', name: 'multiply', desc: '', args: []);
  }

  /// `Plus`
  String get plus {
    return Intl.message('Plus', name: 'plus', desc: '', args: []);
  }

  /// `Divide`
  String get divide {
    return Intl.message('Divide', name: 'divide', desc: '', args: []);
  }

  /// `Sum`
  String get sum {
    return Intl.message('Sum', name: 'sum', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Braces`
  String get braces {
    return Intl.message('Braces', name: 'braces', desc: '', args: []);
  }

  /// `Code`
  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  /// `Software`
  String get software {
    return Intl.message('Software', name: 'software', desc: '', args: []);
  }

  /// `Development`
  String get development {
    return Intl.message('Development', name: 'development', desc: '', args: []);
  }

  /// `Question Mark`
  String get questionMark {
    return Intl.message(
      'Question Mark',
      name: 'questionMark',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message('Calendar', name: 'calendar', desc: '', args: []);
  }

  /// `Reservations`
  String get reservations {
    return Intl.message(
      'Reservations',
      name: 'reservations',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Date Range`
  String get dateRange {
    return Intl.message('Date Range', name: 'dateRange', desc: '', args: []);
  }

  /// `Deadline`
  String get deadline {
    return Intl.message('Deadline', name: 'deadline', desc: '', args: []);
  }

  /// `Fast Time`
  String get fastTime {
    return Intl.message('Fast Time', name: 'fastTime', desc: '', args: []);
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Delete Event`
  String get deleteEvent {
    return Intl.message(
      'Delete Event',
      name: 'deleteEvent',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Expired`
  String get expired {
    return Intl.message('Expired', name: 'expired', desc: '', args: []);
  }

  /// `Center Alignment`
  String get centerAlignment {
    return Intl.message(
      'Center Alignment',
      name: 'centerAlignment',
      desc: '',
      args: [],
    );
  }

  /// `Left Alignment`
  String get leftAlignment {
    return Intl.message(
      'Left Alignment',
      name: 'leftAlignment',
      desc: '',
      args: [],
    );
  }

  /// `Right Alignment`
  String get rightAlignment {
    return Intl.message(
      'Right Alignment',
      name: 'rightAlignment',
      desc: '',
      args: [],
    );
  }

  /// `Hide Keyboard`
  String get hideKeyboard {
    return Intl.message(
      'Hide Keyboard',
      name: 'hideKeyboard',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get created {
    return Intl.message('Created', name: 'created', desc: '', args: []);
  }

  /// `Event`
  String get event {
    return Intl.message('Event', name: 'event', desc: '', args: []);
  }

  /// `Long Time`
  String get longTime {
    return Intl.message('Long Time', name: 'longTime', desc: '', args: []);
  }

  /// `Repeat`
  String get repeat {
    return Intl.message('Repeat', name: 'repeat', desc: '', args: []);
  }

  /// `Mail`
  String get mail {
    return Intl.message('Mail', name: 'mail', desc: '', args: []);
  }

  /// `Envelop`
  String get envelop {
    return Intl.message('Envelop', name: 'envelop', desc: '', args: []);
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Like`
  String get like {
    return Intl.message('Like', name: 'like', desc: '', args: []);
  }

  /// `Thumb`
  String get thumb {
    return Intl.message('Thumb', name: 'thumb', desc: '', args: []);
  }

  /// `Dislike`
  String get dislike {
    return Intl.message('Dislike', name: 'dislike', desc: '', args: []);
  }

  /// `Favorite`
  String get favorite {
    return Intl.message('Favorite', name: 'favorite', desc: '', args: []);
  }

  /// `List`
  String get list {
    return Intl.message('List', name: 'list', desc: '', args: []);
  }

  /// `Cross`
  String get cross {
    return Intl.message('Cross', name: 'cross', desc: '', args: []);
  }

  /// `Snowflake`
  String get snowflake {
    return Intl.message('Snowflake', name: 'snowflake', desc: '', args: []);
  }

  /// `Rating Star`
  String get ratingStar {
    return Intl.message('Rating Star', name: 'ratingStar', desc: '', args: []);
  }

  /// `Star`
  String get star {
    return Intl.message('Star', name: 'star', desc: '', args: []);
  }

  /// `Star Inverse`
  String get starInverse {
    return Intl.message(
      'Star Inverse',
      name: 'starInverse',
      desc: '',
      args: [],
    );
  }

  /// `Diamond`
  String get diamond {
    return Intl.message('Diamond', name: 'diamond', desc: '', args: []);
  }

  /// `Circle Outlined`
  String get circleOutlined {
    return Intl.message(
      'Circle Outlined',
      name: 'circleOutlined',
      desc: '',
      args: [],
    );
  }

  /// `Circle Filled`
  String get circleFilled {
    return Intl.message(
      'Circle Filled',
      name: 'circleFilled',
      desc: '',
      args: [],
    );
  }

  /// `Cube`
  String get cube {
    return Intl.message('Cube', name: 'cube', desc: '', args: []);
  }

  /// `Cylinder`
  String get cylinder {
    return Intl.message('Cylinder', name: 'cylinder', desc: '', args: []);
  }

  /// `Heart`
  String get heart {
    return Intl.message('Heart', name: 'heart', desc: '', args: []);
  }

  /// `Oval`
  String get oval {
    return Intl.message('Oval', name: 'oval', desc: '', args: []);
  }

  /// `Dot`
  String get dot {
    return Intl.message('Dot', name: 'dot', desc: '', args: []);
  }

  /// `Dots`
  String get dots {
    return Intl.message('Dots', name: 'dots', desc: '', args: []);
  }

  /// `Square`
  String get square {
    return Intl.message('Square', name: 'square', desc: '', args: []);
  }

  /// `Arrows Up Down`
  String get arrowsUpDown {
    return Intl.message(
      'Arrows Up Down',
      name: 'arrowsUpDown',
      desc: '',
      args: [],
    );
  }

  /// `Balloon`
  String get balloon {
    return Intl.message('Balloon', name: 'balloon', desc: '', args: []);
  }

  /// `Present`
  String get present {
    return Intl.message('Present', name: 'present', desc: '', args: []);
  }

  /// `Christmas`
  String get christmas {
    return Intl.message('Christmas', name: 'christmas', desc: '', args: []);
  }

  /// `Tree`
  String get tree {
    return Intl.message('Tree', name: 'tree', desc: '', args: []);
  }

  /// `Bauble`
  String get bauble {
    return Intl.message('Bauble', name: 'bauble', desc: '', args: []);
  }

  /// `Invitation`
  String get invitation {
    return Intl.message('Invitation', name: 'invitation', desc: '', args: []);
  }

  /// `Wine and Glass`
  String get wineAndGlass {
    return Intl.message(
      'Wine and Glass',
      name: 'wineAndGlass',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get birthday {
    return Intl.message('Birthday', name: 'birthday', desc: '', args: []);
  }

  /// `Elevator`
  String get elevator {
    return Intl.message('Elevator', name: 'elevator', desc: '', args: []);
  }

  /// `Mother`
  String get mother {
    return Intl.message('Mother', name: 'mother', desc: '', args: []);
  }

  /// `Woman`
  String get woman {
    return Intl.message('Woman', name: 'woman', desc: '', args: []);
  }

  /// `Father`
  String get father {
    return Intl.message('Father', name: 'father', desc: '', args: []);
  }

  /// `Cleaning`
  String get cleaning {
    return Intl.message('Cleaning', name: 'cleaning', desc: '', args: []);
  }

  /// `House`
  String get house {
    return Intl.message('House', name: 'house', desc: '', args: []);
  }

  /// `Shopping Basket`
  String get shoppingBasket {
    return Intl.message(
      'Shopping Basket',
      name: 'shoppingBasket',
      desc: '',
      args: [],
    );
  }

  /// `Shop`
  String get shop {
    return Intl.message('Shop', name: 'shop', desc: '', args: []);
  }

  /// `Jacket`
  String get jacket {
    return Intl.message('Jacket', name: 'jacket', desc: '', args: []);
  }

  /// `Blender`
  String get blender {
    return Intl.message('Blender', name: 'blender', desc: '', args: []);
  }

  /// `Dress`
  String get dress {
    return Intl.message('Dress', name: 'dress', desc: '', args: []);
  }

  /// `Cat`
  String get cat {
    return Intl.message('Cat', name: 'cat', desc: '', args: []);
  }

  /// `Dog`
  String get dog {
    return Intl.message('Dog', name: 'dog', desc: '', args: []);
  }

  /// `Paint`
  String get paint {
    return Intl.message('Paint', name: 'paint', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Iron`
  String get iron {
    return Intl.message('Iron', name: 'iron', desc: '', args: []);
  }

  /// `Suitcase`
  String get suitcase {
    return Intl.message('Suitcase', name: 'suitcase', desc: '', args: []);
  }

  /// `Airplane`
  String get airplane {
    return Intl.message('Airplane', name: 'airplane', desc: '', args: []);
  }

  /// `Mountain`
  String get mountain {
    return Intl.message('Mountain', name: 'mountain', desc: '', args: []);
  }

  /// `Globe`
  String get globe {
    return Intl.message('Globe', name: 'globe', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `People`
  String get people {
    return Intl.message('People', name: 'people', desc: '', args: []);
  }

  /// `Persons`
  String get persons {
    return Intl.message('Persons', name: 'persons', desc: '', args: []);
  }

  /// `Human`
  String get human {
    return Intl.message('Human', name: 'human', desc: '', args: []);
  }

  /// `Photo`
  String get photo {
    return Intl.message('Photo', name: 'photo', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Bike`
  String get bike {
    return Intl.message('Bike', name: 'bike', desc: '', args: []);
  }

  /// `Sport`
  String get sport {
    return Intl.message('Sport', name: 'sport', desc: '', args: []);
  }

  /// `Bus`
  String get bus {
    return Intl.message('Bus', name: 'bus', desc: '', args: []);
  }

  /// `Taxi`
  String get taxi {
    return Intl.message('Taxi', name: 'taxi', desc: '', args: []);
  }

  /// `Car`
  String get car {
    return Intl.message('Car', name: 'car', desc: '', args: []);
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Disability`
  String get disability {
    return Intl.message('Disability', name: 'disability', desc: '', args: []);
  }

  /// `Walking`
  String get walking {
    return Intl.message('Walking', name: 'walking', desc: '', args: []);
  }

  /// `Music`
  String get music {
    return Intl.message('Music', name: 'music', desc: '', args: []);
  }

  /// `Rest Room`
  String get restRoom {
    return Intl.message('Rest Room', name: 'restRoom', desc: '', args: []);
  }

  /// `Party`
  String get party {
    return Intl.message('Party', name: 'party', desc: '', args: []);
  }

  /// `Sound`
  String get sound {
    return Intl.message('Sound', name: 'sound', desc: '', args: []);
  }

  /// `Audio`
  String get audio {
    return Intl.message('Audio', name: 'audio', desc: '', args: []);
  }

  /// `Travel`
  String get travel {
    return Intl.message('Travel', name: 'travel', desc: '', args: []);
  }

  /// `Holiday`
  String get holiday {
    return Intl.message('Holiday', name: 'holiday', desc: '', args: []);
  }

  /// `Palm`
  String get palm {
    return Intl.message('Palm', name: 'palm', desc: '', args: []);
  }

  /// `Beach`
  String get beach {
    return Intl.message('Beach', name: 'beach', desc: '', args: []);
  }

  /// `Island`
  String get island {
    return Intl.message('Island', name: 'island', desc: '', args: []);
  }

  /// `Parasol`
  String get parasol {
    return Intl.message('Parasol', name: 'parasol', desc: '', args: []);
  }

  /// `Beach Umbrella`
  String get beachUmbrella {
    return Intl.message(
      'Beach Umbrella',
      name: 'beachUmbrella',
      desc: '',
      args: [],
    );
  }

  /// `Brush`
  String get brush {
    return Intl.message('Brush', name: 'brush', desc: '', args: []);
  }

  /// `Icon`
  String get icon {
    return Intl.message('Icon', name: 'icon', desc: '', args: []);
  }

  /// `Sport Car`
  String get sportCar {
    return Intl.message('Sport Car', name: 'sportCar', desc: '', args: []);
  }

  /// `Fashion`
  String get fashion {
    return Intl.message('Fashion', name: 'fashion', desc: '', args: []);
  }

  /// `Clothing`
  String get clothing {
    return Intl.message('Clothing', name: 'clothing', desc: '', args: []);
  }

  /// `T-shirt`
  String get tShirt {
    return Intl.message('T-shirt', name: 'tShirt', desc: '', args: []);
  }

  /// `Golf`
  String get golf {
    return Intl.message('Golf', name: 'golf', desc: '', args: []);
  }

  /// `Garden`
  String get garden {
    return Intl.message('Garden', name: 'garden', desc: '', args: []);
  }

  /// `Flowers`
  String get flowers {
    return Intl.message('Flowers', name: 'flowers', desc: '', args: []);
  }

  /// `Medal`
  String get medal {
    return Intl.message('Medal', name: 'medal', desc: '', args: []);
  }

  /// `Rugby`
  String get rugby {
    return Intl.message('Rugby', name: 'rugby', desc: '', args: []);
  }

  /// `Trophy`
  String get trophy {
    return Intl.message('Trophy', name: 'trophy', desc: '', args: []);
  }

  /// `Cup`
  String get cup {
    return Intl.message('Cup', name: 'cup', desc: '', args: []);
  }

  /// `Ingredients`
  String get ingredients {
    return Intl.message('Ingredients', name: 'ingredients', desc: '', args: []);
  }

  /// `Bread`
  String get bread {
    return Intl.message('Bread', name: 'bread', desc: '', args: []);
  }

  /// `Parsley`
  String get parsley {
    return Intl.message('Parsley', name: 'parsley', desc: '', args: []);
  }

  /// `Chicken`
  String get chicken {
    return Intl.message('Chicken', name: 'chicken', desc: '', args: []);
  }

  /// `Bowl and Chopsticks`
  String get bowlAndChopsticks {
    return Intl.message(
      'Bowl and Chopsticks',
      name: 'bowlAndChopsticks',
      desc: '',
      args: [],
    );
  }

  /// `Pasta`
  String get pasta {
    return Intl.message('Pasta', name: 'pasta', desc: '', args: []);
  }

  /// `Pasta Maker`
  String get pastaMaker {
    return Intl.message('Pasta Maker', name: 'pastaMaker', desc: '', args: []);
  }

  /// `Drinks`
  String get drinks {
    return Intl.message('Drinks', name: 'drinks', desc: '', args: []);
  }

  /// `Cherries`
  String get cherries {
    return Intl.message('Cherries', name: 'cherries', desc: '', args: []);
  }

  /// `Plate`
  String get plate {
    return Intl.message('Plate', name: 'plate', desc: '', args: []);
  }

  /// `Noodles`
  String get noodles {
    return Intl.message('Noodles', name: 'noodles', desc: '', args: []);
  }

  /// `Thai`
  String get thai {
    return Intl.message('Thai', name: 'thai', desc: '', args: []);
  }

  /// `Fork and Knife`
  String get forkAndKnife {
    return Intl.message(
      'Fork and Knife',
      name: 'forkAndKnife',
      desc: '',
      args: [],
    );
  }

  /// `Frozen Fries`
  String get frozenFries {
    return Intl.message(
      'Frozen Fries',
      name: 'frozenFries',
      desc: '',
      args: [],
    );
  }

  /// `Coffee`
  String get coffee {
    return Intl.message('Coffee', name: 'coffee', desc: '', args: []);
  }

  /// `Kettle`
  String get kettle {
    return Intl.message('Kettle', name: 'kettle', desc: '', args: []);
  }

  /// `Beer`
  String get beer {
    return Intl.message('Beer', name: 'beer', desc: '', args: []);
  }

  /// `Bottle`
  String get bottle {
    return Intl.message('Bottle', name: 'bottle', desc: '', args: []);
  }

  /// `Tomato`
  String get tomato {
    return Intl.message('Tomato', name: 'tomato', desc: '', args: []);
  }

  /// `Container`
  String get container {
    return Intl.message('Container', name: 'container', desc: '', args: []);
  }

  /// `Gravy Boat`
  String get gravyBoat {
    return Intl.message('Gravy Boat', name: 'gravyBoat', desc: '', args: []);
  }

  /// `Sauce Boat`
  String get sauceBoat {
    return Intl.message('Sauce Boat', name: 'sauceBoat', desc: '', args: []);
  }

  /// `Ice Cream`
  String get iceCream {
    return Intl.message('Ice Cream', name: 'iceCream', desc: '', args: []);
  }

  /// `Microwave`
  String get microwave {
    return Intl.message('Microwave', name: 'microwave', desc: '', args: []);
  }

  /// `Croissant`
  String get croissant {
    return Intl.message('Croissant', name: 'croissant', desc: '', args: []);
  }

  /// `Steak`
  String get steak {
    return Intl.message('Steak', name: 'steak', desc: '', args: []);
  }

  /// `Food`
  String get food {
    return Intl.message('Food', name: 'food', desc: '', args: []);
  }

  /// `Library`
  String get library {
    return Intl.message('Library', name: 'library', desc: '', args: []);
  }

  /// `Pestle`
  String get pestle {
    return Intl.message('Pestle', name: 'pestle', desc: '', args: []);
  }

  /// `Milk`
  String get milk {
    return Intl.message('Milk', name: 'milk', desc: '', args: []);
  }

  /// `Jar`
  String get jar {
    return Intl.message('Jar', name: 'jar', desc: '', args: []);
  }

  /// `Avocado`
  String get avocado {
    return Intl.message('Avocado', name: 'avocado', desc: '', args: []);
  }

  /// `Spaghetti`
  String get spaghetti {
    return Intl.message('Spaghetti', name: 'spaghetti', desc: '', args: []);
  }

  /// `Eggplant`
  String get eggplant {
    return Intl.message('Eggplant', name: 'eggplant', desc: '', args: []);
  }

  /// `Eggs`
  String get eggs {
    return Intl.message('Eggs', name: 'eggs', desc: '', args: []);
  }

  /// `Broccoli`
  String get broccoli {
    return Intl.message('Broccoli', name: 'broccoli', desc: '', args: []);
  }

  /// `Wine Bottle`
  String get wineBottle {
    return Intl.message('Wine Bottle', name: 'wineBottle', desc: '', args: []);
  }

  /// `Carrot`
  String get carrot {
    return Intl.message('Carrot', name: 'carrot', desc: '', args: []);
  }

  /// `Fish`
  String get fish {
    return Intl.message('Fish', name: 'fish', desc: '', args: []);
  }

  /// `Frozen`
  String get frozen {
    return Intl.message('Frozen', name: 'frozen', desc: '', args: []);
  }

  /// `Fries`
  String get fries {
    return Intl.message('Fries', name: 'fries', desc: '', args: []);
  }

  /// `Meat`
  String get meat {
    return Intl.message('Meat', name: 'meat', desc: '', args: []);
  }

  /// `Pie`
  String get pie {
    return Intl.message('Pie', name: 'pie', desc: '', args: []);
  }

  /// `Pizza`
  String get pizza {
    return Intl.message('Pizza', name: 'pizza', desc: '', args: []);
  }

  /// `Sauce Bottle`
  String get sauceBottle {
    return Intl.message(
      'Sauce Bottle',
      name: 'sauceBottle',
      desc: '',
      args: [],
    );
  }

  /// `Sauce`
  String get sauce {
    return Intl.message('Sauce', name: 'sauce', desc: '', args: []);
  }

  /// `Hot`
  String get hot {
    return Intl.message('Hot', name: 'hot', desc: '', args: []);
  }

  /// `Soup`
  String get soup {
    return Intl.message('Soup', name: 'soup', desc: '', args: []);
  }

  /// `Vegetarian`
  String get vegetarian {
    return Intl.message('Vegetarian', name: 'vegetarian', desc: '', args: []);
  }

  /// `Wine`
  String get wine {
    return Intl.message('Wine', name: 'wine', desc: '', args: []);
  }

  /// `Wok`
  String get wok {
    return Intl.message('Wok', name: 'wok', desc: '', args: []);
  }

  /// `Frying Pan`
  String get fryingPan {
    return Intl.message('Frying Pan', name: 'fryingPan', desc: '', args: []);
  }

  /// `Shopping Bag`
  String get shoppingBag {
    return Intl.message(
      'Shopping Bag',
      name: 'shoppingBag',
      desc: '',
      args: [],
    );
  }

  /// `Pass`
  String get pass {
    return Intl.message('Pass', name: 'pass', desc: '', args: []);
  }

  /// `Todo List`
  String get todoList {
    return Intl.message('Todo List', name: 'todoList', desc: '', args: []);
  }

  /// `Recipe Book`
  String get recipeBook {
    return Intl.message('Recipe Book', name: 'recipeBook', desc: '', args: []);
  }

  /// `Recipes`
  String get recipes {
    return Intl.message('Recipes', name: 'recipes', desc: '', args: []);
  }

  /// `Inventory`
  String get inventory {
    return Intl.message('Inventory', name: 'inventory', desc: '', args: []);
  }

  /// `Wishlist`
  String get wishlist {
    return Intl.message('Wishlist', name: 'wishlist', desc: '', args: []);
  }

  /// `Expenses`
  String get expenses {
    return Intl.message('Expenses', name: 'expenses', desc: '', args: []);
  }

  /// `Refrigerator`
  String get refrigerator {
    return Intl.message(
      'Refrigerator',
      name: 'refrigerator',
      desc: '',
      args: [],
    );
  }

  /// `Wine List`
  String get wineList {
    return Intl.message('Wine List', name: 'wineList', desc: '', args: []);
  }

  /// `Loyalty Card`
  String get loyaltyCard {
    return Intl.message(
      'Loyalty Card',
      name: 'loyaltyCard',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get premium {
    return Intl.message('Premium', name: 'premium', desc: '', args: []);
  }

  /// `Kanban Board`
  String get kanbanBoard {
    return Intl.message(
      'Kanban Board',
      name: 'kanbanBoard',
      desc: '',
      args: [],
    );
  }

  /// `Event Planner`
  String get eventPlanner {
    return Intl.message(
      'Event Planner',
      name: 'eventPlanner',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get events {
    return Intl.message('Events', name: 'events', desc: '', args: []);
  }

  /// `Glasses`
  String get glasses {
    return Intl.message('Glasses', name: 'glasses', desc: '', args: []);
  }

  /// `Pig`
  String get pig {
    return Intl.message('Pig', name: 'pig', desc: '', args: []);
  }

  /// `Travel Itinerary`
  String get travelItinerary {
    return Intl.message(
      'Travel Itinerary',
      name: 'travelItinerary',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get url {
    return Intl.message('URL', name: 'url', desc: '', args: []);
  }

  /// `Vacation Time`
  String get vacationTime {
    return Intl.message(
      'Vacation Time',
      name: 'vacationTime',
      desc: '',
      args: [],
    );
  }

  /// `Itinerary`
  String get itinerary {
    return Intl.message('Itinerary', name: 'itinerary', desc: '', args: []);
  }

  /// `Meditate`
  String get meditate {
    return Intl.message('Meditate', name: 'meditate', desc: '', args: []);
  }

  /// `Contacts`
  String get contacts {
    return Intl.message('Contacts', name: 'contacts', desc: '', args: []);
  }

  /// `Address Book`
  String get addressBook {
    return Intl.message(
      'Address Book',
      name: 'addressBook',
      desc: '',
      args: [],
    );
  }

  /// `Flag`
  String get flag {
    return Intl.message('Flag', name: 'flag', desc: '', args: []);
  }

  /// `Banner`
  String get banner {
    return Intl.message('Banner', name: 'banner', desc: '', args: []);
  }

  /// `Symbol`
  String get symbol {
    return Intl.message('Symbol', name: 'symbol', desc: '', args: []);
  }

  /// `Sun`
  String get sun {
    return Intl.message('Sun', name: 'sun', desc: '', args: []);
  }

  /// `Sunlight`
  String get sunlight {
    return Intl.message('Sunlight', name: 'sunlight', desc: '', args: []);
  }

  /// `Daylight`
  String get daylight {
    return Intl.message('Daylight', name: 'daylight', desc: '', args: []);
  }

  /// `Call`
  String get call {
    return Intl.message('Call', name: 'call', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Mobile`
  String get mobile {
    return Intl.message('Mobile', name: 'mobile', desc: '', args: []);
  }

  /// `Scan Barcode`
  String get scanBarcode {
    return Intl.message(
      'Scan Barcode',
      name: 'scanBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Barcode`
  String get barcode {
    return Intl.message('Barcode', name: 'barcode', desc: '', args: []);
  }

  /// `Folders`
  String get folders {
    return Intl.message('Folders', name: 'folders', desc: '', args: []);
  }

  /// `Files`
  String get files {
    return Intl.message('Files', name: 'files', desc: '', args: []);
  }

  /// `Organization`
  String get organization {
    return Intl.message(
      'Organization',
      name: 'organization',
      desc: '',
      args: [],
    );
  }

  /// `Card`
  String get card {
    return Intl.message('Card', name: 'card', desc: '', args: []);
  }

  /// `Dollar Coins`
  String get dollarCoins {
    return Intl.message(
      'Dollar Coins',
      name: 'dollarCoins',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Repair`
  String get repair {
    return Intl.message('Repair', name: 'repair', desc: '', args: []);
  }

  /// `Fix`
  String get fix {
    return Intl.message('Fix', name: 'fix', desc: '', args: []);
  }

  /// `Maintenance`
  String get maintenance {
    return Intl.message('Maintenance', name: 'maintenance', desc: '', args: []);
  }

  /// `Pet`
  String get pet {
    return Intl.message('Pet', name: 'pet', desc: '', args: []);
  }

  /// `Puppy`
  String get puppy {
    return Intl.message('Puppy', name: 'puppy', desc: '', args: []);
  }

  /// `Kitten`
  String get kitten {
    return Intl.message('Kitten', name: 'kitten', desc: '', args: []);
  }

  /// `Trash`
  String get trash {
    return Intl.message('Trash', name: 'trash', desc: '', args: []);
  }

  /// `Garbage`
  String get garbage {
    return Intl.message('Garbage', name: 'garbage', desc: '', args: []);
  }

  /// `Waste`
  String get waste {
    return Intl.message('Waste', name: 'waste', desc: '', args: []);
  }

  /// `Empty`
  String get empty {
    return Intl.message('Empty', name: 'empty', desc: '', args: []);
  }

  /// `Blank`
  String get blank {
    return Intl.message('Blank', name: 'blank', desc: '', args: []);
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Statistic`
  String get statistic {
    return Intl.message('Statistic', name: 'statistic', desc: '', args: []);
  }

  /// `Data`
  String get data {
    return Intl.message('Data', name: 'data', desc: '', args: []);
  }

  /// `Analysis`
  String get analysis {
    return Intl.message('Analysis', name: 'analysis', desc: '', args: []);
  }

  /// `Write`
  String get write {
    return Intl.message('Write', name: 'write', desc: '', args: []);
  }

  /// `Timer`
  String get timer {
    return Intl.message('Timer', name: 'timer', desc: '', args: []);
  }

  /// `Alarm`
  String get alarm {
    return Intl.message('Alarm', name: 'alarm', desc: '', args: []);
  }

  /// `Directory`
  String get directory {
    return Intl.message('Directory', name: 'directory', desc: '', args: []);
  }

  /// `Cart`
  String get cart {
    return Intl.message('Cart', name: 'cart', desc: '', args: []);
  }

  /// `QR`
  String get qr {
    return Intl.message('QR', name: 'qr', desc: '', args: []);
  }

  /// `Scan`
  String get scan {
    return Intl.message('Scan', name: 'scan', desc: '', args: []);
  }

  /// `Expiration`
  String get expiration {
    return Intl.message('Expiration', name: 'expiration', desc: '', args: []);
  }

  /// `Budget`
  String get budget {
    return Intl.message('Budget', name: 'budget', desc: '', args: []);
  }

  /// `Cost`
  String get cost {
    return Intl.message('Cost', name: 'cost', desc: '', args: []);
  }

  /// `Unbox`
  String get unbox {
    return Intl.message('Unbox', name: 'unbox', desc: '', args: []);
  }

  /// `Opening`
  String get opening {
    return Intl.message('Opening', name: 'opening', desc: '', args: []);
  }

  /// `Document`
  String get document {
    return Intl.message('Document', name: 'document', desc: '', args: []);
  }

  /// `Weight`
  String get weight {
    return Intl.message('Weight', name: 'weight', desc: '', args: []);
  }

  /// `Balance`
  String get balance {
    return Intl.message('Balance', name: 'balance', desc: '', args: []);
  }

  /// `Hour`
  String get hour {
    return Intl.message('Hour', name: 'hour', desc: '', args: []);
  }

  /// `Internet`
  String get internet {
    return Intl.message('Internet', name: 'internet', desc: '', args: []);
  }

  /// `Connection`
  String get connection {
    return Intl.message('Connection', name: 'connection', desc: '', args: []);
  }

  /// `Origin`
  String get origin {
    return Intl.message('Origin', name: 'origin', desc: '', args: []);
  }

  /// `Resource`
  String get resource {
    return Intl.message('Resource', name: 'resource', desc: '', args: []);
  }

  /// `Place`
  String get place {
    return Intl.message('Place', name: 'place', desc: '', args: []);
  }

  /// `Position`
  String get position {
    return Intl.message('Position', name: 'position', desc: '', args: []);
  }

  /// `Alert`
  String get alert {
    return Intl.message('Alert', name: 'alert', desc: '', args: []);
  }

  /// `Caution`
  String get caution {
    return Intl.message('Caution', name: 'caution', desc: '', args: []);
  }

  /// `Company`
  String get company {
    return Intl.message('Company', name: 'company', desc: '', args: []);
  }

  /// `Enterprise`
  String get enterprise {
    return Intl.message('Enterprise', name: 'enterprise', desc: '', args: []);
  }

  /// `Data Center`
  String get dataCenter {
    return Intl.message('Data Center', name: 'dataCenter', desc: '', args: []);
  }

  /// `Computer`
  String get computer {
    return Intl.message('Computer', name: 'computer', desc: '', args: []);
  }

  /// `Connectivity`
  String get connectivity {
    return Intl.message(
      'Connectivity',
      name: 'connectivity',
      desc: '',
      args: [],
    );
  }

  /// `Bug`
  String get bug {
    return Intl.message('Bug', name: 'bug', desc: '', args: []);
  }

  /// `Pest`
  String get pest {
    return Intl.message('Pest', name: 'pest', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Bulb`
  String get bulb {
    return Intl.message('Bulb', name: 'bulb', desc: '', args: []);
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Direction`
  String get direction {
    return Intl.message('Direction', name: 'direction', desc: '', args: []);
  }

  /// `Secure Input`
  String get secureInput {
    return Intl.message(
      'Secure Input',
      name: 'secureInput',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get cash {
    return Intl.message('Cash', name: 'cash', desc: '', args: []);
  }

  /// `Watch`
  String get watch {
    return Intl.message('Watch', name: 'watch', desc: '', args: []);
  }

  /// `Savings`
  String get savings {
    return Intl.message('Savings', name: 'savings', desc: '', args: []);
  }

  /// `Finance`
  String get finance {
    return Intl.message('Finance', name: 'finance', desc: '', args: []);
  }

  /// `Wealth`
  String get wealth {
    return Intl.message('Wealth', name: 'wealth', desc: '', args: []);
  }

  /// `Baby`
  String get baby {
    return Intl.message('Baby', name: 'baby', desc: '', args: []);
  }

  /// `Cone`
  String get cone {
    return Intl.message('Cone', name: 'cone', desc: '', args: []);
  }

  /// `No Icon`
  String get noIcon {
    return Intl.message('No Icon', name: 'noIcon', desc: '', args: []);
  }

  /// `Pan`
  String get pan {
    return Intl.message('Pan', name: 'pan', desc: '', args: []);
  }

  /// `Santa Claus`
  String get santaClaus {
    return Intl.message('Santa Claus', name: 'santaClaus', desc: '', args: []);
  }

  /// `Small`
  String get small {
    return Intl.message('Small', name: 'small', desc: '', args: []);
  }

  /// `Vegetables`
  String get vegetables {
    return Intl.message('Vegetables', name: 'vegetables', desc: '', args: []);
  }

  /// `Love`
  String get love {
    return Intl.message('Love', name: 'love', desc: '', args: []);
  }

  /// `Romantic`
  String get romantic {
    return Intl.message('Romantic', name: 'romantic', desc: '', args: []);
  }

  /// `HostHub`
  String get appName {
    return Intl.message('HostHub', name: 'appName', desc: '', args: []);
  }

  /// `Stacktrace`
  String get stacktraceHeader {
    return Intl.message(
      'Stacktrace',
      name: 'stacktraceHeader',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message('Copied', name: 'copied', desc: '', args: []);
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `Show details`
  String get showErrorDetails {
    return Intl.message(
      'Show details',
      name: 'showErrorDetails',
      desc: '',
      args: [],
    );
  }

  /// `Hide details`
  String get hideErrorDetails {
    return Intl.message(
      'Hide details',
      name: 'hideErrorDetails',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get errorTitle {
    return Intl.message('Error', name: 'errorTitle', desc: '', args: []);
  }

  /// `Alert`
  String get clipboardAlert {
    return Intl.message('Alert', name: 'clipboardAlert', desc: '', args: []);
  }

  /// `Details`
  String get clipboardDetails {
    return Intl.message(
      'Details',
      name: 'clipboardDetails',
      desc: '',
      args: [],
    );
  }

  /// `Can’t load data because Supabase couldn’t find the "{table}" table. Deploy the latest database migrations and refresh the schema cache.`
  String supabaseTableMissing(String table) {
    return Intl.message(
      'Can’t load data because Supabase couldn’t find the "$table" table. Deploy the latest database migrations and refresh the schema cache.',
      name: 'supabaseTableMissing',
      desc: '',
      args: [table],
    );
  }

  /// `Error`
  String get clipboardError {
    return Intl.message('Error', name: 'clipboardError', desc: '', args: []);
  }

  /// `Code`
  String get clipboardCode {
    return Intl.message('Code', name: 'clipboardCode', desc: '', args: []);
  }

  /// `Time`
  String get clipboardTime {
    return Intl.message('Time', name: 'clipboardTime', desc: '', args: []);
  }

  /// `Context`
  String get clipboardContext {
    return Intl.message(
      'Context',
      name: 'clipboardContext',
      desc: '',
      args: [],
    );
  }

  /// `Changes will be lost`
  String get changesWillBeLost {
    return Intl.message(
      'Changes will be lost',
      name: 'changesWillBeLost',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `An unknown error occurred.`
  String get anUnknownErrorOccurred {
    return Intl.message(
      'An unknown error occurred.',
      name: 'anUnknownErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `There was a problem connecting to the server.`
  String get networkError {
    return Intl.message(
      'There was a problem connecting to the server.',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get failed {
    return Intl.message('Failed', name: 'failed', desc: '', args: []);
  }

  /// `Unfortunately, there is a problem with the server. Please try again later.`
  String get errorTextServerError {
    return Intl.message(
      'Unfortunately, there is a problem with the server. Please try again later.',
      name: 'errorTextServerError',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't send the email. Please try again later.`
  String get errorEmailSendFailedGeneric {
    return Intl.message(
      'We couldn\'t send the email. Please try again later.',
      name: 'errorEmailSendFailedGeneric',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't send the confirmation email. Please try again later.`
  String get errorSignUpConfirmationEmailFailed {
    return Intl.message(
      'We couldn\'t send the confirmation email. Please try again later.',
      name: 'errorSignUpConfirmationEmailFailed',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't send the sign-in code email. Please try again later.`
  String get errorLoginOtpEmailFailed {
    return Intl.message(
      'We couldn\'t send the sign-in code email. Please try again later.',
      name: 'errorLoginOtpEmailFailed',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't send the password reset email. Please try again later.`
  String get errorPasswordResetEmailFailed {
    return Intl.message(
      'We couldn\'t send the password reset email. Please try again later.',
      name: 'errorPasswordResetEmailFailed',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't send the welcome email. Please try again later.`
  String get errorUserCreatedEmailFailed {
    return Intl.message(
      'We couldn\'t send the welcome email. Please try again later.',
      name: 'errorUserCreatedEmailFailed',
      desc: '',
      args: [],
    );
  }

  /// `Try again later`
  String get tryAgainLater {
    return Intl.message(
      'Try again later',
      name: 'tryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Cannot add list.`
  String get cannotAddList {
    return Intl.message(
      'Cannot add list.',
      name: 'cannotAddList',
      desc: '',
      args: [],
    );
  }

  /// `Cannot delete all user data.`
  String get cannotDeleteAllUserData {
    return Intl.message(
      'Cannot delete all user data.',
      name: 'cannotDeleteAllUserData',
      desc: '',
      args: [],
    );
  }

  /// `We can't complete this action because the configuration is invalid. Check the settings and try again.`
  String get configurationInvalid {
    return Intl.message(
      'We can\'t complete this action because the configuration is invalid. Check the settings and try again.',
      name: 'configurationInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Field is linked to field of type '{fieldType}'`
  String fieldIsLinkedTo(String fieldType) {
    return Intl.message(
      'Field is linked to field of type \'$fieldType\'',
      name: 'fieldIsLinkedTo',
      desc: '',
      args: [fieldType],
    );
  }

  /// `Cannot delete field`
  String get cannotDeleteField {
    return Intl.message(
      'Cannot delete field',
      name: 'cannotDeleteField',
      desc: '',
      args: [],
    );
  }

  /// `Cannot load data from link`
  String get cannotLoadLinkData {
    return Intl.message(
      'Cannot load data from link',
      name: 'cannotLoadLinkData',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load user data. Please contact support.`
  String get failedToLoadUser {
    return Intl.message(
      'Unable to load user data. Please contact support.',
      name: 'failedToLoadUser',
      desc: '',
      args: [],
    );
  }

  /// `Cannot open link`
  String get cannotOpenLink {
    return Intl.message(
      'Cannot open link',
      name: 'cannotOpenLink',
      desc: '',
      args: [],
    );
  }

  /// `Location not found`
  String get locationNotFoundAlertTitle {
    return Intl.message(
      'Location not found',
      name: 'locationNotFoundAlertTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please check the address to enable automatic distance calculation, or enter the distance manually.`
  String get locationNotFoundAlertMessage {
    return Intl.message(
      'Please check the address to enable automatic distance calculation, or enter the distance manually.',
      name: 'locationNotFoundAlertMessage',
      desc: '',
      args: [],
    );
  }

  /// `Data could not be fetched`
  String get errorTextDataFetchFailed {
    return Intl.message(
      'Data could not be fetched',
      name: 'errorTextDataFetchFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete image.`
  String get failedToDeleteImage {
    return Intl.message(
      'Failed to delete image.',
      name: 'failedToDeleteImage',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your email.`
  String get emailNotConfirmed {
    return Intl.message(
      'Please confirm your email.',
      name: 'emailNotConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Error saving item.`
  String get errorSavingItem {
    return Intl.message(
      'Error saving item.',
      name: 'errorSavingItem',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload image.`
  String get failedToUploadImage {
    return Intl.message(
      'Failed to upload image.',
      name: 'failedToUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get loginFailed {
    return Intl.message(
      'Login failed',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect username or password.`
  String get errorTextIncorrectUsernameOrPassword {
    return Intl.message(
      'Incorrect username or password.',
      name: 'errorTextIncorrectUsernameOrPassword',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address format.`
  String get errorTextInvalidEmailFormat {
    return Intl.message(
      'Invalid email address format.',
      name: 'errorTextInvalidEmailFormat',
      desc: '',
      args: [],
    );
  }

  /// `Invalid URL`
  String get invalidUrl {
    return Intl.message('Invalid URL', name: 'invalidUrl', desc: '', args: []);
  }

  /// `Invalid verification code provided, please try again.`
  String get errorTextInvalidVerificationCode {
    return Intl.message(
      'Invalid verification code provided, please try again.',
      name: 'errorTextInvalidVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `A password must contain minimal 6 characters`
  String get passwordConsistOfMin6Characters {
    return Intl.message(
      'A password must contain minimal 6 characters',
      name: 'passwordConsistOfMin6Characters',
      desc: '',
      args: [],
    );
  }

  /// `Too many attempts`
  String get tooManyAttempts {
    return Intl.message(
      'Too many attempts',
      name: 'tooManyAttempts',
      desc: '',
      args: [],
    );
  }

  /// `There is already a user with this email address.`
  String get errorTextUsernameExists {
    return Intl.message(
      'There is already a user with this email address.',
      name: 'errorTextUsernameExists',
      desc: '',
      args: [],
    );
  }

  /// `Content documents`
  String get contentDocumentsTitle {
    return Intl.message(
      'Content documents',
      name: 'contentDocumentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Each page, locale, and version is stored as a JSON document.`
  String get contentDocumentsDescription {
    return Intl.message(
      'Each page, locale, and version is stored as a JSON document.',
      name: 'contentDocumentsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load content documents: {error}`
  String contentDocumentsLoadFailed(String error) {
    return Intl.message(
      'Failed to load content documents: $error',
      name: 'contentDocumentsLoadFailed',
      desc: '',
      args: [error],
    );
  }

  /// `No documents found.`
  String get contentDocumentsEmpty {
    return Intl.message(
      'No documents found.',
      name: 'contentDocumentsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{slug} (v{version})`
  String contentDocumentsVersionLabel(String slug, String version) {
    return Intl.message(
      '$slug (v$version)',
      name: 'contentDocumentsVersionLabel',
      desc: '',
      args: [slug, version],
    );
  }

  /// `{status} • updated {updatedAt}`
  String contentDocumentsUpdated(String status, String updatedAt) {
    return Intl.message(
      '$status • updated $updatedAt',
      name: 'contentDocumentsUpdated',
      desc: '',
      args: [status, updatedAt],
    );
  }

  /// `Published {publishedAt}`
  String contentDocumentsPublished(String publishedAt) {
    return Intl.message(
      'Published $publishedAt',
      name: 'contentDocumentsPublished',
      desc: '',
      args: [publishedAt],
    );
  }

  /// `Connect Lodgify to import your properties.`
  String get propertySetupConnectDescription {
    return Intl.message(
      'Connect Lodgify to import your properties.',
      name: 'propertySetupConnectDescription',
      desc: '',
      args: [],
    );
  }

  /// `Connect Lodgify`
  String get propertySetupConnectTitle {
    return Intl.message(
      'Connect Lodgify',
      name: 'propertySetupConnectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Go to Settings to add your Lodgify API key and connect your account.`
  String get propertySetupConnectBody {
    return Intl.message(
      'Go to Settings to add your Lodgify API key and connect your account.',
      name: 'propertySetupConnectBody',
      desc: '',
      args: [],
    );
  }

  /// `Go to Settings`
  String get propertySetupGoToSettings {
    return Intl.message(
      'Go to Settings',
      name: 'propertySetupGoToSettings',
      desc: '',
      args: [],
    );
  }

  /// `Sync your properties from Lodgify.`
  String get propertySetupSyncDescription {
    return Intl.message(
      'Sync your properties from Lodgify.',
      name: 'propertySetupSyncDescription',
      desc: '',
      args: [],
    );
  }

  /// `Sync properties`
  String get propertySetupSyncTitle {
    return Intl.message(
      'Sync properties',
      name: 'propertySetupSyncTitle',
      desc: '',
      args: [],
    );
  }

  /// `Lodgify is connected. Sync your properties from Lodgify to get started.`
  String get propertySetupSyncBody {
    return Intl.message(
      'Lodgify is connected. Sync your properties from Lodgify to get started.',
      name: 'propertySetupSyncBody',
      desc: '',
      args: [],
    );
  }

  /// `To change the property name, update it in Lodgify and sync.`
  String get propertyNameLodgifyHint {
    return Intl.message(
      'To change the property name, update it in Lodgify and sync.',
      name: 'propertyNameLodgifyHint',
      desc: '',
      args: [],
    );
  }

  /// `Property website`
  String get sitesTitle {
    return Intl.message(
      'Property website',
      name: 'sitesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Each website is scoped to a workspace with locales and domains.`
  String get sitesDescription {
    return Intl.message(
      'Each website is scoped to a workspace with locales and domains.',
      name: 'sitesDescription',
      desc: '',
      args: [],
    );
  }

  /// `New site entry`
  String get sitesNewEntryTitle {
    return Intl.message(
      'New site entry',
      name: 'sitesNewEntryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Site name`
  String get sitesNameLabel {
    return Intl.message(
      'Site name',
      name: 'sitesNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Trysil Panorama`
  String get sitesNameHint {
    return Intl.message(
      'Trysil Panorama',
      name: 'sitesNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Default locale`
  String get sitesDefaultLocaleLabel {
    return Intl.message(
      'Default locale',
      name: 'sitesDefaultLocaleLabel',
      desc: '',
      args: [],
    );
  }

  /// `en`
  String get sitesDefaultLocaleHint {
    return Intl.message(
      'en',
      name: 'sitesDefaultLocaleHint',
      desc: '',
      args: [],
    );
  }

  /// `Create site`
  String get sitesCreateButton {
    return Intl.message(
      'Create site',
      name: 'sitesCreateButton',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load sites: {error}`
  String sitesLoadFailed(String error) {
    return Intl.message(
      'Failed to load sites: $error',
      name: 'sitesLoadFailed',
      desc: '',
      args: [error],
    );
  }

  /// `No sites configured yet.`
  String get sitesEmpty {
    return Intl.message(
      'No sites configured yet.',
      name: 'sitesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Locale: {defaultLocale} • Locales: {locales}`
  String sitesLocaleSummary(String defaultLocale, String locales) {
    return Intl.message(
      'Locale: $defaultLocale • Locales: $locales',
      name: 'sitesLocaleSummary',
      desc: '',
      args: [defaultLocale, locales],
    );
  }

  /// `Light mode`
  String get lightMode {
    return Intl.message('Light mode', name: 'lightMode', desc: '', args: []);
  }

  /// `Dark mode`
  String get darkMode {
    return Intl.message('Dark mode', name: 'darkMode', desc: '', args: []);
  }

  /// `System setting`
  String get systemSetting {
    return Intl.message(
      'System setting',
      name: 'systemSetting',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get login {
    return Intl.message('Log in', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Log in with Google`
  String get loginWithGoogle {
    return Intl.message(
      'Log in with Google',
      name: 'loginWithGoogle',
      desc: 'Button label for logging in with Google.',
      args: [],
    );
  }

  /// `Register with Google`
  String get registerWithGoogle {
    return Intl.message(
      'Register with Google',
      name: 'registerWithGoogle',
      desc: 'Button label for registering with Google.',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `This is a required field`
  String get requiredField {
    return Intl.message(
      'This is a required field',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email`
  String get enterValidEmail {
    return Intl.message(
      'Enter a valid email',
      name: 'enterValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter minimal 6 characters`
  String get enterMin6Characters {
    return Intl.message(
      'Enter minimal 6 characters',
      name: 'enterMin6Characters',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message('Welcome', name: 'welcome', desc: '', args: []);
  }

  /// `Welcome`
  String get authWelcome {
    return Intl.message('Welcome', name: 'authWelcome', desc: '', args: []);
  }

  /// `Reset password`
  String get resetPassword {
    return Intl.message(
      'Reset password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Send reset link`
  String get sendResetLink {
    return Intl.message(
      'Send reset link',
      name: 'sendResetLink',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get enterAValidEmail {
    return Intl.message(
      'Enter a valid email address',
      name: 'enterAValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Verification code`
  String get verificationCode {
    return Intl.message(
      'Verification code',
      name: 'verificationCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid code`
  String get enterAValidCode {
    return Intl.message(
      'Enter a valid code',
      name: 'enterAValidCode',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get newPassword {
    return Intl.message(
      'New password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `At least {count} characters`
  String enterMinCharacters(int count) {
    return Intl.message(
      'At least $count characters',
      name: 'enterMinCharacters',
      desc: '',
      args: [count],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Enter the verification code sent to your email and choose a new password.`
  String get resetPasswordInstructions {
    return Intl.message(
      'Enter the verification code sent to your email and choose a new password.',
      name: 'resetPasswordInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Back to login`
  String get backToLogin {
    return Intl.message(
      'Back to login',
      name: 'backToLogin',
      desc: '',
      args: [],
    );
  }

  /// `Password updated`
  String get passwordUpdated {
    return Intl.message(
      'Password updated',
      name: 'passwordUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Resend code`
  String get resendCode {
    return Intl.message('Resend code', name: 'resendCode', desc: '', args: []);
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `Set password`
  String get setPasswordTitle {
    return Intl.message(
      'Set password',
      name: 'setPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Welcome! Set a password to activate your account.`
  String get setPasswordSubtitle {
    return Intl.message(
      'Welcome! Set a password to activate your account.',
      name: 'setPasswordSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `The reset link has expired. Request a new one.`
  String get resetPasswordLinkExpired {
    return Intl.message(
      'The reset link has expired. Request a new one.',
      name: 'resetPasswordLinkExpired',
      desc: '',
      args: [],
    );
  }

  /// `Request new reset email`
  String get requestNewPasswordEmail {
    return Intl.message(
      'Request new reset email',
      name: 'requestNewPasswordEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter verification code`
  String get enterVerificationCode {
    return Intl.message(
      'Enter verification code',
      name: 'enterVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent to {email}`
  String verificationCodeSentText(String email) {
    return Intl.message(
      'Verification code sent to $email',
      name: 'verificationCodeSentText',
      desc: '',
      args: [email],
    );
  }

  /// `No account yet?`
  String get noAccountYet {
    return Intl.message(
      'No account yet?',
      name: 'noAccountYet',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Resend available in {seconds} s`
  String resendAvailableIn(int seconds) {
    return Intl.message(
      'Resend available in $seconds s',
      name: 'resendAvailableIn',
      desc: '',
      args: [seconds],
    );
  }

  /// `Sign in with magic link`
  String get signInWithMagicLink {
    return Intl.message(
      'Sign in with magic link',
      name: 'signInWithMagicLink',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email and we'll send you a magic link to sign in.`
  String get magicLinkSubtitle {
    return Intl.message(
      'Enter your email and we\'ll send you a magic link to sign in.',
      name: 'magicLinkSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Send magic link`
  String get sendMagicLink {
    return Intl.message(
      'Send magic link',
      name: 'sendMagicLink',
      desc: '',
      args: [],
    );
  }

  /// `Check your email`
  String get magicLinkSentTitle {
    return Intl.message(
      'Check your email',
      name: 'magicLinkSentTitle',
      desc: '',
      args: [],
    );
  }

  /// `We sent a magic link to {email}. Check your inbox and spam folder.`
  String magicLinkSentDescription(String email) {
    return Intl.message(
      'We sent a magic link to $email. Check your inbox and spam folder.',
      name: 'magicLinkSentDescription',
      desc: '',
      args: [email],
    );
  }

  /// `We sent a magic link. Check your inbox and spam folder.`
  String get magicLinkSentDescriptionFallback {
    return Intl.message(
      'We sent a magic link. Check your inbox and spam folder.',
      name: 'magicLinkSentDescriptionFallback',
      desc: '',
      args: [],
    );
  }

  /// `Prefer signing in with a password?`
  String get preferPasswordSignIn {
    return Intl.message(
      'Prefer signing in with a password?',
      name: 'preferPasswordSignIn',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get orDivider {
    return Intl.message('or', name: 'orDivider', desc: '', args: []);
  }

  /// `Error`
  String get errorDialogTitle {
    return Intl.message('Error', name: 'errorDialogTitle', desc: '', args: []);
  }

  /// `Dismiss`
  String get errorDialogDismiss {
    return Intl.message(
      'Dismiss',
      name: 'errorDialogDismiss',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect email or password.`
  String get errorInvalidCredentials {
    return Intl.message(
      'Incorrect email or password.',
      name: 'errorInvalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Your email address is not confirmed yet.`
  String get errorEmailNotConfirmed {
    return Intl.message(
      'Your email address is not confirmed yet.',
      name: 'errorEmailNotConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Too many attempts. Please try again later.`
  String get errorRateLimited {
    return Intl.message(
      'Too many attempts. Please try again later.',
      name: 'errorRateLimited',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get errorGeneric {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'errorGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dontHaveAnAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Already an account?`
  String get alreadyAnAccount {
    return Intl.message(
      'Already an account?',
      name: 'alreadyAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign up failed`
  String get signUpFailed {
    return Intl.message(
      'Sign up failed',
      name: 'signUpFailed',
      desc: '',
      args: [],
    );
  }

  /// `Oops, a problem occorred. We are working on it.`
  String get oopsAproblemOccured {
    return Intl.message(
      'Oops, a problem occorred. We are working on it.',
      name: 'oopsAproblemOccured',
      desc: '',
      args: [],
    );
  }

  /// `Lodgify status`
  String get propertyLodgifyStatus {
    return Intl.message(
      'Lodgify status',
      name: 'propertyLodgifyStatus',
      desc: '',
      args: [],
    );
  }

  /// `Linked`
  String get propertyLodgifyLinked {
    return Intl.message(
      'Linked',
      name: 'propertyLodgifyLinked',
      desc: '',
      args: [],
    );
  }

  /// `Not linked`
  String get propertyLodgifyNotLinked {
    return Intl.message(
      'Not linked',
      name: 'propertyLodgifyNotLinked',
      desc: '',
      args: [],
    );
  }

  /// `Last sync`
  String get propertyLastSync {
    return Intl.message(
      'Last sync',
      name: 'propertyLastSync',
      desc: '',
      args: [],
    );
  }

  /// `Create manually`
  String get propertySetupManualTitle {
    return Intl.message(
      'Create manually',
      name: 'propertySetupManualTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add a property without Lodgify connection.`
  String get propertySetupManualBody {
    return Intl.message(
      'Add a property without Lodgify connection.',
      name: 'propertySetupManualBody',
      desc: '',
      args: [],
    );
  }

  /// `Create property`
  String get propertySetupManualButton {
    return Intl.message(
      'Create property',
      name: 'propertySetupManualButton',
      desc: '',
      args: [],
    );
  }

  /// `Property name`
  String get propertySetupManualNameLabel {
    return Intl.message(
      'Property name',
      name: 'propertySetupManualNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter a property name.`
  String get propertySetupManualNameRequired {
    return Intl.message(
      'Enter a property name.',
      name: 'propertySetupManualNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get propertySetupOrDivider {
    return Intl.message(
      'or',
      name: 'propertySetupOrDivider',
      desc: '',
      args: [],
    );
  }

  /// `Per-property channel pricing settings.`
  String get pricingDescription {
    return Intl.message(
      'Per-property channel pricing settings.',
      name: 'pricingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Channel settings`
  String get pricingChannelSettingsHeader {
    return Intl.message(
      'Channel settings',
      name: 'pricingChannelSettingsHeader',
      desc: '',
      args: [],
    );
  }

  /// `All amounts in`
  String get pricingCurrencyNote {
    return Intl.message(
      'All amounts in',
      name: 'pricingCurrencyNote',
      desc: '',
      args: [],
    );
  }

  /// `Commission: empty = default.`
  String get pricingCommissionNote {
    return Intl.message(
      'Commission: empty = default.',
      name: 'pricingCommissionNote',
      desc: '',
      args: [],
    );
  }

  /// `Commission override`
  String get pricingCommissionOverride {
    return Intl.message(
      'Commission override',
      name: 'pricingCommissionOverride',
      desc: '',
      args: [],
    );
  }

  /// `Empty = default`
  String get pricingCommissionDefault {
    return Intl.message(
      'Empty = default',
      name: 'pricingCommissionDefault',
      desc: '',
      args: [],
    );
  }

  /// `Rate markup on base price`
  String get pricingRateMarkup {
    return Intl.message(
      'Rate markup on base price',
      name: 'pricingRateMarkup',
      desc: '',
      args: [],
    );
  }

  /// `Markup % applied on this channel.`
  String get pricingRateMarkupDescription {
    return Intl.message(
      'Markup % applied on this channel.',
      name: 'pricingRateMarkupDescription',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning costs`
  String get pricingCleaningCost {
    return Intl.message(
      'Cleaning costs',
      name: 'pricingCleaningCost',
      desc: '',
      args: [],
    );
  }

  /// `Linen costs`
  String get pricingLinenCost {
    return Intl.message(
      'Linen costs',
      name: 'pricingLinenCost',
      desc: '',
      args: [],
    );
  }

  /// `Service costs`
  String get pricingServiceCost {
    return Intl.message(
      'Service costs',
      name: 'pricingServiceCost',
      desc: '',
      args: [],
    );
  }

  /// `Other costs`
  String get pricingOtherCost {
    return Intl.message(
      'Other costs',
      name: 'pricingOtherCost',
      desc: '',
      args: [],
    );
  }

  /// `Pricing settings saved.`
  String get pricingSaved {
    return Intl.message(
      'Pricing settings saved.',
      name: 'pricingSaved',
      desc: '',
      args: [],
    );
  }

  /// `Pricing`
  String get menuPricing {
    return Intl.message('Pricing', name: 'menuPricing', desc: '', args: []);
  }

  /// `Revenue`
  String get menuRevenue {
    return Intl.message('Revenue', name: 'menuRevenue', desc: '', args: []);
  }

  /// `Channel fee defaults (%)`
  String get channelFeeDefaultsHeader {
    return Intl.message(
      'Channel fee defaults (%)',
      name: 'channelFeeDefaultsHeader',
      desc: '',
      args: [],
    );
  }

  /// `Default commission percentages used when no override is set per property.`
  String get channelFeeDefaultsDescription {
    return Intl.message(
      'Default commission percentages used when no override is set per property.',
      name: 'channelFeeDefaultsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Website Content`
  String get cmsContentTitle {
    return Intl.message(
      'Website Content',
      name: 'cmsContentTitle',
      desc: '',
      args: [],
    );
  }

  /// `View and manage all website content for this site.`
  String get cmsContentDescription {
    return Intl.message(
      'View and manage all website content for this site.',
      name: 'cmsContentDescription',
      desc: '',
      args: [],
    );
  }

  /// `Site Configuration`
  String get cmsSiteConfigSection {
    return Intl.message(
      'Site Configuration',
      name: 'cmsSiteConfigSection',
      desc: '',
      args: [],
    );
  }

  /// `Cabin Details`
  String get cmsCabinSection {
    return Intl.message(
      'Cabin Details',
      name: 'cmsCabinSection',
      desc: '',
      args: [],
    );
  }

  /// `Home Page`
  String get cmsHomePageSection {
    return Intl.message(
      'Home Page',
      name: 'cmsHomePageSection',
      desc: '',
      args: [],
    );
  }

  /// `Practical Info`
  String get cmsPracticalPageSection {
    return Intl.message(
      'Practical Info',
      name: 'cmsPracticalPageSection',
      desc: '',
      args: [],
    );
  }

  /// `Area & Activities`
  String get cmsAreaPageSection {
    return Intl.message(
      'Area & Activities',
      name: 'cmsAreaPageSection',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get cmsPrivacyPageSection {
    return Intl.message(
      'Privacy Policy',
      name: 'cmsPrivacyPageSection',
      desc: '',
      args: [],
    );
  }

  /// `Contact Form`
  String get cmsContactFormSection {
    return Intl.message(
      'Contact Form',
      name: 'cmsContactFormSection',
      desc: '',
      args: [],
    );
  }

  /// `Preview Website`
  String get cmsPreviewButton {
    return Intl.message(
      'Preview Website',
      name: 'cmsPreviewButton',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get cmsPublishButton {
    return Intl.message(
      'Publish',
      name: 'cmsPublishButton',
      desc: '',
      args: [],
    );
  }

  /// `Draft`
  String get cmsStatusDraft {
    return Intl.message('Draft', name: 'cmsStatusDraft', desc: '', args: []);
  }

  /// `Published`
  String get cmsStatusPublished {
    return Intl.message(
      'Published',
      name: 'cmsStatusPublished',
      desc: '',
      args: [],
    );
  }

  /// `No content documents found for this site.`
  String get cmsNoContent {
    return Intl.message(
      'No content documents found for this site.',
      name: 'cmsNoContent',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load content: {error}`
  String cmsLoadFailed(String error) {
    return Intl.message(
      'Failed to load content: $error',
      name: 'cmsLoadFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Back to sites`
  String get cmsBackToSites {
    return Intl.message(
      'Back to sites',
      name: 'cmsBackToSites',
      desc: '',
      args: [],
    );
  }

  /// `Save Draft`
  String get cmsSaveDraftButton {
    return Intl.message(
      'Save Draft',
      name: 'cmsSaveDraftButton',
      desc: '',
      args: [],
    );
  }

  /// `Draft saved.`
  String get cmsSaveDraftSuccess {
    return Intl.message(
      'Draft saved.',
      name: 'cmsSaveDraftSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Content published.`
  String get cmsPublishSuccess {
    return Intl.message(
      'Content published.',
      name: 'cmsPublishSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Publish content`
  String get cmsPublishConfirmTitle {
    return Intl.message(
      'Publish content',
      name: 'cmsPublishConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `This will make the current content live on the website. Continue?`
  String get cmsPublishConfirmBody {
    return Intl.message(
      'This will make the current content live on the website. Continue?',
      name: 'cmsPublishConfirmBody',
      desc: '',
      args: [],
    );
  }

  /// `Version History`
  String get cmsVersionHistory {
    return Intl.message(
      'Version History',
      name: 'cmsVersionHistory',
      desc: '',
      args: [],
    );
  }

  /// `Version {version}`
  String cmsVersionLabel(int version) {
    return Intl.message(
      'Version $version',
      name: 'cmsVersionLabel',
      desc: '',
      args: [version],
    );
  }

  /// `Published {date}`
  String cmsVersionDate(String date) {
    return Intl.message(
      'Published $date',
      name: 'cmsVersionDate',
      desc: '',
      args: [date],
    );
  }

  /// `Restore`
  String get cmsRestoreButton {
    return Intl.message(
      'Restore',
      name: 'cmsRestoreButton',
      desc: '',
      args: [],
    );
  }

  /// `Restore version`
  String get cmsRestoreConfirmTitle {
    return Intl.message(
      'Restore version',
      name: 'cmsRestoreConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Replace current content with version {version}? The restored content will be saved as a draft for review.`
  String cmsRestoreConfirmBody(int version) {
    return Intl.message(
      'Replace current content with version $version? The restored content will be saved as a draft for review.',
      name: 'cmsRestoreConfirmBody',
      desc: '',
      args: [version],
    );
  }

  /// `Version restored as draft.`
  String get cmsRestoreSuccess {
    return Intl.message(
      'Version restored as draft.',
      name: 'cmsRestoreSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No published versions yet.`
  String get cmsNoVersions {
    return Intl.message(
      'No published versions yet.',
      name: 'cmsNoVersions',
      desc: '',
      args: [],
    );
  }

  /// `Add item`
  String get cmsAddItem {
    return Intl.message('Add item', name: 'cmsAddItem', desc: '', args: []);
  }

  /// `Remove`
  String get cmsRemoveItem {
    return Intl.message('Remove', name: 'cmsRemoveItem', desc: '', args: []);
  }

  /// `Unsaved changes`
  String get cmsUnsavedChangesTitle {
    return Intl.message(
      'Unsaved changes',
      name: 'cmsUnsavedChangesTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have unsaved changes. What would you like to do?`
  String get cmsUnsavedChangesBody {
    return Intl.message(
      'You have unsaved changes. What would you like to do?',
      name: 'cmsUnsavedChangesBody',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get cmsDiscardButton {
    return Intl.message(
      'Discard',
      name: 'cmsDiscardButton',
      desc: '',
      args: [],
    );
  }

  /// `Revenue for {propertyName} from Lodgify bookings.`
  String revenueDescription(Object propertyName) {
    return Intl.message(
      'Revenue for $propertyName from Lodgify bookings.',
      name: 'revenueDescription',
      desc: '',
      args: [propertyName],
    );
  }

  /// `Unknown property`
  String get revenueUnknownProperty {
    return Intl.message(
      'Unknown property',
      name: 'revenueUnknownProperty',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get revenueRefreshTooltip {
    return Intl.message(
      'Refresh',
      name: 'revenueRefreshTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get revenuePeriodMonth {
    return Intl.message(
      'Month',
      name: 'revenuePeriodMonth',
      desc: '',
      args: [],
    );
  }

  /// `Quarter`
  String get revenuePeriodQuarter {
    return Intl.message(
      'Quarter',
      name: 'revenuePeriodQuarter',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get revenuePeriodYear {
    return Intl.message('Year', name: 'revenuePeriodYear', desc: '', args: []);
  }

  /// `Current period overview`
  String get revenueOverviewHeader {
    return Intl.message(
      'Current period overview',
      name: 'revenueOverviewHeader',
      desc: '',
      args: [],
    );
  }

  /// `Total bookings`
  String get revenueTotalBookings {
    return Intl.message(
      'Total bookings',
      name: 'revenueTotalBookings',
      desc: '',
      args: [],
    );
  }

  /// `Total revenue`
  String get revenueTotalRevenue {
    return Intl.message(
      'Total revenue',
      name: 'revenueTotalRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Fees`
  String get revenueFees {
    return Intl.message('Fees', name: 'revenueFees', desc: '', args: []);
  }

  /// `Service costs`
  String get revenueServiceCosts {
    return Intl.message(
      'Service costs',
      name: 'revenueServiceCosts',
      desc: '',
      args: [],
    );
  }

  /// `Net revenue`
  String get revenueNetRevenue {
    return Intl.message(
      'Net revenue',
      name: 'revenueNetRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Booker`
  String get revenueColumnBooker {
    return Intl.message(
      'Booker',
      name: 'revenueColumnBooker',
      desc: '',
      args: [],
    );
  }

  /// `Check-in`
  String get revenueColumnCheckIn {
    return Intl.message(
      'Check-in',
      name: 'revenueColumnCheckIn',
      desc: '',
      args: [],
    );
  }

  /// `Check-out`
  String get revenueColumnCheckOut {
    return Intl.message(
      'Check-out',
      name: 'revenueColumnCheckOut',
      desc: '',
      args: [],
    );
  }

  /// `Nights`
  String get revenueColumnNights {
    return Intl.message(
      'Nights',
      name: 'revenueColumnNights',
      desc: '',
      args: [],
    );
  }

  /// `Nightly\nrate`
  String get revenueColumnNightlyRate {
    return Intl.message(
      'Nightly\nrate',
      name: 'revenueColumnNightlyRate',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get revenueColumnTotal {
    return Intl.message(
      'Total',
      name: 'revenueColumnTotal',
      desc: '',
      args: [],
    );
  }

  /// `Fixed\ncosts`
  String get revenueColumnFixedCosts {
    return Intl.message(
      'Fixed\ncosts',
      name: 'revenueColumnFixedCosts',
      desc: '',
      args: [],
    );
  }

  /// `Channel\nfee`
  String get revenueColumnChannelFee {
    return Intl.message(
      'Channel\nfee',
      name: 'revenueColumnChannelFee',
      desc: '',
      args: [],
    );
  }

  /// `Net`
  String get revenueColumnNet {
    return Intl.message('Net', name: 'revenueColumnNet', desc: '', args: []);
  }

  /// `Link a Lodgify ID to this property to load revenue.`
  String get revenueNoLodgifyId {
    return Intl.message(
      'Link a Lodgify ID to this property to load revenue.',
      name: 'revenueNoLodgifyId',
      desc: '',
      args: [],
    );
  }

  /// `Revenue could not be loaded.`
  String get revenueLoadFailed {
    return Intl.message(
      'Revenue could not be loaded.',
      name: 'revenueLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Unknown booker`
  String get revenueUnknownBooker {
    return Intl.message(
      'Unknown booker',
      name: 'revenueUnknownBooker',
      desc: '',
      args: [],
    );
  }

  /// `Quarter {quarter} {year}`
  String revenueQuarterLabel(Object quarter, Object year) {
    return Intl.message(
      'Quarter $quarter $year',
      name: 'revenueQuarterLabel',
      desc: '',
      args: [quarter, year],
    );
  }

  /// `Booker`
  String get reservationSectionBooker {
    return Intl.message(
      'Booker',
      name: 'reservationSectionBooker',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get reservationName {
    return Intl.message('Name', name: 'reservationName', desc: '', args: []);
  }

  /// `Email`
  String get reservationEmail {
    return Intl.message('Email', name: 'reservationEmail', desc: '', args: []);
  }

  /// `Phone`
  String get reservationPhone {
    return Intl.message('Phone', name: 'reservationPhone', desc: '', args: []);
  }

  /// `Stay`
  String get reservationSectionStay {
    return Intl.message(
      'Stay',
      name: 'reservationSectionStay',
      desc: '',
      args: [],
    );
  }

  /// `Check-in`
  String get reservationCheckIn {
    return Intl.message(
      'Check-in',
      name: 'reservationCheckIn',
      desc: '',
      args: [],
    );
  }

  /// `Check-out`
  String get reservationCheckOut {
    return Intl.message(
      'Check-out',
      name: 'reservationCheckOut',
      desc: '',
      args: [],
    );
  }

  /// `Nights`
  String get reservationNights {
    return Intl.message(
      'Nights',
      name: 'reservationNights',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get reservationStatus {
    return Intl.message(
      'Status',
      name: 'reservationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get reservationSource {
    return Intl.message(
      'Source',
      name: 'reservationSource',
      desc: '',
      args: [],
    );
  }

  /// `Reservation ID`
  String get reservationId {
    return Intl.message(
      'Reservation ID',
      name: 'reservationId',
      desc: '',
      args: [],
    );
  }

  /// `Guests`
  String get reservationSectionGuests {
    return Intl.message(
      'Guests',
      name: 'reservationSectionGuests',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get reservationGuestTotal {
    return Intl.message(
      'Total',
      name: 'reservationGuestTotal',
      desc: '',
      args: [],
    );
  }

  /// `Adults`
  String get reservationAdults {
    return Intl.message(
      'Adults',
      name: 'reservationAdults',
      desc: '',
      args: [],
    );
  }

  /// `Children`
  String get reservationChildren {
    return Intl.message(
      'Children',
      name: 'reservationChildren',
      desc: '',
      args: [],
    );
  }

  /// `Infants`
  String get reservationInfants {
    return Intl.message(
      'Infants',
      name: 'reservationInfants',
      desc: '',
      args: [],
    );
  }

  /// `Revenue`
  String get reservationSectionRevenue {
    return Intl.message(
      'Revenue',
      name: 'reservationSectionRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Gross`
  String get reservationGross {
    return Intl.message('Gross', name: 'reservationGross', desc: '', args: []);
  }

  /// `Net`
  String get reservationNet {
    return Intl.message('Net', name: 'reservationNet', desc: '', args: []);
  }

  /// `Outstanding`
  String get reservationOutstanding {
    return Intl.message(
      'Outstanding',
      name: 'reservationOutstanding',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get reservationSectionOther {
    return Intl.message(
      'Other',
      name: 'reservationSectionOther',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get reservationNotes {
    return Intl.message('Notes', name: 'reservationNotes', desc: '', args: []);
  }

  /// `Created`
  String get reservationCreatedAt {
    return Intl.message(
      'Created',
      name: 'reservationCreatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Updated`
  String get reservationUpdatedAt {
    return Intl.message(
      'Updated',
      name: 'reservationUpdatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Full payload`
  String get reservationSectionPayload {
    return Intl.message(
      'Full payload',
      name: 'reservationSectionPayload',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get reservationCloseTooltip {
    return Intl.message(
      'Close',
      name: 'reservationCloseTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Rent / nightly rate`
  String get revenueBreakdownRent {
    return Intl.message(
      'Rent / nightly rate',
      name: 'revenueBreakdownRent',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning costs`
  String get revenueBreakdownCleaning {
    return Intl.message(
      'Cleaning costs',
      name: 'revenueBreakdownCleaning',
      desc: '',
      args: [],
    );
  }

  /// `Linen / bed linen`
  String get revenueBreakdownLinen {
    return Intl.message(
      'Linen / bed linen',
      name: 'revenueBreakdownLinen',
      desc: '',
      args: [],
    );
  }

  /// `Service costs`
  String get revenueBreakdownServiceCosts {
    return Intl.message(
      'Service costs',
      name: 'revenueBreakdownServiceCosts',
      desc: '',
      args: [],
    );
  }

  /// `Other fixed costs`
  String get revenueBreakdownOtherCosts {
    return Intl.message(
      'Other fixed costs',
      name: 'revenueBreakdownOtherCosts',
      desc: '',
      args: [],
    );
  }

  /// `Channel fee (Booking/Airbnb)`
  String get revenueBreakdownChannelFee {
    return Intl.message(
      'Channel fee (Booking/Airbnb)',
      name: 'revenueBreakdownChannelFee',
      desc: '',
      args: [],
    );
  }

  /// `Tax / VAT`
  String get revenueBreakdownTax {
    return Intl.message(
      'Tax / VAT',
      name: 'revenueBreakdownTax',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'nl'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
