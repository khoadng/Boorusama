// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_parts/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';
import 'search/pages.dart';

class EshuushuuBuilder extends BaseBooruBuilder {
  EshuushuuBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
      }) => CreateBooruConfigScope(
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
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    final posts = payload.posts.map((e) => e as EshuushuuPost).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<EshuushuuPost>(),
    );
  };

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => EshuushuuSearchPage(
        params: params,
      );

  @override
  final postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<EshuushuuPost>(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<EshuushuuPost>(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<EshuushuuPost>(),
      DetailsPart.tags: (context) => const EshuushuuInheritedTagsTile(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<EshuushuuPost>(),
    },
  );
}
