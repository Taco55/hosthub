import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/media_library_cubit.dart';
import '../../domain/media_file.dart';

/// Which files a picker may hand back.
enum MediaPickerMode {
  /// One file; choosing replaces what was there (a highlight's image).
  single,

  /// Several, up to a maximum (hero photos, a gallery set).
  multiple,
}

/// The one picker, with three callers (README §C.1): hero, gallery, and a
/// single row image. The difference is the selection rule and the words —
/// not a second implementation.
///
/// Returns the chosen storage paths in the order they were picked, or null when
/// the owner cancelled. A cancel leaves the library exactly as it is: uploads
/// that landed stay in it, because they did land.
Future<List<String>?> showMediaPicker(
  BuildContext context, {
  required MediaLibraryCubit cubit,
  required String title,
  required MediaPickerMode mode,
  required List<String> initialSelection,
  int? maxSelection,
}) {
  return showStyledModal<List<String>>(
    context,
    title: title,
    sheet: const StyledModalSheet(presentation: StyledModalPresentation.dialog),
    sizing: const StyledModalSizing(
      dialogMinWidth: 760,
      dialogMaxWidth: 760,
      bodyMinHeight: 460,
      enableBodyScroll: true,
    ),
    builder: (modalContext, controller) => BlocProvider.value(
      value: cubit,
      child: _MediaPickerBody(
        controller: controller,
        mode: mode,
        initialSelection: initialSelection,
        maxSelection: maxSelection,
      ),
    ),
  );
}

class _MediaPickerBody extends StatefulWidget {
  const _MediaPickerBody({
    required this.controller,
    required this.mode,
    required this.initialSelection,
    this.maxSelection,
  });

  final StyledModalController<List<String>> controller;
  final MediaPickerMode mode;
  final List<String> initialSelection;
  final int? maxSelection;

  @override
  State<_MediaPickerBody> createState() => _MediaPickerBodyState();
}

class _MediaPickerBodyState extends State<_MediaPickerBody> {
  /// The order files were picked in — the strip renders in this order, so a
  /// Set would lose the one thing the owner arranged.
  late List<String> _selection = List.of(widget.initialSelection);
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures — the grid renders what lands; a failure shows
    // as the library's own error state.
    context.read<MediaLibraryCubit>().load();
  }

  bool get _isSingle => widget.mode == MediaPickerMode.single;

  int get _remaining => widget.maxSelection == null
      ? 0
      : widget.maxSelection! - _selection.length;

  void _onSelectionChanged(Set<MediaFile> next, List<MediaFile> library) {
    setState(() {
      if (_isSingle) {
        _selection = next.isEmpty ? [] : [next.first.storagePath];
        return;
      }
      // Keep the existing order and append what is new, so picking does not
      // reshuffle a strip the owner already arranged.
      final paths = next.map((file) => file.storagePath).toSet();
      _selection = [
        for (final path in _selection)
          if (paths.contains(path)) path,
        for (final file in library)
          if (paths.contains(file.storagePath) &&
              !_selection.contains(file.storagePath))
            file.storagePath,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MediaLibraryCubit>();
    final state = context.watch<MediaLibraryCubit>().state;
    final spacing = context.styledSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: Text(
            _isSingle
                ? context.s.weMediaPickerSingleHint
                : context.s.weMediaPickerHint(_remaining),
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: StyledSegmentedControl(
            variant: StyledSegmentedControlVariant.plain,
            segments: [
              StyledSegment(label: context.s.weMediaTabLibrary),
              StyledSegment(label: context.s.weMediaTabUpload),
            ],
            selectedIndex: _tab,
            onChanged: (index) => setState(() => _tab = index),
          ),
        ),
        SizedBox(height: spacing.md),
        if (_tab == 0)
          _LibraryTab(
            state: state,
            cubit: cubit,
            selection: _selection,
            mode: widget.mode,
            maxSelection: widget.maxSelection,
            onSelectionChanged: (next) =>
                _onSelectionChanged(next, state.files),
          )
        else
          _UploadTab(state: state, cubit: cubit),
        SizedBox(height: spacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StyledButton(
              title: context.s.weMediaCancel,
              variant: StyledButtonVariant.secondary,
              size: StyledButtonSize.compact,
              onPressed: () => widget.controller.close(null),
            ),
            SizedBox(width: spacing.sm),
            StyledButton(
              // The confirm counts what actually goes back, so the button can
              // be read instead of guessed.
              title: _isSingle
                  ? context.s.weMediaReplace
                  : context.s.weMediaAdd(_selection.length),
              size: StyledButtonSize.compact,
              enabled: _selection.isNotEmpty,
              onPressed: () {
                cubit.clearUploads();
                widget.controller.close(_selection);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab({
    required this.state,
    required this.cubit,
    required this.selection,
    required this.mode,
    required this.onSelectionChanged,
    this.maxSelection,
  });

  final MediaLibraryState state;
  final MediaLibraryCubit cubit;
  final List<String> selection;
  final MediaPickerMode mode;
  final int? maxSelection;
  final ValueChanged<Set<MediaFile>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (state.loading && state.files.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.files.isEmpty) {
      return StyledEmptyState(
        iconData: Icons.photo_library_outlined,
        title: context.s.weMediaEmptyTitle,
        description: context.s.weMediaEmptyBody,
      );
    }

    final selected = {
      for (final file in state.files)
        if (selection.contains(file.storagePath)) file,
    };

    return StyledSelectableGrid<MediaFile>(
      items: state.files,
      selection: selected,
      selectionMode: mode == MediaPickerMode.single
          ? StyledSelectionMode.single
          : StyledSelectionMode.multiple,
      maxSelection: maxSelection,
      onSelectionChanged: onSelectionChanged,
      itemBuilder: (context, file) => Image.network(
        // A grid of tiles, not a gallery: the thumb is what a 160-pixel tile
        // can show, and the master is what opening this modal used to cost.
        cubit.thumbUrlOf(file.storagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) =>
            const Icon(Icons.broken_image_outlined),
      ),
      captionBuilder: (file) => file.filename,
      // Every tile says what it is for, so "where is this photo used?" is
      // answered by the picker instead of asked about it (README §C.1).
      subtitleBuilder: (file) =>
          file.usage.isEmpty ? context.s.weMediaUnused : file.usage.join(' · '),
    );
  }
}

class _UploadTab extends StatelessWidget {
  const _UploadTab({required this.state, required this.cubit});

  final MediaLibraryState state;
  final MediaLibraryCubit cubit;

  String _statusLabel(BuildContext context, MediaUpload upload) {
    return switch (upload.rejection) {
      MediaRejection.type => context.s.weUploadRejectedType,
      MediaRejection.tooLarge => context.s.weUploadRejectedTooLarge,
      MediaRejection.tooSmall => context.s.weUploadRejectedTooSmall(
        upload.width ?? 0,
        upload.height ?? 0,
      ),
      MediaRejection.portrait => context.s.weUploadRejectedPortrait,
      null => context.s.weUploadFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StyledDropzone(
          title: context.s.weUploadDropTitle,
          requirements: [
            context.s.weUploadRequirements,
            context.s.weUploadResizeNote,
          ],
          // Picking files is platform work the picker does not own yet; the
          // zone is here so the requirements are stated where they belong.
          onPickFiles: () {},
        ),
        SizedBox(height: context.styledSpacing.lg),
        for (final upload in state.uploads)
          StyledUploadRow(
            name: upload.filename,
            status: upload.isBusy
                ? StyledUploadStatus.uploading(
                    progress: upload.progress,
                    label: context.s.weUploadInProgress,
                  )
                : upload.done
                ? StyledUploadStatus.done(
                    detail: context.s.weUploadDone(
                      upload.width ?? 0,
                      upload.height ?? 0,
                    ),
                  )
                : StyledUploadStatus.failed(
                    reason: _statusLabel(context, upload),
                  ),
          ),
      ],
    );
  }
}
