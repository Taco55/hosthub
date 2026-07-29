import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/site_content_cubit.dart';
import '../../data/edge_function_translation_service.dart';
import '../../data/website_content_repository.dart';
import '../../domain/editor_schema.dart';
import 'editor_card_view.dart';
import 'editor_column.dart';

/// Juridisch: the privacy statement, edited where it belongs.
///
/// It is a page of the site, but not a tab of the editor. A legal document has
/// a different author from the marketing copy, changes per year rather than per
/// season, and a fifth tab would invite editing exactly what you do not want
/// casually edited. So it sits under Site-instellingen — and runs through
/// *exactly* the same model as everything else: source language,
/// `Automatisch`/`Vergrendeld` per field, stale detection, explicit save, and
/// publishing with the rest. Same machinery, different place.
class LegalDocumentSection extends StatelessWidget {
  const LegalDocumentSection({super.key, required this.siteId});

  final String siteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SiteContentCubit>(
      create: (_) =>
          SiteContentCubit(
              translationService: EdgeFunctionTranslationService(
                supabase: Supabase.instance.client,
                siteId: siteId,
                page: WebsiteContentRepository.page,
              ),
              repository: WebsiteContentRepository(
                supabase: Supabase.instance.client,
              ),
              siteId: siteId,
            )
            // A cubit of its own rather than the editor's: this section is
            // reachable without the editor being open, and its draft is its own
            // — saving the privacy statement must not commit unsaved page copy.
            ..loadContent().then((_) => null),
      child: const _LegalDocumentView(),
    );
  }
}

class _LegalDocumentView extends StatefulWidget {
  const _LegalDocumentView();

  @override
  State<_LegalDocumentView> createState() => _LegalDocumentViewState();
}

class _LegalDocumentViewState extends State<_LegalDocumentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SiteContentCubit>().selectPage(kLegalPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteContentCubit, SiteContentState>(
      builder: (context, state) {
        if (state.loadStatus == ContentLoadStatus.loading) {
          return StyledSection(
            header: context.s.legalSectionTitle,
            horizontalPadding: 0,
            children: const [Center(child: CircularProgressIndicator())],
          );
        }
        if (state.loadStatus != ContentLoadStatus.ready) {
          // Never fall back to seed copy: a legal document the owner did not
          // write is the worst thing this screen could show.
          return StyledSection(
            header: context.s.legalSectionTitle,
            horizontalPadding: 0,
            children: [
              StyledEmptyState(
                iconData: Icons.cloud_off_outlined,
                title: context.s.weErrorLoadFailed,
                description: context.s.weLoadFailedDescription,
                actionLabel: context.s.weLoadFailedRetry,
                onAction: () => context.read<SiteContentCubit>().loadContent(),
              ),
            ],
          );
        }

        final cards = kPageCards[kLegalPage] ?? const <EditorCard>[];

        return StyledSection(
          header: context.s.legalSectionTitle,
          footer: context.s.legalSectionFooter,
          horizontalPadding: 0,
          headerAction: EditorLocaleSwitcher(state: state),
          children: [
            // The warning sits above the fields, not in a tooltip: someone who
            // learns this is a legal text after editing it was told too late.
            StyledNotice(
              icon: Icons.gavel_outlined,
              message: context.s.legalSectionWarning,
              tone: StyledNoticeTone.warning,
            ),
            SizedBox(height: context.styledSpacing.lg),
            for (final card in cards) ...[
              EditorCardView(state: state, card: card),
              SizedBox(height: context.styledSpacing.lg),
            ],
            EditorSaveBar(state: state),
          ],
        );
      },
    );
  }
}
