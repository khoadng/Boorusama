// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

//FIXME: remind user that this feature is experimental
class CreateBooruCustomDownloadFileNameField extends StatefulWidget {
  const CreateBooruCustomDownloadFileNameField({
    super.key,
    this.format,
    this.onChanged,
  });

  final String? format;
  final void Function(String value)? onChanged;

  @override
  State<CreateBooruCustomDownloadFileNameField> createState() =>
      _CreateBooruCustomDownloadFileNameFieldState();
}

class _CreateBooruCustomDownloadFileNameFieldState
    extends State<CreateBooruCustomDownloadFileNameField> {
  late final textController = TextEditingController(text: widget.format);

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Custom download file name format'),
        const SizedBox(height: 4),
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
      ],
    );
  }
}
