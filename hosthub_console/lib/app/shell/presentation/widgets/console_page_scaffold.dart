import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:styled_widgets/styled_widgets.dart';

class ConsolePageScaffold extends StatefulWidget {
  const ConsolePageScaffold({
    super.key,
    required this.title,
    required this.leftChild,
    this.description,
    this.actions,
    this.actionText,
    this.actionIcon,
    this.onAction,
    this.actionEnabled,
    this.actionInProgress,
    this.showActionIcon = true,
    this.leftPaneSize,
    this.rightPaneSize,
    this.rightChild,
    this.showRightPane = false,
    this.rightPaneWidth = 380,
    this.rightPaneFlexible = false,
    this.rightPaneMinWidth,
    this.rightPaneMaxWidth,
    this.rightPaneWidthFactor,
    this.isDirty = false,
    this.isSaving = false,
    this.onSave,
    this.onBack,
    this.bottom,
    this.floatingActionButton,
    this.padding = const EdgeInsets.fromLTRB(64, 24, 64, 24),
    this.contentPadding = EdgeInsets.zero,
    this.showLoadingIndicator = false,
    this.panePadding = const EdgeInsets.all(24),
    this.wrapLeftPane = true,
    this.wrapRightPane = true,
  });

  final String title;
  final String? description;
  final Widget leftChild;
  final List<Widget>? actions;
  final String? actionText;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool? actionEnabled;
  final bool? actionInProgress;
  final bool showActionIcon;
  final Widget? rightChild;

  /// Optional sizing rules for the left pane; defaults to `Expanded`.
  final AdminPaneSize? leftPaneSize;

  /// Optional sizing rules for the right pane; defaults to [rightPaneWidth].
  /// When provided, overrides [rightPaneWidth] and the legacy `rightPaneFlexible` flags.
  final AdminPaneSize? rightPaneSize;

  /// Controls whether the right pane is visible.
  final bool showRightPane;

  /// Fixed width for the right pane.
  final double rightPaneWidth;

  /// Allow the right pane to resize based on screen width.
  final bool rightPaneFlexible;

  /// Minimum width when [rightPaneFlexible] is true.
  final double? rightPaneMinWidth;

  /// Maximum width when [rightPaneFlexible] is true.
  final double? rightPaneMaxWidth;

  /// Fraction of screen width to target when [rightPaneFlexible] is true.
  final double? rightPaneWidthFactor;

  /// Generic editor meta.
  final bool isDirty;
  final bool isSaving;

  /// Called when the user presses the save button.
  final VoidCallback? onSave;

  /// Called when the user presses back or system back.
  /// Return `true` to allow navigating back, `false` to block it.
  final Future<bool> Function()? onBack;

  final Widget? bottom;
  final Widget? floatingActionButton;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final bool showLoadingIndicator;
  final EdgeInsets panePadding;
  final bool wrapLeftPane;
  final bool wrapRightPane;

  @override
  State<ConsolePageScaffold> createState() => _ConsolePageScaffoldState();
}

class _ConsolePageScaffoldState extends State<ConsolePageScaffold> {
  Future<void> _handleBack() async {
    if (!mounted) return;
    if (widget.onBack != null) {
      final allow = await widget.onBack!.call();
      if (!allow || !mounted) return;
    }
    await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primaryAction = widget.onAction ?? widget.onSave;
    final isActionBusy = widget.actionInProgress ?? widget.isSaving;
    final actionLabel =
        widget.actionText ?? (widget.isDirty ? 'Save' : 'Saved');
    final actionIconData = widget.showActionIcon
        ? (widget.actionIcon ?? Icons.save_outlined)
        : null;
    final actionIsEnabled =
        (widget.actionEnabled ?? widget.isDirty) &&
        !isActionBusy &&
        primaryAction != null;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 700;
    final effectivePadding = isCompact
        ? EdgeInsets.fromLTRB(
            math.min(widget.padding.left, 16),
            math.min(widget.padding.top, 12),
            math.min(widget.padding.right, 16),
            math.min(widget.padding.bottom, 12),
          )
        : widget.padding;
    final effectivePanePadding = isCompact
        ? EdgeInsets.all(math.min(widget.panePadding.left, 12))
        : widget.panePadding;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || widget.onBack == null) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: theme.appColors.settingsBackgroundColor,
        floatingActionButton: widget.floatingActionButton,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: effectivePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Builder(
                      builder: (context) {
                        final hasBack = widget.onBack != null;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (hasBack) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                ),
                                onPressed: _handleBack,
                                padding: const EdgeInsets.only(right: 12),
                                splashRadius: 20,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  if (widget.description != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.description!,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.actions != null) ...widget.actions!,
                                if (primaryAction != null &&
                                    widget.actions != null)
                                  const SizedBox(width: 8),
                                if (primaryAction != null)
                                  StyledButton(
                                    title: actionLabel,
                                    onPressed: primaryAction,
                                    enabled: actionIsEnabled,
                                    leftIconData: actionIconData,
                                    showLeftIcon: actionIconData != null,
                                    showProgressIndicatorWhenDisabled:
                                        isActionBusy,
                                    minHeight: 40,
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (widget.bottom != null) ...[
                      const SizedBox(height: 8),
                      widget.bottom!,
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final hasRightPane =
                              widget.showRightPane && widget.rightChild != null;
                          const gap = 12.0;
                          final availableWidth = constraints.maxWidth;
                          final usableWidth = hasRightPane
                              ? availableWidth - gap
                              : availableWidth;

                          final rightWidth = hasRightPane
                              ? _resolveRightPaneWidth(
                                  context,
                                  usableWidth,
                                ).clamp(0, usableWidth).toDouble()
                              : 0.0;
                          final leftWidth = _resolveLeftPaneWidth(
                            usableWidth,
                            rightWidth,
                          )?.clamp(0, usableWidth - rightWidth).toDouble();
                          final fallbackLeftWidth = math
                              .max(usableWidth - rightWidth, 0)
                              .toDouble();
                          final resolvedLeftWidth =
                              leftWidth ?? fallbackLeftWidth;

                          return Padding(
                            padding: widget.contentPadding,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLeftPane(
                                  resolvedLeftWidth,
                                  effectivePanePadding,
                                ),
                                if (hasRightPane) ...[
                                  const SizedBox(width: gap),
                                  SizedBox(
                                    width: rightWidth,
                                    child: widget.wrapRightPane
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .appColors
                                                    .contrastBackgroundHard,
                                                border: Border.all(
                                                  color: theme.dividerColor,
                                                ),
                                              ),
                                              child: widget.rightChild,
                                            ),
                                          )
                                        : widget.rightChild ??
                                              const SizedBox.shrink(),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showLoadingIndicator)
                Positioned(
                  top: widget.padding.top,
                  left: widget.padding.left,
                  right: widget.padding.right,
                  child: const LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPane(double? targetWidth, EdgeInsets panePadding) {
    final paneSize = widget.leftPaneSize;
    final child = widget.leftChild;

    if (targetWidth == null) {
      final wrapped = widget.wrapLeftPane
          ? _wrapPane(child, panePadding)
          : _padPane(child, panePadding);
      return Expanded(child: wrapped);
    }

    final minWidth = paneSize?.minWidth ?? 0;
    final safeMinWidth = minWidth > targetWidth ? targetWidth : minWidth;
    final maxWidth = paneSize?.maxWidth ?? double.infinity;

    final constraints = BoxConstraints(
      minWidth: safeMinWidth,
      maxWidth: maxWidth,
    );

    final wrapped = widget.wrapLeftPane
        ? _wrapPane(child, panePadding)
        : _padPane(child, panePadding);

    return ConstrainedBox(
      constraints: constraints,
      child: SizedBox(width: targetWidth, child: wrapped),
    );
  }

  Widget _wrapPane(Widget child, EdgeInsets panePadding) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appColors.contrastBackgroundHard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(padding: panePadding, child: child),
    );
  }

  Widget _padPane(Widget child, EdgeInsets panePadding) {
    if (panePadding == EdgeInsets.zero) return child;
    return Padding(padding: panePadding, child: child);
  }

  double _resolveRightPaneWidth(BuildContext context, double availableWidth) {
    final customSize = widget.rightPaneSize;
    if (customSize != null) {
      return customSize.resolve(availableWidth);
    }

    if (!widget.rightPaneFlexible) return widget.rightPaneWidth;

    const defaultFactor = 0.45;
    final factor = widget.rightPaneWidthFactor ?? defaultFactor;
    final minWidth = widget.rightPaneMinWidth ?? widget.rightPaneWidth;
    final maxWidth = widget.rightPaneMaxWidth ?? widget.rightPaneWidth;
    final targetWidth = availableWidth * factor;

    return targetWidth.clamp(minWidth, maxWidth).toDouble();
  }

  double? _resolveLeftPaneWidth(
    double availableWidth,
    double resolvedRightWidth,
  ) {
    final customSize = widget.leftPaneSize;
    if (customSize == null) return null;

    final remaining = availableWidth - resolvedRightWidth;
    if (remaining <= 0) return 0;

    return customSize
        .resolve(availableWidth, fallbackWidth: remaining)
        .clamp(0, remaining)
        .toDouble();
  }
}

/// Declarative sizing rules for admin scaffold panes.
///
/// - Use [AdminPaneSize.fixed] for a static width.
/// - Use [AdminPaneSize.flexible] to grow/shrink with the available width,
///   clamped by optional min/max values (defaults to the `baseWidth` or target width).
class AdminPaneSize {
  const AdminPaneSize._({
    this.fixedWidth,
    this.baseWidth,
    this.minWidth,
    this.maxWidth,
    this.widthFactor,
  });

  const AdminPaneSize.fixed(double width) : this._(fixedWidth: width);

  const AdminPaneSize.flexible({
    double? baseWidth,
    double widthFactor = 0.45,
    double? minWidth,
    double? maxWidth,
  }) : this._(
         baseWidth: baseWidth,
         minWidth: minWidth,
         maxWidth: maxWidth,
         widthFactor: widthFactor,
       );

  final double? fixedWidth;
  final double? baseWidth;
  final double? minWidth;
  final double? maxWidth;
  final double? widthFactor;

  bool get isFixed => fixedWidth != null;

  double resolve(double availableWidth, {double? fallbackWidth}) {
    if (isFixed) return fixedWidth!;

    final factor = widthFactor ?? 0.45;
    final targetWidth = availableWidth * factor;
    final baseline = baseWidth ?? fallbackWidth ?? targetWidth;
    final minResolved = minWidth ?? baseline;
    var maxResolved = maxWidth ?? baseline;

    // Guard against invalid clamp ranges when min is larger than max.
    if (maxResolved < minResolved) {
      maxResolved = minResolved;
    }

    return targetWidth.clamp(minResolved, maxResolved).toDouble();
  }
}
