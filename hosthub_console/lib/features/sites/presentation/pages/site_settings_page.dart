import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/cms/cms.dart';

/// Per-site website settings: contact recipient + email sender name (email) and
/// Lodgify property/room ids (booking). Backed by CmsCubit (state.site) and
/// persisted via CmsCubit.saveSiteSettings.
class SiteSettingsPage extends StatefulWidget {
  const SiteSettingsPage({super.key, required this.siteId});

  final String siteId;

  @override
  State<SiteSettingsPage> createState() => _SiteSettingsPageState();
}

class _SiteSettingsPageState extends State<SiteSettingsPage> {
  final _emailFromName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _lodgifyPropertyId = TextEditingController();
  final _lodgifyRoomTypeId = TextEditingController();

  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CmsCubit>().loadSiteContent(siteId: widget.siteId);
    });
  }

  @override
  void dispose() {
    _emailFromName.dispose();
    _contactEmail.dispose();
    _lodgifyPropertyId.dispose();
    _lodgifyRoomTypeId.dispose();
    super.dispose();
  }

  void _hydrate(SiteSummary site) {
    if (_initialized) return;
    _initialized = true;
    _emailFromName.text = site.emailFromName ?? '';
    _contactEmail.text = site.contactEmail ?? '';
    _lodgifyPropertyId.text = site.lodgifyPropertyId ?? '';
    _lodgifyRoomTypeId.text = site.lodgifyRoomTypeId ?? '';
  }

  String? _norm(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final s = context.s;
    try {
      await context.read<CmsCubit>().saveSiteSettings(
        contactEmail: _norm(_contactEmail.text),
        emailFromName: _norm(_emailFromName.text),
        lodgifyPropertyId: _norm(_lodgifyPropertyId.text),
        lodgifyRoomTypeId: _norm(_lodgifyRoomTypeId.text),
      );
      messenger.showSnackBar(SnackBar(content: Text(s.siteSettingsSaved)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.siteSettingsSaveFailed)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CmsCubit, CmsState>(
      listenWhen: (previous, current) =>
          current.site != null && current.site!.id == widget.siteId,
      listener: (context, state) {
        final site = state.site;
        if (site != null && site.id == widget.siteId) _hydrate(site);
      },
      builder: (context, state) {
        final loading = state.status == CmsStatus.loading && !_initialized;
        return ConsolePageScaffold(
          title: context.s.siteSettingsTitle,
          description: context.s.siteSettingsSubtitle,
          actionText: context.s.saveButton,
          actionIcon: Icons.save_outlined,
          actionEnabled: !_saving && !loading,
          actionInProgress: _saving,
          onAction: (_saving || loading) ? null : () => _save(),
          leftChild: SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    children: [
                      StyledSection(
                        isFirstSection: true,
                        header: context.s.siteSettingsContactSection,
                        inset: false,
                        children: [
                          StyledTextFormField(
                            controller: _emailFromName,
                            label: context.s.siteSettingsEmailFromNameLabel,
                            helperText: context.s.siteSettingsEmailFromNameHint,
                          ),
                          const SizedBox(height: 12),
                          StyledTextFormField(
                            controller: _contactEmail,
                            label: context.s.siteSettingsContactEmailLabel,
                            helperText: context.s.siteSettingsContactEmailHint,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      StyledSection(
                        header: context.s.siteSettingsBookingSection,
                        inset: false,
                        children: [
                          StyledTextFormField(
                            controller: _lodgifyPropertyId,
                            label: context.s.siteSettingsLodgifyPropertyIdLabel,
                          ),
                          const SizedBox(height: 12),
                          StyledTextFormField(
                            controller: _lodgifyRoomTypeId,
                            label: context.s.siteSettingsLodgifyRoomTypeIdLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
