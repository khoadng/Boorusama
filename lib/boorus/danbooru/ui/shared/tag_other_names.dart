// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_tags_x/flutter_tags_x.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

class TagOtherNames extends StatelessWidget {
  const TagOtherNames({
    super.key,
    required this.otherNames,
  });

  final List<String> otherNames;

  @override
  Widget build(BuildContext context) {
    return Screen.of(context).size == ScreenSize.small
        ? Tags(
            heightHorizontalScroll: 40,
            spacing: 2,
            horizontalScroll: true,
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            itemCount: otherNames.length,
            itemBuilder: (index) {
              return Chip(
                shape:
                    const StadiumBorder(side: BorderSide(color: Colors.grey)),
                padding: const EdgeInsets.all(4),
                labelPadding: const EdgeInsets.all(1),
                visualDensity: VisualDensity.compact,
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Text(
                    otherNames[index].removeUnderscoreWithSpace(),
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Wrap(
                spacing: 5,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: otherNames
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
                                  MediaQuery.of(context).size.width * 0.85,
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
              ),
            ),
          );
  }
}
