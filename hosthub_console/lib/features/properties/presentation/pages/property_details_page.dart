import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class PropertyDetailsPage extends StatelessWidget {
  const PropertyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final current = state.currentProperty;
        if (state.status == PropertyContextStatus.loading ||
            state.status == PropertyContextStatus.initial) {
          return ConsolePageScaffold(
            title: context.s.propertyDetailsTitle,
            description: context.s.propertyDetailsDescription,
            leftChild: const Center(child: CircularProgressIndicator()),
          );
        }
        if (current == null) {
          return ConsolePageScaffold(
            title: context.s.propertyDetailsTitle,
            description: context.s.propertyDetailsDescription,
            leftChild: Text(context.s.propertyDetailsEmpty),
          );
        }

        final propertyRepository = context.read<PropertyRepository>();

        return FutureBuilder<PropertyDetails>(
          future: propertyRepository.fetchPropertyDetails(current.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ConsolePageScaffold(
                title: context.s.propertyDetailsTitle,
                description: context.s.propertyDetailsDescription,
                leftChild:
                    const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return ConsolePageScaffold(
                title: context.s.propertyDetailsTitle,
                description: context.s.propertyDetailsDescription,
                leftChild:
                    Text('Failed to load details: ${snapshot.error}'),
              );
            }

            final details = snapshot.data;
            if (details == null) {
              return ConsolePageScaffold(
                title: context.s.propertyDetailsTitle,
                description: context.s.propertyDetailsDescription,
                leftChild: Text(context.s.propertyDetailsEmpty),
              );
            }

            return ConsolePageScaffold(
              title: context.s.propertyDetailsTitle,
              description: context.s.propertyDetailsDescription,
              leftChild: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  _LodgifyStatusSection(
                    lodgifyId: details.lodgifyId,
                  ),
                  const SizedBox(height: 16),
                  _RentalDetailsSection(details: details),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Lodgify Status Section
// ---------------------------------------------------------------------------

class _LodgifyStatusSection extends StatelessWidget {
  const _LodgifyStatusSection({required this.lodgifyId});

  final String? lodgifyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLinked = lodgifyId != null && lodgifyId!.trim().isNotEmpty;

    return StyledSection(
      isFirstSection: true,
      header: 'Lodgify',
      grouped: false,
      children: [
        StyledTile(
          title: context.s.propertyLodgifyStatus,
          leading: Icon(
            isLinked ? Icons.link : Icons.link_off,
            color: isLinked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          value: Text(
            isLinked
                ? context.s.propertyLodgifyLinked
                : context.s.propertyLodgifyNotLinked,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isLinked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isLinked) ...[
          StyledTile(
            title: 'Lodgify ID',
            value: Text(
              lodgifyId!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final lastSync =
                  settingsState.settings?.lodgifyLastSyncedAt;
              if (lastSync == null) return const SizedBox.shrink();
              final localeCode =
                  Localizations.localeOf(context).languageCode;
              final formatted =
                  timeago.format(lastSync.toLocal(), locale: localeCode);
              return StyledTile(
                title: context.s.propertyLastSync,
                value: Text(
                  formatted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rental Details Section (read-only)
// ---------------------------------------------------------------------------

class _RentalDetailsSection extends StatelessWidget {
  const _RentalDetailsSection({required this.details});

  final PropertyDetails details;

  @override
  Widget build(BuildContext context) {
    final isLodgifyLinked =
        details.lodgifyId != null && details.lodgifyId!.trim().isNotEmpty;

    return StyledSection(
      header: 'Rental details',
      grouped: false,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledFormField(
                label: 'Name',
                initialValue: details.name,
                readOnly: true,
              ),
              if (isLodgifyLinked) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        context.s.propertyNameLodgifyHint,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        _readOnlyField('Address', details.address),
        _readOnlyField('ZIP', details.zip),
        _readOnlyField('City', details.city),
        _readOnlyField('Country', details.country),
        _readOnlyField('Image URL', details.imageUrl),
        _readOnlyField('Has addons', _formatBool(details.hasAddons)),
        _readOnlyField('Has agreement', _formatBool(details.hasAgreement)),
        _readOnlyField('Agreement text', details.agreementText),
        _readOnlyField('Agreement URL', details.agreementUrl),
        _readOnlyField(
          'Owner spoken languages',
          details.ownerSpokenLanguages?.join(', '),
        ),
        _readOnlyField('Rating', details.rating?.toString()),
        _readOnlyField(
          'Price unit in days',
          details.priceUnitInDays?.toString(),
        ),
        _readOnlyField('Min price', _formatNum(details.minPrice)),
        _readOnlyField(
          'Original min price',
          _formatNum(details.originalMinPrice),
        ),
        _readOnlyField('Max price', _formatNum(details.maxPrice)),
        _readOnlyField(
          'Original max price',
          _formatNum(details.originalMaxPrice),
        ),
        _readOnlyField(
          'In/out max date',
          details.inOutMaxDate?.toLocal().toString(),
        ),
        _readOnlyField(
          'In/out rules',
          _formatJson(details.inOut),
          maxLines: 6,
        ),
        _readOnlyField(
          'Subscription plans',
          details.subscriptionPlans?.join(', '),
        ),
        _readOnlyField(
          'Rooms',
          _formatJson(details.rooms),
          maxLines: 6,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _readOnlyField(String label, String? value, {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: StyledFormField(
      label: label,
      initialValue: value ?? '',
      readOnly: true,
      maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : null,
    ),
  );
}

String _formatBool(bool? value) {
  if (value == null) return '';
  return value ? 'Yes' : 'No';
}

String _formatNum(num? value) => value?.toString() ?? '';

String _formatJson(Object? value) {
  if (value == null) return '';
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}
