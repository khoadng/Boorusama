// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/common/string_utils.dart';
import 'package:boorusama/core/presentation/widgets/conditional_parent_widget.dart';
import 'package:boorusama/core/utils.dart';
import 'post_tag_list.dart';

class PostInfo extends StatefulWidget {
  const PostInfo({
    Key? key,
    required this.post,
    this.scrollController,
    this.isModal = true,
  }) : super(key: key);

  final Post post;
  final ScrollController? scrollController;
  final bool isModal;

  @override
  State<PostInfo> createState() => _PostInfoState();
}

class _PostInfoState extends State<PostInfo> {
  late final scrollController = widget.scrollController ?? ScrollController();

  @override
  void dispose() {
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: widget.isModal,
      conditionalBuilder: (child) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Modal(
          child: child,
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: CustomScrollView(
            controller: widget.scrollController,
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: ArtistSection(
                  post: widget.post,
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Theme.of(context).cardColor),
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: const Text('post.detail.size').tr(),
                      trailing: Text(filesize(widget.post.fileSize, 1)),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: const Text('post.detail.resolution').tr(),
                      trailing: Text(
                          '${widget.post.width.toInt()}x${widget.post.height.toInt()}'),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: const Text('post.detail.rating').tr(),
                      trailing: Text(widget.post.rating
                          .toString()
                          .split('.')
                          .last
                          .pascalCase),
                    ),
                  ],
                ),
              )),
              SliverToBoxAdapter(
                  child: BlocProvider.value(
                value: context.read<TagBloc>()
                  ..add(TagFetched(tags: widget.post.tags)),
                child: const PostTagList(),
              )),
            ],
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

class ArtistSection extends StatefulWidget {
  const ArtistSection({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<ArtistSection> createState() => _ArtistSectionState();
}

class _ArtistSectionState extends State<ArtistSection> {
  final artistCommentaryDisplay =
      ValueNotifier(ArtistCommentaryTranlationState.original);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ArtistCommentaryBloc>()
          .add(ArtistCommentaryFetched(postId: widget.post.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistCommentaryBloc, ArtistCommentaryState>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final artistCommentary = state.commentary;

          return ValueListenableBuilder<ArtistCommentaryTranlationState>(
            valueListenable: artistCommentaryDisplay,
            builder: (context, display, _) => Wrap(
              children: [
                SourceLink(
                  name: widget.post.artistTags.isEmpty
                      ? ''
                      : widget.post.artistTags.first,
                  title: Text(widget.post.artistTags.join(' ')),
                  uri: widget.post.source.uri,
                  actionBuilder: () => artistCommentary.isTranslated
                      ? PopupMenuButton<ArtistCommentaryTranlationState>(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          onSelected: (value) =>
                              artistCommentaryDisplay.value = value,
                          itemBuilder: (_) => [
                            PopupMenuItem<ArtistCommentaryTranlationState>(
                              value: getTranslationNextState(display),
                              child: ListTile(
                                title: Text(getTranslationText(display)).tr(),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                if (artistCommentary.hasCommentary)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: SelectableText(
                      getDescriptionText(display, artistCommentary),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class SourceLink extends StatelessWidget {
  const SourceLink({
    Key? key,
    required this.title,
    required this.uri,
    required this.actionBuilder,
    required this.name,
  }) : super(key: key);

  final Widget title;
  final Uri? uri;
  final Widget Function() actionBuilder;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: title,
      subtitle: InkWell(
        onLongPress: () =>
            Clipboard.setData(ClipboardData(text: uri.toString()))
                .then((_) => showSimpleSnackBar(
                      duration: const Duration(seconds: 1),
                      context: context,
                      content: const Text('post.detail.copied').tr(),
                    )),
        onTap: () {
          if (uri == null) return;
          launchExternalUrl(uri!);
        },
        child: Text(
          uri.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      leading: CircleAvatar(
        child: Center(
          child: Text(name.getFirstCharacter().toUpperCase()),
        ),
      ),
      trailing: actionBuilder(),
    );
  }
}

class ArtistCommentaryPlaceholder extends StatelessWidget {
  const ArtistCommentaryPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(),
          title: Container(
            margin: EdgeInsets.only(right: width * 0.4),
            height: 20,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        ...List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: width * 0.1 + Random().nextDouble() * width * 0.9,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
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
    return 'post.detail.show_original';
  } else {
    return 'post.detail.show_translated';
  }
}

String getDescriptionText(
  ArtistCommentaryTranlationState currentState,
  ArtistCommentary artistCommentary,
) {
  if (currentState == ArtistCommentaryTranlationState.translated) {
    return '${artistCommentary.translatedTitle}\n${artistCommentary.translatedDescription}';
  } else {
    return '${artistCommentary.originalTitle}\n${artistCommentary.originalDescription}';
  }
}
