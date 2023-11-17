// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:expandable/expandable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/filename_generators/token_option.dart';
import 'package:boorusama/core/feats/posts/post.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class CustomDownloadFileNameSection extends ConsumerStatefulWidget {
  const CustomDownloadFileNameSection({
    super.key,
    this.format,
    this.onIndividualDownloadChanged,
    this.onBulkDownloadChanged,
    required this.config,
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
        .readBooruBuilder(widget.config)
        ?.downloadFilenameBuilder
        .patternMatchMap;

    individualTextController = RichTextController(
      text: widget.config.customDownloadFileNameFormat,
      patternMatchMap: patternMatchMap,
      onMatch: (match) {},
    );

    bulkTextController = RichTextController(
      text: widget.config.customBulkDownloadFileNameFormat,
      patternMatchMap: patternMatchMap,
      onMatch: (match) {},
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
        ref.watchBooruBuilder(widget.config)?.downloadFilenameBuilder;
    final defaultFileNameFormat =
        downloadFilenameBuilder?.defaultFileNameFormat ?? '';
    final defaultBulkDownloadFileNameFormat =
        downloadFilenameBuilder?.defaultBulkDownloadFileNameFormat ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            text: 'Custom filename format ',
            children: [
              TextSpan(
                text: '(Experimental)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: generator
                  .generateSamples(format)
                  .map((e) => FilenamePreview(
                        filename: e,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ))
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

class DownloadFormatCard extends ConsumerStatefulWidget {
  const DownloadFormatCard({
    super.key,
    required this.downloadFilenameBuilder,
    required this.defaultFileNameFormat,
    required this.format,
    required this.onChanged,
    required this.config,
    required this.title,
    this.previewBuilder,
  });

  final DownloadFilenameGenerator<Post>? downloadFilenameBuilder;
  final String defaultFileNameFormat;
  final String? format;
  final BooruConfig config;
  final void Function(String value)? onChanged;
  final String title;
  final Widget Function(
      DownloadFilenameGenerator<Post> generator, String format)? previewBuilder;

  @override
  ConsumerState<DownloadFormatCard> createState() => _DownloadFormatCardState();
}

class _DownloadFormatCardState extends ConsumerState<DownloadFormatCard> {
  late final textController = RichTextController(
    text: widget.format,
    patternMatchMap: ref
        .readBooruBuilder(widget.config)
        ?.downloadFilenameBuilder
        .patternMatchMap,
    onMatch: (match) {},
  );

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
                    widget.downloadFilenameBuilder!, value.text)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: FilenamePreview(
                      filename: widget.downloadFilenameBuilder!
                          .generateSample(value.text),
                    ),
                  ),
          )
        : const SizedBox();

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: context.theme.hintColor),
      ),
      child: ExpandablePanel(
        theme: const ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          tapBodyToCollapse: true,
          iconColor: Colors.white,
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(widget.title, style: context.textTheme.bodyMedium!),
        ),
        collapsed: preview,
        expanded: Column(
          children: [
            preview,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FormatEditingField(
                controller: textController,
                onChanged: widget.onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        textController.text = widget.defaultFileNameFormat;
                        widget.onChanged?.call(widget.defaultFileNameFormat);
                      });
                    },
                    child: const Text('Reset'),
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

class FormatEditingField extends StatelessWidget {
  const FormatEditingField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final RichTextController controller;
  final void Function(String value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      child: TextField(
        controller: controller,
        maxLines: null,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintMaxLines: 4,
          hintText: '\n\n\n',
        ),
      ),
    );
  }
}

class FilenamePreview extends StatelessWidget {
  const FilenamePreview({
    super.key,
    required this.filename,
    this.padding,
  });

  final String filename;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.hashtag,
            size: 16,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
              child: Text(
            filename,
            style: context.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: context.theme.hintColor,
            ),
          )),
        ],
      ),
    );
  }
}

class AvailableTokens extends ConsumerWidget {
  const AvailableTokens({
    super.key,
    required this.downloadFilenameBuilder,
  });

  final DownloadFilenameGenerator? downloadFilenameBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableTokens = downloadFilenameBuilder?.availableTokens ?? {};

    return Wrap(
      runSpacing: isMobilePlatform() ? -4 : 8,
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Available tokens: '),
        for (final token in availableTokens)
          RawChip(
            visualDensity: VisualDensity.compact,
            label: Text(token),
            onPressed: () {
              final tokenOptions =
                  downloadFilenameBuilder?.getTokenOptions(token);

              if (tokenOptions == null) {
                showErrorToast('Token $token is not available');
                return;
              }

              showAdaptiveBottomSheet(
                context,
                builder: (context) => TokenOptionHelpModal(
                  token: token,
                  tokenOptions: tokenOptions,
                  downloadFilenameBuilder: downloadFilenameBuilder,
                ),
              );
            },
          ),
      ],
    );
  }
}

class TokenOptionHelpModal extends StatelessWidget {
  const TokenOptionHelpModal({
    super.key,
    required this.token,
    required this.tokenOptions,
    required this.downloadFilenameBuilder,
  });

  final String token;
  final List<String> tokenOptions;
  final DownloadFilenameGenerator<Post>? downloadFilenameBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(token),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: tokenOptions.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Available options',
                    style: context.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    itemCount: tokenOptions.length,
                    itemBuilder: (context, index) {
                      final option = tokenOptions[index];
                      final docs = downloadFilenameBuilder
                          ?.getDocsForTokenOption(token, option);

                      return ListTile(
                        title: Row(
                          children: [
                            Flexible(child: Text(option)),
                            const SizedBox(width: 4),
                            switch (docs?.tokenOption) {
                              IntegerTokenOption _ => const Chip(
                                  label: Text('integer'),
                                  visualDensity: ShrinkVisualDensity(),
                                ),
                              BooleanTokenOption _ => const Chip(
                                  label: Text('boolean'),
                                  visualDensity: ShrinkVisualDensity(),
                                ),
                              StringTokenOption _ => const Chip(
                                  label: Text('string'),
                                  visualDensity: ShrinkVisualDensity(),
                                ),
                              _ => const SizedBox.shrink(),
                            }
                          ],
                        ),
                        subtitle: docs != null ? Text(docs.description) : null,
                        trailing: IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: option))
                                .then((value) => showSuccessToast('Copied'));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('No options available'),
            ),
    );
  }
}
