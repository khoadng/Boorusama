// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/artist_commentary_repository.dart';
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

  /// Cache the artist Commentary once it was successfully obtained.
  ref.maintainState = true;

  return artistCommentary;
});

class PostInfoModal extends HookWidget {
  const PostInfoModal({
    Key key,
    @required this.panelMinHeight,
    @required this.post,
    @required this.scrollController,
  }) : super(key: key);

  final double panelMinHeight;
  final Post post;
  final ScrollController scrollController;

  Widget _buildLoading(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: Colors.grey[500],
      baseColor: Colors.grey[700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(),
            title: Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.4),
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          ...List.generate(
            4,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 10.0),
              width: Random().nextDouble() *
                  MediaQuery.of(context).size.width *
                  0.9,
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artistCommentaryDisplay =
        useState(ArtistCommentaryTranlationState.original());
    final artistCommentary = useProvider(_artistCommentaryProvider(post.id));
    final showArtistCommentary = useState(false);
    final showCommentaryTranslateOption = useState(false);

    useValueChanged(artistCommentary, (_, __) {
      artistCommentary.whenData((commentary) {
        if (commentary.hasCommentary) {
          showArtistCommentary.value = true;
        } else if (commentary.isTranslated) {
          showCommentaryTranslateOption.value = true;
        }
      });
    });
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      height: panelMinHeight,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          automaticallyImplyLeading: false,
          title: Text("Information"),
        ),
        body: CustomScrollView(
          controller: scrollController,
          shrinkWrap: true,
          slivers: [
            if (showArtistCommentary.value) ...[
              SliverToBoxAdapter(
                child: artistCommentary.when(
                  loading: () => _buildLoading(context),
                  data: (artistCommentary) => Wrap(
                    children: <Widget>[
                      ListTile(
                        title: Text(post.tagStringArtist.pretty),
                        leading: CircleAvatar(),
                        trailing: showCommentaryTranslateOption.value
                            ? PopupMenuButton<ArtistCommentaryTranlationState>(
                                icon: Icon(Icons.keyboard_arrow_down),
                                onSelected: (value) {
                                  artistCommentaryDisplay.value = value;
                                },
                                itemBuilder: (BuildContext context) => <
                                    PopupMenuEntry<
                                        ArtistCommentaryTranlationState>>[
                                  PopupMenuItem<
                                      ArtistCommentaryTranlationState>(
                                    value: artistCommentaryDisplay.value.when(
                                      translated: () =>
                                          ArtistCommentaryTranlationState
                                              .original(),
                                      original: () =>
                                          ArtistCommentaryTranlationState
                                              .translated(),
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
                        translated: () => Html(
                            data:
                                "${artistCommentary.translatedTitle}\n${artistCommentary.translatedDescription}"),
                        original: () => Html(
                            data:
                                "${artistCommentary.originalTitle}\n${artistCommentary.originalDescription}"),
                      ),
                    ],
                  ),
                  error: (name, message) => Text("Failed to load commentary"),
                ),
              )
            ],
            SliverToBoxAdapter(
              child: Divider(
                height: 8,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
            ),
            SliverToBoxAdapter(
                child: PostTagList(
              tagStringComma: post.tagString.toCommaFormat(),
            )),
          ],
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
