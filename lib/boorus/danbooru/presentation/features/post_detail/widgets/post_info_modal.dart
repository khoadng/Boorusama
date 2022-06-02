// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/artist_commentary_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/webview.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';
import 'post_tag_list.dart';

part 'post_info_modal.freezed.dart';

final _artistCommentaryProvider = FutureProvider.autoDispose
    .family<ArtistCommentary, int>((ref, postId) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(artistCommentaryProvider);
  final dto = await repo.getCommentary(
    postId,
    cancelToken: cancelToken,
  );
  final artistCommentary = dto.toEntity();

  ref.maintainState = true;

  return artistCommentary;
});

class PostInfoModal extends HookWidget {
  const PostInfoModal({
    Key key,
    @required this.post,
    @required this.scrollController,
  }) : super(key: key);

  final Post post;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    var apiEndpoint = useProvider(apiEndpointProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Modal(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(
                  child: ArtistSection(
                    post: post,
                  ),
                ),
                SliverToBoxAdapter(
                    child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Theme.of(context).cardColor),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text("Size"),
                        trailing: Text("${filesize(post.fileSize, 1)}"),
                      ),
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text("Resolution"),
                        trailing: Text(
                            "${post.width.toInt()}x${post.height.toInt()}"),
                      ),
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text("Rating"),
                        trailing: Text(post.rating.value
                            .toString()
                            .split('.')
                            .last
                            .pascalCase),
                      ),
                    ],
                  ),
                )),
                SliverToBoxAdapter(
                    child: PostTagList(
                  apiEndpoint: apiEndpoint,
                  tagStringComma: post.tagString.toCommaFormat(),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@freezed
abstract class ArtistCommentaryTranlationState
    with _$ArtistCommentaryTranlationState {
  const factory ArtistCommentaryTranlationState.original() = _Original;

  const factory ArtistCommentaryTranlationState.translated() = _Translated;
}

class ArtistSection extends HookWidget {
  const ArtistSection({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  Widget _buildLoading(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(),
          title: Container(
            margin:
                EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.4),
            height: 20,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        ...List.generate(
          4,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 10.0),
            width: MediaQuery.of(context).size.width * 0.1 +
                Random().nextDouble() * MediaQuery.of(context).size.width * 0.9,
            height: 20,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final artistCommentaryDisplay =
        useState(ArtistCommentaryTranlationState.original());
    final artistCommentary = useProvider(_artistCommentaryProvider(post.id));
    return artistCommentary.when(
      loading: () => _buildLoading(context),
      data: (artistCommentary) {
        return Wrap(
          children: <Widget>[
            ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(post.tagStringArtist.pretty),
              subtitle: InkWell(
                onLongPress: () => Clipboard.setData(
                        ClipboardData(text: post.source.uri.toString()))
                    .then((results) {
                  final snackbar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    elevation: 6.0,
                    content: Text(
                      'Copied',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                }),
                onTap: () => post.source != null
                    ? Navigator.of(context).push(
                        SlideInRoute(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  WebView(url: post.source.uri.toString()),
                        ),
                      )
                    : null,
                child: Text(
                  post.source.uri.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              leading: CircleAvatar(),
              trailing: artistCommentary.isTranslated
                  ? PopupMenuButton<ArtistCommentaryTranlationState>(
                      icon: Icon(Icons.keyboard_arrow_down),
                      onSelected: (value) {
                        artistCommentaryDisplay.value = value;
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<ArtistCommentaryTranlationState>>[
                        PopupMenuItem<ArtistCommentaryTranlationState>(
                          value: artistCommentaryDisplay.value.when(
                            translated: () =>
                                ArtistCommentaryTranlationState.original(),
                            original: () =>
                                ArtistCommentaryTranlationState.translated(),
                          ),
                          child: ListTile(
                            title: artistCommentaryDisplay.value.when(
                              translated: () => Text("Show Original"),
                              original: () => Text("Show Translated"),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            ),
            artistCommentaryDisplay.value.when(
              translated: () => SelectableText(
                  "${artistCommentary.translatedTitle}\n${artistCommentary.translatedDescription}"),
              original: () => SelectableText(
                  "${artistCommentary.originalTitle}\n${artistCommentary.originalDescription}"),
            ),
          ],
        );
      },
      error: (name, message) => Text("Failed to load commentary"),
    );
  }
}
