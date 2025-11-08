// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/home/types.dart';
import '../../core/posts/details/widgets.dart';
import 'comments/widgets.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/types.dart';
import 'home/widgets.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class Shimmie2Builder extends BaseBooruBuilder {
  Shimmie2Builder();

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
        child: CreateShimmie2ConfigPage(
          backgroundColor: backgroundColor,
        ),
      );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
        id: id,
        child: CreateShimmie2ConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
        ),
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    final posts = payload.posts.map((e) => e as Shimmie2Post).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<Shimmie2Post>(),
    );
  };

  @override
  final postDetailsUIBuilder = kShimmie2PostDetailsUIBuilder;

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const Shimmie2HomePage();

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const Shimmie2FavoritesPage();

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      kShimmie2AltHomeView;

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const Shimmie2UnknownBooruWidgetsBuilder();

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, post) => Shimmie2CommentPage(
        post: post,
        useAppBar: useAppBar,
      );

  @override
  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder =>
      (context, controller, postController) {
        return Shimmie2MultiSelectionActions(
          postController: postController,
        );
      };
}
