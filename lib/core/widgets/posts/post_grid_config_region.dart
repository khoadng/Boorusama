// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/widgets/posts/post_grid_config_icon_button.dart';
import 'package:boorusama/foundation/platform.dart';

class PostGridConfigRegion extends ConsumerWidget {
  const PostGridConfigRegion({
    super.key,
    required this.blacklistHeader,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    Widget blacklistHeader,
  ) builder;
  final Widget blacklistHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return !isMobilePlatform()
        ? Builder(
            builder: (context) {
              final gridSize = ref.watch(gridSizeSettingsProvider);
              final imageListType = ref.watch(imageListTypeSettingsProvider);
              final pageMode = ref.watch(pageModeSettingsProvider);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          width: 230,
                          child: PostGridActionSheet(
                            popOnSelect: false,
                            gridSize: gridSize,
                            pageMode: pageMode,
                            imageListType: imageListType,
                            onModeChanged: (mode) => ref.setPageMode(mode),
                            onGridChanged: (grid) => ref.setGridSize(grid),
                            onImageListChanged: (imageListType) =>
                                ref.setImageListType(imageListType),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: blacklistHeader,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: builder(
                      context,
                      blacklistHeader,
                    ),
                  ),
                ],
              );
            },
          )
        : builder(
            context,
            blacklistHeader,
          );
  }
}
