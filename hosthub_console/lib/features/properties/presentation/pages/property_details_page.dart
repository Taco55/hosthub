import 'dart:convert';

import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/reservations/presentation/reservation_display.dart';

/// The property record (design "PROPERTY DETAILS"): what Lodgify knows about
/// this property, laid out to be read.
///
/// Read-only by design — Lodgify owns these fields — so the page draws
/// definition lists inside content cards instead of a form of disabled inputs:
/// an input, even a greyed one, still promises "this is a field you could fill
/// in", which is the one thing that is not true here.
class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  /// Design `.set-wide` on this page: `max-width:820px`. A record reads down a
  /// column — it does not need the 1040px the console's tables take.
  static const double _recordMaxWidth = 820;

  Future<PropertyDetails>? _details;
  int? _requestedPropertyId;
  bool _syncing = false;

  void _load(int propertyId) {
    _details = context.read<PropertyRepository>().fetchPropertyDetails(
      propertyId,
    );
    _requestedPropertyId = propertyId;
  }

  void _reload(int propertyId) => setState(() => _load(propertyId));

  /// Pull this one property out of Lodgify and write it onto the row.
  ///
  /// The account-wide sync only ever *discovers* properties, so without this the
  /// columns behind every card would keep their defaults for good. One property
  /// per press, on demand: the alternative — refetching all of them on every
  /// account sync — is the shape that runs into Lodgify's rate limit.
  Future<void> _sync(int propertyId, String lodgifyId) async {
    final channelManager = context.read<ChannelManagerRepository>();
    final properties = context.read<PropertyRepository>();
    setState(() => _syncing = true);

    try {
      final record = await channelManager.fetchPropertyDetails(lodgifyId);
      final saved = await properties.saveChannelDetails(
        propertyId: propertyId,
        details: record,
      );
      if (!mounted) return;
      setState(() {
        // The update returned the stored row, so the page can show it without
        // reading the same row back.
        _details = Future.value(saved);
        _requestedPropertyId = propertyId;
        _syncing = false;
      });
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: context.s.propertyDetailsSyncDone,
      );
    } catch (error, stack) {
      if (!mounted) return;
      setState(() => _syncing = false);
      // The record itself stays on screen: a failed sync means the fields are
      // old, not gone.
      await showAppError(
        context,
        AppError.fromDomain(context, DomainError.from(error, stack: stack)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final current = state.currentProperty;
        if (state.status == PropertyContextStatus.loading ||
            state.status == PropertyContextStatus.initial) {
          return _page(
            context,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (current == null) {
          return _page(context, child: Text(context.s.propertyDetailsEmpty));
        }

        if (_requestedPropertyId != current.id) _load(current.id);

        return FutureBuilder<PropertyDetails>(
          future: _details,
          builder: (context, snapshot) {
            final waiting = snapshot.connectionState == ConnectionState.waiting;
            final details = snapshot.data;

            // Before the row arrives the property picker already knows whether
            // this property is linked, so the action never has to wait to decide
            // what it is.
            final lodgifyId = (details?.lodgifyId ?? current.lodgifyId)?.trim();
            final canSync = lodgifyId != null && lodgifyId.isNotEmpty;

            return _page(
              context,
              propertyName: details?.name ?? current.name,
              canSync: canSync,
              syncedAt: details?.lodgifySyncedAt,
              onAction: waiting || _syncing
                  ? null
                  : () => canSync
                        ? _sync(current.id, lodgifyId)
                        : _reload(current.id),
              isLoading: waiting || _syncing,
              child: switch (details) {
                _ when snapshot.hasError => _LoadFailed(
                  onRetry: () => _reload(current.id),
                ),
                null => const SizedBox.shrink(),
                _ => _Record(details: details),
              },
            );
          },
        );
      },
    );
  }

  /// Design `.top`: the section crumb over a title that names the property.
  /// One helper because every state of this page wears the same header — the
  /// six copies it replaced had already drifted into the old title+sentence
  /// shape.
  Widget _page(
    BuildContext context, {
    required Widget child,
    String? propertyName,
    VoidCallback? onAction,
    bool canSync = false,
    DateTime? syncedAt,
    bool isLoading = false,
  }) {
    final s = context.s;
    return StyledWebPageScaffold(
      // Design: the cards *are* this page's surfaces. A pane card around them
      // would draw a second border around every one of them.
      decorateLeftPane: false,
      overline: s.propertyDetailsOverline,
      title: propertyName ?? s.propertyDetailsTitle,
      contentMaxWidth: _recordMaxWidth,
      isLoading: isLoading,
      actions: [
        if (onAction != null)
          _SyncAction(
            onPressed: onAction,
            canSync: canSync,
            syncedAt: syncedAt,
          ),
      ],
      // The scaffold publishes its scope around the panes, and this expression
      // runs while the scaffold is still being constructed, so the outer
      // context sits above it — hence the `Builder`.
      leftChild: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.only(
            top: context.styledSpacing.lg,
            // The page's bottom padding, spent at the end of the list, so the
            // last card does not sit against the window edge.
            bottom: StyledWebPageScaffoldScope.of(context).contentBottomInset,
          ),
          children: [child],
        ),
      ),
    );
  }
}

/// Design `.top` puts "Nu synchroniseren" here, and for a linked property that
/// is what the button does: it pulls this property out of Lodgify and writes it
/// onto the row. Without a linked Lodgify property there is nothing to pull, so
/// it falls back to what it can honestly offer — reading the row again.
///
/// The question behind the button is never "did it reload?" but "how old is
/// this?", so its tooltip answers that with this property's own sync stamp, and
/// the connection row directly below the header carries the same date in the
/// open.
class _SyncAction extends StatelessWidget {
  const _SyncAction({
    required this.onPressed,
    required this.canSync,
    required this.syncedAt,
  });

  final VoidCallback onPressed;
  final bool canSync;
  final DateTime? syncedAt;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final stamp = syncedAt;
    return Tooltip(
      message: switch (stamp) {
        _ when !canSync => s.propertyDetailsRefreshTooltip,
        null => s.propertyDetailsSyncTooltip,
        _ => s.propertyDetailsRefreshTooltipSynced(
          timeago.format(
            stamp.toLocal(),
            locale: Localizations.localeOf(context).languageCode,
          ),
        ),
      },
      // Design `.btn-sm`: 34 high, 13px sides, a 12.5px label and a 15px
      // glyph — a toolbar action, quieter than the 40-high `.btn` a form
      // submits with. Its colours are the preset's outlined button.
      child: StyledButton(
        variant: StyledButtonVariant.secondary,
        title: canSync ? s.propertyDetailsSync : s.propertyDetailsRefresh,
        showLeftIcon: true,
        leftIconData: canSync ? Icons.sync : Icons.refresh,
        minHeight: 34,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        cornerRadius: 10,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        iconSize: 15,
        onPressed: onPressed,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The record
// ---------------------------------------------------------------------------

class _Record extends StatelessWidget {
  const _Record({required this.details});

  final PropertyDetails details;

  @override
  Widget build(BuildContext context) {
    final spacing = context.styledSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LodgifyConnection(details: details),
        SizedBox(height: spacing.md),
        const _SourceNote(),
        SizedBox(height: spacing.lg),
        _AddressCard(details: details),
        SizedBox(height: spacing.lg),
        _RentalCard(details: details),
        SizedBox(height: spacing.lg),
        _RawData(details: details),
      ],
    );
  }
}

/// Design `.conn`: which Lodgify property this record mirrors, and whether the
/// link is live — the first thing to check when a field looks wrong.
class _LodgifyConnection extends StatelessWidget {
  const _LodgifyConnection({required this.details});

  final PropertyDetails details;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final lodgifyId = details.lodgifyId?.trim();
    final isLinked = lodgifyId != null && lodgifyId.isNotEmpty;

    return StyledSection(
      isFirstSection: true,
      inset: true,
      padding: EdgeInsets.zero,
      horizontalPadding: 0,
      showDividers: false,
      children: [
        StyledTile(
          leading: StyledIconBadge.monogram(
            'LG',
            size: 38,
            borderRadius: 11,
            backgroundColor: theme.colorScheme.secondary,
            iconColor: theme.colorScheme.onSecondary,
          ),
          title: 'Lodgify',
          titleStyle: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          subtitle: isLinked
              ? _linkedSummary(context, lodgifyId, details.lodgifySyncedAt)
              : s.propertyDetailsConnectionMissing,
          trailing: isLinked
              ? StatusPill(
                  label: s.propertyDetailsConnectionActive,
                  tone: StatusPillTone.positive,
                  icon: Icons.check,
                )
              : StatusPill(label: s.propertyLodgifyNotLinked),
        ),
      ],
    );
  }

  /// The date here is this property's own sync stamp, not the account's. They are
  /// different questions — the account stamp says when the console last looked
  /// for *new* properties, which tells you nothing about the age of the fields on
  /// this page. A linked property that has never been synced says exactly that,
  /// because every card below it is then showing column defaults.
  String _linkedSummary(
    BuildContext context,
    String lodgifyId,
    DateTime? syncedAt,
  ) {
    final s = context.s;
    if (syncedAt == null) {
      return s.propertyDetailsConnectionSummaryNoSync(lodgifyId);
    }
    return s.propertyDetailsConnectionSummary(
      lodgifyId,
      timeago.format(
        syncedAt.toLocal(),
        locale: Localizations.localeOf(context).languageCode,
      ),
    );
  }
}

/// Design `.srcnote`: a footnote, not a banner. It says where the page's data
/// comes from, which is the reason the page has no editable field.
class _SourceNote extends StatelessWidget {
  const _SourceNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StyledNotice(
      icon: Icons.info_outline,
      // A footnote carries no surface of its own: transparent and unpadded,
      // the notice is exactly the design's icon plus a line of muted text.
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      foregroundColor: theme.colorScheme.outline,
      child: Text(
        context.s.propertyDetailsSourceNote,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.details});

  final PropertyDetails details;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ContentCard(
      icon: Icons.location_on_outlined,
      title: s.propertyDetailsAddressCard,
      children: [
        StyledDefinitionList(
          definitions: [
            StyledDefinition(
              label: s.propertyDetailsStreet,
              value: details.address,
            ),
            StyledDefinition(label: s.propertyDetailsZip, value: details.zip),
            StyledDefinition(label: s.propertyDetailsCity, value: details.city),
            StyledDefinition(
              label: s.propertyDetailsCountry,
              value: details.country,
            ),
          ],
        ),
      ],
    );
  }
}

class _RentalCard extends StatelessWidget {
  const _RentalCard({required this.details});

  final PropertyDetails details;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final rating = details.rating;
    final priceUnitInDays = details.priceUnitInDays;

    return ContentCard(
      icon: Icons.home_work_outlined,
      title: s.propertyDetailsRentalCard,
      children: [
        StyledDefinitionList(
          definitions: [
            StyledDefinition(
              label: s.propertyDetailsRooms,
              value: _roomSummary(details.rooms, s),
            ),
            StyledDefinition(
              label: s.propertyDetailsRating,
              value: rating == null
                  ? null
                  : s.propertyDetailsRatingValue(_number(rating)),
            ),
            StyledDefinition(
              label: s.propertyDetailsPriceRange,
              value: _priceRange(details),
            ),
            StyledDefinition(
              label: s.propertyDetailsPriceUnit,
              value: priceUnitInDays == null
                  ? null
                  : s.propertyDetailsPriceUnitValue(priceUnitInDays),
            ),
            StyledDefinition(
              label: s.propertyDetailsOwnerLanguages,
              value: details.ownerSpokenLanguages?.join(', '),
            ),
            StyledDefinition(
              label: s.propertyDetailsAddons,
              value: _presence(details.hasAddons, s),
            ),
            StyledDefinition(
              label: s.propertyDetailsAgreement,
              value: _presence(details.hasAgreement, s),
            ),
          ],
        ),
      ],
    );
  }
}

/// Design `.chan` + `pre.raw`: the payload Lodgify sent, folded away. Worth
/// keeping because it is where a field the record does not name yet can still
/// be looked up — "why does the site say three nights minimum?" is answered
/// here, not in a support ticket.
class _RawData extends StatelessWidget {
  const _RawData({required this.details});

  final PropertyDetails details;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final inOut = _json(details.inOut);
    final rooms = _json(details.rooms);
    final plans = details.subscriptionPlans;

    final blocks = <(String, String)>[
      if (inOut != null) (s.propertyDetailsRawInOut, inOut),
      if (rooms != null) (s.propertyDetailsRooms, rooms),
      if (plans != null && plans.isNotEmpty)
        (s.propertyDetailsRawSubscriptions, plans.join('\n')),
    ];

    return StyledSection(
      inset: true,
      padding: EdgeInsets.zero,
      horizontalPadding: 0,
      showDividers: false,
      children: [
        StyledExpansionTile(
          title: s.propertyDetailsRawTitle,
          emphasizeTitle: true,
          // Design `.chan-hd .sum`: the closed header says what is inside, so
          // the fold is worth opening — or worth leaving shut. A quiet grey
          // line, not the emphasised value a settings row carries.
          value: Text(
            s.propertyDetailsRawSummary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.end,
          ),
          // Design `.chan-body{padding:4px 16px 16px}`.
          childrenPadding: EdgeInsets.fromLTRB(
            context.styledSpacing.lg,
            context.styledSpacing.xs,
            context.styledSpacing.lg,
            context.styledSpacing.lg,
          ),
          // `pre.raw` is block content: it fills the card's width rather than
          // shrinking to the width of its longest line.
          childrenCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (blocks.isEmpty)
              Text(
                s.propertyDetailsRawEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            for (var i = 0; i < blocks.length; i++) ...[
              if (i > 0) SizedBox(height: context.styledSpacing.lg),
              _RawLabel(label: blocks[i].$1),
              StyledCodeBlock(code: blocks[i].$2),
            ],
          ],
        ),
      ],
    );
  }
}

class _RawLabel extends StatelessWidget {
  const _RawLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: context.styledSpacing.xs),
      child: Text(
        label,
        // The design sets these sub-labels in 11.5px caps; the console keeps
        // sentence case for the same reason its table headers do (theme preset,
        // `tables`), and takes the weight and the muted colour.
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return StyledNotice(
      tone: StyledNoticeTone.error,
      icon: Icons.error_outline,
      message: s.errorGeneric,
      trailing: StyledButton(
        variant: StyledButtonVariant.secondary,
        title: s.propertyDetailsRefreshRetry,
        minHeight: 34,
        onPressed: onRetry,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Value formatting
// ---------------------------------------------------------------------------

/// Design "4 slaapkamers · 8 gasten". Lodgify's room payload has no fixed
/// shape, so this claims only what is actually in it: how many rooms, plus the
/// guest capacity when the rooms carry one. When neither can be read the row
/// stays empty and the raw block below holds the answer.
String? _roomSummary(Object? rooms, S s) {
  if (rooms is! List || rooms.isEmpty) return null;

  final parts = <String>[s.propertyDetailsRoomsCount(rooms.length)];
  var guests = 0;
  for (final room in rooms) {
    if (room is! Map) continue;
    for (final key in const [
      'max_people',
      'maxPeople',
      'sleeps',
      'people',
      'capacity',
    ]) {
      final value = room[key];
      if (value is num) {
        guests += value.toInt();
        break;
      }
    }
  }
  if (guests > 0) parts.add(s.propertyDetailsGuestsCount(guests));
  return parts.join(' · ');
}

/// Design "kr 2 400 – kr 4 100": the band Lodgify quotes for this property. One
/// price when both ends match, nothing when neither end is known.
String? _priceRange(PropertyDetails details) {
  final min = details.minPrice;
  final max = details.maxPrice;
  final currency = details.currencyCode;
  if (min == null && max == null) return null;
  if (min == null || max == null) return formatAmount(min ?? max, currency);
  if (min == max) return formatAmount(min, currency);
  return '${formatAmount(min, currency)} – ${formatAmount(max, currency)}';
}

/// Lodgify reports extras and the rental agreement as a flag, not as content,
/// so the row says whether there is one — in the design's own vocabulary.
String? _presence(bool? value, S s) {
  if (value == null) return null;
  return value ? s.propertyDetailsPresent : s.propertyDetailsAbsent;
}

String _number(num value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toString();

String? _json(Object? value) {
  if (value == null) return null;
  if (value is List && value.isEmpty) return null;
  if (value is Map && value.isEmpty) return null;
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}
