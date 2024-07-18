// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/string.dart';

class TagOtherNames extends StatelessWidget {
  const TagOtherNames({
    super.key,
    required this.otherNames,
  });

  final List<String>? otherNames;

  @override
  Widget build(BuildContext context) {
    return Screen.of(context).size == ScreenSize.small
        ? otherNames != null
            ? otherNames!.length > 4
                ? Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: otherNames!.length,
                      itemBuilder: (context, index) =>
                          OtherNameChip(otherName: otherNames![index]),
                    ),
                  )
                : Wrap(
                    spacing: 4,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: otherNames!
                        .map((e) => OtherNameChip(otherName: e))
                        .toList(),
                  )
            : const TagChipsPlaceholder(height: 42, itemCount: 10)
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: otherNames != null
                  ? Wrap(
                      spacing: 4,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: otherNames!
                          .map((e) => OtherNameChip(otherName: e))
                          .toList(),
                    )
                  : const TagChipsPlaceholder(),
            ),
          );
  }
}

class OtherNameChip extends StatelessWidget {
  const OtherNameChip({
    super.key,
    required this.otherName,
  });

  final String otherName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onLongPress: () =>
            Clipboard.setData(ClipboardData(text: otherName)).then(
          (_) => showSimpleSnackBar(
            context: context,
            duration: AppDurations.shortToast,
            content: const Text('Copied'),
          ),
        ),
        child: RawChip(
          onPressed: () {},
          side: BorderSide(
            color: context.theme.hintColor,
            width: 0.5,
          ),
          padding: const EdgeInsets.all(4),
          labelPadding: const EdgeInsets.all(1),
          visualDensity: VisualDensity.compact,
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.85,
            ),
            child: Text(
              otherName.replaceUnderscoreWithSpace(),
              overflow: TextOverflow.fade,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
