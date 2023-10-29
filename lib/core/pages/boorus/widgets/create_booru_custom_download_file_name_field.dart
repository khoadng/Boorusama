// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

//FIXME: remind user that this feature is experimental
class CreateBooruCustomDownloadFileNameField extends ConsumerStatefulWidget {
  const CreateBooruCustomDownloadFileNameField({
    super.key,
    this.format,
    this.onChanged,
    required this.config,
    required this.defaultFormat,
  });

  final String? format;
  final String defaultFormat;
  final void Function(String value)? onChanged;
  final BooruConfig config;

  @override
  ConsumerState<CreateBooruCustomDownloadFileNameField> createState() =>
      _CreateBooruCustomDownloadFileNameFieldState();
}

class _CreateBooruCustomDownloadFileNameFieldState
    extends ConsumerState<CreateBooruCustomDownloadFileNameField> {
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
    final downloadFilenameBuilder =
        ref.watchBooruBuilder(widget.config)?.downloadFilenameBuilder;
    final availableTokens = downloadFilenameBuilder?.availableTokens ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
                child: Text('Custom download file name format (Experimental)')),
            TextButton(
              onPressed: () => textController.text = widget.defaultFormat,
              child: const Text('Reset'),
            ),
          ],
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          child: TextField(
            controller: textController,
            maxLines: null,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintMaxLines: 4,
              hintText: '\n\n\n',
              filled: true,
              fillColor: context.colorScheme.background,
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: context.theme.colorScheme.secondary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        if (downloadFilenameBuilder != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.hashtag,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: textController,
                    builder: (context, value, child) => Text(
                      downloadFilenameBuilder.generateSample(value.text),
                      style: context.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.theme.hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Wrap(
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
                  final tokenOptions = ref
                      .watchBooruBuilder(widget.config)
                      ?.downloadFilenameBuilder
                      .getTokenOptions(token);

                  if (tokenOptions == null) {
                    showErrorToast('Token $token is not available');
                    return;
                  }

                  showAdaptiveBottomSheet(
                    context,
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Available options'),
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
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: tokenOptions.length,
                                    itemBuilder: (context, index) {
                                      final option = tokenOptions[index];
                                      final docs = downloadFilenameBuilder
                                          ?.getDocsForTokenOption(option);

                                      return ListTile(
                                        title: Text(option),
                                        subtitle:
                                            docs != null ? Text(docs) : null,
                                        trailing: IconButton(
                                          onPressed: () {
                                            Clipboard.setData(
                                                    ClipboardData(text: option))
                                                .then((value) =>
                                                    showSuccessToast('Copied'));
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
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
