// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';

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
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                height: 32,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: otherNames!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Chip(
                        shape: const StadiumBorder(
                            side: BorderSide(color: Colors.grey)),
                        padding: const EdgeInsets.all(4),
                        labelPadding: const EdgeInsets.all(1),
                        visualDensity: VisualDensity.compact,
                        label: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                          ),
                          child: Text(
                            otherNames![index].removeUnderscoreWithSpace(),
                            overflow: TextOverflow.fade,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const TagChipsPlaceholder(height: 42, itemCount: 4)
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
                          .map((e) => Chip(
                                shape: const StadiumBorder(
                                  side: BorderSide(color: Colors.grey),
                                ),
                                padding: const EdgeInsets.all(4),
                                labelPadding: const EdgeInsets.all(1),
                                visualDensity: VisualDensity.compact,
                                label: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.85,
                                  ),
                                  child: Text(
                                    e.removeUnderscoreWithSpace(),
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  : const TagChipsPlaceholder(),
            ),
          );
  }
}
