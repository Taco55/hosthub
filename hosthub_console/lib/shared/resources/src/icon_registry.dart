// This file defines the IconMetadata model and the iconRegistry.

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:hosthub_console/shared/l10n/l10n.dart';
import 'organize_icons.dart';

class IconMetadata {
  final IconData data;
  final List<String> keywords;
  final Set<IconCategory> categories;

  const IconMetadata(this.data, this.keywords, this.categories);
}

enum IconCategory {
  foodAndCooking,
  general,
  events,
  lifestyle,
  symbols,
  lists;

  // static S get s => S.current;

  IconData get iconData => switch (this) {
    foodAndCooking => OrganizeIcons.broccoli,
    general => OrganizeIcons.star,
    events => OrganizeIcons.christmas,
    lifestyle => OrganizeIcons.heart,
    symbols => OrganizeIcons.math,
    lists => OrganizeIcons.bulletLists,
  };

  String get nameLocalized => switch (this) {
    foodAndCooking => "food and cooking",
    general => "general",
    events => "events",
    lifestyle => "health",
    symbols => "symbols",
    lists => "lists",
  };

  List<IconMetadata> get allMetadata {
    return IconRegistry.all.values
        .where((meta) => meta.categories.contains(this))
        .toList();
  }

  /// Returns all IconData for a given IconCategory
  List<IconData> get getIconDataForCategory {
    return IconRegistry.all.values
        .where((meta) => meta.categories.contains(this))
        .map((meta) => meta.data)
        .toList();
  }
}

class IconRegistry {
  static S get l => S.current;

  static Map<String, IconMetadata> get all => _iconRegistry;

  Map<IconCategory, Map<String, IconMetadata>> get groupedIcons {
    final map = <IconCategory, Map<String, IconMetadata>>{};
    for (final entry in _iconRegistry.entries) {
      for (final type in entry.value.categories) {
        map.putIfAbsent(type, () => {})[entry.key] = entry.value;
      }
    }
    return map;
  }

  /// Returns the first IconType for a given IconData
  static IconCategory? getCategoryForIconData(IconData? iconData) =>
      _iconRegistry.values
          .firstWhereOrNull((meta) => meta.data == iconData)
          ?.categories
          .firstOrNull;

  /// Searches for icons that match a keyword (case insensitive)
  static List<IconMetadata> searchIcons(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return _iconRegistry.values
        .where(
          (meta) => meta.keywords.any(
            (kw) => kw.toLowerCase().contains(lowerKeyword),
          ),
        )
        .toList();
  }

  /// Returns the IconMetadata for a given IconData
  static IconMetadata? getMetadataForIconData(IconData data) {
    return _iconRegistry.values.firstWhereOrNull((meta) => meta.data == data);
  }

  /// Returns the icon name (String key) for a given IconData
  static String? getNameForIconData(IconData data) {
    return _iconRegistry.entries
        .firstWhereOrNull((entry) => entry.value.data == data)
        ?.key;
  }

  static IconData? getIcon(String key) {
    return _iconRegistry[key]?.data;
  }

  static final Map<String, IconMetadata> _iconRegistry = {
    // General
    'flag': IconMetadata(
      OrganizeIcons.flag,
      [l.flag, l.banner, l.symbol],
      {IconCategory.general, IconCategory.lifestyle},
    ),
    'sun': IconMetadata(
      OrganizeIcons.sun,
      [l.sun, l.sunlight, l.daylight],
      {IconCategory.general},
    ),
    'call': IconMetadata(
      OrganizeIcons.call,
      [l.call, l.phone, l.mobile],
      {IconCategory.general},
    ),
    'scan_barcode': IconMetadata(
      OrganizeIcons.scanBarcode,
      [l.scanBarcode, l.qrCode, l.barcode],
      {IconCategory.general},
    ),
    'folders': IconMetadata(
      OrganizeIcons.folders,
      [l.folders, l.files, l.organization],
      {IconCategory.general},
    ),
    'invitation_2': IconMetadata(
      OrganizeIcons.invitation_2,
      [l.invitation, l.event, l.card],
      {IconCategory.general, IconCategory.events},
    ),
    'dollar_coins': IconMetadata(
      OrganizeIcons.dollarCoins,
      [l.dollarCoins, l.money, l.currency],
      {IconCategory.general},
    ),
    'repair': IconMetadata(
      OrganizeIcons.repair,
      [l.repair, l.fix, l.maintenance],
      {IconCategory.general},
    ),
    'dog': IconMetadata(
      OrganizeIcons.dog,
      [l.dog, l.pet, l.puppy],
      {IconCategory.general, IconCategory.lifestyle},
    ),
    'cat': IconMetadata(
      OrganizeIcons.cat,
      [l.cat, l.pet, l.kitten],
      {IconCategory.general, IconCategory.lifestyle},
    ),
    'dollar': IconMetadata(
      OrganizeIcons.dollar,
      [l.dollar, l.money, l.cash],
      {IconCategory.general},
    ),
    'barcode': IconMetadata(
      OrganizeIcons.barcode,
      [l.barcode, l.qrCode, l.scan],
      {IconCategory.general},
    ),
    'trash': IconMetadata(
      OrganizeIcons.trash,
      [l.trash, l.garbage, l.waste],
      {IconCategory.general},
    ),
    'empty': IconMetadata(
      OrganizeIcons.empty,
      [l.empty, l.blank, l.clear],
      {IconCategory.general},
    ),
    'statistic': IconMetadata(
      OrganizeIcons.statistic,
      [l.statistic, l.data, l.analysis],
      {IconCategory.general},
    ),
    'pen': IconMetadata(
      OrganizeIcons.pen,
      [l.pen, l.write, l.edit],
      {IconCategory.general},
    ),
    'alarm_clock': IconMetadata(
      OrganizeIcons.alarmClock,
      [l.alarmClock, l.timer, l.alarm],
      {IconCategory.general},
    ),
    'purse': IconMetadata(
      OrganizeIcons.purse,
      [l.purse, l.wallet, l.moneyBag],
      {IconCategory.general},
    ),
    'folder': IconMetadata(
      OrganizeIcons.folder,
      [l.folder, l.directory, l.file],
      {IconCategory.general},
    ),
    'shopping_cart': IconMetadata(
      OrganizeIcons.shoppingCart,
      [l.shoppingCart, l.cart, l.shopping],
      {IconCategory.general, IconCategory.lifestyle},
    ),
    'qr': IconMetadata(
      OrganizeIcons.qr,
      [l.qrCode, l.scan, l.barcode],
      {IconCategory.general},
    ),
    'expiry': IconMetadata(
      OrganizeIcons.expiry,
      [l.expiry, l.expiration, l.deadline],
      {IconCategory.general, IconCategory.symbols},
    ),
    'expenses_2': IconMetadata(
      OrganizeIcons.expenses_2,
      [l.expenses, l.budget, l.cost],
      {IconCategory.general, IconCategory.lists},
    ),
    'open_package': IconMetadata(
      OrganizeIcons.openPackage,
      [l.openPackage, l.unbox, l.opening],
      {IconCategory.general},
    ),
    'printer': IconMetadata(
      OrganizeIcons.printer,
      [l.printer, l.print, l.document],
      {IconCategory.general},
    ),
    'scale': IconMetadata(
      OrganizeIcons.scale,
      [l.scale, l.weight, l.balance],
      {IconCategory.general},
    ),
    'time': IconMetadata(
      OrganizeIcons.time,
      [l.time, l.clock, l.hour],
      {IconCategory.general},
    ),
    'wifi': IconMetadata(
      OrganizeIcons.wifi,
      [l.wifi, l.internet, l.connection],
      {IconCategory.general},
    ),
    'clock': IconMetadata(
      OrganizeIcons.clock,
      [l.clock, l.time, l.watch],
      {IconCategory.general},
    ),
    'source': IconMetadata(
      OrganizeIcons.source,
      [l.source, l.origin, l.resource],
      {IconCategory.general},
    ),
    'location': IconMetadata(
      OrganizeIcons.location,
      [l.location, l.place, l.position],
      {IconCategory.general},
    ),
    'warning': IconMetadata(
      OrganizeIcons.warning,
      [l.warning, l.alert, l.caution],
      {IconCategory.general},
    ),
    'analytics': IconMetadata(
      OrganizeIcons.analytics,
      [l.analytics, l.analysis, l.data],
      {IconCategory.general},
    ),
    'business': IconMetadata(
      OrganizeIcons.business,
      [l.business, l.company, l.enterprise],
      {IconCategory.general},
    ),
    'money': IconMetadata(
      OrganizeIcons.money,
      [l.money, l.cash, l.finance],
      {IconCategory.general},
    ),
    'money_bag': IconMetadata(
      OrganizeIcons.moneyBag,
      [l.moneyBag, l.wealth, l.savings],
      {IconCategory.general},
    ),
    'coin': IconMetadata(
      OrganizeIcons.coin,
      [l.coins, l.currency, l.money],
      {IconCategory.general},
    ),
    'coin_2': IconMetadata(
      OrganizeIcons.coin_2,
      [l.coin, l.currency, l.money],
      {IconCategory.general},
    ),
    'coin_3': IconMetadata(
      OrganizeIcons.coin_3,
      [l.coin, l.currency, l.money],
      {IconCategory.general},
    ),
    'server': IconMetadata(
      OrganizeIcons.server,
      [l.server, l.dataCenter, l.computer],
      {IconCategory.general},
    ),
    'network': IconMetadata(
      OrganizeIcons.network,
      [l.network, l.connectivity, l.internet],
      {IconCategory.general},
    ),
    'insect': IconMetadata(
      OrganizeIcons.insect,
      [l.insect, l.bug, l.pest],
      {IconCategory.general},
    ),
    'lamp': IconMetadata(
      OrganizeIcons.lamp,
      [l.lamp, l.light, l.bulb],
      {IconCategory.general},
    ),
    'bel': IconMetadata(
      OrganizeIcons.bel,
      [l.bell, l.alert, l.notification],
      {IconCategory.general},
    ),
    'compass': IconMetadata(
      OrganizeIcons.compass,
      [l.compass, l.navigation, l.direction],
      {IconCategory.general, IconCategory.symbols},
    ),
    'hide_input': IconMetadata(
      OrganizeIcons.hideInput,
      [l.hideInput, l.hide, l.secureInput],
      {IconCategory.general, IconCategory.symbols},
    ),

    // Additional general icons
    'calendar': IconMetadata(
      OrganizeIcons.calendar,
      [l.calendar, l.date],
      {IconCategory.general},
    ),
    'date_range': IconMetadata(
      OrganizeIcons.dateRange,
      [l.dateRange, l.calendar],
      {IconCategory.general},
    ),
    'deadline': IconMetadata(
      OrganizeIcons.deadline,
      [l.deadline, l.time],
      {IconCategory.general},
    ),
    'deadline_2': IconMetadata(
      OrganizeIcons.deadline_2,
      [l.deadline, l.time],
      {IconCategory.general},
    ),
    'delete_event': IconMetadata(
      OrganizeIcons.deleteEvent,
      [l.deleteEvent, l.remove, l.event],
      {IconCategory.general, IconCategory.events},
    ),
    'expired': IconMetadata(
      OrganizeIcons.expired,
      [l.expired, l.deadline],
      {IconCategory.general},
    ),
    'fast_time': IconMetadata(
      OrganizeIcons.fastTime,
      [l.fastTime, l.clock],
      {IconCategory.general},
    ),
    'long_time': IconMetadata(
      OrganizeIcons.longTime,
      [l.longTime, l.clock],
      {IconCategory.general},
    ),
    'mail': IconMetadata(
      OrganizeIcons.mail,
      [l.mail, l.envelop],
      {IconCategory.general},
    ),
    'download_stored_files': IconMetadata(
      OrganizeIcons.downloadStoredFiles,
      [l.download, l.file],
      {IconCategory.general},
    ),
    'flag_2': IconMetadata(
      OrganizeIcons.flag_2,
      [l.flag, l.banner, l.symbol],
      {IconCategory.general, IconCategory.lifestyle},
    ),
    'icon': IconMetadata(OrganizeIcons.icon, [l.icon], {IconCategory.general}),
    'like_thumb': IconMetadata(
      OrganizeIcons.likeThumb,
      [l.like, l.thumb],
      {IconCategory.general},
    ),
    'dislike': IconMetadata(
      OrganizeIcons.dislike,
      [l.dislike, l.thumb],
      {IconCategory.general},
    ),
    'no_icon': IconMetadata(
      OrganizeIcons.noIcon,
      [l.noIcon, l.icon],
      {IconCategory.general},
    ),
    'piggy_bank': IconMetadata(
      OrganizeIcons.piggyBank,
      [l.pig, l.savings],
      {IconCategory.general},
    ),

    // Symbols icons
    'amount': IconMetadata(
      OrganizeIcons.amount,
      [l.amount, '='],
      {IconCategory.symbols},
    ),
    'label': IconMetadata(
      OrganizeIcons.label,
      [l.label],
      {IconCategory.symbols},
    ),
    'label_2': IconMetadata(
      OrganizeIcons.label_2,
      [l.label],
      {IconCategory.symbols},
    ),
    'label_3': IconMetadata(
      OrganizeIcons.label_3,
      [l.label],
      {IconCategory.symbols},
    ),
    'indicator': IconMetadata(
      OrganizeIcons.indicator,
      [l.indicator],
      {IconCategory.symbols},
    ),
    'distance': IconMetadata(
      OrganizeIcons.distance,
      [l.distance, l.route],
      {IconCategory.symbols},
    ),
    'distance_2': IconMetadata(
      OrganizeIcons.distance_2,
      [l.distance, l.route],
      {IconCategory.symbols},
    ),
    'navigation': IconMetadata(
      OrganizeIcons.navigation,
      [l.compass, l.navigation],
      {IconCategory.symbols},
    ),
    'navigation_2': IconMetadata(
      OrganizeIcons.navigation_2,
      [l.compass, l.navigation],
      {IconCategory.symbols},
    ),
    'mark': IconMetadata(
      OrganizeIcons.mark,
      [l.mark, l.tag, l.label],
      {IconCategory.symbols},
    ),
    'mark_2': IconMetadata(
      OrganizeIcons.mark_2,
      [l.mark, l.tag, l.label],
      {IconCategory.symbols},
    ),
    'arrow': IconMetadata(
      OrganizeIcons.arrow,
      [l.arrow, l.right],
      {IconCategory.symbols},
    ),
    'arrow_2': IconMetadata(
      OrganizeIcons.arrow_2,
      [l.arrow, l.left],
      {IconCategory.symbols},
    ),
    'tag': IconMetadata(
      OrganizeIcons.tag,
      [l.tag, l.numbers],
      {IconCategory.symbols},
    ),
    'exclamation_mark': IconMetadata(
      OrganizeIcons.exclamationPoint,
      [l.exclamation],
      {IconCategory.symbols},
    ),
    'toggle_on': IconMetadata(
      OrganizeIcons.toggleOn,
      [l.toggle],
      {IconCategory.symbols},
    ),
    'check': IconMetadata(
      OrganizeIcons.check,
      [l.check],
      {IconCategory.symbols},
    ),
    'bullet_lists': IconMetadata(
      OrganizeIcons.bulletLists,
      [l.bulletLists],
      {IconCategory.symbols, IconCategory.lists},
    ),
    'round_number': IconMetadata(
      OrganizeIcons.roundNumber,
      [l.roundNumber],
      {IconCategory.symbols},
    ),
    'decimal_number': IconMetadata(
      OrganizeIcons.decimalNumber,
      [l.decimalNumber],
      {IconCategory.symbols},
    ),
    'text': IconMetadata(
      OrganizeIcons.text,
      [l.text, l.letter],
      {IconCategory.symbols},
    ),
    'notes': IconMetadata(
      OrganizeIcons.notes,
      [l.text, l.letter],
      {IconCategory.symbols},
    ),
    'notes_2': IconMetadata(
      OrganizeIcons.notes_2,
      [l.text, l.letter],
      {IconCategory.symbols},
    ),

    'save': IconMetadata(
      OrganizeIcons.save,
      [l.save, l.store],
      {IconCategory.symbols},
    ),
    'small_caps': IconMetadata(
      OrganizeIcons.smallCaps,
      [l.smallCaps, l.text, l.letters],
      {IconCategory.symbols},
    ),
    'column_height_outlined': IconMetadata(
      OrganizeIcons.columnHeightOutlined,
      [l.height, l.column],
      {IconCategory.symbols},
    ),
    'copy': IconMetadata(OrganizeIcons.copy, [l.copy], {IconCategory.symbols}),
    'copy_2': IconMetadata(
      OrganizeIcons.copy_2,
      [l.copy],
      {IconCategory.symbols},
    ),
    'dash': IconMetadata(OrganizeIcons.dash, [l.dash], {IconCategory.symbols}),
    'dash_2': IconMetadata(
      OrganizeIcons.dash_2,
      [l.dash],
      {IconCategory.symbols},
    ),
    'dash_3': IconMetadata(
      OrganizeIcons.dash_3,
      [l.dash],
      {IconCategory.symbols},
    ),
    'vertical_line': IconMetadata(
      OrganizeIcons.verticalLine,
      [l.verticalLine],
      {IconCategory.symbols},
    ),
    'vertical_line_2': IconMetadata(
      OrganizeIcons.verticalLine_2,
      [l.verticalLine],
      {IconCategory.symbols},
    ),
    'drag': IconMetadata(OrganizeIcons.drag, [l.drag], {IconCategory.symbols}),
    'edit': IconMetadata(
      OrganizeIcons.edit,
      [l.edit, l.pencil],
      {IconCategory.symbols},
    ),
    'font_colors': IconMetadata(
      OrganizeIcons.fontColors,
      [l.fontColors, l.underline],
      {IconCategory.symbols},
    ),
    'font_size': IconMetadata(
      OrganizeIcons.fontSize,
      [l.fontSize, l.letters],
      {IconCategory.symbols},
    ),
    'form': IconMetadata(
      OrganizeIcons.form,
      [l.form, l.edit],
      {IconCategory.symbols},
    ),
    'line_height': IconMetadata(
      OrganizeIcons.lineHeight,
      [l.lineHeight],
      {IconCategory.symbols},
    ),
    'numbered_list': IconMetadata(
      OrganizeIcons.numberedList,
      [l.numberedList],
      {IconCategory.symbols},
    ),
    'width': IconMetadata(
      OrganizeIcons.width,
      [l.width],
      {IconCategory.symbols},
    ),
    'table': IconMetadata(
      OrganizeIcons.table,
      [l.table],
      {IconCategory.symbols},
    ),
    'table_of_content': IconMetadata(
      OrganizeIcons.tableOfContent,
      [l.tableOfContent],
      {IconCategory.symbols},
    ),
    'percent': IconMetadata(
      OrganizeIcons.percent,
      [l.percent],
      {IconCategory.symbols},
    ),
    'subtract': IconMetadata(
      OrganizeIcons.subtract,
      [l.subtract, l.operatorSign, l.math],
      {IconCategory.symbols},
    ),
    'multiply': IconMetadata(
      OrganizeIcons.multiply,
      [l.multiply, l.operatorSign, l.math],
      {IconCategory.symbols},
    ),
    'plus': IconMetadata(
      OrganizeIcons.plus,
      [l.plus, l.operatorSign, l.math],
      {IconCategory.symbols, IconCategory.lists},
    ),
    'divide': IconMetadata(
      OrganizeIcons.divide,
      [l.divide, l.operatorSign, l.math],
      {IconCategory.symbols},
    ),
    'sum': IconMetadata(
      OrganizeIcons.sum,
      [l.sum, l.math],
      {IconCategory.symbols},
    ),
    'math': IconMetadata(
      OrganizeIcons.math,
      [l.math, l.operatorSign],
      {IconCategory.symbols},
    ),
    'add': IconMetadata(OrganizeIcons.add, [l.add], {IconCategory.symbols}),
    'code': IconMetadata(
      OrganizeIcons.code,
      [l.braces, l.code, l.software],
      {IconCategory.symbols},
    ),
    'code_2': IconMetadata(
      OrganizeIcons.code_2,
      [l.code, l.software, l.development],
      {IconCategory.symbols},
    ),
    'question_mark_2': IconMetadata(
      OrganizeIcons.questionMark_2,
      [l.questionMark],
      {IconCategory.symbols},
    ),
    'alignment': IconMetadata(
      OrganizeIcons.alignment,
      [l.centerAlignment, l.leftAlignment, l.rightAlignment],
      {IconCategory.symbols},
    ),
    'attention': IconMetadata(
      OrganizeIcons.attention,
      [l.warning, l.alert, l.caution],
      {IconCategory.symbols},
    ),
    'circle': IconMetadata(
      OrganizeIcons.circle,
      [l.circleFilled, l.circleOutlined],
      {IconCategory.symbols},
    ),
    'circle_2': IconMetadata(
      OrganizeIcons.circle_2,
      [l.circleFilled, l.circleOutlined],
      {IconCategory.symbols},
    ),
    'cone': IconMetadata(OrganizeIcons.cone, [l.cone], {IconCategory.symbols}),
    'cross': IconMetadata(
      OrganizeIcons.cross,
      [l.cross],
      {IconCategory.symbols},
    ),
    'cube': IconMetadata(OrganizeIcons.cube, [l.cube], {IconCategory.symbols}),
    'cylinder': IconMetadata(
      OrganizeIcons.cylinder,
      [l.cylinder],
      {IconCategory.symbols},
    ),
    'diamond': IconMetadata(
      OrganizeIcons.diamond,
      [l.diamond],
      {IconCategory.symbols},
    ),
    'dot': IconMetadata(OrganizeIcons.dot, [l.dot], {IconCategory.symbols}),
    'left_alignment': IconMetadata(
      OrganizeIcons.leftAlignment,
      [l.leftAlignment],
      {IconCategory.symbols},
    ),
    'oval': IconMetadata(OrganizeIcons.oval, [l.oval], {IconCategory.symbols}),
    'plus_2': IconMetadata(
      OrganizeIcons.plus_2,
      [l.plus, l.operatorSign, l.math],
      {IconCategory.symbols, IconCategory.lists},
    ),
    'question_mark': IconMetadata(
      OrganizeIcons.questionMark,
      [l.questionMark],
      {IconCategory.symbols},
    ),
    'right_alignment': IconMetadata(
      OrganizeIcons.rightAlignment,
      [l.rightAlignment],
      {IconCategory.symbols},
    ),
    'small': IconMetadata(
      OrganizeIcons.small,
      [l.small],
      {IconCategory.symbols},
    ),
    'square': IconMetadata(
      OrganizeIcons.square,
      [l.square],
      {IconCategory.symbols},
    ),
    'star': IconMetadata(
      OrganizeIcons.star,
      [l.starInverse, l.star],
      {IconCategory.symbols},
    ),
    'star_inverse': IconMetadata(
      OrganizeIcons.starInverse,
      [l.starInverse, l.star],
      {IconCategory.symbols},
    ),
    'star_rating': IconMetadata(
      OrganizeIcons.starRating,
      [l.ratingStar, l.star],
      {IconCategory.symbols},
    ),
    'up_and_down_arrows': IconMetadata(
      OrganizeIcons.upAndDownArrows,
      [l.arrowsUpDown],
      {IconCategory.symbols},
    ),

    // Events
    'balloon': IconMetadata(
      OrganizeIcons.balloon,
      [l.balloon],
      {IconCategory.events},
    ),
    'balloon_2': IconMetadata(
      OrganizeIcons.balloon_2,
      [l.balloon],
      {IconCategory.events},
    ),
    'christmas': IconMetadata(
      OrganizeIcons.christmas,
      [l.present, l.christmas, l.tree],
      {IconCategory.events},
    ),
    'christmas_2': IconMetadata(
      OrganizeIcons.christmas_2,
      [l.bauble, l.christmas],
      {IconCategory.events},
    ),
    'christmas_3': IconMetadata(
      OrganizeIcons.christmas_3,
      [l.bauble, l.christmas, l.tree],
      {IconCategory.events},
    ),
    'christmas_4': IconMetadata(
      OrganizeIcons.christmas_4,
      [l.bauble, l.christmas, l.tree],
      {IconCategory.events},
    ),
    'snowflake': IconMetadata(
      OrganizeIcons.snowflake,
      [l.snowflake, l.christmas],
      {IconCategory.foodAndCooking, IconCategory.events, IconCategory.symbols},
    ),
    'invitation': IconMetadata(
      OrganizeIcons.invitation,
      [l.invitation, l.envelop],
      {IconCategory.events},
    ),
    'wine_and_glass': IconMetadata(
      OrganizeIcons.wineAndGlass,
      [l.wineAndGlass],
      {IconCategory.events, IconCategory.foodAndCooking},
    ),
    'birthday': IconMetadata(
      OrganizeIcons.birthday,
      [l.birthday, l.pie],
      {IconCategory.events},
    ),
    'elevator': IconMetadata(
      OrganizeIcons.elevator,
      [l.elevator],
      {IconCategory.events},
    ),
    'add_calendar': IconMetadata(
      OrganizeIcons.addCalendar,
      [l.add, l.calendar, l.date],
      {IconCategory.events},
    ),
    'event_created': IconMetadata(
      OrganizeIcons.eventCreated,
      [l.event, l.created],
      {IconCategory.events},
    ),
    'santa_claus': IconMetadata(
      OrganizeIcons.santaClaus,
      [l.santaClaus, l.christmas],
      {IconCategory.events},
    ),

    // Lifestyle
    'mother': IconMetadata(
      OrganizeIcons.mother,
      [l.mother, l.woman],
      {IconCategory.lifestyle},
    ),
    'mother_2': IconMetadata(
      OrganizeIcons.mother_2,
      [l.mother, l.woman],
      {IconCategory.lifestyle},
    ),
    'father': IconMetadata(
      OrganizeIcons.father,
      [l.father, l.woman],
      {IconCategory.lifestyle},
    ),
    'cleaning': IconMetadata(
      OrganizeIcons.cleaning,
      [l.cleaning],
      {IconCategory.lifestyle},
    ),
    'house': IconMetadata(
      OrganizeIcons.house,
      [l.house],
      {IconCategory.lifestyle},
    ),
    'shopping_basket': IconMetadata(
      OrganizeIcons.shoppingBasket,
      [l.shoppingBasket],
      {IconCategory.lifestyle},
    ),
    'shop': IconMetadata(
      OrganizeIcons.shop,
      [l.shop],
      {IconCategory.lifestyle},
    ),
    'jacket': IconMetadata(
      OrganizeIcons.jacket,
      [l.jacket],
      {IconCategory.lifestyle},
    ),
    'blender': IconMetadata(
      OrganizeIcons.blender,
      [l.blender],
      {IconCategory.lifestyle},
    ),
    'dress': IconMetadata(
      OrganizeIcons.dress,
      [l.dress, l.fashion, l.clothing],
      {IconCategory.lifestyle},
    ),
    'theme': IconMetadata(
      OrganizeIcons.theme,
      [l.paint, l.theme],
      {IconCategory.lifestyle},
    ),
    'iron': IconMetadata(
      OrganizeIcons.iron,
      [l.iron],
      {IconCategory.lifestyle},
    ),
    'suit_case': IconMetadata(
      OrganizeIcons.suitcase,
      [l.suitcase],
      {IconCategory.lifestyle},
    ),
    'airplane': IconMetadata(
      OrganizeIcons.airplane,
      [l.airplane],
      {IconCategory.lifestyle},
    ),
    'mountain': IconMetadata(
      OrganizeIcons.mountain,
      [l.mountain],
      {IconCategory.lifestyle},
    ),
    'globe': IconMetadata(
      OrganizeIcons.globe,
      [l.globe],
      {IconCategory.lifestyle},
    ),
    'home': IconMetadata(
      OrganizeIcons.home,
      [l.home, l.house],
      {IconCategory.lifestyle},
    ),
    'people': IconMetadata(
      OrganizeIcons.people,
      [l.people, l.persons, l.human],
      {IconCategory.lifestyle},
    ),
    'photo': IconMetadata(
      OrganizeIcons.photo,
      [l.photo, l.gallery, l.mountain],
      {IconCategory.lifestyle},
    ),
    'photo_library': IconMetadata(
      OrganizeIcons.photoLibrary,
      [l.photo, l.mountain],
      {IconCategory.lifestyle},
    ),
    'bike': IconMetadata(
      OrganizeIcons.bike,
      [l.bike, l.sport],
      {IconCategory.lifestyle},
    ),
    'bus': IconMetadata(OrganizeIcons.bus, [l.bus], {IconCategory.lifestyle}),
    'taxi': IconMetadata(
      OrganizeIcons.taxi,
      [l.taxi, l.car, l.auto],
      {IconCategory.lifestyle},
    ),
    'disability': IconMetadata(
      OrganizeIcons.disability,
      [l.disability],
      {IconCategory.lifestyle},
    ),
    'dog_2': IconMetadata(
      OrganizeIcons.dog_2,
      [l.dog, l.walking],
      {IconCategory.lifestyle},
    ),
    'music': IconMetadata(
      OrganizeIcons.music,
      [l.music],
      {IconCategory.lifestyle},
    ),
    'restroom': IconMetadata(
      OrganizeIcons.restroom,
      [l.restRoom, l.people],
      {IconCategory.lifestyle},
    ),
    'party': IconMetadata(
      OrganizeIcons.party,
      [l.music, l.party],
      {IconCategory.lifestyle},
    ),
    'sound': IconMetadata(
      OrganizeIcons.sound,
      [l.sound, l.audio],
      {IconCategory.lifestyle},
    ),
    'holiday': IconMetadata(
      OrganizeIcons.holiday,
      [l.travel, l.holiday],
      {IconCategory.lifestyle},
    ),
    'car': IconMetadata(OrganizeIcons.car, [l.car], {IconCategory.lifestyle}),
    'sport_car': IconMetadata(
      OrganizeIcons.sportCar,
      [l.sportCar],
      {IconCategory.lifestyle},
    ),
    'fashion': IconMetadata(
      OrganizeIcons.fashion,
      [l.tShirt, l.sport, l.clothing, l.fashion],
      {IconCategory.lifestyle},
    ),
    'fashion_2': IconMetadata(
      OrganizeIcons.fashion_2,
      [l.dress, l.fashion, l.clothing],
      {IconCategory.lifestyle},
    ),
    'flag_lifestyle': IconMetadata(
      OrganizeIcons.flag,
      [l.flag, l.golf],
      {IconCategory.lifestyle},
    ),
    'garden': IconMetadata(
      OrganizeIcons.garden,
      [l.garden, l.flowers],
      {IconCategory.lifestyle},
    ),
    'medal': IconMetadata(
      OrganizeIcons.medal,
      [l.medal],
      {IconCategory.lifestyle},
    ),
    'rugby': IconMetadata(
      OrganizeIcons.rugby,
      [l.rugby, l.sport],
      {IconCategory.lifestyle},
    ),
    'trophy': IconMetadata(
      OrganizeIcons.trophy,
      [l.trophy, l.cup, l.sport],
      {IconCategory.lifestyle},
    ),
    'baby': IconMetadata(
      OrganizeIcons.baby,
      [l.baby],
      {IconCategory.lifestyle},
    ),
    'dress_2': IconMetadata(
      OrganizeIcons.dress_2,
      [l.dress, l.fashion, l.clothing],
      {IconCategory.lifestyle},
    ),
    'garden_2': IconMetadata(
      OrganizeIcons.garden_2,
      [l.garden, l.flowers],
      {IconCategory.lifestyle},
    ),
    'globe_2': IconMetadata(
      OrganizeIcons.globe_2,
      [l.globe],
      {IconCategory.lifestyle},
    ),
    'heart': IconMetadata(
      OrganizeIcons.heart,
      [l.heart, l.love, l.romantic],
      {IconCategory.lifestyle},
    ),
    'heart_2': IconMetadata(
      OrganizeIcons.heart_2,
      [l.heart, l.love, l.romantic],
      {IconCategory.lifestyle},
    ),
    'holiday_2': IconMetadata(
      OrganizeIcons.holiday_2,
      [l.travel, l.holiday],
      {IconCategory.lifestyle},
    ),
    'holiday_3': IconMetadata(
      OrganizeIcons.holiday_3,
      [l.travel, l.holiday],
      {IconCategory.lifestyle},
    ),

    // Food and Cooking
    'ingredients': IconMetadata(
      OrganizeIcons.ingredients,
      [l.ingredients],
      {IconCategory.foodAndCooking},
    ),
    'bread_2': IconMetadata(
      OrganizeIcons.bread_2,
      [l.bread],
      {IconCategory.foodAndCooking},
    ),
    'parsley': IconMetadata(
      OrganizeIcons.parsley,
      [l.parsley],
      {IconCategory.foodAndCooking},
    ),
    'chicken': IconMetadata(
      OrganizeIcons.chicken,
      [l.chicken],
      {IconCategory.foodAndCooking},
    ),
    'bowl_and_chopsticks': IconMetadata(
      OrganizeIcons.bowlAndChopsticks,
      [l.bowlAndChopsticks],
      {IconCategory.foodAndCooking},
    ),
    'pasta': IconMetadata(
      OrganizeIcons.pasta,
      [l.pasta],
      {IconCategory.foodAndCooking},
    ),
    'pasta_maker': IconMetadata(
      OrganizeIcons.pastaMaker,
      [l.pastaMaker],
      {IconCategory.foodAndCooking},
    ),
    'wine_and_glass2': IconMetadata(
      OrganizeIcons.wineAndGlass2,
      [l.wineAndGlass, l.drinks],
      {IconCategory.foodAndCooking},
    ),
    'cherries': IconMetadata(
      OrganizeIcons.cherries,
      [l.cherries],
      {IconCategory.foodAndCooking},
    ),
    'plate': IconMetadata(
      OrganizeIcons.plate,
      [l.plate],
      {IconCategory.foodAndCooking},
    ),
    'thai_noodles': IconMetadata(
      OrganizeIcons.thaiNoodles,
      [l.noodles, l.thai],
      {IconCategory.foodAndCooking},
    ),
    'fork_and_knife': IconMetadata(
      OrganizeIcons.forkAndKnife,
      [l.forkAndKnife],
      {IconCategory.foodAndCooking},
    ),
    'frozen_fries': IconMetadata(
      OrganizeIcons.frozenFries,
      [l.frozenFries],
      {IconCategory.foodAndCooking},
    ),
    'coffee_kettle': IconMetadata(
      OrganizeIcons.coffeeKettle,
      [l.coffee, l.kettle],
      {IconCategory.foodAndCooking},
    ),
    'beer': IconMetadata(
      OrganizeIcons.beer,
      [l.beer],
      {IconCategory.foodAndCooking},
    ),
    'bottle': IconMetadata(
      OrganizeIcons.bottle,
      [l.bottle],
      {IconCategory.foodAndCooking},
    ),
    'tomato': IconMetadata(
      OrganizeIcons.tomato,
      [l.tomato],
      {IconCategory.foodAndCooking},
    ),
    'container': IconMetadata(
      OrganizeIcons.container,
      [l.container],
      {IconCategory.foodAndCooking},
    ),
    'gravy_boat': IconMetadata(
      OrganizeIcons.gravyBoat,
      [l.gravyBoat, l.sauceBoat],
      {IconCategory.foodAndCooking},
    ),
    'ice_cream_cone': IconMetadata(
      OrganizeIcons.iceCreamCone,
      [l.iceCream],
      {IconCategory.foodAndCooking},
    ),
    'microwave': IconMetadata(
      OrganizeIcons.microwave,
      [l.microwave],
      {IconCategory.foodAndCooking},
    ),
    'croissant': IconMetadata(
      OrganizeIcons.croissant,
      [l.croissant],
      {IconCategory.foodAndCooking},
    ),
    'steak': IconMetadata(
      OrganizeIcons.steak,
      [l.steak],
      {IconCategory.foodAndCooking},
    ),
    'food': IconMetadata(
      OrganizeIcons.food,
      [l.food],
      {IconCategory.foodAndCooking},
    ),
    'pestle': IconMetadata(
      OrganizeIcons.pestle,
      [l.pestle],
      {IconCategory.foodAndCooking},
    ),
    'milk': IconMetadata(
      OrganizeIcons.milk,
      [l.milk],
      {IconCategory.foodAndCooking},
    ),
    'jar': IconMetadata(
      OrganizeIcons.jar,
      [l.jar],
      {IconCategory.foodAndCooking},
    ),
    'avocado': IconMetadata(
      OrganizeIcons.avocado,
      [l.avocado],
      {IconCategory.foodAndCooking},
    ),
    'spaghetti': IconMetadata(
      OrganizeIcons.spaghetti,
      [l.spaghetti],
      {IconCategory.foodAndCooking},
    ),
    'eggplant': IconMetadata(
      OrganizeIcons.eggplant,
      [l.eggplant],
      {IconCategory.foodAndCooking},
    ),
    'eggs': IconMetadata(
      OrganizeIcons.eggs,
      [l.eggs],
      {IconCategory.foodAndCooking},
    ),
    'bread': IconMetadata(
      OrganizeIcons.bread,
      [l.bread],
      {IconCategory.foodAndCooking},
    ),
    'broccoli': IconMetadata(
      OrganizeIcons.broccoli,
      [l.broccoli, l.vegetarian],
      {IconCategory.foodAndCooking, IconCategory.lifestyle},
    ),
    'wine_bottle': IconMetadata(
      OrganizeIcons.wineBottle,
      [l.wineBottle, l.drinks],
      {IconCategory.foodAndCooking},
    ),
    'carrot': IconMetadata(
      OrganizeIcons.carrot,
      [l.carrot],
      {IconCategory.foodAndCooking},
    ),
    'fish': IconMetadata(
      OrganizeIcons.fish,
      [l.fish],
      {IconCategory.foodAndCooking},
    ),
    'meat': IconMetadata(
      OrganizeIcons.meat,
      [l.meat],
      {IconCategory.foodAndCooking},
    ),
    'pie': IconMetadata(
      OrganizeIcons.pie,
      [l.pie],
      {IconCategory.foodAndCooking},
    ),
    'pizza': IconMetadata(
      OrganizeIcons.pizza,
      [l.pizza],
      {IconCategory.foodAndCooking},
    ),
    'sauce_bottle': IconMetadata(
      OrganizeIcons.sauceBottle,
      [l.sauceBottle, l.sauce, l.hot],
      {IconCategory.foodAndCooking},
    ),
    'soup': IconMetadata(
      OrganizeIcons.soup,
      [l.soup],
      {IconCategory.foodAndCooking},
    ),
    'wok': IconMetadata(
      OrganizeIcons.wok,
      [l.wok],
      {IconCategory.foodAndCooking},
    ),
    'frying_pan': IconMetadata(
      OrganizeIcons.fryingPan,
      [l.fryingPan],
      {IconCategory.foodAndCooking},
    ),
    'pan': IconMetadata(
      OrganizeIcons.pan,
      [l.pan],
      {IconCategory.foodAndCooking},
    ),
    'vegetables': IconMetadata(
      OrganizeIcons.vegetables,
      [l.vegetables],
      {IconCategory.foodAndCooking},
    ),

    // Lists
    'shopping_bag': IconMetadata(
      OrganizeIcons.shoppingBag,
      [l.shoppingBag],
      {IconCategory.lists, IconCategory.lifestyle},
    ),
    'pass': IconMetadata(OrganizeIcons.pass, [l.pass], {IconCategory.lists}),
    'todo_list': IconMetadata(
      OrganizeIcons.todoList,
      [l.todoList],
      {IconCategory.lists},
    ),
    'recipe_book': IconMetadata(
      OrganizeIcons.recipeBook,
      [l.recipeBook],
      {IconCategory.lists},
    ),
    'recipe': IconMetadata(
      OrganizeIcons.recipe,
      [l.recipes],
      {IconCategory.lists},
    ),
    'inventory': IconMetadata(
      OrganizeIcons.inventory,
      [l.inventory],
      {IconCategory.lists},
    ),
    'inventory_2': IconMetadata(
      OrganizeIcons.inventory_2,
      [l.inventory],
      {IconCategory.lists},
    ),
    'wishlist': IconMetadata(
      OrganizeIcons.wishlist,
      [l.wishlist],
      {IconCategory.lists},
    ),
    'wishlist_2': IconMetadata(
      OrganizeIcons.wishlist_2,
      [l.wishlist],
      {IconCategory.lists},
    ),
    'expenses': IconMetadata(
      OrganizeIcons.expenses,
      [l.expenses],
      {IconCategory.lists},
    ),
    'refrigerator': IconMetadata(
      OrganizeIcons.refrigerator,
      [l.refrigerator],
      {IconCategory.lists},
    ),
    'wine_list': IconMetadata(
      OrganizeIcons.wineList,
      [l.wineList],
      {IconCategory.lists},
    ),
    'loyalty_card': IconMetadata(
      OrganizeIcons.loyaltyCard,
      [l.loyaltyCard, l.premium],
      {IconCategory.lists},
    ),
    'loyalty_card_2': IconMetadata(
      OrganizeIcons.loyaltyCard_2,
      [l.loyaltyCard, l.premium],
      {IconCategory.lists},
    ),
    'premium_card': IconMetadata(
      OrganizeIcons.premiumCard,
      [l.loyaltyCard, l.premium],
      {IconCategory.lists},
    ),
    'kanban_board': IconMetadata(
      OrganizeIcons.kanbanBoard,
      [l.kanbanBoard],
      {IconCategory.lists},
    ),
    'event_planner': IconMetadata(
      OrganizeIcons.eventPlanner,
      [l.eventPlanner],
      {IconCategory.lists},
    ),
    'events': IconMetadata(
      OrganizeIcons.events,
      [l.events],
      {IconCategory.lists},
    ),
    'glasses': IconMetadata(
      OrganizeIcons.glasses,
      [l.glasses],
      {IconCategory.lists},
    ),
    'pig': IconMetadata(OrganizeIcons.pig, [l.pig], {IconCategory.lists}),
    'travel_itinerary': IconMetadata(
      OrganizeIcons.travelItinerary,
      [l.travelItinerary],
      {IconCategory.lists},
    ),
    'url': IconMetadata(OrganizeIcons.url, [l.url], {IconCategory.lists}),
    'vacation_time': IconMetadata(
      OrganizeIcons.vacationTime,
      [l.vacationTime],
      {IconCategory.lists},
    ),
    'meditate': IconMetadata(
      OrganizeIcons.meditate,
      [l.meditate],
      {IconCategory.lists},
    ),
    'favorite_list': IconMetadata(
      OrganizeIcons.favoriteList,
      [l.favorite, l.list],
      {IconCategory.lists},
    ),
    'task_board': IconMetadata(
      OrganizeIcons.taskBoard,
      [l.kanbanBoard],
      {IconCategory.lists},
    ),
    'contacts': IconMetadata(
      OrganizeIcons.contacts,
      [l.contacts],
      {IconCategory.lists, IconCategory.general},
    ),
    'list': IconMetadata(OrganizeIcons.list, [l.list], {IconCategory.lists}),
  };
}
