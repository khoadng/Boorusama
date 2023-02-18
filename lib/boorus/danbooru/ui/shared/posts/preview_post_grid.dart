// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';

class PreviewPostGrid extends StatelessWidget {
  const PreviewPostGrid({
    super.key,
    required this.posts,
    required this.imageQuality,
    required this.onTap,
    this.physics,
    this.cacheManager,
  });

  final List<PostData> posts;
  final ScrollPhysics? physics;
  final ImageQuality imageQuality;
  final void Function(int index) onTap;
  final CacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          shrinkWrap: true,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: CachedNetworkImage(
                httpHeaders: {
                  'User-Agent': context.read<UserAgentGenerator>().generate(),
                },
                cacheManager: cacheManager,
                fit: BoxFit.cover,
                imageUrl: _getImageUrl(
                  posts[index].post,
                  imageQuality,
                ),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _getImageUrl(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.thumbnailImageUrl;
  if (quality == ImageQuality.high) return post.sampleImageUrl;

  return post.thumbnailImageUrl;
}
