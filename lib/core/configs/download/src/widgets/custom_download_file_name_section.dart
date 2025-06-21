// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../config/types.dart';
import 'available_tokens.dart';
import 'download_format_card.dart';
import 'filename_preview.dart';

class CustomDownloadFileNameSection extends ConsumerStatefulWidget {
  const CustomDownloadFileNameSection({
    required this.config,
    super.key,
    this.format,
    this.onIndividualDownloadChanged,
    this.onBulkDownloadChanged,
  });

  final String? format;
  final void Function(String value)? onIndividualDownloadChanged;
  final void Function(String value)? onBulkDownloadChanged;

  final BooruConfig config;

  @override
  ConsumerState<CustomDownloadFileNameSection> createState() =>
      _CustomDownloadFileNameSectionState();
}

class _CustomDownloadFileNameSectionState
    extends ConsumerState<CustomDownloadFileNameSection> {
  late final Map<RegExp, TextStyle>? patternMatchMap;
  late final RichTextController individualTextController;
  late final RichTextController bulkTextController;

  @override
  void initState() {
    patternMatchMap = ref
        .read(downloadFilenameBuilderProvider(widget.config.auth))
        ?.patternMatchMap;

    individualTextController = RichTextController.fromMap(
      text: widget.config.customDownloadFileNameFormat,
      matchMap: patternMatchMap,
    );

    bulkTextController = RichTextController.fromMap(
      text: widget.config.customBulkDownloadFileNameFormat,
      matchMap: patternMatchMap,
    );

    super.initState();
  }

  @override
  void dispose() {
    individualTextController.dispose();
    bulkTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadFilenameBuilder =
        ref.watch(downloadFilenameBuilderProvider(widget.config.auth));
    final defaultFileNameFormat =
        downloadFilenameBuilder?.defaultFileNameFormat ?? '';
    final defaultBulkDownloadFileNameFormat =
        downloadFilenameBuilder?.defaultBulkDownloadFileNameFormat ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            text: 'Custom filename format',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        DownloadFormatCard(
          title: 'Individual download',
          downloadFilenameBuilder: downloadFilenameBuilder,
          defaultFileNameFormat: defaultFileNameFormat,
          format: widget.format,
          onChanged: widget.onIndividualDownloadChanged,
          config: widget.config,
        ),
        const SizedBox(height: 8),
        DownloadFormatCard(
          title: 'Bulk download',
          downloadFilenameBuilder: downloadFilenameBuilder,
          defaultFileNameFormat: defaultBulkDownloadFileNameFormat,
          format: widget.config.customBulkDownloadFileNameFormat,
          onChanged: widget.onBulkDownloadChanged,
          config: widget.config,
          previewBuilder: (generator, format) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            child: Column(
              children: generator
                  .generateSamples(format)
                  .map(
                    (e) => FilenamePreview(
                      filename: e,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AvailableTokens(
          downloadFilenameBuilder: downloadFilenameBuilder,
        ),
      ],
    );
  }
}
