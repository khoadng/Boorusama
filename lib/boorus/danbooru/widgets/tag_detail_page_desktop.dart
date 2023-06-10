// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'tag_detail_page.dart';

class TagDetailPageDesktop extends StatelessWidget {
  const TagDetailPageDesktop({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
  });

  final String tagName;
  final Widget Function(BuildContext context) otherNamesBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Stack(
              children: [
                Align(
                  alignment: const Alignment(-0.9, -0.9),
                  child: IconButton(
                    onPressed: context.navigator.pop,
                    icon: const Icon(Icons.close),
                  ),
                ),
                Align(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 70),
                      TagTitleName(tagName: tagName),
                      const SizedBox(height: 8),
                      Expanded(child: otherNamesBuilder(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 3, thickness: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TagDetailPage(
                includeHeaders: false,
                tagName: tagName,
                otherNamesBuilder: otherNamesBuilder,
                backgroundImageUrl: '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
