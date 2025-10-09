// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../widgets/widgets.dart';
import '../../../note/types.dart';
import '../../../note/widgets.dart';
import '../constants/editor_keys.dart';
import '../controllers/note_editor_controller.dart';
import '../painters/note_rect_painter.dart';
import '../providers/note_editor_provider.dart';
import '../types/note_changeset.dart';
import '../types/note_image.dart';
import '../types/note_rect_data.dart';
import '../widgets/note_tool_palette.dart';
import 'add_note_dialog.dart';
import 'unsaved_alert_dialog.dart';

class RawNoteEditorPage extends ConsumerStatefulWidget {
  const RawNoteEditorPage({
    super.key,
    required this.image,
    required this.imageBuilder,
    this.onSubmit,
    this.initialNotes = const [],
  });

  final NoteImage image;
  final void Function(NoteChangeset changeset)? onSubmit;
  final List<NoteRectData> initialNotes;
  final Widget Function(BoxConstraints constraints) imageBuilder;

  @override
  ConsumerState<RawNoteEditorPage> createState() => _RawNoteEditorPageState();
}

class _RawNoteEditorPageState extends ConsumerState<RawNoteEditorPage> {
  final _imageKey = GlobalKey();
  final _gestureKey = GlobalKey();
  final transformationController = TransformationController();
  late final NoteEditorController controller;
  var _initialNotesLoaded = false;

  @override
  void initState() {
    super.initState();
    controller = NoteEditorController(
      image: widget.image,
    );

    if (widget.initialNotes.isEmpty) {
      controller.initializeHistory();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNotes();
    });
  }

  void _loadInitialNotes() {
    if (_initialNotesLoaded || widget.initialNotes.isEmpty) return;

    controller.loadInitialNotes(widget.initialNotes);
    controller.initializeHistory();
    _initialNotesLoaded = true;
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    transformationController.dispose();

    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    final imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final gestureBox =
        _gestureKey.currentContext?.findRenderObject() as RenderBox?;

    if (imageBox == null || gestureBox == null) return;

    final widgetPosition = imageBox.globalToLocal(details.globalPosition);
    final gesturePosition = gestureBox.globalToLocal(details.globalPosition);

    final imagePosition = widget.image.widgetToImageCoordinates(
      widgetPosition,
      imageBox.size,
    );

    controller.startGesture(imagePosition, gesturePosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final gestureBox =
        _gestureKey.currentContext?.findRenderObject() as RenderBox?;

    if (imageBox == null || gestureBox == null) return;

    final widgetPosition = imageBox.globalToLocal(details.globalPosition);
    final gesturePosition = gestureBox.globalToLocal(details.globalPosition);

    final imagePosition = widget.image.widgetToImageCoordinates(
      widgetPosition,
      imageBox.size,
    );

    controller.updateGesture(imagePosition, gesturePosition);
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    switch (controller.mode) {
      case GestureMode.moving:
        controller.finishMoving();
      case GestureMode.drawing
          when controller.drawingRect?.isTooSmall() ?? false:
        controller.cancelDrag();
      case GestureMode.drawing when controller.drawingRect != null:
        final text = await _showNoteInputDialog();
        controller.finishDrawing(text);
      case GestureMode.drawing:
      case GestureMode.none:
        break;
    }
  }

  Future<String?> _showNoteInputDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => const AddNoteDialog(),
    );
  }

  void _onTapImage() {
    if (controller.currentTool.value.isInteractive) {
      ref.read(noteEditorProvider.notifier).toggleOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayVisible = ref.watch(
      noteEditorProvider.select((state) => state.overlayVisible),
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final navigator = Navigator.of(context);

            if (controller.hasNoChanges) {
              navigator.pop(true);
            } else {
              final continueEdit = await showDialog(
                context: context,
                builder: (context) => const UnsavedAlertDialog(),
              );

              if (continueEdit == true) {
                return;
              } else {
                navigator.pop(false);
              }
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: overlayVisible
                ? AppBar(
                    actions: [
                      IconButton(
                        key: kUndoButtonKey,
                        icon: const Icon(Icons.undo),
                        onPressed: controller.canUndo ? controller.undo : null,
                      ),
                      IconButton(
                        key: kRedoButtonKey,
                        icon: const Icon(Icons.redo),
                        onPressed: controller.canRedo ? controller.redo : null,
                      ),
                      IconButton(
                        key: kSubmitButtonKey,
                        icon: const Icon(Icons.save),
                        onPressed: controller.hasNoChanges
                            ? null
                            : () {
                                widget.onSubmit?.call(
                                  controller.getChangeset(),
                                );
                              },
                      ),
                    ],
                  )
                : null,
            body: _buildBody(),
            bottomNavigationBar: overlayVisible
                ? SafeArea(
                    child: NoteToolPalette(
                      controller: controller,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder(
      valueListenable: controller.currentTool,
      builder: (context, currentTool, child) {
        final center = Center(
          child: AspectRatio(
            aspectRatio: widget.image.aspectRatio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageSize = widget.image.size;

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: currentTool.isInteractive ? _onTapImage : null,
                      child: _buildImage(constraints),
                    ),

                    if (currentTool.isInteractive)
                      ...controller.savedTrackedNotes.map((trackedNote) {
                        final note = trackedNote
                            .toRectData(
                              originalImageSize: imageSize,
                              imageSize: imageSize,
                            )
                            .toNote();

                        return LayoutBuilder(
                          builder: (context, noteConstraints) {
                            return PostNote(
                              note: note.adjust(
                                width: widget.image.width,
                                height: widget.image.height,
                                widthConstraint: noteConstraints.maxWidth,
                                heightConstraint: noteConstraints.maxHeight,
                              ),
                              displayMode: NoteDisplayMode.inlineHorizontal,
                            );
                          },
                        );
                      }),

                    if (currentTool.isEditable)
                      GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            key: _gestureKey,
                            painter: NoteRectPainter(
                              savedRects: controller.savedRects,
                              image: widget.image,
                              movingRectIndex: controller.movingRectIndex,
                              selectedRectIndex: controller.selectedRectIndex,
                              drawingRect: controller.drawingRect,
                            ),
                            child: Container(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
        return currentTool.isInteractive
            ? InteractiveViewerExtended(
                controller: transformationController,
                child: center,
              )
            : AnimatedBuilder(
                animation: transformationController,
                builder: (context, child) => Transform(
                  transform: transformationController.value,
                  child: child,
                ),
                child: center,
              );
      },
    );
  }

  Widget _buildImage(BoxConstraints constraints) => KeyedSubtree(
    key: _imageKey,
    child: widget.imageBuilder(constraints),
  );
}
