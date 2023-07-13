// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'tag_detail_page.dart';

class TagDetailPageDesktop extends StatelessWidget {
  const TagDetailPageDesktop({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    this.sliverExtraBuilder,
  });

  final String tagName;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final List<Widget>? sliverExtraBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              const SizedBox(height: 10),
                              TagTitleName(tagName: tagName),
                              const SizedBox(height: 8),
                              otherNamesBuilder(context),
                            ],
                          ),
                        ),
                        if (sliverExtraBuilder != null)
                          const SliverSizedBox(height: 12),
                        if (sliverExtraBuilder != null) ...sliverExtraBuilder!,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 32,
                  child: IconButton(
                    onPressed: context.navigator.pop,
                    icon: const Icon(Icons.close),
                  ),
                )
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
