import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/app/shell/navigation/navigation_guard_controller.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import '../../application/media_library_cubit.dart';
import '../../application/site_content_cubit.dart';
import '../../data/media_repository.dart';
import '../../application/unsaved_changes_warning.dart';
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
  /// documents + `site_translations`, edits are written when the owner saves,
  /// and translation runs through the translate-content Edge Function. Without
  /// it the editor runs on the in-memory demo seed.
  final String? siteId;

  @override
  Widget build(BuildContext context) {
    final id = siteId;
    final editor = BlocProvider(
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
    if (id == null) return editor;
    // The library is a per-site thing and only exists for a real site: the
    // demo seed has no bucket to read. Provided above the editor so the media
    // rows and the picker share one library and one upload queue.
    return BlocProvider(
      create: (_) => MediaLibraryCubit(
        repository: MediaRepository(supabase: Supabase.instance.client),
        siteId: id,
      )..load(),
      child: editor,
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
        // Until the site's content is in, there is no form to show: an editor
        // rendering its fallback content beside the real website is how a
        // failed load turns into copy the owner never wrote (§11i).
        if (state.loadStatus != ContentLoadStatus.ready) {
          return StyledWebPageScaffold(
            decorateLeftPane: true,
            title: context.s.weBreadcrumbWebsite,
            showHeader: false,
            leftChild: state.loadStatus == ContentLoadStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : StyledEmptyState(
                    iconData: Icons.cloud_off_outlined,
                    title: context.s.weErrorLoadFailed,
                    description: context.s.weLoadFailedDescription,
                    actionLabel: context.s.weLoadFailedRetry,
                    onAction: () =>
                        context.read<SiteContentCubit>().loadContent(),
                  ),
          );
        }
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

    // A failed load is not a degradation: the editor is left showing content
    // that is not this site's, so it gets the blocking error dialog rather than
    // a toast the owner can type straight past.
    final withLoadError = BlocListener<SiteContentCubit, SiteContentState>(
      listenWhen: (prev, next) =>
          next.loadError != null && prev.loadError != next.loadError,
      listener: (context, state) async {
        final error = state.loadError;
        if (error == null) return;
        await showAppError(
          context,
          // The mapped alert says why it failed; the title says what failed.
          AppError.fromDomain(
            context,
            error,
          ).copyWith(title: context.s.weErrorLoadFailed),
        );
        if (!context.mounted) return;
        context.read<SiteContentCubit>().clearLoadError();
      },
      child: withErrorToasts,
    );

    // §11i: the draft lives in the cubit and nothing writes it behind the
    // owner's back, so leaving is the one moment it can be lost silently.
    final guarded = _UnsavedChangesGuard(child: withLoadError);

    if (siteId == null) return guarded;

    // The rail's source-language switcher changes sites.default_locale; reload
    // the editor content so the authoring language follows it.
    return BlocListener<SiteContextCubit, SiteContextState>(
      listenWhen: (prev, next) =>
          prev.site?.defaultLocale != next.site?.defaultLocale &&
          next.site?.id == siteId,
      listener: (context, _) => context.read<SiteContentCubit>().loadContent(),
      child: guarded,
    );
  }
}

/// Keeps an unsaved draft from disappearing without the owner deciding to lose
/// it (§11i). Three exits, one answer: the side menu asks through
/// [NavigationGuardController], a route pop asks through [PopScope], and the
/// browser's own close/back gets the native prompt. None of them saves — the
/// draft stays in the cubit either way, so "Leave" costs nothing until the tab
/// itself goes.
class _UnsavedChangesGuard extends StatefulWidget {
  const _UnsavedChangesGuard({required this.child});

  final Widget child;

  @override
  State<_UnsavedChangesGuard> createState() => _UnsavedChangesGuardState();
}

class _UnsavedChangesGuardState extends State<_UnsavedChangesGuard> {
  NavigationGuardController? _navigationGuard;

  /// Set once the owner has answered "leave" — the pop that follows must not
  /// ask the same question again.
  bool _leaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<NavigationGuardController>();
    if (identical(controller, _navigationGuard)) return;
    _navigationGuard?.setGuard(null);
    _navigationGuard = controller..setGuard(_confirmLeave);
  }

  @override
  void dispose() {
    _navigationGuard?.setGuard(null);
    setUnsavedChangesWarning(enabled: false);
    super.dispose();
  }

  Future<bool> _confirmLeave() async {
    if (!mounted) return true;
    if (!context.read<SiteContentCubit>().state.unsavedChanges) return true;
    final leave = await showStyledAlertDialog(
      context,
      title: context.s.weLeaveTitle,
      message: context.s.weLeaveMessage,
      actionText: context.s.weLeaveConfirm,
      dismissText: context.s.weLeaveCancel,
      isDestructiveAction: true,
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SiteContentCubit, SiteContentState>(
      listenWhen: (prev, next) => prev.unsavedChanges != next.unsavedChanges,
      listener: (context, state) =>
          setUnsavedChangesWarning(enabled: state.unsavedChanges),
      child: BlocBuilder<SiteContentCubit, SiteContentState>(
        buildWhen: (prev, next) => prev.unsavedChanges != next.unsavedChanges,
        builder: (context, state) => PopScope(
          canPop: !state.unsavedChanges || _leaving,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !await _confirmLeave() || !mounted) return;
            setState(() => _leaving = true);
            Navigator.of(context).pop();
          },
          child: widget.child,
        ),
      ),
    );
  }
}
