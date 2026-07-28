import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// A [StyledTextFormField] whose text is kept in sync with an external [value]
/// (which changes when the cubit resets/retranslates a field), while never
/// clobbering the user's text mid-edit. Edits are pushed via [onChanged].
class EditableContentField extends StatefulWidget {
  const EditableContentField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelTrailing,
    this.footer,
    this.hint,
    this.multiline = false,
    this.autofocus = false,
    this.numeric = false,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final Widget? labelTrailing;
  final Widget? footer;

  /// Helper line under the field — the note that says where a field lands
  /// when it is not readable as text on its own page.
  final String? hint;
  final bool multiline;
  final bool autofocus;

  /// Right-aligned, tabular value column (a shared numeric pair value).
  final bool numeric;

  /// Whether the field accepts edits. A value this language does not own —
  /// one that is shared across locales — is shown disabled; why it is
  /// disabled is said by the tag the caller puts in [labelTrailing].
  final bool enabled;

  @override
  State<EditableContentField> createState() => _EditableContentFieldState();
}

class _EditableContentFieldState extends State<EditableContentField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant EditableContentField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Adopt a value the cubit changed underneath us — a reset-to-AI, a
    // retranslate, or a discard that puts the saved text back while the field
    // still has focus. Typing is never fought: the draft echoes back exactly
    // what was typed, so the controller already holds it.
    final changedElsewhere = widget.value != oldWidget.value;
    if (widget.value != _controller.text &&
        (changedElsewhere || !_focusNode.hasFocus)) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledTextFormField(
      controller: _controller,
      focusNode: _focusNode,
      label: widget.label,
      labelTrailing: widget.labelTrailing,
      footer: widget.footer,
      helperText: widget.hint,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      maxLines: widget.multiline ? 3 : 1,
      minLines: widget.multiline ? 2 : 1,
      // A shared numeric value reads as a figure: right-aligned and tabular,
      // so a column of them lines up (README §B.2).
      textAlign: widget.numeric ? TextAlign.end : TextAlign.start,
      style: widget.numeric
          ? const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
            )
          : null,
      onChanged: widget.onChanged,
    );
  }
}
