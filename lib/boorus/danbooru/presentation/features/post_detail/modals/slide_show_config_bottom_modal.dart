// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/models/slide_show_configuration.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/presentation/widgets/conditional_parent_widget.dart';

class SlideShowConfigContainer extends StatefulWidget {
  const SlideShowConfigContainer({
    Key? key,
    required this.initialConfig,
    required this.onConfigChanged,
    this.isModal = true,
  }) : super(key: key);

  final void Function(SlideShowConfiguration config) onConfigChanged;
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
          bottom: 14 + viewInsets + safeAreaBottom,
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
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('post.detail.slide_show.cancel').tr(),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
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
