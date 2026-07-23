import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/core.dart';

import '../../application/site_content_cubit.dart';
import '../../data/translation_service.dart';
import '../widgets/editor_column.dart';
import '../widgets/preview_pane.dart';
import '../widgets/publish_modal.dart';

/// The CMS website editor: a fixed-width editor column beside the live
/// preview, in a [StyledSplitView]. Source mode (preview language == source)
/// shows the plain form; any other language shows the translation editor.
/// Publish opens the all-languages confirmation modal.
class WebsiteEditorPage extends StatelessWidget {
  const WebsiteEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SiteContentCubit(
        translationService: I.get<TranslationService>(),
      ),
      child: const _WebsiteEditorView(),
    );
  }
}

class _WebsiteEditorView extends StatelessWidget {
  const _WebsiteEditorView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SiteContentCubit, SiteContentState>(
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
        return StyledSplitView(
          primaryWidth: 512,
          minPrimary: 420,
          minSecondary: 360,
          collapseBelow: 900,
          primary: EditorColumn(state: state),
          secondary: PreviewPane(state: state),
        );
      },
    );
  }
}
