// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/posts/posts.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';

class RecommendPostSection extends StatelessWidget {
  const RecommendPostSection({
    super.key,
    required this.posts,
    required this.header,
    required this.onTap,
  });

  final List<PostData> posts;
  final Widget header;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            header,
            Padding(
              padding: const EdgeInsets.all(4),
              child: PreviewPostGrid(
                cacheManager: context.read<PreviewImageCacheManager>(),
                posts: posts,
                imageQuality: state.settings.imageQuality,
                onTap: onTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
