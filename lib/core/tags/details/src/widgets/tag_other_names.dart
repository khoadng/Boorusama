// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/display.dart';
import '../../../../theme.dart';
import '../../../tag/widgets.dart';

class TagOtherNames extends StatelessWidget {
  const TagOtherNames({
    required this.otherNames,
    super.key,
  });

  final List<String>? otherNames;

  @override
  Widget build(BuildContext context) {
    return !context.isLargeScreen
        ? otherNames != null
            ? otherNames!.length > 3
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
    required this.otherName,
    super.key,
  });

  final String otherName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onLongPress: () {
          AppClipboard.copyWithDefaultToast(
            context,
            otherName,
          );
        },
        child: RawChip(
          onPressed: () {},
          side: BorderSide(
            color: Theme.of(context).colorScheme.hintColor,
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
              otherName.replaceAll('_', ' '),
              overflow: TextOverflow.fade,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
