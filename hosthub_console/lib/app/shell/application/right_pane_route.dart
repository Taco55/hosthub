sealed class RightPaneRoute {
  const RightPaneRoute();

  String get key;
}

class RightPaneFieldDetail extends RightPaneRoute {
  const RightPaneFieldDetail(this.fieldId);

  final String fieldId;

  @override
  String get key => 'field:$fieldId';
}

class RightPaneSeedItemDetail extends RightPaneRoute {
  const RightPaneSeedItemDetail(this.itemId);

  final String itemId;

  @override
  String get key => 'seed-item:$itemId';
}
