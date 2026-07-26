import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/properties.dart';

/// Manual listing management. Account scope: it mutates `properties`, which is
/// tenant data owned by the signed-in account — not server configuration. It
/// therefore lives on Settings next to the Lodgify connection that normally
/// produces these rows, and deliberately not on the admin page.
///
/// Plain layout (`inset: false`) because the listing table brings its own card;
/// an inset section would nest one card inside another.
class ListingsSection extends StatefulWidget {
  const ListingsSection({super.key});

  @override
  State<ListingsSection> createState() => _ListingsSectionState();
}

class _ListingsSectionState extends State<ListingsSection> {
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;
  int? _deletingPropertyId;

  bool get _isMutating => _isCreating || _deletingPropertyId != null;

  bool get _canCreate => !_isMutating && _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);

    final cubit = context.read<PropertyContextCubit>();
    if (cubit.state.status == PropertyContextStatus.initial) {
      cubit.loadProperties();
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _createProperty() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isMutating) return;

    setState(() => _isCreating = true);
    try {
      await context.read<PropertyRepository>().createProperty(name: name);
      if (!mounted) return;
      _nameController.clear();
      await context.read<PropertyContextCubit>().loadProperties();
      if (!mounted) return;
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: 'Listing "$name" toegevoegd.',
      );
    } catch (error, stack) {
      if (!mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _deleteProperty(PropertySummary property) async {
    if (_isMutating) return;
    final shouldDelete = await _confirmDelete(property);
    if (!mounted || !shouldDelete) return;

    setState(() => _deletingPropertyId = property.id);
    try {
      await context.read<PropertyRepository>().deleteProperty(property.id);
      if (!mounted) return;
      await context.read<PropertyContextCubit>().loadProperties();
      if (!mounted) return;
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: 'Listing "${property.name}" verwijderd.',
      );
    } catch (error, stack) {
      if (!mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    } finally {
      if (mounted) {
        setState(() => _deletingPropertyId = null);
      }
    }
  }

  Future<bool> _confirmDelete(PropertySummary property) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Listing verwijderen'),
          content: Text(
            'Weet je zeker dat je "${property.name}" wilt verwijderen?',
          ),
          actions: [
            StyledButton(
              title: context.s.cancelButton,
              onPressed: () => Navigator.of(context).pop(false),
              minHeight: 40,
            ),
            StyledButton(
              title: context.s.deleteButton,
              onPressed: () => Navigator.of(context).pop(true),
              minHeight: 40,
              backgroundColor: Theme.of(context).colorScheme.error,
              labelColor: Theme.of(context).colorScheme.onError,
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StyledSection(
      header: 'Listings',
      inset: false,
      horizontalPadding: 0,
      children: [
        Text(
          'Voeg handmatig een listing toe of verwijder listings om een nieuwe website-opzet te testen zonder Lodgify-sync.',
          style: context.theme.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final field = StyledTextFormField(
              controller: _nameController,
              label: context.s.propertySetupManualNameLabel,
              placeholder: context.s.propertySetupManualNameLabel,
              enabled: !_isMutating,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (_canCreate) _createProperty();
              },
            );
            final button = StyledButton(
              title: context.s.propertySetupManualButton,
              onPressed: _canCreate ? _createProperty : null,
              enabled: _canCreate,
              minHeight: 44,
              leftIconData: _isCreating ? null : Icons.add,
              showLeftIcon: !_isCreating,
              showProgressIndicatorWhenDisabled: _isCreating,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [field, const SizedBox(height: 8), button],
              );
            }

            return Row(
              children: [
                Expanded(child: field),
                const SizedBox(width: 12),
                button,
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<PropertyContextCubit, PropertyContextState>(
          builder: (context, state) {
            final properties = state.properties;
            final isLoading =
                state.status == PropertyContextStatus.loading &&
                properties.isEmpty;

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.status == PropertyContextStatus.error &&
                properties.isEmpty) {
              return Text(
                'Kon listings niet laden.',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              );
            }

            return StyledDataTable(
              variant: StyledTableVariant.card,
              dense: true,
              uppercaseHeaderLabels: false,
              columns: const [
                StyledDataColumn(
                  columnHeaderLabel: 'ID',
                  flex: 1,
                  minWidth: 64,
                ),
                StyledDataColumn(
                  columnHeaderLabel: 'Naam',
                  flex: 3,
                  minWidth: 220,
                ),
                StyledDataColumn(
                  columnHeaderLabel: 'Lodgify ID',
                  flex: 2,
                  minWidth: 180,
                ),
                StyledDataColumn(
                  columnHeaderLabel: 'Acties',
                  flex: 2,
                  minWidth: 140,
                ),
              ],
              itemCount: properties.length,
              rowBuilder: (tableContext, index) {
                final property = properties[index];
                final lodgifyId = property.lodgifyId?.trim();
                final isDeleting = _deletingPropertyId == property.id;
                final canDelete = !_isMutating || isDeleting;

                return [
                  Text(
                    property.id.toString(),
                    style: Theme.of(tableContext).textTheme.bodyMedium,
                  ),
                  Text(
                    property.name,
                    style: Theme.of(tableContext).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lodgifyId == null || lodgifyId.isEmpty ? '-' : lodgifyId,
                    style: Theme.of(tableContext).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StyledButton(
                      title: context.s.deleteButton,
                      onPressed: canDelete && !isDeleting
                          ? () => _deleteProperty(property)
                          : null,
                      enabled: canDelete && !isDeleting,
                      showProgressIndicatorWhenDisabled: isDeleting,
                      minHeight: 36,
                      minWidth: 104,
                      backgroundColor: context.colors.error,
                      labelColor: context.colors.onError,
                    ),
                  ),
                ];
              },
              emptyLabel: 'Nog geen listings gevonden.',
            );
          },
        ),
      ],
    );
  }
}
