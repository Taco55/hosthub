import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

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
              repository:
                  WebsiteContentRepository(supabase: Supabase.instance.client),
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
          onConfirm: cubit.publishAll,
        );
        if (confirmed != true) cubit.closePublish();
      },
      builder: (context, state) {
        return StyledWebPageScaffold(
          title: context.s.weBreadcrumbWebsite,
          showHeader: false,
          padding: EdgeInsets.zero,
          paneGap: 0,
          leftPaneSize: const StyledPaneSize.fixed(512),
          leftChild: EditorColumn(state: state, siteId: siteId),
          rightChild: PreviewPane(state: state),
          showRightPane: true,
        );
      },
    );

    if (siteId == null) return view;

    // The rail's source-language switcher changes sites.default_locale; reload
    // the editor content so the authoring language follows it.
    return BlocListener<SiteContextCubit, SiteContextState>(
      listenWhen: (prev, next) =>
          prev.site?.defaultLocale != next.site?.defaultLocale &&
          next.site?.id == siteId,
      listener: (context, _) =>
          context.read<SiteContentCubit>().loadContent(),
      child: view,
    );
  }
}
