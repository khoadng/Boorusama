// Flutter imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//FIXME: remind user that this feature is experimental
class CreateBooruCustomDownloadFileNameField extends ConsumerStatefulWidget {
  const CreateBooruCustomDownloadFileNameField({
    super.key,
    this.format,
    this.onChanged,
    required this.config,
  });

  final String? format;
  final void Function(String value)? onChanged;
  final BooruConfig config;

  @override
  ConsumerState<CreateBooruCustomDownloadFileNameField> createState() =>
      _CreateBooruCustomDownloadFileNameFieldState();
}

class _CreateBooruCustomDownloadFileNameFieldState
    extends ConsumerState<CreateBooruCustomDownloadFileNameField> {
  late final textController = TextEditingController(text: widget.format);

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableTokens = ref
            .watchBooruBuilder(widget.config)
            ?.downloadFilenameBuilder
            .availableTokens ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
                child: Text('Custom download file name format (Experimental)')),
            TextButton(
              onPressed: () => print('object'),
              child: const Text('Help'),
            ),
          ],
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          child: TextField(
            controller: textController,
            maxLines: null,
            decoration: InputDecoration(
              hintMaxLines: 6,
              hintText: '\n\n\n\n',
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
              ),
          ],
        ),
        // TextButton(
        //   onPressed: () => print('object'),
        //   child: Text('Show available tokens'),
        // ),
      ],
    );
  }
}
