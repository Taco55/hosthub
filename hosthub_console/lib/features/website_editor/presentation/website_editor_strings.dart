import 'package:flutter/widgets.dart';

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

/// Localized field label for an editor field key.
String fieldLabel(BuildContext context, String fieldKey) {
  final highlightMatch = RegExp(r'^highlights\.(\d+)$').firstMatch(fieldKey);
  if (highlightMatch != null) {
    return context.s.weFieldHighlight(int.parse(highlightMatch.group(1)!) + 1);
  }
  switch (fieldKey) {
    case 'hero.headline':
      return context.s.weFieldHeadline;
    case 'hero.subtitle':
    case 'practical.header.subtitle':
    case 'contact.subtitle':
      return context.s.weFieldSubtitle;
    // highlights.N is repeatable — handled generically below the switch.
    case 'chalet.description.0':
    case 'area.intro':
      return context.s.weFieldIntro;
    case 'chalet.experience.0':
      return context.s.weFieldExperience(1);
    case 'chalet.experience.1':
      return context.s.weFieldExperience(2);
    case 'practical.header.title':
    case 'contact.title':
      return context.s.weFieldTitle;
    default:
      return fieldKey;
  }
}

/// Localized page name for a page key.
String pageName(BuildContext context, String pageKey) {
  switch (pageKey) {
    case 'home':
      return context.s.wePageHome;
    case 'chalet':
      return context.s.wePageChalet;
    case 'practical':
      return context.s.wePagePractical;
    case 'area':
      return context.s.wePageArea;
    case 'contact':
      return context.s.wePageContact;
    default:
      return pageKey;
  }
}
