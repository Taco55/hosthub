import 'package:flutter/material.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../domain/website_content.dart';

/// Localized display name for a language code (falls back to the code).
String languageName(BuildContext context, String code) {
  switch (code) {
    case 'nl':
      return context.s.weLangDutch;
    case 'en':
      return context.s.weLangEnglish;
    case 'no':
      return context.s.weLangNorwegian;
    default:
      return code.toUpperCase();
  }
}

/// Short uppercase tag for a language code (NL / EN / NO).
String languageShort(String code) =>
    WebsiteSeed.languageShort[code] ?? code.toUpperCase();

/// Localized field label for a plain (non-list) editor field key.
String fieldLabel(BuildContext context, String fieldKey) {
  switch (fieldKey) {
    case 'cabin.hero.title':
      return context.s.weFieldHeadline;
    case 'cabin.hero.subtitle':
    case 'practical.header.subtitle':
    case 'contact.subtitle':
      return context.s.weFieldSubtitle;
    case 'area.intro':
      return context.s.weFieldIntro;
    case 'practical.header.title':
    case 'contact.title':
      return context.s.weFieldTitle;
    default:
      return fieldKey;
  }
}

/// Localized label for row [number] (1-based) of a repeatable list. Rows are
/// numbered by display position — their id is identity, not a name.
String listRowLabel(BuildContext context, String listKey, int number) {
  switch (listKey) {
    case 'home.highlights':
      return context.s.weFieldHighlight(number);
    case 'cabin.description':
      return context.s.weFieldIntro;
    case 'cabin.experience':
      return context.s.weFieldExperience(number);
    default:
      return '$listKey $number';
  }
}

/// Localized page name for a page key.
String pageName(BuildContext context, String pageKey) {
  switch (pageKey) {
    case 'home':
      return context.s.wePageHome;
    case 'practical':
      return context.s.wePagePractical;
    case 'area':
      return context.s.wePageArea;
    case 'gallery':
      return context.s.wePageGallery;
    default:
      return pageKey;
  }
}

/// Localized card title for a schema card id.
String cardTitle(BuildContext context, String cardId) {
  switch (cardId) {
    case 'hero':
      return context.s.weCardHero;
    case 'highlights':
      return context.s.weCardHighlights;
    case 'contact':
      return context.s.weCardContact;
    default:
      return context.s.weCardContent;
  }
}

/// Icon for a schema card id.
IconData cardIcon(String cardId) {
  switch (cardId) {
    case 'hero':
      return Icons.auto_awesome;
    case 'highlights':
      return Icons.star_outline;
    case 'contact':
      return Icons.mail_outline;
    default:
      return Icons.notes_outlined;
  }
}
