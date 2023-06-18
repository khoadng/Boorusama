// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/core/widgets/posts/information_section.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';

class E621InformationSection extends StatelessWidget {
  const E621InformationSection({
    super.key,
    required this.post,
    this.padding,
    this.showSource = false,
  });

  final E621Post post;
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
      //FIXME: Uncomment this when artist page is implemented
      // onArtistTagTap: (context, artist) => goToArtistPage(context, artist),
    );
  }
}
