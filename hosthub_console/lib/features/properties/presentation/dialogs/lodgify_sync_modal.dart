import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/domain/lodgify_sync_plan.dart';

/// What the sync found, and one action that applies all of it.
///
/// The modal decides nothing: [LodgifySyncPlan] already resolved every listing
/// against the properties that exist, so each row only has to say what applying
/// would do to it. Returns true when the owner applied.
///
/// The name-match row is the reason this screen exists. A listing whose name
/// matches a property made by hand used to be counted as "not new" and then
/// quietly skipped — so it was never added *and* never linked. It is now a
/// `Koppelen` row: the property keeps its website content and gains its
/// `lodgify_id`.
Future<bool> showLodgifySyncModal(
  BuildContext context, {
  required LodgifySyncPlan plan,
}) async {
  // Recorded by the primary and read after the shell closed the modal: the
  // decision is a side effect of confirming, not a value the body collects.
  var applied = false;

  await showStyledModal<void>(
    context,
    title: context.s.lodgifySyncResultTitle,
    subtitle: _outcome(context, plan),
    dismiss: const StyledModalDismiss<void>(isDismissible: false),
    sizing: const StyledModalSizing(
      dialogMaxWidth: 560,
      // The body is one StyledSection, which brings its own padding.
      contentPadding: EdgeInsets.zero,
      bodyMaxHeight: 420,
    ),
    // With work to apply this is a confirmation; without it the modal only
    // states an outcome, so it gets an outline `Sluiten` and no filled call to
    // action.
    actions: plan.hasWork
        ? StyledModalActions.confirm(
            label: _applyLabel(context, plan),
            cancelLabel: context.s.cancelButton,
            onPressed: () => applied = true,
          )
        : StyledModalActions.readOnly(label: context.s.closeButton),
    builder: (context, modal) => StyledSection(
      isFirstSection: true,
      children: [for (final entry in plan.listings) _ListingRow(entry: entry)],
    ),
  );

  return applied;
}

/// The counts, as a sentence under the title — never in the button label.
String _outcome(BuildContext context, LodgifySyncPlan plan) {
  if (!plan.hasWork) return context.s.lodgifyNoNewPropertiesFound;
  final parts = [
    if (plan.toCreate.isNotEmpty)
      context.s.lodgifySyncOutcomeNew(plan.toCreate.length),
    if (plan.toLink.isNotEmpty)
      context.s.lodgifySyncOutcomeLink(plan.toLink.length),
  ];
  return parts.join(' · ');
}

/// Repeats the verb: `Toevoegen`, `Koppelen`, or both.
String _applyLabel(BuildContext context, LodgifySyncPlan plan) {
  if (plan.toCreate.isEmpty) return context.s.lodgifySyncLinkAction;
  if (plan.toLink.isEmpty) return context.s.lodgifySyncAddAction;
  return context.s.lodgifySyncAddAndLinkAction;
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({required this.entry});

  final LodgifyListingPlan entry;

  @override
  Widget build(BuildContext context) {
    return switch (entry.action) {
      LodgifyListingAction.create => StyledTile(
        title: entry.label,
        value: StatusPill(
          label: context.s.lodgifySyncStateNew,
          tone: StatusPillTone.info,
        ),
      ),
      LodgifyListingAction.link => StyledTile(
        title: entry.label,
        subtitle: context.s.lodgifySyncLinkSubtitle(entry.existing?.name ?? ''),
        value: StatusPill(
          label: context.s.lodgifySyncStateLink,
          tone: StatusPillTone.info,
        ),
      ),
      LodgifyListingAction.linked => StyledTile(
        title: entry.label,
        value: StatusPill(
          label: context.s.lodgifySyncStateLinked,
          tone: StatusPillTone.positive,
          icon: Icons.check,
        ),
      ),
    };
  }
}
