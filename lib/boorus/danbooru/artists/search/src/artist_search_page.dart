// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../artist/artist.dart';
import '../../artist/providers.dart';
import 'widgets/artist_search_info_card.dart';

class DanbooruArtistSearchPage extends ConsumerStatefulWidget {
  const DanbooruArtistSearchPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruArtistSearchPageState();
}

class _DanbooruArtistSearchPageState
    extends ConsumerState<DanbooruArtistSearchPage> {
  final nameController = TextEditingController();
  final urlController = TextEditingController();
  late final pagingController = PagingController(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: _fetchPage,
  );

  final focusScopeNode = FocusScopeNode();
  final order = ValueNotifier<ArtistOrder?>(null);

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    focusScopeNode.dispose();
    pagingController.dispose();

    super.dispose();
  }

  Future<List<DanbooruArtist>> _fetchPage(int pageKey) async {
    final artists = await ref
        .read(danbooruArtistRepoProvider(ref.readConfigAuth))
        .getArtists(
          name: nameController.text,
          url: urlController.text,
          order: order.value,
          page: pageKey,
          isDeleted: false,
          hasTag: true,
          includeTag: true,
        );

    // exclude banned artists
    artists.removeWhere((artist) => artist.name == 'banned_artist');

    return artists;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: focusScopeNode,
      child: GestureDetector(
        onTap: () => focusScopeNode.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Artists'),
            actions: [
              TextButton(
                child: const Text('Search'),
                onPressed: () {
                  focusScopeNode.unfocus();
                  pagingController.refresh();
                },
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildName(context),
              ),
              SliverToBoxAdapter(
                child: _buildUrl(context),
              ),
              SliverToBoxAdapter(
                child: _buildSort(context),
              ),
              const SliverSizedBox(height: 8),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                sliver: PagingListener(
                  controller: pagingController,
                  builder: (context, state, fetchNextPage) => PagedSliverList(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<DanbooruArtist>(
                      newPageProgressIndicatorBuilder: (context) =>
                          _buildLoading(),
                      firstPageProgressIndicatorBuilder: (context) =>
                          _buildLoading(),
                      itemBuilder: (context, artist, index) =>
                          ArtistSearchInfoCard(
                            focusScopeNode: focusScopeNode,
                            artist: artist,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSort(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            'Sort by',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: order,
          builder: (context, ord, child) {
            return OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: ord,
              onChanged: (value) {
                order.value = value;
                pagingController.refresh();
              },
              items: ArtistOrder.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name.titleCase),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUrl(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              'URL',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BooruTextField(
              controller: urlController,
              onSubmitted: (_) => pagingController.refresh(),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'URL or a part of it',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              'Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BooruTextField(
              controller: nameController,
              onSubmitted: (_) => pagingController.refresh(),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Name, group name, or other name',
                helperText: '*Supports wildcards and regexes',
              ),
            ),
          ),
        ],
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
