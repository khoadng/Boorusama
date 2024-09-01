import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final _kRandomTags = [
  'outdoors',
  'sky',
  'cloud',
  'water',
  'ocean',
  'scenery',
  'sunset',
  'sunrise',
];

// final _kPrimaryColors = [
//   Colors.red,
//   Colors.pink,
//   Colors.purple,
//   Colors.deepPurple,
//   Colors.indigo,
//   Colors.blue,
//   Colors.lightBlue,
//   Colors.cyan,
//   Colors.teal,
//   Colors.green,
//   Colors.lightGreen,
//   Colors.lime,
//   Colors.yellow,
//   Colors.amber,
//   Colors.orange,
//   Colors.deepOrange,
//   Colors.brown,
//   Colors.grey,
//   Colors.blueGrey,
// ];

class ThemePreviewApp extends StatefulWidget {
  const ThemePreviewApp({
    super.key,
    required this.defaultScheme,
    required this.currentScheme,
    required this.onSchemeChanged,
  });

  final ColorScheme defaultScheme;
  final ColorSettings? currentScheme;
  final void Function(ColorSettings color) onSchemeChanged;

  @override
  State<ThemePreviewApp> createState() => _ThemePreviewAppState();
}

class _ThemePreviewAppState extends State<ThemePreviewApp> {
  late var _currentScheme = widget.currentScheme;

  final pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = _currentScheme?.toColorScheme() ?? widget.defaultScheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: colorScheme.brightness == Brightness.dark
          ? AppTheme.darkTheme(
              colorScheme: colorScheme,
            )
          : AppTheme.lightTheme(
              colorScheme: colorScheme,
            ),
      home: Material(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Expanded(
              child: PageView(
                controller: pageController,
                children: [
                  PreviewHome(
                    colorScheme: colorScheme,
                  ),
                  PreviewDetails(
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SmoothPageIndicator(
              controller: pageController,
              count: 2,
              effect: const WormEffect(),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Text(
                    _currentScheme?.nickname ??
                        _currentScheme?.name ??
                        'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: preDefinedColorSettings.length,
                    itemBuilder: (context, index) {
                      final selected =
                          preDefinedColorSettings[index] == _currentScheme;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentScheme = preDefinedColorSettings[index];
                              widget.onSchemeChanged(
                                  preDefinedColorSettings[index]);
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: preDefinedColorSettings[index].surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: selected ? 2 : 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // list of predefined colors
            // SizedBox(
            //   height: 60,
            //   child: ListView.builder(
            //     padding: const EdgeInsets.symmetric(
            //       vertical: 4,
            //       horizontal: 8,
            //     ),
            //     scrollDirection: Axis.horizontal,
            //     itemCount: _kPrimaryColors.length,
            //     itemBuilder: (context, index) {
            //       final selected = _kPrimaryColors[index] == _currentScheme;

            //       return Padding(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 2,
            //         ),
            //         child: GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               // _currentScheme = _kPrimaryColors[index];
            //             });
            //           },
            //           child: Container(
            //             width: 40,
            //             height: 40,
            //             decoration: BoxDecoration(
            //               color: _kPrimaryColors[index],
            //               shape: BoxShape.circle,
            //               border: Border.all(
            //                 color: selected
            //                     ? colorScheme.onSurface
            //                     : Colors.transparent,
            //                 width: selected ? 2 : 0,
            //               ),
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class PreviewFrame extends StatelessWidget {
  const PreviewFrame({
    super.key,
    required this.colorScheme,
    this.padding,
    required this.child,
  });

  final Widget child;
  final ColorScheme colorScheme;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.onSurface,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: child,
      ),
    );
  }
}

class PreviewHome extends StatelessWidget {
  const PreviewHome({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return PreviewFrame(
      colorScheme: colorScheme,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: BooruSearchBar(
              enabled: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _kRandomTags.length,
                itemBuilder: (context, index) {
                  // first is general, second is artist, third is character, fourth is copyright, fifth is meta then repeat
                  final colorIndex = index % 5;
                  final color = switch (colorIndex) {
                    0 => !isDark
                        ? TagColors.dark().general
                        : TagColors.light().general,
                    1 => !isDark
                        ? TagColors.dark().artist
                        : TagColors.light().artist,
                    2 => !isDark
                        ? TagColors.dark().character
                        : TagColors.light().character,
                    3 => !isDark
                        ? TagColors.dark().copyright
                        : TagColors.light().copyright,
                    4 =>
                      !isDark ? TagColors.dark().meta : TagColors.light().meta,
                    _ => !isDark
                        ? TagColors.dark().general
                        : TagColors.light().general,
                  };

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                    ),
                    child: BooruChip(
                      label: Text(_kRandomTags[index]),
                      onPressed: () {},
                      chipColors: generateChipColorsFromColorScheme(
                        color,
                        colorScheme,
                        isDark ? AppThemeMode.dark : AppThemeMode.light,
                        true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverPostGridPlaceHolder()
        ],
      ),
    );
  }
}

final _previewPost = DanbooruPost.empty().copyWith(
  id: 123,
  format: 'jpg',
  rating: Rating.general,
  fileSize: 1024 * 1024 * 5,
  width: 1920,
  height: 1080,
  tags: {
    'artist1',
    'artist2',
    'character1',
    'character2',
    'copy1',
    'copy2',
    'general1',
    'general2',
    'meta1',
    'meta2',
  },
  artistTags: {'artist1', 'artist2'},
  characterTags: {'character1', 'character2'},
  generalTags: {'general1', 'general2'},
  metaTags: {'meta1', 'meta2'},
);

class PreviewDetails extends StatelessWidget {
  const PreviewDetails({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return PreviewFrame(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      colorScheme: colorScheme,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: BooruImage(imageUrl: ''),
          ),
          const SliverToBoxAdapter(
            child: PreviewPostActionToolbar(),
          ),
          SliverToBoxAdapter(
            child: PreviewTagsTile(
              colorScheme: colorScheme,
              post: _previewPost,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                DefaultFileDetailsSection(
                  post: _previewPost,
                ),
                const Divider(thickness: 0.5),
              ],
            ),
          ),
          SliverIgnorePointer(
            sliver: ArtistPostList2(
              tag: _previewPost.artistTags.first,
              builder: (tag) => const SliverPreviewPostGridPlaceholder(
                itemCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewPostActionToolbar extends StatelessWidget {
  const PreviewPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PostActionToolbar(
      children: [
        FavoritePostButton(
          isFaved: true,
          isAuthorized: true,
          addFavorite: () async {
            return;
          },
          removeFavorite: () async {
            return;
          },
        ),
        UpvotePostButton(
          voteState: VoteState.upvoted,
          onUpvote: () async {
            return;
          },
          onRemoveUpvote: () async {
            return;
          },
        ),
        DownvotePostButton(
          voteState: VoteState.downvoted,
          onDownvote: () => {},
          onRemoveDownvote: () => {},
        ),
        BookmarkPostButton(
          post: _previewPost,
        ),
        IgnorePointer(child: DownloadPostButton(post: _previewPost)),
        IgnorePointer(child: SharePostButton(post: _previewPost)),
      ],
    );
  }
}

class PreviewTagsTile extends ConsumerWidget {
  const PreviewTagsTile({
    super.key,
    required this.post,
    required this.colorScheme,
  });

  final DanbooruPost post;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return TagsTile(
      post: post,
      tagColorBuilder: (tag) => switch (tag.category.id) {
        0 => !isDark ? TagColors.dark().general : TagColors.light().general,
        1 => !isDark ? TagColors.dark().artist : TagColors.light().artist,
        4 => !isDark ? TagColors.dark().character : TagColors.light().character,
        3 => !isDark ? TagColors.dark().copyright : TagColors.light().copyright,
        5 => !isDark ? TagColors.dark().meta : TagColors.light().meta,
        _ => !isDark ? TagColors.dark().general : TagColors.light().general,
      },
      tags: createTagGroupItems([
        ...post.artistTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.artist(),
            )),
        ...post.characterTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.character(),
            )),
        ...post.copyrightTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.copyright(),
            )),
        ...post.generalTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.general(),
            )),
        ...post.metaTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.meta(),
            )),
      ]),
    );
  }
}

// class ThemeColorPickerPage extends StatefulWidget {
//   const ThemeColorPickerPage({
//     super.key,
//     required this.currentColor,
//     required this.onColorChanged,
//     required this.isDark,
//     required this.onDarkModeChanged,
//   });

//   final Color currentColor;
//   final void Function(Color color) onColorChanged;
//   final void Function(bool isDark) onDarkModeChanged;
//   final bool isDark;

//   @override
//   State<ThemeColorPickerPage> createState() => _ThemeColorPickerPageState();
// }

// class _ThemeColorPickerPageState extends State<ThemeColorPickerPage> {
//   late var _isDark = widget.isDark;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     ColorPicker(
//                       pickersEnabled: const <ColorPickerType, bool>{
//                         ColorPickerType.wheel: true,
//                         ColorPickerType.primary: true,
//                         ColorPickerType.accent: true,
//                       },
//                       color: widget.currentColor,
//                       onColorChanged: (color) {
//                         setState(
//                           () {
//                             widget.onColorChanged(color);
//                           },
//                         );
//                       },
//                       heading: Text(
//                         'Select color',
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                       subheading: Text(
//                         'Select color shade',
//                         style: Theme.of(context).textTheme.titleSmall,
//                       ),
//                     ),
//                     // Light/dark switch
//                     SwitchListTile(
//                       title: const Text('Dark mode'),
//                       value: _isDark,
//                       onChanged: (value) {
//                         setState(() {
//                           _isDark = value;
//                           widget.onDarkModeChanged(value);
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// A draggable widget that accepts vertical drag gestures
/// and this is only visible on desktop and web platforms.
class Grabber extends StatelessWidget {
  const Grabber({
    super.key,
    required this.onVerticalDragUpdate,
  });

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        color: colorScheme.primary,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
