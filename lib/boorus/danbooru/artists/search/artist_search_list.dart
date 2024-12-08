// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/tags/tag/providers.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import '../artist/artist.dart';
import '../artist/providers.dart';
import '../urls/artist_url_chips.dart';

class DanbooruArtistSearchList extends ConsumerStatefulWidget {
  const DanbooruArtistSearchList({
    super.key,
    required this.nameController,
    required this.urlController,
    required this.order,
    required this.focusScopeNode,
    required this.pagingController,
  });

  final TextEditingController nameController;
  final TextEditingController urlController;
  final ValueNotifier<ArtistOrder?> order;
  final FocusScopeNode focusScopeNode;
  final PagingController<int, DanbooruArtist> pagingController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruArtistSearchPageState();
}

class _DanbooruArtistSearchPageState
    extends ConsumerState<DanbooruArtistSearchList> {
  late final pagingController = widget.pagingController;

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener(_onPageChanged);
  }

  void _onPageChanged(pageKey) {
    _fetchPage(pageKey);
  }

  @override
  void dispose() {
    super.dispose();
    pagingController.removePageRequestListener(_onPageChanged);
  }

  Future<void> _fetchPage(int pageKey) async {
    final artists = await ref
        .read(danbooruArtistRepoProvider(ref.readConfigAuth))
        .getArtists(
          name: widget.nameController.text,
          url: widget.urlController.text,
          order: widget.order.value,
          page: pageKey,
          isDeleted: false,
          hasTag: true,
          includeTag: true,
        );

    if (!mounted) return;

    // exclude banned artists
    artists.removeWhere((artist) => artist.name == 'banned_artist');

    if (artists.isEmpty) {
      pagingController.appendLastPage(artists);
    } else {
      final nextPageKey = pageKey + 1;
      pagingController.appendPage(artists, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<DanbooruArtist>(
        newPageProgressIndicatorBuilder: (context) => _buildLoading(),
        firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
        itemBuilder: (context, artist, index) => ArtistSearchInfoCard(
          focusScopeNode: widget.focusScopeNode,
          artist: artist,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 24,
        width: 24,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

class ArtistSearchInfoCard extends ConsumerStatefulWidget {
  const ArtistSearchInfoCard({
    super.key,
    required this.focusScopeNode,
    required this.artist,
  });

  final FocusScopeNode focusScopeNode;
  final DanbooruArtist artist;

  @override
  ConsumerState<ArtistSearchInfoCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends ConsumerState<ArtistSearchInfoCard> {
  final expandedController = ExpandableController();

  @override
  void dispose() {
    super.dispose();
    expandedController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () {
          widget.focusScopeNode.unfocus();
          goToArtistPage(context, artist.name);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          child: ExpandablePanel(
            controller: expandedController,
            theme: ExpandableThemeData(
              useInkWell: false,
              iconPlacement: ExpandablePanelIconPlacement.right,
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              tapBodyToCollapse: false,
              iconColor: Theme.of(context).iconTheme.color,
            ),
            header: Row(
              children: [
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    artist.name.replaceAll('_', ' '),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ref.watch(tagColorProvider('artist')),
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  padding: const EdgeInsets.all(2),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  visualDensity: const ShrinkVisualDensity(),
                  label: Text(artist.postCount.toString()),
                ),
              ],
            ),
            collapsed: const SizedBox.shrink(),
            expanded: _buildExpanded(artist),
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded(DanbooruArtist artist) {
    return ValueListenableBuilder(
      valueListenable: expandedController,
      builder: (context, expanded, child) => expanded
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (artist.otherNames.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _TagOtherNames(otherNames: artist.otherNames),
                  ],
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: DanbooruArtistUrlChips(
                      artistUrls: artist.activeUrls.map((e) => e.url).toList(),
                      alignment: WrapAlignment.start,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _TagOtherNames extends StatelessWidget {
  const _TagOtherNames({
    required this.otherNames,
  });

  final List<String> otherNames;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: otherNames.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              padding: const EdgeInsets.all(4),
              labelPadding: const EdgeInsets.all(2),
              visualDensity: VisualDensity.compact,
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 32,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                ),
                child: Text(
                  otherNames[index].replaceAll('_', ' '),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
