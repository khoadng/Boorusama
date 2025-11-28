// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/comments/widgets.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/home/types.dart';
import 'artists/widgets.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/types.dart';
import 'home/widgets.dart';
import 'posts/widgets.dart';
import 'search/widgets.dart';
import 'restoration/widgets.dart';

class GelbooruV2Builder extends BaseBooruBuilder {
  GelbooruV2Builder();

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
          customDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
        ),
        child: CreateGelbooruV2ConfigPage(
          backgroundColor: backgroundColor,
          url: id.url,
        ),
      );

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const GelbooruV2HomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
        id: id,
        child: CreateGelbooruV2ConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
          url: id.url,
        ),
      );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => GelbooruV2SearchPage(
        params: params,
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    return GelbooruV2PostDetailsPage(
      payload: payload,
    );
  };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const GelbooruV2FavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruV2ArtistPage(
        artistName: artistName,
      );

  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => GelbooruV2ArtistPage(
        artistName: characterName,
      );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, post) => CommentPageScaffold(
        postId: post.id,
        useAppBar: useAppBar,
      );

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      kGelbooruV2AltHomeView;

  @override
  final postDetailsUIBuilder = kGelbooruV2PostDetailsUIBuilder;

  @override
  SessionRestoreBuilder? get sessionRestoreBuilder => (context, snapshot) {
    return GelbooruV2SessionRestorePage(
      snapshot: snapshot,
    );
  };
}
