import 'package:flutter/widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../domain/website_content.dart';

/// Localized display name for a language code (falls back to the code).
String languageName(BuildContext context, String code) {
  final s = context.s;
  switch (code) {
    case 'nl':
      return s.weLangDutch;
    case 'en':
      return s.weLangEnglish;
    case 'no':
      return s.weLangNorwegian;
    default:
      return code.toUpperCase();
  }
}

/// Short uppercase tag for a language code (NL / EN / NO).
String languageShort(String code) =>
    WebsiteSeed.languageShort[code] ?? code.toUpperCase();

/// Localized field label for an editor field key.
String fieldLabel(BuildContext context, String fieldKey) {
  final s = context.s;
  switch (fieldKey) {
    case 'hero.headline':
      return s.weFieldHeadline;
    case 'hero.subtitle':
    case 'practical.header.subtitle':
    case 'contact.subtitle':
      return s.weFieldSubtitle;
    case 'highlights.0':
      return s.weFieldHighlight(1);
    case 'highlights.1':
      return s.weFieldHighlight(2);
    case 'chalet.description.0':
    case 'area.intro':
      return s.weFieldIntro;
    case 'chalet.experience.0':
      return s.weFieldExperience(1);
    case 'chalet.experience.1':
      return s.weFieldExperience(2);
    case 'practical.header.title':
    case 'contact.title':
      return s.weFieldTitle;
    default:
      return fieldKey;
  }
}

/// Localized page name for a page key.
String pageName(BuildContext context, String pageKey) {
  final s = context.s;
  switch (pageKey) {
    case 'home':
      return s.wePageHome;
    case 'chalet':
      return s.wePageChalet;
    case 'practical':
      return s.wePagePractical;
    case 'area':
      return s.wePageArea;
    case 'contact':
      return s.wePageContact;
    default:
      return pageKey;
  }
}
