// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/artist_commentary/artist_commentary_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/modal.dart';
import 'package:boorusama/core/utils.dart';
import 'post_tag_list.dart';

class PostInfoModal extends HookWidget {
  const PostInfoModal({
    Key? key,
    required this.post,
    required this.scrollController,
  }) : super(key: key);

  final Post post;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
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
                    child: BlocProvider(
                  create: (context) => TagCubit(
                      tagRepository:
                          RepositoryProvider.of<ITagRepository>(context)),
                  child: BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
                    builder: (context, state) => PostTagList(
                      apiEndpoint: state.booru.url,
                      tagStringComma: post.tagString.toCommaFormat(),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ArtistCommentaryTranlationState {
  original,
  translated,
}

class ArtistSection extends HookWidget {
  const ArtistSection({
    Key? key,
    required this.post,
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
        useState(ArtistCommentaryTranlationState.original);

    useEffect(() {
      ReadContext(context)
          .read<ArtistCommentaryCubit>()
          .getArtistCommentary(post.id);
    }, []);

    return BlocBuilder<ArtistCommentaryCubit, AsyncLoadState<ArtistCommentary>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final artistCommentary = state.data!;
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
                  onTap: () {
                    if (post.source.uri == null) return;
                    launchExternalUrl(post.source.uri!);
                  },
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
                            value: getTranslationNextState(
                                artistCommentaryDisplay.value),
                            child: ListTile(
                              title: Text(getTranslationText(
                                  artistCommentaryDisplay.value)),
                            ),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ),
              SelectableText(
                getDescriptionText(
                  artistCommentaryDisplay.value,
                  artistCommentary,
                ),
              ),
            ],
          );
        } else if (state.status == LoadStatus.failure) {
          return SizedBox.shrink();
        } else {
          return _buildLoading(context);
        }
      },
    );
  }
}

ArtistCommentaryTranlationState getTranslationNextState(
    ArtistCommentaryTranlationState currentState) {
  if (currentState == ArtistCommentaryTranlationState.translated) {
    return ArtistCommentaryTranlationState.original;
  } else {
    return ArtistCommentaryTranlationState.translated;
  }
}

String getTranslationText(ArtistCommentaryTranlationState currentState) {
  if (currentState == ArtistCommentaryTranlationState.translated) {
    return "Show Original";
  } else {
    return "Show Translated";
  }
}

String getDescriptionText(
  ArtistCommentaryTranlationState currentState,
  ArtistCommentary artistCommentary,
) {
  if (currentState == ArtistCommentaryTranlationState.translated) {
    return "${artistCommentary.translatedTitle}\n${artistCommentary.translatedDescription}";
  } else {
    return "${artistCommentary.originalTitle}\n${artistCommentary.originalDescription}";
  }
}
