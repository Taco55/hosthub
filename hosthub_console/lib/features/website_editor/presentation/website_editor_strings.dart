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
    case kLegalPage:
      return context.s.wePageLegal;
    default:
      return pageKey;
  }
}

/// Localized title of a media slot — the picker's own heading.
String mediaTitle(BuildContext context, String mediaKey) {
  switch (mediaKey) {
    case 'images.heroPhotos':
      return context.s.weMediaTitleHero;
    case 'images.homeGallery':
      return context.s.weMediaTitleHomeGallery;
    case 'images.galleryAll':
      return context.s.weMediaTitleGallery;
    default:
      return context.s.weMediaTitleRowImage;
  }
}

/// Localized title of a schema card.
String cardTitle(BuildContext context, String cardId) {
  switch (cardId) {
    case 'privacy':
      return context.s.weCardPrivacy;
    case 'hero':
      return context.s.weCardHero;
    case 'keyFacts':
      return context.s.weCardKeyFacts;
    case 'description':
      return context.s.weCardDescription;
    case 'homeGallery':
      return context.s.weCardHomeGallery;
    case 'amenities':
      return context.s.weCardAmenities;
    case 'location':
      return context.s.weCardLocation;
    case 'highlights':
      return context.s.weCardHighlights;
    case 'houseRules':
      return context.s.weCardHouseRules;
    case 'contact':
      return context.s.weCardContact;
    case 'practicalHeader':
    case 'galleryHeader':
      return context.s.weCardHeader;
    case 'quickFacts':
      return context.s.weCardQuickFacts;
    case 'arrival':
      return context.s.weCardArrival;
    case 'parking':
      return context.s.weCardParking;
    case 'layout':
      return context.s.weCardLayout;
    case 'transport':
      return context.s.weCardTransport;
    case 'goodToKnow':
      return context.s.weCardGoodToKnow;
    case 'contactHelp':
      return context.s.weCardContactHelp;
    case 'agreements':
      return context.s.weCardAgreements;
    case 'areaIntro':
      return context.s.weCardAreaIntro;
    case 'areaSections':
      return context.s.weCardAreaSections;
    case 'galleryAll':
      return context.s.weCardGalleryAll;
    default:
      return context.s.weCardContent;
  }
}

/// The line under a card title, where the design has one. Null keeps the card
/// header to its title: a subtitle that restates the title is noise.
String? cardSubtitle(BuildContext context, String cardId) {
  switch (cardId) {
    case 'hero':
      return context.s.weCardHeroSub;
    case 'keyFacts':
      return context.s.weCardKeyFactsSub;
    case 'homeGallery':
      return context.s.weCardHomeGallerySub;
    case 'amenities':
      return context.s.weCardAmenitiesSub;
    case 'highlights':
      return context.s.weCardHighlightsSub;
    case 'houseRules':
      return context.s.weCardHouseRulesSub;
    case 'contact':
      return context.s.weCardContactSub;
    case 'quickFacts':
      return context.s.weCardQuickFactsSub;
    case 'layout':
      return context.s.weCardLayoutSub;
    case 'transport':
      return context.s.weCardTransportSub;
    case 'areaIntro':
      return context.s.weCardAreaIntroSub;
    case 'areaSections':
      return context.s.weCardAreaSectionsSub;
    case 'galleryHeader':
      return context.s.weCardGalleryHeaderSub;
    case 'galleryAll':
      return context.s.weCardGalleryAllSub;
    default:
      return null;
  }
}

/// Icon for a schema card id.
IconData cardIcon(String cardId) {
  switch (cardId) {
    case 'hero':
    case 'practicalHeader':
    case 'galleryHeader':
    case 'areaIntro':
      return Icons.auto_awesome;
    case 'keyFacts':
    case 'layout':
      return Icons.bed_outlined;
    case 'description':
    case 'agreements':
      return Icons.notes_outlined;
    case 'homeGallery':
    case 'galleryAll':
      return Icons.image_outlined;
    case 'amenities':
    case 'areaSections':
      return Icons.list_alt_outlined;
    case 'location':
      return Icons.place_outlined;
    case 'highlights':
      return Icons.star_outline;
    case 'houseRules':
      return Icons.rule_outlined;
    case 'contact':
    case 'contactHelp':
      return Icons.mail_outline;
    case 'quickFacts':
      return Icons.schedule_outlined;
    case 'arrival':
    case 'transport':
      return Icons.route_outlined;
    case 'parking':
      return Icons.directions_car_outlined;
    case 'goodToKnow':
      return Icons.info_outline;
    default:
      return Icons.notes_outlined;
  }
}

/// Localized label of a plain (non-list) editor field.
String fieldLabel(BuildContext context, String fieldKey) {
  switch (fieldKey) {
    case 'legal.privacy.intro':
      return context.s.weFieldPrivacyIntro;
    case 'cabin.hero.title':
      return context.s.weFieldHeadline;
    case 'cabin.meta.locationShort':
      return context.s.weFieldLocationLine;
    case 'cabin.hero.subtitle':
    case 'practical.header.subtitle':
    case 'contact.subtitle':
    case 'home.tagline':
      return context.s.weFieldSubtitle;
    case 'cabin.meta.name':
      return context.s.weFieldSearchName;
    case 'cabin.location.mapQuery':
      return context.s.weFieldMapQuery;
    case 'cabin.rules.checkIn':
    case 'practical.arrival.checkIn':
      return context.s.weFieldCheckIn;
    case 'cabin.rules.checkOut':
    case 'practical.arrival.checkOut':
      return context.s.weFieldCheckOut;
    case 'cabin.rules.cleaningNote':
      return context.s.weFieldCleaningNote;
    case 'cabin.rules.wifiNote':
      return context.s.weFieldWifiNote;
    case 'practical.parking.callout':
      return context.s.weFieldCallout;
    case 'contact.form.submit':
      return context.s.weFieldSubmit;
    case 'contact.form.success':
      return context.s.weFieldSuccess;
    case 'contact.form.error':
      return context.s.weFieldError;
    case 'contact.form.fields.name':
      return context.s.weFormFieldName;
    case 'contact.form.fields.email':
      return context.s.weFormFieldEmail;
    case 'contact.form.fields.period':
      return context.s.weFormFieldPeriod;
    case 'contact.form.fields.message':
      return context.s.weFormFieldMessage;
    case 'area.intro':
      return context.s.weFieldIntro;
    case 'cabin.amenities.title':
    case 'cabin.location.title':
    case 'cabin.rules.title':
    case 'practical.header.title':
    case 'practical.arrival.title':
    case 'practical.parking.title':
    case 'practical.layout.title':
    case 'practical.transport.title':
    case 'practical.goodToKnow.title':
    case 'practical.contactHelp.title':
    case 'practical.agreements.title':
    case 'contact.title':
      return context.s.weFieldTitle;
    default:
      return fieldKey;
  }
}

/// The note a field carries when it is not readable as text on its own page
/// (README §E). Null for a normal field: the preview marks its section.
String? visibilityHint(BuildContext context, FieldVisibility visibility) {
  switch (visibility) {
    case FieldVisibility.inPage:
      return null;
    case FieldVisibility.seo:
      return context.s.weHintSeo;
    case FieldVisibility.map:
      return context.s.weHintMap;
    case FieldVisibility.stateSuccess:
      return context.s.weHintStateSuccess;
    case FieldVisibility.stateError:
      return context.s.weHintStateError;
  }
}

/// The name of a repeatable list, for its subheader.
String listTitle(BuildContext context, String listKey) {
  if (listKey.endsWith('.items') || listKey.endsWith('.bullets')) {
    return context.s.weListLines;
  }
  switch (listKey) {
    case 'home.keyFacts':
      return context.s.weListKeyFacts;
    case 'cabin.description':
      return context.s.weListParagraphs;
    case 'cabin.amenities.groups':
      return context.s.weListGroups;
    case 'cabin.location.distances':
      return context.s.weListDistances;
    case 'home.highlights':
      return context.s.weCardHighlights;
    case 'cabin.rules.bullets':
    case 'practical.arrival.bullets':
    case 'practical.parking.bullets':
    case 'practical.goodToKnow.bullets':
    case 'practical.contactHelp.bullets':
      return context.s.weListLines;
    case 'cabin.rules.times':
    case 'practical.arrival.times':
      return context.s.weListTimes;
    case 'contact.form.fields':
      return context.s.weListFormFields;
    case 'practical.quickFacts':
      return context.s.weListFacts;
    case 'practical.layout.sections':
    case 'area.sections':
      return context.s.weListSections;
    case 'practical.transport.columns':
      return context.s.weListColumns;
    case 'practical.agreements.blocks':
      return context.s.weListSections;
    default:
      return listKey;
  }
}

/// The noun for one row of a list — the rows read `<noun> 3`.
String listItemLabel(BuildContext context, String listKey) {
  if (listKey.endsWith('.items') || listKey.endsWith('.bullets')) {
    return context.s.weItemLine;
  }
  switch (listKey) {
    case 'home.keyFacts':
      return context.s.weItemKeyFact;
    case 'cabin.description':
      return context.s.weItemParagraph;
    case 'cabin.amenities.groups':
      return context.s.weItemGroup;
    case 'cabin.location.distances':
      return context.s.weItemDistance;
    case 'home.highlights':
      return context.s.weItemHighlight;
    case 'cabin.rules.times':
    case 'practical.arrival.times':
      return context.s.weItemTime;
    case 'contact.form.fields':
      return context.s.weItemFormField;
    case 'practical.quickFacts':
      return context.s.weItemFact;
    case 'practical.layout.sections':
    case 'area.sections':
      return context.s.weItemSection;
    case 'practical.transport.columns':
      return context.s.weItemColumn;
    case 'practical.agreements.blocks':
      return context.s.weItemSection;
    default:
      return context.s.weItemLine;
  }
}

/// The noun for one item *inside* a group.
String subListItemLabel(BuildContext context, String listKey) {
  switch (listKey) {
    case 'cabin.amenities.groups':
      return context.s.weItemAmenity;
    default:
      return context.s.weItemLine;
  }
}

/// The label above a pair's label column, or null when the row's own title
/// already says what the pair is (a fixed-label row).
String pairLabelLabel(BuildContext context, String listKey) {
  switch (listKey) {
    case 'cabin.location.distances':
      return context.s.wePairWhat;
    case 'contact.form.fields':
      return context.s.wePairLabel;
    default:
      return context.s.wePairLabel;
  }
}

/// The label above a pair's value column.
String pairValueLabel(BuildContext context, String listKey) {
  switch (listKey) {
    case 'cabin.location.distances':
      return context.s.wePairDistance;
    case 'cabin.rules.times':
    case 'practical.arrival.times':
      return context.s.wePairTime;
    case 'contact.form.fields':
      return context.s.wePairPlaceholder;
    default:
      return context.s.wePairValue;
  }
}

/// The label of one subfield inside a multi-field row (a highlight).
String subFieldLabel(BuildContext context, String listKey, String sub) {
  switch (sub) {
    case 'title':
      return context.s.weFieldTitle;
    case 'description':
      return context.s.weFieldSubline;
    case 'alt':
      return context.s.weFieldAlt;
    default:
      return sub;
  }
}

/// The fixed title of a group in a fixed-title group list
/// (`practical.transport.columns`), by position — a fixed group cannot move.
String fixedGroupTitle(BuildContext context, GroupListRow row, int index) {
  if (row.listKey == 'practical.transport.columns') {
    switch (index) {
      case 0:
        return context.s.weColumnCar;
      case 1:
        return context.s.weColumnAirports;
      case 2:
        return context.s.weColumnPublicTransport;
      case 3:
        return context.s.weColumnParking;
      default:
        return context.s.weColumnNotes;
    }
  }
  return '${listItemLabel(context, row.listKey)} ${index + 1}';
}
