// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:expandable/expandable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../downloads/filename/types.dart';
import '../../../../posts/post/post.dart';
import '../../../config/types.dart';
import 'filename_preview.dart';
import 'format_editing_field.dart';

class DownloadFormatCard extends ConsumerStatefulWidget {
  const DownloadFormatCard({
    required this.downloadFilenameBuilder,
    required this.defaultFileNameFormat,
    required this.format,
    required this.onChanged,
    required this.config,
    required this.title,
    super.key,
    this.previewBuilder,
  });

  final DownloadFilenameGenerator<Post>? downloadFilenameBuilder;
  final String defaultFileNameFormat;
  final String? format;
  final BooruConfig config;
  final void Function(String value)? onChanged;
  final String title;
  final Widget Function(
    DownloadFilenameGenerator<Post> generator,
    String format,
  )? previewBuilder;

  @override
  ConsumerState<DownloadFormatCard> createState() => _DownloadFormatCardState();
}

class _DownloadFormatCardState extends ConsumerState<DownloadFormatCard> {
  late final RichTextController textController;

  @override
  void initState() {
    super.initState();

    textController = RichTextController(
      text: widget.format,
      matchers: ref
          .read(downloadFilenameBuilderProvider(widget.config.auth))
          ?.textMatchers,
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.downloadFilenameBuilder != null
        ? ValueListenableBuilder(
            valueListenable: textController,
            builder: (context, value, child) => widget.previewBuilder != null
                ? widget.previewBuilder!(
                    widget.downloadFilenameBuilder!,
                    value.text,
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: FilenamePreview(
                      filename: widget.downloadFilenameBuilder!
                          .generateSample(value.text),
                    ),
                  ),
          )
        : const SizedBox();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: ExpandablePanel(
        theme: ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          tapBodyToCollapse: true,
          iconColor: Theme.of(context).iconTheme.color,
          inkWellBorderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        collapsed: preview,
        expanded: Column(
          children: [
            preview,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FormatEditingField(
                controller: textController,
                onChanged: widget.onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          textController.text = widget.defaultFileNameFormat;
                          widget.onChanged?.call(widget.defaultFileNameFormat);
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
