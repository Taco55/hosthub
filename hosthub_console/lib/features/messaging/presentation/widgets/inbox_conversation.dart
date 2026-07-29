import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';
import 'package:hosthub_console/features/messaging/presentation/inbox_display.dart';

/// The middle column: the conversation itself and the composer under it.
class InboxConversation extends StatelessWidget {
  const InboxConversation({
    super.key,
    required this.thread,
    required this.subtitle,
    required this.capabilities,
    required this.draft,
    required this.isSending,
    required this.translatedMessageIds,
    required this.translationsByMessageId,
    required this.translatingThreadId,
    required this.interfaceLanguageName,
    required this.onDraftChanged,
    required this.onSend,
    required this.onOpenBooking,
    required this.onOpenInSource,
    required this.onToggleTranslation,
    required this.onRetryMessage,
  });

  final MessageThread thread;

  /// `property · data · via kanaal`, already composed by the page.
  final String subtitle;

  final MessagingCapabilities capabilities;
  final String draft;
  final bool isSending;
  final Set<String> translatedMessageIds;
  final Map<String, String> translationsByMessageId;
  final String? translatingThreadId;

  /// The language the owner reads, for the "Vertalen naar …" line.
  final String interfaceLanguageName;

  final ValueChanged<String> onDraftChanged;
  final VoidCallback? onSend;

  /// Null when the conversation hangs off no booking — then there is nothing
  /// to open and the button is absent rather than dead.
  final VoidCallback? onOpenBooking;

  final VoidCallback? onOpenInSource;
  final ValueChanged<Message> onToggleTranslation;
  final ValueChanged<Message> onRetryMessage;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            thread: thread,
            subtitle: subtitle,
            onOpenBooking: onOpenBooking,
          ),
          Expanded(
            child: _MessageStream(
              thread: thread,
              translatedMessageIds: translatedMessageIds,
              translationsByMessageId: translationsByMessageId,
              isTranslating: translatingThreadId == thread.threadId,
              interfaceLanguageName: interfaceLanguageName,
              onToggleTranslation: onToggleTranslation,
              onRetryMessage: onRetryMessage,
            ),
          ),
          _Composer(
            thread: thread,
            capabilities: capabilities,
            draft: draft,
            isSending: isSending,
            onDraftChanged: onDraftChanged,
            onSend: onSend,
            onOpenInSource: onOpenInSource,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.thread,
    required this.subtitle,
    required this.onOpenBooking,
  });

  final MessageThread thread;
  final String subtitle;
  final VoidCallback? onOpenBooking;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final spacing = context.styledSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xl,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          BookingSourceIcon(source: thread.channel.sourceKey, size: 36),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  thread.guestName ?? InboxDisplay.channelLabel(thread.channel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // The booking detail modal already exists; there is no second view of
          // the same reservation.
          if (onOpenBooking != null) ...[
            SizedBox(width: spacing.md),
            StyledButton(
              title: context.s.inboxOpenBooking,
              size: StyledButtonSize.compact,
              variant: StyledButtonVariant.secondary,
              showLeftIcon: true,
              leftIconData: Icons.calendar_today_outlined,
              onPressed: onOpenBooking,
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageStream extends StatelessWidget {
  const _MessageStream({
    required this.thread,
    required this.translatedMessageIds,
    required this.translationsByMessageId,
    required this.isTranslating,
    required this.interfaceLanguageName,
    required this.onToggleTranslation,
    required this.onRetryMessage,
  });

  final MessageThread thread;
  final Set<String> translatedMessageIds;
  final Map<String, String> translationsByMessageId;
  final bool isTranslating;
  final String interfaceLanguageName;
  final ValueChanged<Message> onToggleTranslation;
  final ValueChanged<Message> onRetryMessage;

  @override
  Widget build(BuildContext context) {
    final spacing = context.styledSpacing;
    if (thread.messages.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: StyledEmptyState.inline(title: context.s.inboxEmptyConversation),
      );
    }

    final entries = _withDaySeparators(thread.messages);

    return ListView.separated(
      padding: EdgeInsets.all(spacing.xl),
      itemCount: entries.length,
      separatorBuilder: (_, _) => SizedBox(height: spacing.md),
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.day != null) {
          return Center(
            child: Text(
              InboxDisplay.daySeparator(context, entry.day!),
              style: context.theme.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        }
        final message = entry.message!;
        return _Bubble(
          message: message,
          // The channel can change inside one thread the moment a guest comes
          // back through another path, so every bubble says which one it was.
          channel: message.channel == MessageChannel.other
              ? thread.channel
              : message.channel,
          translation: translatedMessageIds.contains(message.messageId)
              ? translationsByMessageId[message.messageId]
              : null,
          isTranslating: isTranslating,
          interfaceLanguageName: interfaceLanguageName,
          onToggleTranslation: () => onToggleTranslation(message),
          onRetry: () => onRetryMessage(message),
        );
      },
    );
  }

  static List<_StreamEntry> _withDaySeparators(List<Message> messages) {
    final entries = <_StreamEntry>[];
    DateTime? currentDay;
    for (final message in messages) {
      final day = DateTime(
        message.sentAt.toLocal().year,
        message.sentAt.toLocal().month,
        message.sentAt.toLocal().day,
      );
      if (currentDay != day) {
        currentDay = day;
        entries.add(_StreamEntry.day(day));
      }
      entries.add(_StreamEntry.message(message));
    }
    return entries;
  }
}

class _StreamEntry {
  const _StreamEntry.day(this.day) : message = null;
  const _StreamEntry.message(this.message) : day = null;

  final DateTime? day;
  final Message? message;
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.channel,
    required this.translation,
    required this.isTranslating,
    required this.interfaceLanguageName,
    required this.onToggleTranslation,
    required this.onRetry,
  });

  final Message message;
  final MessageChannel channel;
  final String? translation;
  final bool isTranslating;
  final String interfaceLanguageName;
  final VoidCallback onToggleTranslation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final spacing = context.styledSpacing;
    final styled = StyledWidgetsTheme.of(context);
    final isHost = !message.isInbound;
    // The card radius is the app's, resolved once; a bubble is a small card.
    final radius =
        styled.sharedLayout.cardRadius
            ?.resolve(Directionality.of(context))
            .topLeft ??
        const Radius.circular(14);

    return Align(
      alignment: isHost ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: isHost
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.md - 1,
              ),
              decoration: BoxDecoration(
                color: isHost ? colors.primary : colors.surface,
                border: Border.all(
                  color: isHost ? colors.primary : colors.outlineVariant,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: isHost ? radius : const Radius.circular(5),
                  topRight: isHost ? const Radius.circular(5) : radius,
                  bottomLeft: radius,
                  bottomRight: radius,
                ),
              ),
              child: Text(
                // The translation replaces the text only while the reader asked
                // for it; the original is one tap away and stays the record.
                translation ?? message.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isHost ? colors.onPrimary : colors.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: spacing.xs),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xs),
              child: Wrap(
                spacing: spacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _meta(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (message.isInbound)
                    StyledTextButton(
                      title: translation != null
                          ? context.s.inboxShowOriginal
                          : context.s.inboxTranslate(interfaceLanguageName),
                      enabled: !isTranslating,
                      onPressed: onToggleTranslation,
                    ),
                  if (message.hasFailed) ...[
                    Text(
                      context.s.inboxMessageNotSent,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    StyledTextButton(
                      title: context.s.inboxRetry,
                      onPressed: onRetry,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _meta(BuildContext context) {
    final time = DateFormat(
      'HH:mm',
      Localizations.localeOf(context).toString(),
    ).format(message.sentAt.toLocal());
    final author = message.authorName ?? InboxDisplay.channelLabel(channel);
    return '$author · ${InboxDisplay.channelLabel(channel)} · $time';
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.thread,
    required this.capabilities,
    required this.draft,
    required this.isSending,
    required this.onDraftChanged,
    required this.onSend,
    required this.onOpenInSource,
  });

  final MessageThread thread;
  final MessagingCapabilities capabilities;
  final String draft;
  final bool isSending;
  final ValueChanged<String> onDraftChanged;
  final VoidCallback? onSend;
  final VoidCallback? onOpenInSource;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.draft,
  );

  @override
  void didUpdateWidget(covariant _Composer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switching conversations swaps the draft under the field; typing must not
    // reset the cursor, so only an actual difference is written back.
    if (widget.draft != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.draft,
        selection: TextSelection.collapsed(offset: widget.draft.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _useQuickReply(String text) {
    // A quick reply *fills* the field; it never sends. The owner still owns
    // the words that leave.
    final next = _controller.text.trim().isEmpty
        ? text
        : '${_controller.text.trimRight()}\n\n$text';
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    widget.onDraftChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final spacing = context.styledSpacing;
    final canSend = widget.capabilities.canSend;
    final channelName = InboxDisplay.channelLabel(widget.thread.channel);
    final quickReplies = [
      context.s.inboxQuickReplyCheckIn,
      context.s.inboxQuickReplyDirections,
      context.s.inboxQuickReplyAvailability,
      context.s.inboxQuickReplyThanks,
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        spacing.xl,
        spacing.md,
        spacing.xl,
        spacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (final reply in quickReplies)
                StyledChip(
                  label: _shorten(reply),
                  size: StyledChipSize.display,
                  onTap: () => _useQuickReply(reply),
                ),
            ],
          ),
          SizedBox(height: spacing.sm),
          StyledTextField(
            controller: _controller,
            enabled: !widget.isSending,
            maxLines: 3,
            minLines: 3,
            placeholder: context.s.inboxReplyHint(
              widget.thread.guestName ?? channelName,
              channelName,
            ),
            onChanged: widget.onDraftChanged,
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  // The honest line either way: which channel carries the
                  // reply, or that this source cannot carry one at all.
                  canSend
                      ? context.s.inboxReplyVia(channelName)
                      : context.s.inboxSendUnsupported(
                          widget.capabilities.sourceName,
                        ),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              if (!canSend && widget.onOpenInSource != null)
                StyledButton(
                  title: context.s.inboxOpenInSource(
                    widget.capabilities.sourceName,
                  ),
                  size: StyledButtonSize.compact,
                  variant: StyledButtonVariant.secondary,
                  showLeftIcon: true,
                  leftIconData: Icons.open_in_new,
                  onPressed: widget.onOpenInSource,
                ),
              if (canSend) ...[
                SizedBox(width: spacing.sm),
                StyledButton(
                  title: context.s.inboxSend,
                  size: StyledButtonSize.compact,
                  enabled: widget.onSend != null && !widget.isSending,
                  showProgressIndicatorWhenDisabled: widget.isSending,
                  onPressed: widget.onSend,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// A chip is a handle, not the message. The full text lands in the field.
  static String _shorten(String reply) {
    final firstSentence = reply.split(RegExp(r'[.!?]')).first.trim();
    if (firstSentence.length <= 34) return firstSentence;
    return '${firstSentence.substring(0, 33)}…';
  }
}
