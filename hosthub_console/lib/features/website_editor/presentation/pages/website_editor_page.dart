import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import '../../application/site_content_cubit.dart';
import '../../data/edge_function_translation_service.dart';
import '../../data/translation_service.dart';
import '../../data/website_content_repository.dart';
import '../widgets/editor_column.dart';
import '../widgets/preview_pane.dart';
import '../widgets/publish_modal.dart';

/// The CMS website editor: a fixed-width editor column beside the live
/// preview, in a full-bleed [StyledWebPageScaffold] (header hidden — the
/// editor column carries its own top bar). Source mode (preview language ==
/// source) shows the plain form; any other language shows the translation
/// editor. Publish opens the all-languages confirmation modal.
class WebsiteEditorPage extends StatelessWidget {
  const WebsiteEditorPage({super.key, this.siteId});

  /// When set, the editor is persistent: content hydrates from the site's
  /// documents + `site_translations`, edits autosave, and translation runs
  /// through the translate-content Edge Function. Without it the editor runs
  /// on the in-memory demo seed.
  final String? siteId;

  @override
  Widget build(BuildContext context) {
    final id = siteId;
    return BlocProvider(
      create: (_) => id == null
          ? SiteContentCubit(translationService: I.get<TranslationService>())
          : (SiteContentCubit(
              translationService: EdgeFunctionTranslationService(
                supabase: Supabase.instance.client,
                siteId: id,
                page: WebsiteContentRepository.page,
              ),
              repository: WebsiteContentRepository(
                supabase: Supabase.instance.client,
              ),
              siteId: id,
            )..loadContent()),
      child: _WebsiteEditorView(siteId: id),
    );
  }
}

class _WebsiteEditorView extends StatelessWidget {
  const _WebsiteEditorView({this.siteId});

  final String? siteId;

  @override
  Widget build(BuildContext context) {
    final view = BlocConsumer<SiteContentCubit, SiteContentState>(
      listenWhen: (prev, next) => !prev.publishOpen && next.publishOpen,
      listener: (context, state) async {
        final cubit = context.read<SiteContentCubit>();
        // The dialog runs publishAll as its async action (loading overlay,
        // stays open on failure); on cancel we only clear the open flag.
        final confirmed = await showPublishModal(
          context,
          state: state,
          onConfirm: (skipLanguages) =>
              cubit.publishAll(skipLanguages: skipLanguages),
        );
        if (confirmed != true) cubit.closePublish();
      },
      builder: (context, state) {
        return StyledWebPageScaffold(
          // White editor column (design .editcol); preview stays bare.
          decorateLeftPane: true,
          panePadding: EdgeInsets.zero,
          decorateRightPane: false,
          title: context.s.weBreadcrumbWebsite,
          showHeader: false,
          padding: EdgeInsets.zero,
          paneGap: 0,
          // Fixed editor column beside the preview; when the preview is hidden
          // the column expands to fill the width (null → Expanded pane) instead
          // of stranding a 512px column beside empty space.
          leftPaneSize: state.previewVisible
              ? const StyledPaneSize.fixed(512)
              : null,
          // §11d: with the preview hidden the editor takes the full width but
          // centres its content — a form line does not become more readable by
          // being 1600px wide.
          contentMaxWidth: state.previewVisible ? null : 760,
          leftChild: EditorColumn(
            state: state,
            siteId: siteId,
            // The editor's title names the property, and that comes from the
            // app's property context — not from the content seed.
            propertyName: context
                .watch<PropertyContextCubit>()
                .state
                .currentProperty
                ?.name,
          ),
          rightChild: PreviewPane(state: state),
          showRightPane: state.previewVisible,
        );
      },
    );

    // Non-blocking error feedback (TRANSLATION.md: degrade gracefully with a
    // toast; edits/drafts are kept). Cleared after showing so a repeat of the
    // same failure surfaces again.
    final withErrorToasts = BlocListener<SiteContentCubit, SiteContentState>(
      listenWhen: (prev, next) =>
          next.errorMessage != null && prev.errorMessage != next.errorMessage,
      listener: (context, state) {
        final message = switch (state.errorMessage) {
          'load_failed' => context.s.weErrorLoadFailed,
          'save_failed' => context.s.weErrorSaveFailed,
          'translate_failed' => context.s.weErrorTranslateFailed,
          'reset_failed' => context.s.weErrorResetFailed,
          'publish_failed' => context.s.weErrorPublishFailed,
          _ => null,
        };
        if (message != null) {
          showStyledToast(
            context,
            type: ToastificationType.error,
            title: message,
          );
        }
        context.read<SiteContentCubit>().clearErrorMessage();
      },
      child: view,
    );

    if (siteId == null) return withErrorToasts;

    // The rail's source-language switcher changes sites.default_locale; reload
    // the editor content so the authoring language follows it.
    return BlocListener<SiteContextCubit, SiteContextState>(
      listenWhen: (prev, next) =>
          prev.site?.defaultLocale != next.site?.defaultLocale &&
          next.site?.id == siteId,
      listener: (context, _) => context.read<SiteContentCubit>().loadContent(),
      child: withErrorToasts,
    );
  }
}
