import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';

/// What the API-key modal was asked to do.
class LodgifyApiKeyResult {
  const LodgifyApiKeyResult.save(this.apiKey) : remove = false;
  const LodgifyApiKeyResult.remove() : apiKey = null, remove = true;

  final String? apiKey;
  final bool remove;
}

/// The one credential the console stores, in one form.
///
/// [hasApiKey] says whether a key is stored; [currentApiKey] and [resolveApiKey]
/// say how to get its plaintext. They are separate on purpose — the modal used
/// to derive "a key exists" from "we hold its plaintext", which is why it opened
/// empty for every server-stored key.
///
/// Footer layout follows the one modal rule: `Verwijderen` is the deviating
/// action in the leading slot and opens a confirmation, `Annuleren` and the
/// filled `Opslaan` sit right. Removing a credential is never a filled red
/// surface beside the save button.
Future<LodgifyApiKeyResult?> showLodgifyApiKeyModal(
  BuildContext context, {
  required bool hasApiKey,
  String? currentApiKey,
  Future<String?> Function()? resolveApiKey,
}) {
  final contentKey = GlobalKey<_LodgifyApiKeyFormState>();

  return showStyledModal<LodgifyApiKeyResult>(
    context,
    title: context.s.lodgifyApiKeyLabel,
    subtitle: context.s.lodgifyApiKeyDescription,
    dismiss: const StyledModalDismiss<LodgifyApiKeyResult>(
      isDismissible: false,
    ),
    sizing: const StyledModalSizing(dialogMaxWidth: 520),
    actions: StyledModalActions.save(
      label: hasApiKey ? context.s.saveButton : context.s.add,
      cancelLabel: context.s.cancelButton,
      onPressed: () => contentKey.currentState?.submit(),
      // The leading slot exists only when there is a `Verwijderen` to put in
      // it; `Annuleren` sits next to the primary, not on the far left. It
      // destroys something, so it stays a text button and it asks first.
      leading: hasApiKey
          ? StyledModalFooterLeading.destructive(
              label: context.s.deleteButton,
              onPressed: () => contentKey.currentState?.confirmRemove(),
            )
          : null,
    ),
    // The form decides what closing means: an unchanged key closes without a
    // result, a removal closes with one.
    controls: const StyledModalControls<LodgifyApiKeyResult>(
      closeOnAction: false,
    ),
    builder: (context, modal) => _LodgifyApiKeyForm(
      key: contentKey,
      currentApiKey: currentApiKey,
      resolveApiKey: resolveApiKey,
    ),
  );
}

void _confirmRemove(
  BuildContext context,
  StyledModalController<LodgifyApiKeyResult> controller,
) {
  showStyledAlertDialog(
    context,
    title: context.s.lodgifyApiKeyRemoveTitle,
    message: context.s.lodgifyApiKeyRemoveMessage,
    actionText: context.s.deleteButton,
    dismissText: context.s.cancelButton,
    isDestructiveAction: true,
    onAction: () => controller.close(const LodgifyApiKeyResult.remove()),
  );
}

class _LodgifyApiKeyForm extends StatefulWidget {
  const _LodgifyApiKeyForm({
    super.key,
    required this.currentApiKey,
    required this.resolveApiKey,
  });

  final String? currentApiKey;
  final Future<String?> Function()? resolveApiKey;

  @override
  State<_LodgifyApiKeyForm> createState() => _LodgifyApiKeyFormState();
}

class _LodgifyApiKeyFormState extends State<_LodgifyApiKeyForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  /// The key as it was when the modal opened, so an unchanged submit does not
  /// rewrite a credential and claim it saved something.
  String _originalApiKey = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _originalApiKey = widget.currentApiKey?.trim() ?? '';
    _controller = TextEditingController(text: _originalApiKey);
    final resolve = widget.resolveApiKey;
    if (resolve != null) _prefill(resolve);
  }

  /// Fills the field with the stored key so editing starts from what is there.
  ///
  /// A failed resolve leaves the field empty and says nothing here: the cubit
  /// already put the [DomainError] in state and the page reports it. Typing a
  /// new key still works, which is what this modal is for.
  Future<void> _prefill(Future<String?> Function() resolve) async {
    setState(() => _loading = true);
    try {
      final apiKey = await resolve();
      if (!mounted) return;
      final trimmed = apiKey?.trim() ?? '';
      _originalApiKey = trimmed;
      _controller.text = trimmed;
      _controller.selection = TextSelection.collapsed(offset: trimmed.length);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Asks before removing the stored credential, then closes the modal with the
  /// removal.
  void confirmRemove() =>
      _confirmRemove(context, StyledModalController.of(context));

  /// Called by the modal's footer action.
  ///
  /// The controller comes off this form's own context rather than being handed
  /// in: the intent that drives the footer takes no arguments, and the form is a
  /// descendant of the modal that owns it.
  void submit() {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = StyledModalController.of<LodgifyApiKeyResult>(context);
    final value = _controller.text.trim();
    // Nothing changed — close without a save and without a toast.
    if (value == _originalApiKey) {
      controller.closeWithoutResult();
      return;
    }
    controller.close(LodgifyApiKeyResult.save(value));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: StyledTextFormField(
        controller: _controller,
        autofocus: true,
        // While the stored key is being fetched the field is what waits, not
        // the button: there is nothing to save yet either way.
        enabled: !_loading,
        placeholder: context.s.lodgifyApiKeyLabel,
        obscureText: true,
        // The key is prefilled, so it has to be readable — an obscured field
        // you cannot unmask is worse than an empty one.
        enablePasswordToggle: true,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return context.s.lodgifyApiKeyRequired;
          }
          return null;
        },
      ),
    );
  }
}
