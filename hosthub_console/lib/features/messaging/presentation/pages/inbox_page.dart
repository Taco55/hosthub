import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/services/external_link.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/messaging/application/inbox_cubit.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';
import 'package:hosthub_console/features/messaging/presentation/inbox_display.dart';
import 'package:hosthub_console/features/messaging/presentation/widgets/inbox_conversation.dart';
import 'package:hosthub_console/features/messaging/presentation/widgets/inbox_reservation_rail.dart';
import 'package:hosthub_console/features/messaging/presentation/widgets/inbox_thread_list.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_chrome.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_refs.dart';
import 'package:hosthub_console/features/portfolio/presentation/widgets/property_filter_button.dart';
import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';
import 'package:hosthub_console/features/reservations/presentation/dialogs/reservation_details_dialog.dart';

/// Berichten: every guest conversation of every channel, in one list.
///
/// Three columns — list 346 · conversation flexible · booking rail 264 — with
/// the rail folding away below 940px of container width and the list narrowing
/// after that. There is no second filter bar: the property filter is the same
/// control Boekingen uses, with the same scope logic, and with one property it
/// is absent exactly as it is there.
///
/// Nothing in this file names a messaging source. What can and cannot be done
/// comes from [MessagingCapabilities], and every `false` gets a visible,
/// explained degradation.
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) => const _InboxView();
}

class _InboxView extends StatefulWidget {
  const _InboxView();

  @override
  State<_InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<_InboxView> {
  /// The list's own property filter, kept next to the screen rather than in the
  /// stored portfolio scope: Boekingen and Omzet each keep their own for the
  /// same reason, and narrowing one must not narrow another.
  Set<int>? _selectedPropertyIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final properties = context.read<PropertyContextCubit>().state.properties;
      _load(properties);
      // The rail reads the booking behind a conversation out of the bookings
      // the console already loads; nothing extra is fetched for this screen.
      context.read<ReservationsCubit>().loadReservations(
        properties: portfolioPropertyRefs(properties),
      );
    });
  }

  void _load(List<PropertySummary> properties, {bool refresh = false}) {
    final selection = _selectionFor(properties);
    context.read<InboxCubit>().load(
      propertyIds: selection.selectedInOrder,
      refresh: refresh,
    );
  }

  PropertySelection _selectionFor(List<PropertySummary> properties) {
    final available = [for (final property in properties) property.id];
    final selected = _selectedPropertyIds;
    if (selected == null) return PropertySelection.all(available);
    return PropertySelection.of(available, selectedPropertyIds: selected);
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = context.watch<PropertyContextCubit>().state;
    final properties = propertyState.properties;
    final chrome = PortfolioChrome(propertyCount: properties.length);
    final selection = _selectionFor(properties);

    return MultiBlocListener(
      listeners: [
        BlocListener<PropertyContextCubit, PropertyContextState>(
          listenWhen: (previous, current) =>
              previous.properties.length != current.properties.length,
          listener: (context, state) => _load(state.properties),
        ),
        BlocListener<InboxCubit, InboxState>(
          listenWhen: (previous, current) =>
              previous.error != current.error && current.error != null,
          listener: (context, state) async {
            final error = state.error;
            if (error == null) return;
            // A failed first load blocks with a retry; a failure over data that
            // is already on screen is a toast, and the data stays.
            if (state.loadFailed) return;
            showStyledToast(
              context,
              type: ToastificationType.error,
              title: context.s.inboxSyncFailed,
              action: ToastAction(
                label: context.s.inboxRetry,
                onPressed: () => _load(properties, refresh: true),
                dismissOnPressed: true,
              ),
            );
            context.read<InboxCubit>().clearError();
          },
        ),
      ],
      child: BlocBuilder<InboxCubit, InboxState>(
        builder: (context, state) {
          return StyledWebPageScaffold(
            // The three columns are the surfaces; a pane card around them adds
            // a border the design does not have.
            decorateLeftPane: false,
            overline: chrome.isSingleProperty
                ? context.s.navGroupSingleProperty
                : context.s.navGroupPortfolio,
            title: context.s.inboxTitle,
            actions: [
              if (chrome.showsPropertyFilter)
                PropertyFilterButton(
                  selection: selection,
                  options: portfolioFilterOptions(properties),
                  onChanged: (next) {
                    setState(
                      () => _selectedPropertyIds = next.selectedPropertyIds,
                    );
                    _load(properties);
                  },
                ),
            ],
            isLoading: state.isRefreshing,
            leftChild: _body(context, state: state, properties: properties),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context, {
    required InboxState state,
    required List<PropertySummary> properties,
  }) {
    if (state.status == InboxStatus.loading && state.threads.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.loadFailed) {
      return Center(
        child: StyledEmptyState(
          iconData: Icons.mark_email_unread_outlined,
          title: context.s.inboxLoadFailed,
          description: context.s.inboxLoadFailedDescription,
          actionLabel: context.s.inboxRetry,
          onAction: () => _load(properties, refresh: true),
        ),
      );
    }

    final cubit = context.read<InboxCubit>();
    final propertyNames = {
      for (final property in properties) property.id: property.name,
    };
    final abbreviations = uniquePropertyAbbreviations([
      for (final property in properties) (id: property.id, name: property.name),
    ]);
    final showPropertyChip = properties.length > 1;
    final visible = state.visibleThreads(propertyNames: propertyNames);
    final reservations = context.watch<ReservationsCubit>().state.entries;
    final selected = state.selectedThread;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showRail =
            constraints.maxWidth >= InboxReservationRail.collapseBelow;
        final radius =
            StyledWidgetsTheme.of(context).sharedLayout.cardRadius ??
            BorderRadius.circular(14);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: showRail ? InboxThreadList.width : 282,
                  child: InboxThreadList(
                    threads: visible,
                    filter: state.filter,
                    query: state.query,
                    selectedThreadId: state.selectedThreadId,
                    countFor: state.countFor,
                    propertyNames: propertyNames,
                    propertyAbbreviations: abbreviations,
                    stayFor: (thread) => _stayLabel(
                      context,
                      _reservationFor(thread, reservations),
                    ),
                    showPropertyChip: showPropertyChip,
                    onFilterChanged: cubit.changeFilter,
                    onQueryChanged: cubit.search,
                    onThreadSelected: (thread) =>
                        cubit.openThread(thread.threadId),
                  ),
                ),
                if (selected == null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(context.styledSpacing.xxl),
                        child: StyledEmptyState(
                          iconData: Icons.mark_email_unread_outlined,
                          title: context.s.inboxEmptyAll,
                          description: context.s.inboxEmptyAllHint,
                        ),
                      ),
                    ),
                  )
                else ...[
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 320),
                      child: InboxConversation(
                        thread: selected,
                        subtitle: _subtitle(
                          context,
                          thread: selected,
                          reservation: _reservationFor(selected, reservations),
                          propertyName:
                              propertyNames[selected.propertyId] ?? '',
                        ),
                        capabilities: cubit.capabilities,
                        draft: state.draftFor(selected.threadId),
                        isSending: state.isSending,
                        translatedMessageIds: state.translatedMessageIds,
                        translationsByMessageId: state.translationsByMessageId,
                        translatingThreadId: state.translatingThreadId,
                        interfaceLanguageName: _interfaceLanguageName(context),
                        onDraftChanged: (body) =>
                            cubit.updateDraft(selected.threadId, body),
                        onSend: cubit.capabilities.canSend
                            ? () => cubit.sendDraft(selected.threadId)
                            : null,
                        onOpenBooking: _openBookingHandler(
                          context,
                          _reservationFor(selected, reservations),
                        ),
                        onOpenInSource: _openInSourceHandler(
                          cubit.capabilities,
                          selected,
                        ),
                        onToggleTranslation: (message) =>
                            cubit.toggleTranslation(
                              threadId: selected.threadId,
                              messageId: message.messageId,
                              targetLanguage: Localizations.localeOf(
                                context,
                              ).languageCode,
                            ),
                        onRetryMessage: (_) =>
                            cubit.sendDraft(selected.threadId),
                      ),
                    ),
                  ),
                  if (showRail)
                    SizedBox(
                      width: InboxReservationRail.width,
                      child: InboxReservationRail(
                        thread: selected,
                        reservation: _reservationFor(selected, reservations),
                        propertyName: propertyNames[selected.propertyId] ?? '',
                        showProperty: showPropertyChip,
                        earlierBookingCount: _earlierBookings(
                          selected,
                          reservations,
                        ),
                        canArchiveAtSource: cubit.capabilities.canArchive,
                        canMarkReadAtSource: cubit.capabilities.canMarkRead,
                        sourceName: cubit.capabilities.sourceName,
                        onSnooze: (until) =>
                            cubit.snooze(selected.threadId, until),
                        onArchive: () => cubit.setArchived(
                          selected.threadId,
                          archived: true,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// The booking a conversation belongs to, or null for an enquiry that never
  /// became one.
  Reservation? _reservationFor(
    MessageThread thread,
    List<Reservation> reservations,
  ) {
    final reservationId = thread.reservationId?.trim();
    if (reservationId == null || reservationId.isEmpty) return null;
    for (final booking in reservations) {
      if (booking.reservationId?.trim() == reservationId) return booking;
    }
    return null;
  }

  /// How often this guest booked before — matched on the booker's name, which
  /// is the only identity every channel supplies.
  int _earlierBookings(MessageThread thread, List<Reservation> reservations) {
    final name = thread.guestName?.trim().toLowerCase();
    if (name == null || name.isEmpty) return 0;
    final current = thread.reservationId?.trim();
    return reservations
        .where(
          (booking) =>
              booking.guestName?.trim().toLowerCase() == name &&
              booking.reservationId?.trim() != current,
        )
        .length;
  }

  String _stayLabel(BuildContext context, Reservation? reservation) {
    if (reservation == null) return '';
    return InboxDisplay.stayRange(
      context,
      reservation.startDate,
      reservation.endDate,
    );
  }

  String _subtitle(
    BuildContext context, {
    required MessageThread thread,
    required Reservation? reservation,
    required String propertyName,
  }) {
    final channel = InboxDisplay.channelLabel(thread.channel);
    final stay = _stayLabel(context, reservation);
    if (stay.isEmpty) {
      return context.s.inboxThreadSubtitleNoStay(propertyName, channel);
    }
    return context.s.inboxThreadSubtitle(channel, stay, propertyName);
  }

  VoidCallback? _openBookingHandler(
    BuildContext context,
    Reservation? reservation,
  ) {
    if (reservation == null) return null;
    final locale = Localizations.localeOf(context).toString();
    return () => showReservationDetailsDialog(
      context,
      entry: reservation,
      dateFormatter: DateFormat('d MMM yyyy', locale),
      dateTimeFormatter: DateFormat('d MMM yyyy HH:mm', locale),
      revenue: ReservationRevenueSummary.empty,
    );
  }

  /// The way out when the console cannot do something itself. Absent — rather
  /// than dead — when the source has no address for this conversation.
  VoidCallback? _openInSourceHandler(
    MessagingCapabilities capabilities,
    MessageThread thread,
  ) {
    final link = capabilities.deepLinkFor(thread.sourceThreadId);
    if (link == null) return null;
    return () => openExternalLink(link);
  }

  /// The language the owner is reading the console in — what "Vertalen naar …"
  /// offers.
  static String _interfaceLanguageName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return switch (locale.languageCode) {
      'nl' => 'Nederlands',
      'en' => 'English',
      _ => locale.languageCode.toUpperCase(),
    };
  }
}
