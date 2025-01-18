// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../settings/providers.dart';
import '../../../rating/rating.dart';

class ExplicitContentBlockOverlay extends StatefulWidget {
  const ExplicitContentBlockOverlay({
    required this.rating,
    required this.child,
    super.key,
  });

  final Rating rating;
  final Widget child;

  @override
  State<ExplicitContentBlockOverlay> createState() =>
      _ExplicitContentBlockOverlayState();
}

class _ExplicitContentBlockOverlayState
    extends State<ExplicitContentBlockOverlay> {
  late final _block = ValueNotifier(widget.rating.isExplicit);

  @override
  void didUpdateWidget(covariant ExplicitContentBlockOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rating != widget.rating) {
      _block.value = widget.rating.isExplicit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        _buildCover(),
        _buildButton(),
      ],
    );
  }

  Widget _buildButton() {
    return Consumer(
      builder: (_, ref, __) {
        final enable = ref.watch(
          imageListingSettingsProvider
              .select((value) => value.blurExplicitMedia),
        );

        return enable
            ? ValueListenableBuilder(
                valueListenable: _block,
                builder: (_, block, __) => block
                    ? Positioned.fill(
                        child: ActionChip(
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(25),
                          ),
                          label: Text(
                            'Explicit'.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          onPressed: () {
                            _block.value = false;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildCover() {
    return Consumer(
      builder: (_, ref, __) {
        final enable = ref.watch(
          imageListingSettingsProvider
              .select((value) => value.blurExplicitMedia),
        );

        return enable
            ? ValueListenableBuilder(
                valueListenable: _block,
                builder: (_, block, __) => block
                    ? Positioned.fill(
                        child: Container(
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                        ),
                      )
                    : const SizedBox.shrink(),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
