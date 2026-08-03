import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_back.dart';
import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/user_settings/presentation/widgets/site_settings_sections.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/legal_document_section.dart';

/// Site-instellingen: everything that is about **this one property's website**.
///
/// It gathers what used to be spread over three screens called "instellingen":
/// the site's own details, the website languages and the source language (which
/// sat on the account page), the contact recipient and the channel ids, and the
/// legal document (§A.6). The rule that decides what belongs here is the one
/// question the owner actually has — does this hold for all my properties, or
/// for this one? Everything that cascades is Standaardwaarden; everything about
/// the organisation is Account; this is what deviates per property.
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
    try {
      await context.read<CmsCubit>().saveSiteSettings(
        contactEmail: _norm(_contactEmail.text),
        emailFromName: _norm(_emailFromName.text),
        lodgifyPropertyId: _norm(_lodgifyPropertyId.text),
        lodgifyRoomTypeId: _norm(_lodgifyRoomTypeId.text),
      );
      if (!mounted) return;
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: context.s.siteSettingsSaved,
      );
    } catch (_) {
      if (!mounted) return;
      showStyledToast(
        context,
        type: ToastificationType.error,
        description: context.s.siteSettingsSaveFailed,
      );
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
        return StyledWebPageScaffold(
          // Design `.top`: the crumb says which part of the console this is,
          // the title is the screen.
          overline: context.s.navPropertyWebsite,
          title: context.s.navPropertySiteSettings,
          primaryAction: StyledWebPageAction(
            label: context.s.saveButton,
            icon: Icons.save_outlined,
            enabled: !_saving && !loading,
            inProgress: _saving,
            onPressed: (_saving || loading) ? null : () => _save(),
          ),
          // The sidebar carries no row for this page, so the back button is the
          // way out — and it must survive a cold link, which has no stack.
          onBack: () => leaveTo(context, '/sites/${widget.siteId}'),
          backLabel: context.s.navPropertyWebsite,
          intrinsicPaneHeight: true,
          leftChild: SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Site details, website languages and the source
                      // language: property scope, so they live here rather
                      // than on the account page they used to sit on.
                      ...buildSiteSettingsSections(
                        context,
                        context.watch<SiteContextCubit>().state,
                      ),
                      const SizedBox(height: 20),
                      StyledSection(
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
                      const SizedBox(height: 20),
                      LegalDocumentSection(siteId: widget.siteId),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
