// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../artist/artist.dart';
import '../../../artist/providers.dart';
import 'artist_search_info_card.dart';

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
