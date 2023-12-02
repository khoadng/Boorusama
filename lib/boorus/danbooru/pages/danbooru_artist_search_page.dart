// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:expandable/expandable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_artist_url_chips.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_artists.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

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

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    urlController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Artists'),
          actions: [
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                ref.read(searchedArtistNameProvider.notifier).state =
                    nameController.text.isEmpty ? null : nameController.text;
                ref.read(searchedArtistUrlProvider.notifier).state =
                    urlController.text.isEmpty ? null : urlController.text;
              },
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        decoration: const InputDecoration(
                          hintText: 'Name, group name, or other name',
                          helperText: '*Supports wildcards and regexes',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        decoration: const InputDecoration(
                          hintText: 'URL or a part of it',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  SizedBox(
                    width: 62,
                    child: Text(
                      'Sort by',
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  OptionDropDownButton(
                    alignment: AlignmentDirectional.centerStart,
                    value: ref.watch(artistOrderProvider),
                    onChanged: (value) {
                      ref.read(artistOrderProvider.notifier).state = value!;
                    },
                    items: ArtistOrder.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name.titleCase),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SliverSizedBox(height: 8),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              sliver: RiverPagedBuilder.autoDispose(
                provider: danbooruArtistsProvider,
                firstPageProgressIndicatorBuilder: (context, controller) =>
                    const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                pullToRefresh: false,
                firstPageKey: 1,
                pagedBuilder: (controller, builder) => PagedSliverList(
                  pagingController: controller,
                  builderDelegate: builder,
                ),
                itemBuilder: (context, artist, index) => Card(
                  color: context.colorScheme.surface,
                  child: InkWell(
                    onTap: () => goToArtistPage(context, artist.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 12),
                      child: ExpandablePanel(
                        theme: ExpandableThemeData(
                          useInkWell: false,
                          iconPlacement: ExpandablePanelIconPlacement.right,
                          headerAlignment:
                              ExpandablePanelHeaderAlignment.center,
                          tapBodyToCollapse: false,
                          iconColor: context.theme.iconTheme.color,
                        ),
                        header: Row(
                          children: [
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                artist.name.replaceAll('_', ' '),
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: ref.getTagColor(context, 'artist'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              padding: const EdgeInsets.all(2),
                              backgroundColor:
                                  context.colorScheme.secondaryContainer,
                              visualDensity: const ShrinkVisualDensity(),
                              label: Text(artist.postCount.toString()),
                            ),
                          ],
                        ),
                        collapsed: const SizedBox.shrink(),
                        expanded: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (artist.otherNames.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _TagOtherNames(otherNames: artist.otherNames),
                              ],
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: DanbooruArtistUrlChips(
                                  artist: artist,
                                  alignment: WrapAlignment.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
              backgroundColor: context.colorScheme.secondaryContainer,
              shape: const StadiumBorder(side: BorderSide(color: Colors.grey)),
              padding: const EdgeInsets.all(4),
              labelPadding: const EdgeInsets.all(1),
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
