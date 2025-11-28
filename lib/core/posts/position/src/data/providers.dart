// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../errors/types.dart';
import '../../../post/providers.dart';
import '../../../post/types.dart';
import '../types/repo.dart';
import '../types/target.dart';

PageFinderHandler defaultPostPageFinderHandler(
  PostRepository<Post> postRepo, {
  required int detectionStatusCode,
}) => (query) async {
  final result = await postRepo
      .getPosts(
        query.tags,
        query.page,
        limit: query.limit,
        options: PostFetchOptions.raw,
      )
      .run();

  return result.fold(
    (error) {
      return switch (error) {
        ServerError(:final httpStatusCode)
            when httpStatusCode == detectionStatusCode =>
          // Try to extract max page from error message if available
          // Otherwise default to the requested page as indicator
          PageFinderPaginationLimitReached(
            maxPage: query.page - 1,
            requestedPage: query.page,
          ),
        ServerError(:final message) => PageFinderServerError(
          message: message,
        ),
        _ => PageFinderServerError(message: error.toString()),
      };
    },
    (postResult) {
      // Also check if result is empty - might indicate beyond pagination
      if (postResult.posts.isEmpty && query.page > 1) {
        // Empty results on page > 1 might mean we're beyond the limit
        // But we can't be sure, so return empty page
        return PageFinderEmptyPage();
      }

      return PageFinderSuccess(
        items: postResult.posts
            .map(
              (post) => PageFinderTarget(
                id: post.id,
              ),
            )
            .toList(),
      );
    },
  );
};

final defaultPostPageFinderRepoProvider =
    Provider.family<PageFinderRepository, BooruConfigSearch>(
      (ref, config) {
        return PageFinderBuilder(
          fetch: defaultPostPageFinderHandler(
            ref.watch(postRepoProvider(config)),
            detectionStatusCode: 410,
          ),
        );
      },
    );
