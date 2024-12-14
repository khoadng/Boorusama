// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/zerochan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/blacklists/blacklist.dart';
import '../../core/blacklists/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/details/details.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/sources/source.dart';
import '../../core/router.dart';
import '../../core/tags/tag/colors.dart';
import '../../core/tags/tag/providers.dart';
import '../../core/tags/tag/tag.dart';
import '../../core/theme.dart';
import '../danbooru/danbooru.dart';
import 'providers.dart';
import 'zerochan_post.dart';

const kZerochanCustomDownloadFileNameFormat =
    '{id}_{width}x{height}.{extension}';

class ZerochanBuilder
    with
        FavoriteNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        UnknownMetatagsMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  ZerochanBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat: null,
            ),
            child: CreateAnonConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateAnonConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as ZerochanPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<ZerochanPost>(),
        );
      };

  @override
  TagColorBuilder get tagColorBuilder => (brightness, tagType) {
        final colors =
            brightness.isLight ? TagColors.dark() : TagColors.light();

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
  final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    defaultFileNameFormat: kZerochanCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kZerochanCustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    hasMd5: false,
    hasRating: false,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'source': (post, config) => post.source.url,
    },
  );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<ZerochanPost>(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<ZerochanPost>(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<ZerochanPost>(),
      DetailsPart.tags: (context) => const ZerochanTagsTile(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<ZerochanPost>(),
    },
  );
}

class ZerochanRepository implements BooruRepository {
  const ZerochanRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return null;
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(zerochanPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(emptyAutocompleteRepoProvider);
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(emptyNoteRepoProvider);
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(emptyTagRepoProvider);
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return const UrlInsidePostExtractor();
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return EmptyFavoriteRepository();
  }

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return GlobalBlacklistTagRefRepository(ref);
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => ZerochanClient(dio: dio, baseUrl: config.url)
        .getPosts(strict: true)
        .then((value) => true);
  }
}

class ZerochanTagsTile extends ConsumerStatefulWidget {
  const ZerochanTagsTile({
    super.key,
  });

  @override
  ConsumerState<ZerochanTagsTile> createState() => _ZerochanTagsTileState();
}

class _ZerochanTagsTileState extends ConsumerState<ZerochanTagsTile> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<ZerochanPost>(context);

    if (expanded) {
      ref.listen(zerochanTagsFromIdProvider(post.id), (previous, next) {
        next.when(
          data: (data) {
            if (!mounted) return;

            // if (data.isNotEmpty) {
            //   if (widget.onTagsLoaded != null) {
            //     widget.onTagsLoaded!(createTagGroupItems(data));
            //   }
            // }

            if (data.isEmpty && post.tags.isNotEmpty) {
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

    return SliverToBoxAdapter(
      child: error == null
          ? TagsTile(
              tags: expanded
                  ? ref.watch(zerochanTagsFromIdProvider(post.id)).maybeWhen(
                        data: (data) => createTagGroupItems(data),
                        orElse: () => null,
                      )
                  : null,
              post: post,
              onExpand: () => setState(() => expanded = true),
              onCollapse: () {
                // Don't set expanded to false to prevent rebuilding the tags list
                setState(() => error = null);
              },
              onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
            )
          : BasicTagList(
              tags: post.tags.toList(),
              onTap: (tag) => goToSearchPage(context, tag: tag),
            ),
    );
  }
}
