// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/zerochan/types/types.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart' as path;
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/theme/theme.dart';

final zerochanClientProvider =
    Provider.family<ZerochanClient, BooruConfig>((ref, config) {
  final dio = newDio(ref.watch(dioArgsProvider(config)));
  final logger = ref.watch(loggerProvider);

  return ZerochanClient(
    dio: dio,
    logger: (message) => logger.logE('ZerochanClient', message),
  );
});

final zerochanPostRepoProvider = Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(zerochanClientProvider(config));

    return PostRepositoryBuilder(
      getSettings: () async => ref.read(settingsProvider),
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          sort: ZerochanSortOrder.popularity,
          limit: limit,
        );

        return posts
            .map((e) => ZerochanPost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.thumbnail ?? '',
                  sampleImageUrl: e.sampleUrl() ?? '',
                  originalImageUrl: e.fileUrl() ?? '',
                  tags: e.tags?.toSet() ?? {},
                  rating: Rating.general,
                  hasComment: false,
                  isTranslated: false,
                  hasParentOrChildren: false,
                  source: PostSource.from(e.source),
                  score: 0,
                  duration: 0,
                  fileSize: 0,
                  format: path.extension(e.thumbnail ?? ''),
                  hasSound: null,
                  height: e.height?.toDouble() ?? 0,
                  md5: '',
                  videoThumbnailUrl: '',
                  videoUrl: '',
                  width: e.width?.toDouble() ?? 0,
                  uploaderId: null,
                  uploaderName: null,
                  createdAt: null,
                ))
            .toList();
      },
    );
  },
);

final zerochanAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(zerochanClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v3',
    persistentStaleDuration: const Duration(days: 1),
    autocomplete: (query) async {
      final tags = await client.getAutocomplete(query: query);

      return tags
          .where((e) =>
              e.type !=
              'Meta') // Can't search posts by meta tags for some reason
          .map((e) => AutocompleteData(
                label: e.value?.toLowerCase() ?? '',
                value: e.value?.toLowerCase() ?? '',
                postCount: e.total,
                antecedent: e.alias?.toLowerCase().replaceAll(' ', '_'),
                category: e.type?.toLowerCase().replaceAll(' ', '_') ?? '',
              ))
          .toList();
    },
  );
});

final zerochanTagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, int>(
  (ref, id) async {
    final config = ref.watchConfig;
    final client = ref.watch(zerochanClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data
        .where((e) => e.value != null)
        .map((e) => Tag(
              name: e.value!.toLowerCase().replaceAll(' ', '_'),
              category: stringToTagCategory(
                  e.type?.toLowerCase().replaceAll(' ', '_') ?? ''),
              postCount: 0,
            ))
        .toList();
  },
);

class ZerochanBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        NoteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        NoGranularRatingQueryBuilderMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  const ZerochanBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final AutocompleteRepository autocompleteRepo;
  final PostRepository postRepo;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateAnonConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat: null,
            ),
            backgroundColor: backgroundColor,
            isNewConfig: true,
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateAnonConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(tags, page);

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query.toLowerCase());

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder, ref) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
              tagListBuilder: (context, post) => ZerochanTagsTile(post: post),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
            ),
          );

  @override
  TagColorBuilder get tagColorBuilder => (themeMode, tagType) {
        final colors =
            themeMode == ThemeMode.light ? TagColors.dark() : TagColors.light();

        return switch (tagType) {
          'mangaka' ||
          'studio' ||
          // This is from a fallback in case the tag is already searched in other boorus
          'artist' =>
            colors.artist,
          'source' ||
          'game' ||
          'visual_novel' ||
          'series' ||
          // This is from a fallback in case the tag is already searched in other boorus
          'copyright' =>
            colors.copyright,
          'character' => colors.character,
          'meta' => colors.meta,
          _ => colors.general,
        };
      };

  @override
  DownloadFilenameGenerator<Post> get downloadFilenameBuilder =>
      LegacyFilenameBuilder(
        generateFileName: (post, downloadUrl) => basename(downloadUrl),
      );
}

class ZerochanPost extends SimplePost {
  ZerochanPost({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
    required super.tags,
    required super.rating,
    required super.hasComment,
    required super.isTranslated,
    required super.hasParentOrChildren,
    required super.source,
    required super.score,
    required super.duration,
    required super.fileSize,
    required super.format,
    required super.hasSound,
    required super.height,
    required super.md5,
    required super.videoThumbnailUrl,
    required super.videoUrl,
    required super.width,
    required super.uploaderId,
    required super.createdAt,
    required super.uploaderName,
  });

  @override
  String getLink(String baseUrl) {
    return baseUrl.endsWith('/') ? '$baseUrl$id' : '$baseUrl/$id';
  }
}

class ZerochanTagsTile extends ConsumerStatefulWidget {
  const ZerochanTagsTile({
    super.key,
    required this.post,
    this.onTagsLoaded,
  });

  final Post post;
  final void Function(List<TagGroupItem> tags)? onTagsLoaded;

  @override
  ConsumerState<ZerochanTagsTile> createState() => _ZerochanTagsTileState();
}

class _ZerochanTagsTileState extends ConsumerState<ZerochanTagsTile> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      ref.listen(zerochanTagsFromIdProvider(widget.post.id), (previous, next) {
        next.when(
          data: (data) {
            if (!mounted) return;

            if (data.isNotEmpty) {
              if (widget.onTagsLoaded != null) {
                widget.onTagsLoaded!(createTagGroupItems(data));
              }
            }

            if (data.isEmpty && widget.post.tags.isNotEmpty) {
              // Just a dummy data so the check below will branch into the else block
              setState(() => error = 'No tags found');
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            if (!mounted) return;
            setState(() => this.error = error);
          },
        );
      });
    }

    return error == null
        ? TagsTile(
            tags: expanded
                ? ref
                    .watch(zerochanTagsFromIdProvider(widget.post.id))
                    .maybeWhen(
                      data: (data) => createTagGroupItems(data),
                      orElse: () => null,
                    )
                : null,
            post: widget.post,
            onExpand: () => setState(() => expanded = true),
            onCollapse: () {
              // Don't set expanded to false to prevent rebuilding the tags list
              setState(() => error = null);
            },
            onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
          )
        : BasicTagList(
            tags: widget.post.tags.toList(),
            onTap: (tag) => goToSearchPage(context, tag: tag),
          );
  }
}
