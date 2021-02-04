// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/providers/slide_show_providers.dart';
import 'modal.dart';

class SlideShowConfigBottomModal extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final numberEditingController = useTextEditingController();
    final config = useProvider(slideShowConfigurationStateProvider);

    return Modal(
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
                Flexible(flex: 3, child: Text("Interval (seconds)")),
                Flexible(
                  flex: 1,
                  child: NumberInputWithIncrementDecrement(
                    initialValue: config.state.interval,
                    onDecrement: (value) =>
                        config.state = config.state.copyWith(
                      interval: value,
                    ),
                    onIncrement: (value) =>
                        config.state = config.state.copyWith(
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
                Flexible(flex: 3, child: Text("Skip animation")),
                Flexible(
                  flex: 1,
                  child: Switch(
                    value: config.state.skipAnimation,
                    onChanged: (value) => config.state =
                        config.state.copyWith(skipAnimation: value),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                RaisedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("OK"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
