import 'dart:ui' as ui show PlaceholderAlignment;
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';

class TagText extends SpecialText {
  TagText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback? onTap, {
    required this.start,
    required this.controller,
    required this.context,
    required String startFlag,
  }) : super(startFlag, ' ', textStyle, onTap: onTap);

  final TextEditingController controller;
  final int start;
  final BuildContext context;

  @override
  bool isEnd(String value) {
    // final index = value.indexOf('@');
    // final index1 = value.indexOf('.');

    // print('index: $index index1: $index1 value: $value');

    // return index >= 0 &&
    //     index1 >= 0 &&
    //     index1 > index + 1 &&
    //     super.isEnd(value);

    return value.endsWith(' ');
  }

  @override
  InlineSpan finishText() {
    final String text = toString();

    return ExtendedWidgetSpan(
      actualText: text,
      start: start,
      alignment: ui.PlaceholderAlignment.middle,
      child: TagTextChip(
        text: text,
        controller: controller,
        start: start,
      ),
      deleteAll: true,
    );
  }
}

class TagTextChip extends StatelessWidget {
  const TagTextChip({
    super.key,
    required this.text,
    required this.controller,
    required this.start,
  });

  final String text;
  final TextEditingController controller;
  final int start;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(
          right: 5,
          top: 2,
          bottom: 2,
        ),
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              color: context.colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text.trim().replaceAll('_', ' '),
                    //style: textStyle?.copyWith(color: Colors.orange),
                    style: TextStyle(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  InkWell(
                    child: Icon(
                      Icons.close,
                      size: 15.0,
                      color: context.colorScheme.onSurface,
                    ),
                    onTap: () {
                      controller.value = controller.value.copyWith(
                        text: controller.text
                            .replaceRange(start, start + text.length, ''),
                        selection: TextSelection.fromPosition(
                          TextPosition(offset: start),
                        ),
                      );
                    },
                  )
                ],
              ),
            )),
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (c) {
            final textEditingController = TextEditingController()
              ..text = text.trim();
            return Column(
              children: [
                const Expanded(
                  child: SizedBox.shrink(),
                ),
                Material(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        suffixIcon: TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            controller.value = controller.value.copyWith(
                              text: controller.text.replaceRange(
                                  start,
                                  start + text.length,
                                  '${textEditingController.text} '),
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                    offset: start +
                                        ('${textEditingController.text} ')
                                            .length),
                              ),
                            );

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                )
              ],
            );
          },
        );
      },
    );
  }
}
