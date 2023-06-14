// Flutter imports:
import 'package:flutter/material.dart';

class RecommendSectionPlaceHolder extends StatelessWidget {
  const RecommendSectionPlaceHolder({
    super.key,
    required this.header,
  });

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
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        ),
      ],
    );
  }
}
