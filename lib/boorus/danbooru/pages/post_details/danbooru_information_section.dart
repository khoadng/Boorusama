// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/posts/information_section.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';

class DanbooruInformationSection extends StatelessWidget {
  const DanbooruInformationSection({
    super.key,
    required this.post,
    this.padding,
    this.showSource = false,
  });

  final DanbooruPost post;
  final EdgeInsetsGeometry? padding;
  final bool showSource;

  @override
  Widget build(BuildContext context) {
    return InformationSection(
      showSource: showSource,
      padding: padding,
      characterTags: post.characterTags,
      artistTags: post.artistTags,
      copyrightTags: post.copyrightTags,
      createdAt: post.createdAt,
      source: post.source,
      onArtistTagTap: (context, artist) => goToArtistPage(context, artist),
    );
  }
}
