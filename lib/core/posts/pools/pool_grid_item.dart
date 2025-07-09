// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../theme.dart';

class PoolGridItem extends ConsumerWidget {
  const PoolGridItem({
    required this.image,
    required this.onTap,
    required this.total,
    required this.name,
    super.key,
  });

  final Widget image;
  final void Function() onTap;
  final int total;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    Positioned.fill(child: image),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashFactory: FasterInkSplash.splashFactory,
                          splashColor: Colors.black38,
                          onTap: onTap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name.replaceAll('_', ' '),
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              height: 28,
              decoration: BoxDecoration(
                color: context.extendedColorScheme.surfaceContainerOverlayDim,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    total.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context
                          .extendedColorScheme
                          .onSurfaceContainerOverlayDim,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Symbols.photo_library,
                    color: context
                        .extendedColorScheme
                        .onSurfaceContainerOverlayDim,
                    fill: 1,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
