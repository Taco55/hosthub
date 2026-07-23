import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// Console page scaffold.
///
/// Thin adapter over the shared [StyledWebPageScaffold]: it delegates the
/// header + dual-pane layout to the shared widget and layers on the
/// console-specific chrome (primary/save action button, loading indicator,
/// floating action button, page background and per-pane surface decoration).
///
/// Keeping this as an adapter — rather than a fork of the layout logic — means
/// the pane sizing, responsive behaviour and pane surface all stay in sync with
/// the rest of the styled apps, while the console keeps its richer editor API.
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
  /// Runs the caller's back guard (if any). Returns `true` when navigation
  /// should proceed. Does not pop itself — the caller decides.
  Future<bool> _guardBack() async {
    if (!mounted) return false;
    if (widget.onBack != null) {
      final allow = await widget.onBack!.call();
      if (!allow || !mounted) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    final scaffold = StyledWebPageScaffold(
      title: widget.title,
      description: widget.description,
      onBack: widget.onBack != null ? _guardBack : null,
      bottom: widget.bottom,
      padding: effectivePadding,
      contentPadding: widget.contentPadding,
      actions: _buildActions(),
      showRightPane: widget.showRightPane && widget.rightChild != null,
      leftPaneSize: _toStyledPaneSize(widget.leftPaneSize),
      rightPaneSize: _resolveRightPaneSize(),
      leftChild: _decorateLeftPane(widget.leftChild, effectivePanePadding),
      rightChild: widget.rightChild == null
          ? null
          : _decorateRightPane(widget.rightChild!),
    );

    Widget body = scaffold;
    if (widget.showLoadingIndicator) {
      body = Stack(
        children: [
          body,
          Positioned(
            top: effectivePadding.top,
            left: effectivePadding.left,
            right: effectivePadding.right,
            child: const LinearProgressIndicator(minHeight: 2),
          ),
        ],
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || widget.onBack == null) return;
        if (await _guardBack() && mounted) {
          await Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.appColors.settingsBackgroundColor,
        floatingActionButton: widget.floatingActionButton,
        body: body,
      ),
    );
  }

  /// Builds the header action row: the caller-provided actions followed by the
  /// primary/save button (when an action or save handler is configured).
  List<Widget>? _buildActions() {
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

    final actions = <Widget>[
      if (widget.actions != null) ...widget.actions!,
      if (primaryAction != null) ...[
        if (widget.actions != null) const SizedBox(width: 8),
        StyledButton(
          title: actionLabel,
          onPressed: primaryAction,
          enabled: actionIsEnabled,
          leftIconData: actionIconData,
          showLeftIcon: actionIconData != null,
          showProgressIndicatorWhenDisabled: isActionBusy,
          minHeight: 40,
        ),
      ],
    ];

    return actions.isEmpty ? null : actions;
  }

  /// Left pane surface: a rounded [Material] so ListTile-based children (e.g.
  /// ExpansionTile headers) can paint their background and ink splashes.
  Widget _decorateLeftPane(Widget child, EdgeInsets panePadding) {
    if (!widget.wrapLeftPane) {
      return panePadding == EdgeInsets.zero
          ? child
          : Padding(padding: panePadding, child: child);
    }
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.canvas,
      color: theme.appColors.contrastBackgroundHard,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: panePadding, child: child),
    );
  }

  /// Right pane surface: like the left pane but with a divider-coloured border.
  Widget _decorateRightPane(Widget child) {
    if (!widget.wrapRightPane) return child;
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.canvas,
      color: theme.appColors.contrastBackgroundHard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: child,
    );
  }

  /// Resolves the right pane sizing, honouring both the declarative
  /// [ConsolePageScaffold.rightPaneSize] and the legacy width/flex flags.
  StyledPaneSize? _resolveRightPaneSize() {
    if (!(widget.showRightPane && widget.rightChild != null)) return null;
    final custom = widget.rightPaneSize;
    if (custom != null) return _toStyledPaneSize(custom);

    if (widget.rightPaneFlexible) {
      return StyledPaneSize.flexible(
        widthFactor: widget.rightPaneWidthFactor ?? 0.45,
        minWidth: widget.rightPaneMinWidth ?? widget.rightPaneWidth,
        maxWidth: widget.rightPaneMaxWidth ?? widget.rightPaneWidth,
      );
    }
    return StyledPaneSize.fixed(widget.rightPaneWidth);
  }

  StyledPaneSize? _toStyledPaneSize(AdminPaneSize? size) {
    if (size == null) return null;
    if (size.isFixed) return StyledPaneSize.fixed(size.fixedWidth!);
    return StyledPaneSize.flexible(
      baseWidth: size.baseWidth,
      widthFactor: size.widthFactor ?? 0.45,
      minWidth: size.minWidth,
      maxWidth: size.maxWidth,
    );
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
}
