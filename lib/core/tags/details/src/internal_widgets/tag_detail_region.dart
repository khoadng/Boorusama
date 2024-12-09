// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/display.dart';

class TagDetailsRegion extends ConsumerWidget {
  const TagDetailsRegion({
    super.key,
    required this.builder,
    required this.detailsBuilder,
  });

  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context) detailsBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return !context.isLargeScreen
        ? builder(context)
        : Material(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 4),
                SizedBox(
                  width: max(MediaQuery.sizeOf(context).width * 0.25, 350),
                  child: SingleChildScrollView(
                    child: SafeArea(
                      left: false,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                iconSize: 28,
                                splashRadius: 24,
                                icon: const Icon(
                                  Symbols.close,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Spacer(),
                            ],
                          ),
                          detailsBuilder(context),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 12,
                  thickness: 1,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MediaQuery.removeViewPadding(
                    context: context,
                    removeLeft: true,
                    child: builder(context),
                  ),
                ),
              ],
            ),
          );
  }
}
