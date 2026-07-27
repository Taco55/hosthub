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
    this.multiline = false,
    this.autofocus = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final Widget? labelTrailing;
  final Widget? footer;
  final bool multiline;
  final bool autofocus;

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
      autofocus: widget.autofocus,
      maxLines: widget.multiline ? 3 : 1,
      minLines: widget.multiline ? 2 : 1,
      onChanged: widget.onChanged,
    );
  }
}
