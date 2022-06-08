// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/providers/slide_show_providers.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/modal.dart';

class SlideShowConfigBottomModal extends HookWidget {
  const SlideShowConfigBottomModal({
    Key? key,
    required this.config,
  }) : super(key: key);
  final ValueNotifier<SlideShowConfiguration> config;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final numberEditingController = useTextEditingController();

    return Modal(
      title: "Slide Show",
      child: Padding(
        padding: EdgeInsets.only(
          left: 26,
          right: 26,
          top: 14,
          bottom: 14 + viewInsets + safeAreaBottom,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Flexible(flex: 3, child: Text("Interval (seconds)")),
                Flexible(
                  flex: 1,
                  child: NumberInputWithIncrementDecrement(
                    initialValue: config.value.interval,
                    onDecrement: (value) =>
                        config.value = config.value.copyWith(
                      interval: value,
                    ),
                    onIncrement: (value) =>
                        config.value = config.value.copyWith(
                      interval: value,
                    ),
                    min: 0,
                    controller: numberEditingController,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Flexible(flex: 3, child: Text("Skip animation")),
                Flexible(
                  flex: 1,
                  child: Switch(
                    value: config.value.skipAnimation,
                    onChanged: (value) => config.value =
                        config.value.copyWith(skipAnimation: value),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("OK"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
