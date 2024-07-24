// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client_artists.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../artists.dart';
import 'danbooru_artist_search_list.dart';

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
  final pagingController = PagingController<int, DanbooruArtist>(
    firstPageKey: 1,
  );

  final focusScopeNode = FocusScopeNode();
  final order = ValueNotifier<ArtistOrder?>(null);

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    urlController.dispose();
    focusScopeNode.dispose();
    pagingController.dispose();
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
                sliver: DanbooruArtistSearchList(
                  nameController: nameController,
                  urlController: urlController,
                  order: order,
                  focusScopeNode: focusScopeNode,
                  pagingController: pagingController,
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
            style: context.textTheme.titleMedium,
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
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name.titleCase),
                      ))
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
              style: context.textTheme.titleMedium,
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
              style: context.textTheme.titleMedium,
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
}
