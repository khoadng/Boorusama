// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

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
    return !isMobilePlatform()
        ? Material(
            color: context.colorScheme.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: max(context.screenWidth * 0.25, 350),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              iconSize: 40,
                              splashRadius: 24,
                              icon: const Icon(
                                Icons.close,
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
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                ),
                Expanded(
                  child: builder(context),
                ),
              ],
            ),
          )
        : builder(context);
  }
}
