// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:expandable/expandable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/utils/flutter_utils.dart';
import '../../../artist/artist.dart';
import '../../../urls/widgets.dart';

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
