// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:number_inc_dec/number_inc_dec.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class SlideShowConfigContainer extends StatefulWidget {
  const SlideShowConfigContainer({
    super.key,
    required this.initialConfig,
    this.isModal = true,
  });

  final SlideShowConfiguration initialConfig;
  final bool isModal;

  @override
  State<SlideShowConfigContainer> createState() =>
      _SlideShowConfigContainerState();
}

class _SlideShowConfigContainerState extends State<SlideShowConfigContainer> {
  final numberEditingController = TextEditingController();
  late var config = ValueNotifier(widget.initialConfig);

  @override
  void dispose() {
    numberEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;

    return ConditionalParentWidget(
      condition: widget.isModal,
      conditionalBuilder: (child) => Modal(
        title: 'Slide Show',
        child: child,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 26,
          right: 26,
          top: 14,
          bottom: viewInsets + safeAreaBottom + 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: const Text('post.detail.slide_show.interval').tr(),
                ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: const Text('post.detail.slide_show.skip_anim').tr(),
                ),
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
                  onPressed: () => context.navigator.pop(null),
                  child: const Text('post.detail.slide_show.cancel').tr(),
                ),
                ElevatedButton(
                  onPressed: () => context.navigator.pop(config.value),
                  child: const Text('post.detail.slide_show.ok').tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
