// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/posts/posts.dart';

class RecommendPostSection extends StatelessWidget {
  const RecommendPostSection({
    Key? key,
    required this.posts,
    required this.header,
  }) : super(key: key);

  final List<PostData> posts;
  final Widget header;

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
                posts: posts,
                imageQuality: state.settings.imageQuality,
              ),
            ),
          ],
        );
      },
    );
  }
}
