// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/posts.dart';

class RecommendSectionPlaceHolder extends StatelessWidget {
  const RecommendSectionPlaceHolder({
    Key? key,
    required this.header,
  }) : super(key: key);

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: const PreviewPostGridPlaceHolder(
              itemCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}
