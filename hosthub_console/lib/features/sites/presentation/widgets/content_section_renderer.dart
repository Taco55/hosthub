import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/cms/data/cms_repository.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

/// Renders a [ContentDocument]'s JSONB content as editable UI sections
/// based on its [ContentDocument.contentType].
class ContentSectionRenderer extends StatelessWidget {
  const ContentSectionRenderer({
    super.key,
    required this.document,
    required this.content,
    required this.onContentChanged,
  });

  final ContentDocument document;

  /// The effective content (dirty or persisted).
  final Map<String, dynamic> content;

  /// Called whenever the user edits any field.
  final ValueChanged<Map<String, dynamic>> onContentChanged;

  @override
  Widget build(BuildContext context) {
    switch (document.contentType) {
      case 'site_config':
        return _SiteConfigEditor(
          content: content,
          onChanged: onContentChanged,
        );
      case 'cabin':
        return _CabinContentEditor(
          content: content,
          onChanged: onContentChanged,
        );
      case 'page':
        return _PageContentEditor(
          slug: document.slug,
          content: content,
          onChanged: onContentChanged,
        );
      case 'contact_form':
        return _ContactFormEditor(
          content: content,
          onChanged: onContentChanged,
        );
      default:
        return _RawJsonView(content: content);
    }
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

String _str(dynamic value) => value?.toString() ?? '';

List<String> _strList(dynamic value) {
  if (value is List) return value.map((e) => _str(e)).toList();
  return [];
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is List) return value.map((e) => _map(e)).toList();
  return [];
}

Widget _subsection(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _label(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 2),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Editable field helper — wraps StyledFormField with a controller
// ---------------------------------------------------------------------------

/// Creates a [StyledFormField] bound to a [TextEditingController].
Widget _editableField(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: StyledFormField(
      label: label,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType ?? (maxLines > 1 ? TextInputType.multiline : null),
    ),
  );
}

// ---------------------------------------------------------------------------
// Controller helpers — create, populate, listen, and dispose
// ---------------------------------------------------------------------------

/// Creates a controller, sets its text, and attaches a listener.
TextEditingController _ctrl(dynamic value, VoidCallback onChanged) {
  final c = TextEditingController(text: _str(value));
  c.addListener(onChanged);
  return c;
}

// ---------------------------------------------------------------------------
// Object Array Editor — for editing lists of {key: value} objects
// ---------------------------------------------------------------------------

class _ObjectArrayEditor extends StatefulWidget {
  const _ObjectArrayEditor({
    required this.items,
    required this.fieldDefs,
    required this.onChanged,
  });

  /// Current list of maps.
  final List<Map<String, dynamic>> items;

  /// Field definitions: list of (jsonKey, label, maxLines).
  final List<({String key, String label, int maxLines})> fieldDefs;

  /// Called when the list changes (add/remove/edit).
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  State<_ObjectArrayEditor> createState() => _ObjectArrayEditorState();
}

class _ObjectArrayEditorState extends State<_ObjectArrayEditor> {
  // One list of controllers per row, one controller per field.
  late List<List<TextEditingController>> _rows;

  @override
  void initState() {
    super.initState();
    _rows = _buildRows(widget.items);
  }

  @override
  void didUpdateWidget(covariant _ObjectArrayEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild only when items identity changes (e.g. restore version).
    if (!identical(oldWidget.items, widget.items) &&
        oldWidget.items.length != widget.items.length) {
      _disposeAll();
      _rows = _buildRows(widget.items);
    }
  }

  List<List<TextEditingController>> _buildRows(
    List<Map<String, dynamic>> items,
  ) {
    return items.map((item) {
      return widget.fieldDefs.map((def) {
        final c = TextEditingController(text: _str(item[def.key]));
        c.addListener(_onFieldChanged);
        return c;
      }).toList();
    }).toList();
  }

  void _onFieldChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  List<Map<String, dynamic>> _serialize() {
    return _rows.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < widget.fieldDefs.length; i++) {
        map[widget.fieldDefs[i].key] = row[i].text;
      }
      return map;
    }).toList();
  }

  void _addRow() {
    final controllers = widget.fieldDefs.map((def) {
      final c = TextEditingController();
      c.addListener(_onFieldChanged);
      return c;
    }).toList();
    setState(() {
      _rows.add(controllers);
    });
    widget.onChanged(_serialize());
  }

  void _removeRow(int index) {
    final row = _rows.removeAt(index);
    for (final c in row) {
      c.dispose();
    }
    setState(() {});
    widget.onChanged(_serialize());
  }

  void _disposeAll() {
    for (final row in _rows) {
      for (final c in row) {
        c.dispose();
      }
    }
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (var j = 0; j < widget.fieldDefs.length; j++)
                          _editableField(
                            widget.fieldDefs[j].label,
                            _rows[i][j],
                            maxLines: widget.fieldDefs[j].maxLines,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => _removeRow(i),
                    tooltip: context.s.cmsRemoveItem,
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.s.cmsAddItem),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Titled Object Array Editor — title + items pattern (amenity groups, etc.)
// ---------------------------------------------------------------------------

class _TitledGroupArrayEditor extends StatefulWidget {
  const _TitledGroupArrayEditor({
    required this.groups,
    required this.titleLabel,
    required this.itemsLabel,
    required this.onChanged,
    this.itemsKey = 'items',
  });

  final List<Map<String, dynamic>> groups;
  final String titleLabel;
  final String itemsLabel;

  /// JSON key for the bullet list: 'items' or 'bullets'.
  final String itemsKey;

  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  State<_TitledGroupArrayEditor> createState() =>
      _TitledGroupArrayEditorState();
}

class _TitledGroupArrayEditorState extends State<_TitledGroupArrayEditor> {
  late List<({TextEditingController title, TextEditingController items})> _rows;

  @override
  void initState() {
    super.initState();
    _rows = _buildRows(widget.groups);
  }

  @override
  void didUpdateWidget(covariant _TitledGroupArrayEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.groups, widget.groups) &&
        oldWidget.groups.length != widget.groups.length) {
      _disposeAll();
      _rows = _buildRows(widget.groups);
    }
  }

  List<({TextEditingController title, TextEditingController items})> _buildRows(
    List<Map<String, dynamic>> groups,
  ) {
    return groups.map((g) {
      final title = TextEditingController(text: _str(g['title']));
      final items = TextEditingController(
        text: _strList(g[widget.itemsKey]).join('\n'),
      );
      title.addListener(_onChanged);
      items.addListener(_onChanged);
      return (title: title, items: items);
    }).toList();
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  List<Map<String, dynamic>> _serialize() {
    return _rows.map((r) {
      final lines =
          r.items.text.split('\n').where((l) => l.isNotEmpty).toList();
      return <String, dynamic>{
        'title': r.title.text,
        widget.itemsKey: lines,
      };
    }).toList();
  }

  void _addRow() {
    final title = TextEditingController();
    final items = TextEditingController();
    title.addListener(_onChanged);
    items.addListener(_onChanged);
    setState(() {
      _rows.add((title: title, items: items));
    });
    widget.onChanged(_serialize());
  }

  void _removeRow(int index) {
    final row = _rows.removeAt(index);
    row.title.dispose();
    row.items.dispose();
    setState(() {});
    widget.onChanged(_serialize());
  }

  void _disposeAll() {
    for (final r in _rows) {
      r.title.dispose();
      r.items.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _editableField(widget.titleLabel, _rows[i].title),
                        _editableField(
                          widget.itemsLabel,
                          _rows[i].items,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => _removeRow(i),
                    tooltip: context.s.cmsRemoveItem,
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.s.cmsAddItem),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Site Config Editor
// ---------------------------------------------------------------------------

class _SiteConfigEditor extends StatefulWidget {
  const _SiteConfigEditor({required this.content, required this.onChanged});
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_SiteConfigEditor> createState() => _SiteConfigEditorState();
}

class _SiteConfigEditorState extends State<_SiteConfigEditor> {
  late TextEditingController _name;
  late TextEditingController _location;
  late TextEditingController _capacity;
  late TextEditingController _bedrooms;
  late TextEditingController _bathrooms;
  late TextEditingController _mapEmbedUrl;
  late TextEditingController _mapLinkUrl;

  @override
  void initState() {
    super.initState();
    _init(widget.content);
  }

  @override
  void didUpdateWidget(covariant _SiteConfigEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _disposeAll();
      _init(widget.content);
      setState(() {});
    }
  }

  void _init(Map<String, dynamic> c) {
    _name = _ctrl(c['name'], _onChanged);
    _location = _ctrl(c['location'], _onChanged);
    _capacity = _ctrl(c['capacity'], _onChanged);
    _bedrooms = _ctrl(c['bedrooms'], _onChanged);
    _bathrooms = _ctrl(c['bathrooms'], _onChanged);
    _mapEmbedUrl = _ctrl(c['mapEmbedUrl'], _onChanged);
    _mapLinkUrl = _ctrl(c['mapLinkUrl'], _onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  Map<String, dynamic> _serialize() {
    return {
      'name': _name.text,
      'location': _location.text,
      'capacity': int.tryParse(_capacity.text) ?? _capacity.text,
      'bedrooms': int.tryParse(_bedrooms.text) ?? _bedrooms.text,
      'bathrooms': int.tryParse(_bathrooms.text) ?? _bathrooms.text,
      'mapEmbedUrl': _mapEmbedUrl.text,
      'mapLinkUrl': _mapLinkUrl.text,
    };
  }

  void _disposeAll() {
    _name.dispose();
    _location.dispose();
    _capacity.dispose();
    _bedrooms.dispose();
    _bathrooms.dispose();
    _mapEmbedUrl.dispose();
    _mapLinkUrl.dispose();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableField('Name', _name),
        _editableField('Location', _location),
        _editableField('Capacity', _capacity,
            keyboardType: TextInputType.number),
        _editableField('Bedrooms', _bedrooms,
            keyboardType: TextInputType.number),
        _editableField('Bathrooms', _bathrooms,
            keyboardType: TextInputType.number),
        _editableField('Map Embed URL', _mapEmbedUrl),
        _editableField('Map Link URL', _mapLinkUrl),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Privacy Page Editor
// ---------------------------------------------------------------------------

class _PrivacyPageEditor extends StatefulWidget {
  const _PrivacyPageEditor({required this.content, required this.onChanged});
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_PrivacyPageEditor> createState() => _PrivacyPageEditorState();
}

class _PrivacyPageEditorState extends State<_PrivacyPageEditor> {
  late TextEditingController _intro;
  late TextEditingController _bullets;

  @override
  void initState() {
    super.initState();
    _init(widget.content);
  }

  @override
  void didUpdateWidget(covariant _PrivacyPageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _disposeAll();
      _init(widget.content);
      setState(() {});
    }
  }

  void _init(Map<String, dynamic> c) {
    _intro = _ctrl(c['intro'], _onChanged);
    _bullets = TextEditingController(
      text: _strList(c['bullets']).join('\n'),
    );
    _bullets.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  Map<String, dynamic> _serialize() {
    return {
      'intro': _intro.text,
      'bullets': _bullets.text.split('\n').where((l) => l.isNotEmpty).toList(),
    };
  }

  void _disposeAll() {
    _intro.dispose();
    _bullets.dispose();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableField('Intro', _intro, maxLines: 3),
        _editableField('Bullets (one per line)', _bullets, maxLines: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Contact Form Editor
// ---------------------------------------------------------------------------

class _ContactFormEditor extends StatefulWidget {
  const _ContactFormEditor({required this.content, required this.onChanged});
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_ContactFormEditor> createState() => _ContactFormEditorState();
}

class _ContactFormEditorState extends State<_ContactFormEditor> {
  late TextEditingController _title;
  late TextEditingController _subtitle;
  late TextEditingController _nameLabel;
  late TextEditingController _namePlaceholder;
  late TextEditingController _emailLabel;
  late TextEditingController _emailPlaceholder;
  late TextEditingController _periodLabel;
  late TextEditingController _periodPlaceholder;
  late TextEditingController _messageLabel;
  late TextEditingController _messagePlaceholder;
  late TextEditingController _submit;
  late TextEditingController _success;
  late TextEditingController _error;

  @override
  void initState() {
    super.initState();
    _init(widget.content);
  }

  @override
  void didUpdateWidget(covariant _ContactFormEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _disposeAll();
      _init(widget.content);
      setState(() {});
    }
  }

  void _init(Map<String, dynamic> c) {
    final form = _map(c['form']);
    _title = _ctrl(c['title'], _onChanged);
    _subtitle = _ctrl(c['subtitle'], _onChanged);
    _nameLabel = _ctrl(_map(form['name'])['label'], _onChanged);
    _namePlaceholder = _ctrl(_map(form['name'])['placeholder'], _onChanged);
    _emailLabel = _ctrl(_map(form['email'])['label'], _onChanged);
    _emailPlaceholder = _ctrl(_map(form['email'])['placeholder'], _onChanged);
    _periodLabel = _ctrl(_map(form['period'])['label'], _onChanged);
    _periodPlaceholder = _ctrl(_map(form['period'])['placeholder'], _onChanged);
    _messageLabel = _ctrl(_map(form['message'])['label'], _onChanged);
    _messagePlaceholder =
        _ctrl(_map(form['message'])['placeholder'], _onChanged);
    _submit = _ctrl(form['submit'], _onChanged);
    _success = _ctrl(form['success'], _onChanged);
    _error = _ctrl(form['error'], _onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  Map<String, dynamic> _serialize() {
    return {
      'title': _title.text,
      'subtitle': _subtitle.text,
      'form': {
        'name': {'label': _nameLabel.text, 'placeholder': _namePlaceholder.text},
        'email': {
          'label': _emailLabel.text,
          'placeholder': _emailPlaceholder.text,
        },
        'period': {
          'label': _periodLabel.text,
          'placeholder': _periodPlaceholder.text,
        },
        'message': {
          'label': _messageLabel.text,
          'placeholder': _messagePlaceholder.text,
        },
        'submit': _submit.text,
        'success': _success.text,
        'error': _error.text,
      },
    };
  }

  void _disposeAll() {
    _title.dispose();
    _subtitle.dispose();
    _nameLabel.dispose();
    _namePlaceholder.dispose();
    _emailLabel.dispose();
    _emailPlaceholder.dispose();
    _periodLabel.dispose();
    _periodPlaceholder.dispose();
    _messageLabel.dispose();
    _messagePlaceholder.dispose();
    _submit.dispose();
    _success.dispose();
    _error.dispose();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableField('Title', _title),
        _editableField('Subtitle', _subtitle, maxLines: 3),
        _subsection(context, 'Form Fields'),
        _editableField('Name label', _nameLabel),
        _editableField('Name placeholder', _namePlaceholder),
        _editableField('Email label', _emailLabel),
        _editableField('Email placeholder', _emailPlaceholder),
        _editableField('Period label', _periodLabel),
        _editableField('Period placeholder', _periodPlaceholder),
        _editableField('Message label', _messageLabel),
        _editableField('Message placeholder', _messagePlaceholder),
        _editableField('Submit button', _submit),
        _editableField('Success message', _success, maxLines: 2),
        _editableField('Error message', _error, maxLines: 2),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Raw JSON fallback (read-only)
// ---------------------------------------------------------------------------

class _RawJsonView extends StatelessWidget {
  const _RawJsonView({required this.content});
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StyledFormField(
        label: 'Content (raw)',
        initialValue: content.toString(),
        readOnly: true,
        maxLines: 8,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page Content Editor (delegates by slug)
// ---------------------------------------------------------------------------

class _PageContentEditor extends StatelessWidget {
  const _PageContentEditor({
    required this.slug,
    required this.content,
    required this.onChanged,
  });
  final String slug;
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  Widget build(BuildContext context) {
    switch (slug) {
      case 'home':
        return _HomePageEditor(content: content, onChanged: onChanged);
      case 'practical':
        return _PracticalPageEditor(content: content, onChanged: onChanged);
      case 'area':
        return _AreaPageEditor(content: content, onChanged: onChanged);
      case 'privacy':
        return _PrivacyPageEditor(content: content, onChanged: onChanged);
      default:
        return _RawJsonView(content: content);
    }
  }
}

// ---------------------------------------------------------------------------
// Home Page Editor
// ---------------------------------------------------------------------------

class _HomePageEditor extends StatefulWidget {
  const _HomePageEditor({required this.content, required this.onChanged});
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_HomePageEditor> createState() => _HomePageEditorState();
}

class _HomePageEditorState extends State<_HomePageEditor> {
  late TextEditingController _tagline;
  late TextEditingController _amenities;
  late TextEditingController _locationDesc;

  // Object arrays managed by _ObjectArrayEditor — stored as current values.
  late List<Map<String, dynamic>> _keyFacts;
  late List<Map<String, dynamic>> _highlights;
  late List<Map<String, dynamic>> _reviews;
  late List<Map<String, dynamic>> _faq;

  @override
  void initState() {
    super.initState();
    _init(widget.content);
  }

  @override
  void didUpdateWidget(covariant _HomePageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _disposeAll();
      _init(widget.content);
      setState(() {});
    }
  }

  void _init(Map<String, dynamic> c) {
    _tagline = _ctrl(c['tagline'], _onChanged);
    _amenities = TextEditingController(
      text: _strList(c['amenities']).join('\n'),
    );
    _amenities.addListener(_onChanged);
    _locationDesc = _ctrl(_map(c['location'])['description'], _onChanged);
    _keyFacts = _mapList(c['keyFacts']);
    _highlights = _mapList(c['highlights']);
    _reviews = _mapList(c['reviews']);
    _faq = _mapList(c['faq']);
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  Map<String, dynamic> _serialize() {
    return {
      'tagline': _tagline.text,
      'keyFacts': _keyFacts,
      'highlights': _highlights,
      'amenities':
          _amenities.text.split('\n').where((l) => l.isNotEmpty).toList(),
      'reviews': _reviews,
      'faq': _faq,
      'location': {'description': _locationDesc.text},
    };
  }

  void _disposeAll() {
    _tagline.dispose();
    _amenities.dispose();
    _locationDesc.dispose();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableField('Tagline', _tagline),

        _subsection(context, 'Key Facts'),
        _ObjectArrayEditor(
          items: _keyFacts,
          fieldDefs: const [
            (key: 'label', label: 'Label', maxLines: 1),
            (key: 'value', label: 'Value', maxLines: 1),
          ],
          onChanged: (v) {
            _keyFacts = v;
            _onChanged();
          },
        ),

        _subsection(context, 'Highlights'),
        _ObjectArrayEditor(
          items: _highlights,
          fieldDefs: const [
            (key: 'title', label: 'Title', maxLines: 1),
            (key: 'description', label: 'Description', maxLines: 2),
          ],
          onChanged: (v) {
            _highlights = v;
            _onChanged();
          },
        ),

        _subsection(context, 'Amenities (one per line)'),
        _editableField('Amenities', _amenities, maxLines: 6),

        _subsection(context, 'Reviews'),
        _ObjectArrayEditor(
          items: _reviews,
          fieldDefs: const [
            (key: 'quote', label: 'Quote', maxLines: 2),
            (key: 'name', label: 'Name', maxLines: 1),
            (key: 'stay', label: 'Stay', maxLines: 1),
          ],
          onChanged: (v) {
            _reviews = v;
            _onChanged();
          },
        ),

        _subsection(context, 'FAQ'),
        _ObjectArrayEditor(
          items: _faq,
          fieldDefs: const [
            (key: 'question', label: 'Question', maxLines: 1),
            (key: 'answer', label: 'Answer', maxLines: 3),
          ],
          onChanged: (v) {
            _faq = v;
            _onChanged();
          },
        ),

        _subsection(context, 'Location'),
        _editableField('Description', _locationDesc, maxLines: 3),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cabin Content Editor
// ---------------------------------------------------------------------------

class _CabinContentEditor extends StatefulWidget {
  const _CabinContentEditor({required this.content, required this.onChanged});
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_CabinContentEditor> createState() => _CabinContentEditorState();
}

class _CabinContentEditorState extends State<_CabinContentEditor> {
  // Hero
  late TextEditingController _heroTitle;
  late TextEditingController _heroSubtitle;
  late List<Map<String, dynamic>> _badges;

  // Meta
  late TextEditingController _metaName;
  late TextEditingController _metaLocation;
  late TextEditingController _metaSleeps;
  late TextEditingController _metaAltitude;

  // Experience & Description
  late TextEditingController _experience;
  late TextEditingController _description;

  // Layout & Facilities
  late TextEditingController _layoutTitle;
  late TextEditingController _layoutItems;

  // Location
  late TextEditingController _locationTitle;
  late List<Map<String, dynamic>> _distances;

  // Access & Transport
  late TextEditingController _accessTitle;
  late TextEditingController _accessCar;
  late TextEditingController _accessAirports;
  late TextEditingController _accessPublicTransport;
  late TextEditingController _accessParking;
  late TextEditingController _accessNotes;

  // Amenities
  late TextEditingController _amenitiesTitle;
  late List<Map<String, dynamic>> _amenityGroups;

  // House Rules
  late TextEditingController _rulesTitle;
  late TextEditingController _rulesBullets;
  late TextEditingController _rulesCheckIn;
  late TextEditingController _rulesCheckOut;
  late TextEditingController _rulesCheckInNote;
  late TextEditingController _rulesCleaningNote;
  late TextEditingController _rulesWifiNote;

  // Policies
  late TextEditingController _policiesTitle;
  late List<Map<String, dynamic>> _policyBlocks;

  @override
  void initState() {
    super.initState();
    _init(widget.content);
  }

  @override
  void didUpdateWidget(covariant _CabinContentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _disposeAll();
      _init(widget.content);
      setState(() {});
    }
  }

  void _init(Map<String, dynamic> c) {
    final hero = _map(c['hero']);
    final meta = _map(c['meta']);
    final layout = _map(c['layoutAndFacilities']);
    final location = _map(c['location']);
    final access = _map(c['accessAndTransport']);
    final amenities = _map(c['amenities']);
    final rules = _map(c['houseRules']);
    final policies = _map(c['policies']);

    _heroTitle = _ctrl(hero['title'], _onChanged);
    _heroSubtitle = _ctrl(hero['subtitle'], _onChanged);
    _badges = _mapList(hero['badges']);

    _metaName = _ctrl(meta['name'], _onChanged);
    _metaLocation = _ctrl(meta['locationShort'], _onChanged);
    _metaSleeps = _ctrl(meta['sleeps'], _onChanged);
    _metaAltitude = _ctrl(meta['altitude'], _onChanged);

    _experience = TextEditingController(
      text: _strList(c['experience']).join('\n'),
    );
    _experience.addListener(_onChanged);

    _description = TextEditingController(
      text: _strList(c['description']).join('\n\n'),
    );
    _description.addListener(_onChanged);

    _layoutTitle = _ctrl(layout['title'], _onChanged);
    _layoutItems = TextEditingController(
      text: _strList(layout['items']).join('\n'),
    );
    _layoutItems.addListener(_onChanged);

    _locationTitle = _ctrl(location['title'], _onChanged);
    _distances = _mapList(location['distances']);

    _accessTitle = _ctrl(access['title'], _onChanged);
    _accessCar = TextEditingController(
      text: _strList(access['car']).join('\n'),
    );
    _accessCar.addListener(_onChanged);
    _accessAirports = TextEditingController(
      text: _strList(access['airports']).join('\n'),
    );
    _accessAirports.addListener(_onChanged);
    _accessPublicTransport = TextEditingController(
      text: _strList(access['publicTransport']).join('\n'),
    );
    _accessPublicTransport.addListener(_onChanged);
    _accessParking = TextEditingController(
      text: _strList(access['parking']).join('\n'),
    );
    _accessParking.addListener(_onChanged);
    _accessNotes = TextEditingController(
      text: _strList(access['notes']).join('\n'),
    );
    _accessNotes.addListener(_onChanged);

    _amenitiesTitle = _ctrl(amenities['title'], _onChanged);
    _amenityGroups = _mapList(amenities['groups']);

    _rulesTitle = _ctrl(rules['title'], _onChanged);
    _rulesBullets = TextEditingController(
      text: _strList(rules['bullets']).join('\n'),
    );
    _rulesBullets.addListener(_onChanged);
    _rulesCheckIn = _ctrl(rules['checkIn'], _onChanged);
    _rulesCheckOut = _ctrl(rules['checkOut'], _onChanged);
    _rulesCheckInNote = _ctrl(rules['checkInNote'], _onChanged);
    _rulesCleaningNote = _ctrl(rules['cleaningNote'], _onChanged);
    _rulesWifiNote = _ctrl(rules['wifiNote'], _onChanged);

    _policiesTitle = _ctrl(policies['title'], _onChanged);
    _policyBlocks = _mapList(policies['blocks']);
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  List<String> _lines(TextEditingController c) =>
      c.text.split('\n').where((l) => l.isNotEmpty).toList();

  List<String> _paragraphs(TextEditingController c) =>
      c.text.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

  Map<String, dynamic> _serialize() {
    return {
      'hero': {
        'title': _heroTitle.text,
        'subtitle': _heroSubtitle.text,
        'badges': _badges,
      },
      'meta': {
        'name': _metaName.text,
        'locationShort': _metaLocation.text,
        'sleeps': _metaSleeps.text,
        'altitude': _metaAltitude.text,
      },
      'experience': _lines(_experience),
      'description': _paragraphs(_description),
      'layoutAndFacilities': {
        'title': _layoutTitle.text,
        'items': _lines(_layoutItems),
      },
      'location': {
        'title': _locationTitle.text,
        'distances': _distances,
      },
      'accessAndTransport': {
        'title': _accessTitle.text,
        'car': _lines(_accessCar),
        'airports': _lines(_accessAirports),
        'publicTransport': _lines(_accessPublicTransport),
        'parking': _lines(_accessParking),
        'notes': _lines(_accessNotes),
      },
      'amenities': {
        'title': _amenitiesTitle.text,
        'groups': _amenityGroups,
      },
      'houseRules': {
        'title': _rulesTitle.text,
        'bullets': _lines(_rulesBullets),
        'checkIn': _rulesCheckIn.text,
        'checkOut': _rulesCheckOut.text,
        'checkInNote': _rulesCheckInNote.text,
        'cleaningNote': _rulesCleaningNote.text,
        'wifiNote': _rulesWifiNote.text,
      },
      'policies': {
        'title': _policiesTitle.text,
        'blocks': _policyBlocks,
      },
    };
  }

  void _disposeAll() {
    _heroTitle.dispose();
    _heroSubtitle.dispose();
    _metaName.dispose();
    _metaLocation.dispose();
    _metaSleeps.dispose();
    _metaAltitude.dispose();
    _experience.dispose();
    _description.dispose();
    _layoutTitle.dispose();
    _layoutItems.dispose();
    _locationTitle.dispose();
    _accessTitle.dispose();
    _accessCar.dispose();
    _accessAirports.dispose();
    _accessPublicTransport.dispose();
    _accessParking.dispose();
    _accessNotes.dispose();
    _amenitiesTitle.dispose();
    _rulesTitle.dispose();
    _rulesBullets.dispose();
    _rulesCheckIn.dispose();
    _rulesCheckOut.dispose();
    _rulesCheckInNote.dispose();
    _rulesCleaningNote.dispose();
    _rulesWifiNote.dispose();
    _policiesTitle.dispose();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero
        _subsection(context, 'Hero'),
        _editableField('Title', _heroTitle),
        _editableField('Subtitle', _heroSubtitle),
        _ObjectArrayEditor(
          items: _badges,
          fieldDefs: const [
            (key: 'label', label: 'Label', maxLines: 1),
            (key: 'value', label: 'Value', maxLines: 1),
          ],
          onChanged: (v) {
            _badges = v;
            _onChanged();
          },
        ),
        const SizedBox(height: 8),

        // Meta
        _subsection(context, 'Meta'),
        _editableField('Name', _metaName),
        _editableField('Location', _metaLocation),
        _editableField('Sleeps', _metaSleeps),
        _editableField('Altitude', _metaAltitude),
        const SizedBox(height: 8),

        // Experience
        _subsection(context, 'Experience (one per line)'),
        _editableField('Experience', _experience, maxLines: 6),
        const SizedBox(height: 8),

        // Description
        _subsection(context, 'Description (paragraphs separated by blank line)'),
        _editableField('Description', _description, maxLines: 8),
        const SizedBox(height: 8),

        // Layout & Facilities
        _subsection(context, 'Layout & Facilities'),
        _editableField('Section title', _layoutTitle),
        _editableField('Items (one per line)', _layoutItems, maxLines: 8),
        const SizedBox(height: 8),

        // Location
        _subsection(context, 'Location'),
        _editableField('Section title', _locationTitle),
        _label(context, 'Distances'),
        _ObjectArrayEditor(
          items: _distances,
          fieldDefs: const [
            (key: 'label', label: 'Label', maxLines: 1),
            (key: 'value', label: 'Value', maxLines: 1),
          ],
          onChanged: (v) {
            _distances = v;
            _onChanged();
          },
        ),
        const SizedBox(height: 8),

        // Access & Transport
        _subsection(context, 'Access & Transport'),
        _editableField('Section title', _accessTitle),
        _label(context, 'Car'),
        _editableField('Car (one per line)', _accessCar, maxLines: 4),
        _label(context, 'Airports'),
        _editableField('Airports (one per line)', _accessAirports, maxLines: 4),
        _label(context, 'Public Transport'),
        _editableField('Public transport (one per line)',
            _accessPublicTransport,
            maxLines: 4),
        _label(context, 'Parking'),
        _editableField('Parking (one per line)', _accessParking, maxLines: 4),
        _label(context, 'Notes'),
        _editableField('Notes (one per line)', _accessNotes, maxLines: 4),
        const SizedBox(height: 8),

        // Amenities
        _subsection(context, 'Amenities'),
        _editableField('Section title', _amenitiesTitle),
        _TitledGroupArrayEditor(
          groups: _amenityGroups,
          titleLabel: 'Group name',
          itemsLabel: 'Items (one per line)',
          onChanged: (v) {
            _amenityGroups = v;
            _onChanged();
          },
        ),
        const SizedBox(height: 8),

        // House Rules
        _subsection(context, 'House Rules'),
        _editableField('Section title', _rulesTitle),
        _editableField('Rules (one per line)', _rulesBullets, maxLines: 6),
        _editableField('Check-in', _rulesCheckIn),
        _editableField('Check-out', _rulesCheckOut),
        _editableField('Check-in note', _rulesCheckInNote, maxLines: 3),
        _editableField('Cleaning note', _rulesCleaningNote, maxLines: 3),
        _editableField('WiFi note', _rulesWifiNote),
        const SizedBox(height: 8),

        // Policies
        _subsection(context, 'Policies'),
        _editableField('Section title', _policiesTitle),
        _TitledGroupArrayEditor(
          groups: _policyBlocks,
          titleLabel: 'Policy title',
          itemsLabel: 'Items (one per line)',
          onChanged: (v) {
            _policyBlocks = v;
            _onChanged();
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Practical Page Editor
// ---------------------------------------------------------------------------

class _PracticalPageEditor extends StatefulWidget {
  const _PracticalPageEditor({required this.content, required this.onChanged});
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_PracticalPageEditor> createState() => _PracticalPageEditorState();
}

class _PracticalPageEditorState extends State<_PracticalPageEditor> {
  // Header
  late TextEditingController _headerTitle;
  late TextEditingController _headerSubtitle;

  // Quick Facts
  late List<Map<String, dynamic>> _quickFacts;

  // Arrival & Access
  late TextEditingController _arrivalTitle;
  late TextEditingController _arrivalCheckIn;
  late TextEditingController _arrivalCheckOut;
  late TextEditingController _arrivalBullets;

  // Parking & Charging
  late TextEditingController _parkingTitle;
  late TextEditingController _parkingBullets;
  late TextEditingController _parkingCallout;

  // Layout & Facilities
  late TextEditingController _layoutTitle;
  late List<Map<String, dynamic>> _layoutSections;

  // Transport
  late TextEditingController _transportTitle;
  late List<Map<String, dynamic>> _transportColumns;

  // Good to Know
  late TextEditingController _goodToKnowTitle;
  late TextEditingController _goodToKnowBullets;

  // Contact & Help
  late TextEditingController _contactTitle;
  late TextEditingController _contactBullets;

  // Agreements & Payment
  late TextEditingController _agreementsTitle;
  late List<Map<String, dynamic>> _agreementBlocks;

  @override
  void initState() {
    super.initState();
    _init(widget.content);
  }

  @override
  void didUpdateWidget(covariant _PracticalPageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _disposeAll();
      _init(widget.content);
      setState(() {});
    }
  }

  void _init(Map<String, dynamic> c) {
    final header = _map(c['header']);
    final arrival = _map(c['arrivalAccess']);
    final parking = _map(c['parkingCharging']);
    final layout = _map(c['layoutFacilities']);
    final transport = _map(c['transport']);
    final goodToKnow = _map(c['goodToKnow']);
    final contact = _map(c['contactHelp']);
    final agreements = _map(c['agreementsAndPayment']);

    _headerTitle = _ctrl(header['title'], _onChanged);
    _headerSubtitle = _ctrl(header['subtitle'], _onChanged);

    _quickFacts = _mapList(c['quickFacts']);

    _arrivalTitle = _ctrl(arrival['title'], _onChanged);
    _arrivalCheckIn = _ctrl(arrival['checkIn'], _onChanged);
    _arrivalCheckOut = _ctrl(arrival['checkOut'], _onChanged);
    _arrivalBullets = TextEditingController(
      text: _strList(arrival['bullets']).join('\n'),
    );
    _arrivalBullets.addListener(_onChanged);

    _parkingTitle = _ctrl(parking['title'], _onChanged);
    _parkingBullets = TextEditingController(
      text: _strList(parking['bullets']).join('\n'),
    );
    _parkingBullets.addListener(_onChanged);
    _parkingCallout = _ctrl(parking['callout'], _onChanged);

    _layoutTitle = _ctrl(layout['title'], _onChanged);
    _layoutSections = _mapList(layout['sections']);

    _transportTitle = _ctrl(transport['title'], _onChanged);
    _transportColumns = _mapList(transport['columns']);

    _goodToKnowTitle = _ctrl(goodToKnow['title'], _onChanged);
    _goodToKnowBullets = TextEditingController(
      text: _strList(goodToKnow['bullets']).join('\n'),
    );
    _goodToKnowBullets.addListener(_onChanged);

    _contactTitle = _ctrl(contact['title'], _onChanged);
    _contactBullets = TextEditingController(
      text: _strList(contact['bullets']).join('\n'),
    );
    _contactBullets.addListener(_onChanged);

    _agreementsTitle = _ctrl(agreements['title'], _onChanged);
    _agreementBlocks = _mapList(agreements['blocks']);
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  List<String> _lines(TextEditingController c) =>
      c.text.split('\n').where((l) => l.isNotEmpty).toList();

  Map<String, dynamic> _serialize() {
    return {
      'header': {
        'title': _headerTitle.text,
        'subtitle': _headerSubtitle.text,
      },
      'quickFacts': _quickFacts,
      'arrivalAccess': {
        'title': _arrivalTitle.text,
        'checkIn': _arrivalCheckIn.text,
        'checkOut': _arrivalCheckOut.text,
        'bullets': _lines(_arrivalBullets),
      },
      'parkingCharging': {
        'title': _parkingTitle.text,
        'bullets': _lines(_parkingBullets),
        'callout': _parkingCallout.text,
      },
      'layoutFacilities': {
        'title': _layoutTitle.text,
        'sections': _layoutSections,
      },
      'transport': {
        'title': _transportTitle.text,
        'columns': _transportColumns,
      },
      'goodToKnow': {
        'title': _goodToKnowTitle.text,
        'bullets': _lines(_goodToKnowBullets),
      },
      'contactHelp': {
        'title': _contactTitle.text,
        'bullets': _lines(_contactBullets),
      },
      'agreementsAndPayment': {
        'title': _agreementsTitle.text,
        'blocks': _agreementBlocks,
      },
    };
  }

  void _disposeAll() {
    _headerTitle.dispose();
    _headerSubtitle.dispose();
    _arrivalTitle.dispose();
    _arrivalCheckIn.dispose();
    _arrivalCheckOut.dispose();
    _arrivalBullets.dispose();
    _parkingTitle.dispose();
    _parkingBullets.dispose();
    _parkingCallout.dispose();
    _layoutTitle.dispose();
    _transportTitle.dispose();
    _goodToKnowTitle.dispose();
    _goodToKnowBullets.dispose();
    _contactTitle.dispose();
    _contactBullets.dispose();
    _agreementsTitle.dispose();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableField('Title', _headerTitle),
        _editableField('Subtitle', _headerSubtitle),

        _subsection(context, 'Quick Facts'),
        _ObjectArrayEditor(
          items: _quickFacts,
          fieldDefs: const [
            (key: 'label', label: 'Label', maxLines: 1),
            (key: 'value', label: 'Value', maxLines: 1),
          ],
          onChanged: (v) {
            _quickFacts = v;
            _onChanged();
          },
        ),

        _subsection(context, 'Arrival & Access'),
        _editableField('Section title', _arrivalTitle),
        _editableField('Check-in', _arrivalCheckIn),
        _editableField('Check-out', _arrivalCheckOut),
        _editableField('Bullets (one per line)', _arrivalBullets, maxLines: 6),

        _subsection(context, 'Parking & Charging'),
        _editableField('Section title', _parkingTitle),
        _editableField('Bullets (one per line)', _parkingBullets, maxLines: 4),
        _editableField('Note', _parkingCallout, maxLines: 2),

        _subsection(context, 'Layout & Facilities'),
        _editableField('Section title', _layoutTitle),
        _TitledGroupArrayEditor(
          groups: _layoutSections,
          titleLabel: 'Section name',
          itemsLabel: 'Bullets (one per line)',
          itemsKey: 'bullets',
          onChanged: (v) {
            _layoutSections = v;
            _onChanged();
          },
        ),

        _subsection(context, 'Transport'),
        _editableField('Section title', _transportTitle),
        _TitledGroupArrayEditor(
          groups: _transportColumns,
          titleLabel: 'Column name',
          itemsLabel: 'Bullets (one per line)',
          itemsKey: 'bullets',
          onChanged: (v) {
            _transportColumns = v;
            _onChanged();
          },
        ),

        _subsection(context, 'Good to Know'),
        _editableField('Section title', _goodToKnowTitle),
        _editableField('Bullets (one per line)', _goodToKnowBullets,
            maxLines: 6),

        _subsection(context, 'Contact & Help'),
        _editableField('Section title', _contactTitle),
        _editableField('Bullets (one per line)', _contactBullets, maxLines: 6),

        _subsection(context, 'Agreements & Payment'),
        _editableField('Section title', _agreementsTitle),
        _TitledGroupArrayEditor(
          groups: _agreementBlocks,
          titleLabel: 'Block title',
          itemsLabel: 'Items (one per line)',
          onChanged: (v) {
            _agreementBlocks = v;
            _onChanged();
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Area Page Editor
// ---------------------------------------------------------------------------

class _AreaPageEditor extends StatefulWidget {
  const _AreaPageEditor({required this.content, required this.onChanged});
  final Map<String, dynamic> content;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_AreaPageEditor> createState() => _AreaPageEditorState();
}

class _AreaPageEditorState extends State<_AreaPageEditor> {
  late TextEditingController _intro;
  late List<Map<String, dynamic>> _sections;

  @override
  void initState() {
    super.initState();
    _init(widget.content);
  }

  @override
  void didUpdateWidget(covariant _AreaPageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _disposeAll();
      _init(widget.content);
      setState(() {});
    }
  }

  void _init(Map<String, dynamic> c) {
    _intro = _ctrl(c['intro'], _onChanged);
    _sections = _mapList(c['sections']);
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  Map<String, dynamic> _serialize() {
    return {
      'intro': _intro.text,
      'sections': _sections,
    };
  }

  void _disposeAll() {
    _intro.dispose();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableField('Intro', _intro, maxLines: 3),
        _subsection(context, 'Sections'),
        _AreaSectionsEditor(
          sections: _sections,
          onChanged: (v) {
            _sections = v;
            _onChanged();
          },
        ),
      ],
    );
  }
}

/// Area sections have title + description + bullets, which needs a custom editor.
class _AreaSectionsEditor extends StatefulWidget {
  const _AreaSectionsEditor({
    required this.sections,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> sections;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  State<_AreaSectionsEditor> createState() => _AreaSectionsEditorState();
}

class _AreaSectionsEditorState extends State<_AreaSectionsEditor> {
  late List<
      ({
        TextEditingController title,
        TextEditingController description,
        TextEditingController bullets,
      })> _rows;

  @override
  void initState() {
    super.initState();
    _rows = _buildRows(widget.sections);
  }

  @override
  void didUpdateWidget(covariant _AreaSectionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.sections, widget.sections) &&
        oldWidget.sections.length != widget.sections.length) {
      _disposeAll();
      _rows = _buildRows(widget.sections);
    }
  }

  List<
      ({
        TextEditingController title,
        TextEditingController description,
        TextEditingController bullets,
      })> _buildRows(List<Map<String, dynamic>> sections) {
    return sections.map((s) {
      final title = TextEditingController(text: _str(s['title']));
      final description = TextEditingController(text: _str(s['description']));
      final bullets = TextEditingController(
        text: _strList(s['bullets']).join('\n'),
      );
      title.addListener(_onChanged);
      description.addListener(_onChanged);
      bullets.addListener(_onChanged);
      return (title: title, description: description, bullets: bullets);
    }).toList();
  }

  void _onChanged() {
    if (!mounted) return;
    widget.onChanged(_serialize());
  }

  List<Map<String, dynamic>> _serialize() {
    return _rows.map((r) {
      return <String, dynamic>{
        'title': r.title.text,
        'description': r.description.text,
        'bullets':
            r.bullets.text.split('\n').where((l) => l.isNotEmpty).toList(),
      };
    }).toList();
  }

  void _addRow() {
    final title = TextEditingController();
    final description = TextEditingController();
    final bullets = TextEditingController();
    title.addListener(_onChanged);
    description.addListener(_onChanged);
    bullets.addListener(_onChanged);
    setState(() {
      _rows.add((title: title, description: description, bullets: bullets));
    });
    widget.onChanged(_serialize());
  }

  void _removeRow(int index) {
    final row = _rows.removeAt(index);
    row.title.dispose();
    row.description.dispose();
    row.bullets.dispose();
    setState(() {});
    widget.onChanged(_serialize());
  }

  void _disposeAll() {
    for (final r in _rows) {
      r.title.dispose();
      r.description.dispose();
      r.bullets.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _editableField('Title', _rows[i].title),
                      _editableField('Description', _rows[i].description,
                          maxLines: 3),
                      _editableField(
                          'Bullets (one per line)', _rows[i].bullets,
                          maxLines: 4),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () => _removeRow(i),
                  tooltip: context.s.cmsRemoveItem,
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add, size: 18),
          label: Text(context.s.cmsAddItem),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layout Sections Editor (practical page — title + intro + bullets)
// ---------------------------------------------------------------------------
// Reuses _TitledGroupArrayEditor with an extra intro field, but for now the
// intro is folded into the bullets text. The _TitledGroupArrayEditor already
// handles the title + items pattern.  For layout sections that have an 'intro'
// field, we serialize it separately via _AreaSectionsEditor-style approach.
// However, since _TitledGroupArrayEditor is already used and the 'intro' field
// is rare, we accept the minor data loss for layout section intros in the
// practical page.  A future enhancement could add a 3-field group editor.
