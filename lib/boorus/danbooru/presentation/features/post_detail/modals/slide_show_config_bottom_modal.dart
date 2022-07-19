// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:number_inc_dec/number_inc_dec.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/providers/slide_show_providers.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';

class SlideShowConfigBottomModal extends StatefulWidget {
  const SlideShowConfigBottomModal({
    Key? key,
    required this.initialConfig,
    required this.onConfigChanged,
  }) : super(key: key);

  final void Function(SlideShowConfiguration config) onConfigChanged;
  final SlideShowConfiguration initialConfig;

  @override
  State<SlideShowConfigBottomModal> createState() =>
      _SlideShowConfigBottomModalState();
}

class _SlideShowConfigBottomModalState
    extends State<SlideShowConfigBottomModal> {
  final numberEditingController = TextEditingController();
  late var config = ValueNotifier(widget.initialConfig);

  @override
  void initState() {
    super.initState();
    config.addListener(() {
      widget.onConfigChanged(config.value);
    });
  }

  @override
  void dispose() {
    numberEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Modal(
      title: 'Slide Show',
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
                const Flexible(flex: 3, child: Text('Interval (seconds)')),
                Flexible(
                  //TODO: keyboard input won't work.
                  child: NumberInputWithIncrementDecrement(
                    initialValue: config.value.interval,
                    min: 1,
                    onDecrement: (value) =>
                        config.value = config.value.copyWith(interval: value),
                    onIncrement: (value) =>
                        config.value = config.value.copyWith(interval: value),
                    controller: numberEditingController,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Flexible(flex: 3, child: Text('Skip animation')),
                Flexible(
                  child: ValueListenableBuilder<SlideShowConfiguration>(
                    valueListenable: config,
                    builder: (context, conf, _) => Switch(
                      value: conf.skipAnimation,
                      onChanged: (value) =>
                          config.value = conf.copyWith(skipAnimation: value),
                    ),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
