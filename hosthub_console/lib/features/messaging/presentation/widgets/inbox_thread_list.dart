import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/messaging/application/inbox_cubit.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';
import 'package:hosthub_console/features/messaging/presentation/inbox_display.dart';

/// The left column: search, the three filters with their counts, and one row
/// per conversation.
class InboxThreadList extends StatelessWidget {
  const InboxThreadList({
    super.key,
    required this.threads,
    required this.filter,
    required this.query,
    required this.selectedThreadId,
    required this.countFor,
    required this.propertyNames,
    required this.propertyAbbreviations,
    required this.stayFor,
    required this.showPropertyChip,
    required this.onFilterChanged,
    required this.onQueryChanged,
    required this.onThreadSelected,
  });

  final List<MessageThread> threads;
  final InboxFilter filter;
  final String query;
  final String? selectedThreadId;
  final int Function(InboxFilter filter) countFor;
  final Map<int, String> propertyNames;
  final Map<int, String> propertyAbbreviations;

  /// The stay behind a thread, already formatted — the list does not go looking
  /// for bookings itself.
  final String Function(MessageThread thread) stayFor;

  /// One property means no property UI anywhere, the same rule the booking
  /// screens follow.
  final bool showPropertyChip;

  final ValueChanged<InboxFilter> onFilterChanged;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MessageThread> onThreadSelected;

  static const double width = 346;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Tools(
            filter: filter,
            query: query,
            countFor: countFor,
            onFilterChanged: onFilterChanged,
            onQueryChanged: onQueryChanged,
          ),
          Expanded(
            child: threads.isEmpty
                ? _EmptyList(filter: filter, query: query)
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: threads.length,
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      return _ThreadRow(
                        thread: thread,
                        selected: thread.threadId == selectedThreadId,
                        propertyAbbreviation:
                            propertyAbbreviations[thread.propertyId] ?? '??',
                        showPropertyChip: showPropertyChip,
                        stay: stayFor(thread),
                        onTap: () => onThreadSelected(thread),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Tools extends StatefulWidget {
  const _Tools({
    required this.filter,
    required this.query,
    required this.countFor,
    required this.onFilterChanged,
    required this.onQueryChanged,
  });

  final InboxFilter filter;
  final String query;
  final int Function(InboxFilter filter) countFor;
  final ValueChanged<InboxFilter> onFilterChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  State<_Tools> createState() => _ToolsState();
}

class _ToolsState extends State<_Tools> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.query,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.styledSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StyledSearchField(
            controller: _searchController,
            placeholder: context.s.inboxSearchHint,
            // Every character narrows: with three columns on screen there is
            // no cost to searching as you type.
            minSearchCharacters: 0,
            onSearch: widget.onQueryChanged,
            onCleared: () => widget.onQueryChanged(''),
          ),
          SizedBox(height: spacing.sm),
          StyledSegmentedControl(
            expand: true,
            minSegmentWidth: 0,
            segments: [
              for (final option in InboxFilter.values)
                StyledSegment(
                  label: _label(context, option),
                  // A count is a fact about the segment, not a change worth
                  // noticing — quiet, so it never outshouts the selection.
                  badge: widget.countFor(option) == 0
                      ? null
                      : widget.countFor(option).toString(),
                  badgeStyle: StyledSegmentBadgeStyle.quiet,
                ),
            ],
            selectedIndex: InboxFilter.values.indexOf(widget.filter),
            onChanged: (index) =>
                widget.onFilterChanged(InboxFilter.values[index]),
          ),
        ],
      ),
    );
  }

  static String _label(BuildContext context, InboxFilter filter) {
    return switch (filter) {
      InboxFilter.all => context.s.inboxFilterAll,
      InboxFilter.unread => context.s.inboxFilterUnread,
      InboxFilter.action => context.s.inboxFilterAction,
    };
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({
    required this.thread,
    required this.selected,
    required this.propertyAbbreviation,
    required this.showPropertyChip,
    required this.stay,
    required this.onTap,
  });

  final MessageThread thread;
  final bool selected;
  final String propertyAbbreviation;
  final bool showPropertyChip;
  final String stay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final spacing = context.styledSpacing;
    final unread = thread.isUnread;

    return Material(
      // Selection is the only thing that colours a row. Unread is weight and a
      // dot: two meanings in one colour is one too many.
      color: selected ? colors.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingSourceIcon(source: thread.channel.sourceKey, size: 32),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            thread.guestName ??
                                InboxDisplay.channelLabel(thread.channel),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          InboxDisplay.relativeTime(
                            context,
                            thread.lastMessageAt,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (showPropertyChip || stay.isNotEmpty) ...[
                      SizedBox(height: spacing.xs),
                      Row(
                        children: [
                          if (showPropertyChip) ...[
                            PropertyChip(
                              abbreviation: propertyAbbreviation,
                              size: 20,
                              borderRadius: 6,
                            ),
                            SizedBox(width: spacing.sm),
                          ],
                          if (stay.isNotEmpty)
                            Flexible(
                              child: Text(
                                stay,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if ((thread.lastMessagePreview ?? '').isNotEmpty) ...[
                      SizedBox(height: spacing.xs),
                      Text(
                        thread.lastMessagePreview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: unread
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.sm),
                    StatusPill(
                      label: thread.awaitingHost
                          ? context.s.inboxTagAwaiting
                          : context.s.inboxTagAnswered,
                      tone: thread.awaitingHost
                          ? StatusPillTone.caution
                          : StatusPillTone.positive,
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                SizedBox(width: spacing.sm),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// An empty list is never a blank column: it says which emptiness this is.
class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.filter, required this.query});

  final InboxFilter filter;
  final String query;

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter != InboxFilter.all || query.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.all(context.styledSpacing.xl),
      child: StyledEmptyState.inline(
        title: isFiltered
            ? context.s.inboxEmptyFiltered
            : context.s.inboxEmptyAll,
        description: isFiltered
            ? context.s.inboxEmptyFilteredHint
            : context.s.inboxEmptyAllHint,
      ),
    );
  }
}
