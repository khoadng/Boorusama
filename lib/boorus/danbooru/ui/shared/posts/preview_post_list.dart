// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';

class PreviewPostList extends StatelessWidget {
  const PreviewPostList({
    super.key,
    required this.posts,
    this.physics,
    this.cacheManager,
  });

  final List<Post> posts;
  final ScrollPhysics? physics;
  final CacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: CachedNetworkImage(
            httpHeaders: {
              'User-Agent': context.read<UserAgentGenerator>().generate(),
            },
            cacheManager: cacheManager,
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.3,
            fit: BoxFit.cover,
            imageUrl: posts[index].thumbnailImageUrl,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
