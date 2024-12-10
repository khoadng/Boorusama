// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import '../../../../core/images/interactive_booru_image.dart';
import '../../../../widgets/widgets.dart';
import '../../posts/post/post.dart';
import '../../users/details/routes.dart';
import 'providers/version_providers.dart';
import 'widgets/tag_edit_history_card.dart';

final _postIdProvider = Provider<int>((ref) {
  throw UnimplementedError();
});

final _imageUrlProvider = Provider<String>((ref) {
  throw UnimplementedError();
});

class DanbooruPostVersionsPage extends ConsumerStatefulWidget {
  const DanbooruPostVersionsPage({
    super.key,
    required this.postId,
    required this.previewUrl,
  });

  factory DanbooruPostVersionsPage.post({
    Key? key,
    required DanbooruPost post,
  }) =>
      DanbooruPostVersionsPage(
        key: key,
        postId: post.id,
        previewUrl: post.url720x720,
      );

  final int postId;
  final String previewUrl;

  @override
  ConsumerState<DanbooruPostVersionsPage> createState() =>
      _DanbooruPostVersionsPageState();
}

class _DanbooruPostVersionsPageState
    extends ConsumerState<DanbooruPostVersionsPage> {
  late final splitController = MultiSplitViewController(
    areas: [
      Area(
        id: 'image',
        data: 'image',
        size: 250,
        min: 60,
        builder: (context, area) => ProviderScope(
          overrides: [
            _imageUrlProvider.overrideWithValue(widget.previewUrl),
          ],
          child: const _Image(),
        ),
      ),
      Area(
        id: 'content',
        data: 'content',
        builder: (context, area) => ProviderScope(
          overrides: [
            _postIdProvider.overrideWithValue(widget.postId),
          ],
          child: const _Content(),
        ),
      ),
    ],
  );

  @override
  void dispose() {
    splitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: CircularIconButton(
            icon: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Symbols.arrow_back_ios),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Theme(
        data: Theme.of(context).copyWith(
          focusColor: Theme.of(context).colorScheme.primary,
        ),
        child: MultiSplitViewTheme(
          data: MultiSplitViewThemeData(
            dividerThickness: 24,
            dividerPainter: DividerPainters.grooved1(
              color: Theme.of(context).colorScheme.onSurface,
              thickness: 4,
              size: 75,
              highlightedColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: MultiSplitView(
            axis: Axis.vertical,
            controller: splitController,
          ),
        ),
      ),
    );
  }
}

class _Image extends ConsumerWidget {
  const _Image();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(_imageUrlProvider);

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => constraints.maxHeight > 80
                ? InteractiveBooruImage(
                    useHero: false,
                    heroTag: '',
                    aspectRatio: null,
                    imageUrl: imageUrl,
                  )
                : SizedBox(
                    height: constraints.maxHeight - 4,
                  ),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 4,
        ),
      ],
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postId = ref.watch(_postIdProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          sliver: ref.watch(danbooruPostVersionsProvider(postId)).when(
                data: (data) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TagEditHistoryCard(
                      version: data[index],
                      onUserTap: () => goToUserDetailsPage(
                        context,
                        uid: data[index].updater.id,
                      ),
                    ),
                    childCount: data.length,
                  ),
                ),
                loading: () => SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                error: (error, stackTrace) => SliverToBoxAdapter(
                  child: Center(
                    child: Text(error.toString()),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
