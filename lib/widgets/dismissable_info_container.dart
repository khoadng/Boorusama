// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class DismissableInfoContainer extends StatefulWidget {
  const DismissableInfoContainer({
    super.key,
    required this.content,
    this.forceShow = false,
    this.mainColor,
    this.actions = const [],
  });

  final String content;
  final bool forceShow;
  final Color? mainColor;
  final List<Widget> actions;

  @override
  State<DismissableInfoContainer> createState() =>
      _DismissableInfoContainerState();
}

class _DismissableInfoContainerState extends State<DismissableInfoContainer> {
  var _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final colors = generateChipColors(
      widget.mainColor ?? Colors.grey,
      context.themeMode,
    );

    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            color: colors.backgroundColor,
            border: Border.all(
              color: colors.borderColor,
              width: 1,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Html(
                        style: {
                          'body': Style(
                            color: Colors.white,
                          ),
                        },
                        data: widget.content,
                      ),
                      OverflowBar(
                        children: widget.actions,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.forceShow)
          Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isDismissed = true;
                  });
                },
              )),
      ],
    );
  }
}
