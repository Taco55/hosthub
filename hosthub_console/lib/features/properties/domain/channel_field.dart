import 'package:hosthub_console/features/properties/domain/channel_overrides.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';

/// One editable value of a channel's settings.
///
/// The two tiers already merge field by field; this names the fields so the
/// screens can ask questions *about* a field — how many properties follow it,
/// which ones deviate, what a draft change would touch — without any of them
/// keeping a list of field names of its own.
enum ChannelField {
  commission,
  markup,
  cleaning,
  linen,
  service,
  other;

  /// Whether the field is a percentage rather than an amount. The unit is a
  /// property of the field, so the form does not decide it per row.
  bool get isPercentage =>
      this == ChannelField.commission || this == ChannelField.markup;

  /// Whether the property states this field itself.
  bool isOverriddenIn(ChannelOverride override) {
    switch (this) {
      case ChannelField.commission:
        return override.commissionPercentage != null;
      case ChannelField.markup:
        return override.rateMarkupPercentage != null;
      case ChannelField.cleaning:
        return override.cleaningCost != null;
      case ChannelField.linen:
        return override.linenCost != null;
      case ChannelField.service:
        return override.serviceCost != null;
      case ChannelField.other:
        return override.otherCost != null;
    }
  }

  /// The account tier's value for this field, as a number.
  double amountIn(ChannelConfig config) {
    switch (this) {
      case ChannelField.commission:
        return config.commissionPercentage;
      case ChannelField.markup:
        return config.rateMarkupPercentage;
      case ChannelField.cleaning:
        return config.cleaningCost.amount;
      case ChannelField.linen:
        return config.linenCost.amount;
      case ChannelField.service:
        return config.serviceCost.amount;
      case ChannelField.other:
        return config.otherCost.amount;
    }
  }

  /// How this field's cost is calculated, or null for the percentages.
  CostType? costTypeIn(ChannelConfig config) {
    switch (this) {
      case ChannelField.commission:
      case ChannelField.markup:
        return null;
      case ChannelField.cleaning:
        return config.cleaningCost.type;
      case ChannelField.linen:
        return config.linenCost.type;
      case ChannelField.service:
        return config.serviceCost.type;
      case ChannelField.other:
        return config.otherCost.type;
    }
  }

  /// [config] with this field set to [amount], keeping the cost type.
  ChannelConfig withAmount(ChannelConfig config, double amount) {
    switch (this) {
      case ChannelField.commission:
        return config.copyWith(commissionPercentage: amount);
      case ChannelField.markup:
        return config.copyWith(rateMarkupPercentage: amount);
      case ChannelField.cleaning:
        return config.copyWith(
          cleaningCost: CostEntry(
            amount: amount,
            type: config.cleaningCost.type,
          ),
        );
      case ChannelField.linen:
        return config.copyWith(
          linenCost: CostEntry(amount: amount, type: config.linenCost.type),
        );
      case ChannelField.service:
        return config.copyWith(
          serviceCost: CostEntry(amount: amount, type: config.serviceCost.type),
        );
      case ChannelField.other:
        return config.copyWith(
          otherCost: CostEntry(amount: amount, type: config.otherCost.type),
        );
    }
  }
}
