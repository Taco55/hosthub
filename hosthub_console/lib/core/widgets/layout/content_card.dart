import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// The design's `.card`: a bordered surface whose header — an icon badge plus a
/// title — sits *inside* the card, above its content.
///
/// Unlike the theme's default tile-group section, which hugs its rows, a
/// content card is padded on all four sides: it holds a block of content (a
/// form, a definition list) rather than full-bleed rows.
///
/// One definition for every card in the console, so the editor's Hero card and
/// the property record's Address card can never drift apart.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
    this.headerTrailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  /// The line under the title, where a card has one. Null keeps the header to
  /// its title: a subtitle that restates the title is noise.
  final String? subtitle;

  /// Right-hand slot in the header — a `N gewijzigd` rollup, a source badge.
  final Widget? headerTrailing;

  /// `.card{padding:18px}` — the card's own inset, on all four sides.
  static const double _cardPadding = 18;

  /// `.cardhd{margin-bottom:14px}` — header to content.
  static const double _headerSpacing = 14;

  @override
  Widget build(BuildContext context) {
    return StyledSection(
      inset: true,
      // Flush with the column's own gutter instead of adding the theme's 24px
      // section inset on top of it.
      horizontalPadding: 0,
      // No outer padding: the theme's 24px section top would stack on top of
      // the column's own 16px between cards, and `.card{margin-bottom:16px}`
      // is the whole gap.
      padding: EdgeInsets.zero,
      headerInsideGroup: true,
      // `innerPadding` is applied to each non-tile child, not once around the
      // group: `EdgeInsets.all(18)` would put 18px above *and* below every
      // child, so two fields would sit 18+16+18 = 52px apart where
      // `.field{margin-bottom:16px}` asks for 16. Horizontal only here; the
      // card's own 18px top and bottom come from the header padding and the
      // trailing spacer below.
      innerPadding: const EdgeInsets.symmetric(horizontal: _cardPadding),
      headerInsidePadding: const EdgeInsets.fromLTRB(
        0,
        _cardPadding,
        0,
        _headerSpacing,
      ),
      header: Row(
        children: [
          StyledIconBadge(icon: icon, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (headerTrailing != null) ...[
            const SizedBox(width: 12),
            headerTrailing!,
          ],
        ],
      ),
      showDividers: false,
      // `.card{padding:18px}` bottom — the group has no vertical padding of
      // its own now that `innerPadding` is horizontal.
      children: [
        ...children,
        const SizedBox(height: _cardPadding),
      ],
    );
  }
}
