// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

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
  final void Function(ColorSettings? color) onSchemeChanged;

  @override
  State<ThemePreviewApp> createState() => _ThemePreviewAppState();
}

class _ThemePreviewAppState extends State<ThemePreviewApp> {
  late var _currentScheme = widget.currentScheme;
  final predefined = [
    null,
    ...preDefinedColorSettings,
  ];

  final pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = _currentScheme?.toColorScheme() ?? widget.defaultScheme;

    final pages = [
      PreviewHome(
        colorScheme: colorScheme,
      ),
      PreviewDetails(
        colorScheme: colorScheme,
      ),
    ];

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              SizedBox(
                height: 500,
                child: PageView(
                  controller: pageController,
                  children: pages,
                ),
              ),
              const SizedBox(height: 12),
              SmoothPageIndicator(
                controller: pageController,
                count: pages.length,
                effect: WormEffect(
                  activeDotColor: colorScheme.primary,
                  dotColor: colorScheme.outlineVariant.withOpacity(0.25),
                  dotHeight: 8,
                  dotWidth: 16,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(
                        _currentScheme?.nickname ??
                            _currentScheme?.name ??
                            'Default',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Wrap(
                      runSpacing: 8,
                      children: [
                        ...predefined.map((e) {
                          final selected = e == _currentScheme;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: _PreviewColor(
                              color: e,
                              onTap: () {
                                setState(() {
                                  _currentScheme = e;
                                  widget.onSchemeChanged(e);
                                });
                              },
                              colorScheme: colorScheme,
                              selected: selected,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

bool _sameish(Color a, Color b, [int threshold = 10]) {
  return (a.red - b.red).abs() < threshold &&
      (a.green - b.green).abs() < threshold &&
      (a.blue - b.blue).abs() < threshold;
}

class _PreviewColor extends StatelessWidget {
  const _PreviewColor({
    required this.color,
    required this.onTap,
    required this.colorScheme,
    required this.selected,
  });

  final ColorSettings? color;
  final ColorScheme colorScheme;
  final void Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = color;

    final sameColorWithSurface = c != null &&
        _sameish(c.surface ?? Colors.transparent, colorScheme.surface, 20);

    if (c == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.onSurface,
              width: selected ? 2.5 : 1.3,
            ),
          ),
          child: Icon(
            Icons.refresh,
            color: colorScheme.onSurface,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: c.surface ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : sameColorWithSurface
                    ? colorScheme.onSurface
                    : Colors.transparent,
            width: selected
                ? 2.5
                : sameColorWithSurface
                    ? 1.3
                    : 0,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check,
                color: colorScheme.onSurface,
              )
            : null,
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
          horizontal: 40,
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
        horizontal: 4,
      ),
      colorScheme: colorScheme,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: BooruImage(imageUrl: ''),
            ),
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
