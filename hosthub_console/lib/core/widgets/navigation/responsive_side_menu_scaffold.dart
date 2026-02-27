import 'package:flutter/material.dart';

typedef ResponsiveSideMenuBuilder =
    Widget Function(
      BuildContext context,
      bool isPinned,
      VoidCallback closeDrawer,
    );

typedef ResponsiveSideBodyBuilder =
    Widget Function(BuildContext context, bool isPinned);

typedef ResponsiveSideAppBarBuilder =
    PreferredSizeWidget? Function(
      BuildContext context,
      bool isPinned,
      VoidCallback openDrawer,
    );

/// A scaffold that keeps a custom side menu pinned on large screens and turns it
/// into a drawer when the available width gets smaller than [breakpoint].
///
/// The widget is intentionally opinionated: it only controls how the side menu
/// is shown, while the caller retains full control over the app bar and body.
class ResponsiveSideMenuScaffold extends StatefulWidget {
  const ResponsiveSideMenuScaffold({
    super.key,
    required this.menuBuilder,
    required this.bodyBuilder,
    this.appBarBuilder,
    this.breakpoint = 1100,
    this.menuWidth = 320,
    this.backgroundColor,
    this.contentBackgroundColor,
    this.menuBackgroundColor,
    this.pinnedMenuDecoration,
    this.menuSeparator,
    this.menuSafeArea = true,
    this.extendBodyBehindAppBar = false,
    this.drawerElevation,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  /// Builds the side menu.
  ///
  /// [isPinned] indicates whether the menu is currently rendered side-by-side
  /// or inside a drawer. The provided [closeDrawer] callback closes the drawer
  /// when it's open (it is a no-op when the menu is pinned).
  final ResponsiveSideMenuBuilder menuBuilder;

  /// Builds the main body next to (or below) the menu.
  final ResponsiveSideBodyBuilder bodyBuilder;

  /// Custom builder for the [AppBar]. If omitted, a minimal AppBar that only
  /// shows the drawer icon on narrow screens is used.
  final ResponsiveSideAppBarBuilder? appBarBuilder;

  /// Screen width threshold for pinning the side menu.
  final double breakpoint;

  /// Width of the menu when it is pinned.
  final double menuWidth;

  /// Background color passed to the underlying [Scaffold].
  final Color? backgroundColor;

  /// Optional background color for the pinned menu container.
  final Color? menuBackgroundColor;

  /// Optional decoration for the pinned menu container.
  final BoxDecoration? pinnedMenuDecoration;

  /// Optional separator widget rendered between a pinned menu and the body.
  final Widget? menuSeparator;

  /// Background color for the body container.
  final Color? contentBackgroundColor;

  /// Wraps the menu in a [SafeArea] when true.
  final bool menuSafeArea;

  /// Mirrors the corresponding property on [Scaffold].
  final bool extendBodyBehindAppBar;

  /// Mirrors the corresponding property on [Drawer].
  final double? drawerElevation;

  /// Mirrors the corresponding property on [Scaffold].
  final Widget? floatingActionButton;

  /// Mirrors the corresponding property on [Scaffold].
  final Widget? bottomNavigationBar;

  /// Returns true when the screen width exceeds [breakpoint].
  static bool isPinned(BuildContext context, double breakpoint) {
    return MediaQuery.of(context).size.width >= breakpoint;
  }

  @override
  State<ResponsiveSideMenuScaffold> createState() =>
      _ResponsiveSideMenuScaffoldState();
}

class _ResponsiveSideMenuScaffoldState
    extends State<ResponsiveSideMenuScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isPinned =>
      ResponsiveSideMenuScaffold.isPinned(context, widget.breakpoint);

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();
  void _closeDrawer() => _scaffoldKey.currentState?.closeDrawer();

  @override
  Widget build(BuildContext context) {
    final isPinned = _isPinned;
    final closeDrawer = isPinned ? () {} : _closeDrawer;
    final menu = _buildMenu(context, isPinned, closeDrawer);
    final appBar =
        widget.appBarBuilder?.call(context, isPinned, _openDrawer) ??
        (isPinned ? null : _DefaultResponsiveAppBar(openDrawer: _openDrawer));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: appBar,
      drawer:
          isPinned
              ? null
              : (menu is Drawer
                  ? menu
                  : Drawer(
                      elevation: widget.drawerElevation,
                      width: widget.menuWidth,
                      child: menu,
                    )),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Row(
        children: [
          if (isPinned)
            Container(
              width: widget.menuWidth,
              decoration: widget.pinnedMenuDecoration,
              color: widget.menuBackgroundColor,
              child: menu,
            ),
          if (isPinned && widget.menuSeparator != null) widget.menuSeparator!,
          Expanded(
            child: Container(
              color: widget.contentBackgroundColor,
              child: widget.bodyBuilder(context, isPinned),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(
    BuildContext context,
    bool isPinned,
    VoidCallback closeDrawer,
  ) {
    final menu = widget.menuBuilder(context, isPinned, closeDrawer);
    if (!widget.menuSafeArea) return menu;
    return SafeArea(
      top: !widget.extendBodyBehindAppBar,
      bottom: true,
      left: true,
      right: false,
      child: menu,
    );
  }
}

class _DefaultResponsiveAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _DefaultResponsiveAppBar({required this.openDrawer});

  final VoidCallback openDrawer;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.menu), onPressed: openDrawer),
    );
  }
}
