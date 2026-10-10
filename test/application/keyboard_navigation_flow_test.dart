import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart' as km;
import 'package:material_symbols_icons/symbols.dart';

import 'package:boorusama/core/changelogs/dialog.dart';
import 'package:boorusama/core/changelogs/providers.dart';
import 'package:boorusama/core/changelogs/types.dart';
import 'package:boorusama/core/posts/details_parts/widgets.dart';
import 'package:boorusama/core/configs/listing/providers.dart';
import 'package:boorusama/core/configs/listing/types.dart';
import 'package:boorusama/core/comments/types.dart';
import 'package:boorusama/core/configs/create/src/widgets/create_config_button.dart';
import 'package:boorusama/core/home/src/pages/entry_page.dart';
import 'package:boorusama/core/posts/details_manager/widgets.dart';
import 'package:boorusama/core/posts/explores/widgets.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/posts/post/widgets.dart';
import 'package:boorusama/core/posts/post/src/pages/original_image_page.dart';
import 'package:boorusama/core/premiums/providers.dart';
import 'package:boorusama/core/tags/favorites/src/pages/edit_favorite_tag_sheet.dart';
import 'package:boorusama/core/tags/favorites/src/widgets/favorite_tag_label_selector_field.dart';
import 'package:boorusama/core/search/search/src/views/search_landing_view.dart';
import 'package:boorusama/core/search/search/src/widgets/desktop_search_bar.dart';
import 'package:boorusama/core/search/suggestions/tag_suggestion_items.dart';
import 'package:boorusama/core/search/suggestions/tag_suggestion_item.dart';
import 'package:boorusama/core/search/search/src/widgets/selected_tag_chip.dart';
import 'package:boorusama/core/search/search/src/widgets/search_app_bar.dart';
import 'package:boorusama/core/settings/src/pages/settings_page.dart';
import 'package:boorusama/core/videos/player/widgets.dart';

import '../support/fakes/memory_repositories.dart';
import 'support/app_flow_finders.dart';
import 'support/fake_booru_backend.dart';
import 'support/fake_image_dio.dart';
import 'support/headless_app_harness.dart';
import 'support/keyboard_flow_driver.dart';

void main() {
  final screenChecks = [
    (
      name: 'has no remote dead ends',
      check: (KeyboardFlowDriver keys) => keys.focusProblems(),
    ),
    (
      name: 'shows clearly where focus is',
      check: (KeyboardFlowDriver keys) => keys.faintFocus(),
    ),
  ];
  // Escape closes whatever the remote's back button closes.
  final closeKeys = [
    (name: 'remote back', close: (KeyboardFlowDriver keys) => keys.back()),
    (
      name: 'Escape',
      close: (KeyboardFlowDriver keys) => keys.press(LogicalKeyboardKey.escape),
    ),
  ];

  testWidgets('remote can open a post and return home without touching', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openPostWithRemote(keys);

    await keys.navigateTo(_detailsBackButton());
    await keys.select();
    await keys.harness.pumpUntil(
      tester,
      () => postDetailsScaffold().evaluate().isEmpty,
      description: 'details page to close',
    );
    expect(find.byType(EntryPage), findsOneWidget);
  });

  for (final k in closeKeys) {
    testWidgets('${k.name} closes the post details page', (tester) async {
      final keys = await _mountOnTv(tester);
      await _openPostWithRemote(keys);

      await k.close(keys);
      await keys.harness.pumpUntil(
        tester,
        () => postDetailsScaffold().evaluate().isEmpty,
        description: 'details page to close',
      );
    });
  }

  testWidgets('arrows change posts only while no control is focused', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester, posts: testPostRange(101, 103));
    await _openPostWithRemote(keys);

    await keys.navigateTo(_detailsBackButton());
    await keys.arrow(TraversalDirection.right);
    expect(currentDetailPost(tester).id, 101);
    expect(keys.isFocusWithin(_detailsBackButton()), isFalse);

    await keys.back();
    await _openPostWithRemote(keys);
    await keys.arrow(TraversalDirection.right);
    await keys.harness.pumpUntil(
      tester,
      () => currentDetailPost(tester).id == 102,
      description: 'right arrow to show the next post',
    );
  });

  final dismissals = [
    (
      name: 'remote select',
      dismiss: (KeyboardFlowDriver keys) => keys.select(),
    ),
    for (final k in closeKeys) (name: k.name, dismiss: k.close),
  ];
  for (final c in dismissals) {
    testWidgets('${c.name} closes the changelog dialog', (
      tester,
    ) async {
      final keys = await _mountOnTv(tester, showChangelog: true);
      await keys.harness.pumpUntilFound(tester, find.byType(ChangelogDialog));

      await c.dismiss(keys);

      await keys.harness.pumpUntil(
        tester,
        () => find.byType(ChangelogDialog).evaluate().isEmpty,
        description: 'changelog dialog to close',
      );
    });
  }

  testWidgets('arrowing onto the search bar does not start typing', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);

    await keys.navigateTo(find.byType(DesktopSearchbar));
    expect(tester.testTextInput.isVisible, isFalse);

    await keys.navigateTo(postTile(101));
  });

  testWidgets('remote moves from typing a search into suggestions and back', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await keys.navigateTo(find.byType(DesktopSearchbar));
    await keys.select();
    expect(tester.testTextInput.isVisible, isTrue);

    await keys.arrow(TraversalDirection.down);
    expect(keys.isFocusWithin(_searchSuggestions), isTrue);

    await keys.arrow(TraversalDirection.up);
    expect(keys.isFocusWithin(_searchField), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  for (final k in closeKeys) {
    testWidgets('${k.name} closes search suggestions and stays home', (
      tester,
    ) async {
      final keys = await _mountOnTv(tester);
      await _openSearchSuggestions(keys);

      await k.close(keys);

      expect(_searchSuggestions.evaluate(), isEmpty);
      expect(keys.isFocusWithin(find.byType(DesktopSearchbar)), isTrue);
      expect(find.byType(EntryPage), findsOneWidget);
    });
  }

  testWidgets('remote can reach every search suggestion', (tester) async {
    final keys = await _mountOnTv(tester);
    await _openSearchSuggestions(keys);

    expect(
      await keys.unreachableIn(
        _searchSuggestions,
        reopen: () => _openSearchSuggestions(keys),
      ),
      isEmpty,
    );
  });

  testWidgets(
    'remote opens the tag label sheet from search suggestions and returns '
    'to the search',
    (tester) async {
      final keys = await _mountOnTv(tester);
      await _openSearchSuggestions(keys);
      final labels = find.descendant(
        of: _searchSuggestions,
        matching: find.byType(FavoriteTagLabelSelectorField),
      );
      // Reachability is covered by the suggestions walk, which closing the
      // popover on the way would defeat here.
      await keys.focusOn(labels);

      await keys.select();
      await keys.harness.pumpUntil(
        tester,
        () => _searchSuggestions.evaluate().isEmpty,
        description: 'labels sheet to cover the suggestions',
      );
      await keys.back();

      expect(keys.isFocusWithin(_searchField), isTrue);
      expect(_searchSuggestions, findsOneWidget);
    },
  );

  testWidgets(
    'down from a typed query highlights its tag suggestions while typing '
    'goes on, and Enter adds the highlighted one',
    (tester) async {
      final keys = await _mountOnTv(tester, viewport: kDesktopViewport);
      await _typeSearch(keys, 'cat');

      await keys.arrow(TraversalDirection.down);
      await keys.arrow(TraversalDirection.down);
      expect(_highlightedSuggestion(tester), 'cat_ears');
      expect(keys.isFocusWithin(_searchField), isTrue);

      await keys.press(LogicalKeyboardKey.enter);
      await keys.harness.settle(tester);

      expect(_selectedTags(tester), ['cat_ears']);
      expect(keys.isFocusWithin(_searchField), isTrue);
    },
  );

  testWidgets(
    'on a small screen, down from a typed query highlights its tag '
    'suggestions and Tab never reaches the page they cover',
    (tester) async {
      final keys = await _mountOnTv(tester, viewport: kMobileViewport);
      await _openRoute(keys, '/search');
      final field = find.descendant(
        of: find.byType(SearchAppBar),
        matching: find.byType(EditableText),
      );
      tester.state<EditableTextState>(field).widget.focusNode.requestFocus();
      await tester.enterText(field, 'cat');
      await keys.harness.pumpUntilFound(tester, find.byType(TagSuggestionItem));
      await keys.harness.settle(tester);

      await keys.arrow(TraversalDirection.down);
      expect(_highlightedSuggestion(tester), 'cat');
      expect(keys.isFocusWithin(field), isTrue);

      for (var i = 0; i < 20; i++) {
        await keys.tab();
        expect(keys.isFocusWithin(find.byType(SearchLandingView)), isFalse);
      }
    },
  );

  testWidgets('search suggestions show clearly where focus is', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openSearchSuggestions(keys);

    expect(await keys.faintFocus(within: _searchSuggestions), isEmpty);
  });

  testWidgets('arrows skip controls scrolled out of view under a header', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openRoute(keys, _editProfilePath);
    await keys.navigateTo(find.byType(CreateOrUpdateBooruConfigButton));

    // Scrolled by mouse or touch, so tiles sit hidden under the header.
    final list = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    tester.state<ScrollableState>(list.last).position.jumpTo(300);
    await keys.harness.settle(tester);

    await keys.arrow(TraversalDirection.left);

    expect(keys.isFocusWithin(find.byTooltip('Back')), isTrue);
  });

  for (final k in closeKeys) {
    testWidgets(
      'remote can open settings from the sidebar and close it with '
      '${k.name}',
      (tester) async {
        final keys = await _mountOnTv(tester);

        await keys.navigateTo(_sidebarTile(Symbols.settings));
        await keys.select();
        await keys.harness.pumpUntilFound(tester, find.byType(SettingsPage));

        await k.close(keys);
        await keys.harness.pumpUntil(
          tester,
          () => find.byType(SettingsPage).evaluate().isEmpty,
          description: 'settings to close',
        );
      },
    );
  }

  final menus = [
    (
      name: 'post menu',
      button: _postMenuButton,
      prepare: _openPostInfoWithRemote,
    ),
    (
      name: 'profile dropdown',
      button: _profileDropdown,
      prepare: (KeyboardFlowDriver keys) =>
          _openRoute(keys, '$_editProfilePath?q=listing'),
    ),
    (
      name: 'blacklisted tag menu',
      button: _blacklistTileMenu,
      prepare: _openBlacklist,
    ),
  ];
  for (final c in menus) {
    Future<KeyboardFlowDriver> openMenu(WidgetTester tester) async {
      final keys = await _mountOnTv(tester, blacklistedTags: ['spoilers']);
      await c.prepare(keys);
      await _openMenuWithRemote(keys, c.button);
      return keys;
    }

    for (final k in closeKeys) {
      testWidgets('${k.name} closes the ${c.name} and returns to its button', (
        tester,
      ) async {
        final keys = await openMenu(tester);
        final route = ModalRoute.of(tester.element(c.button));

        await k.close(keys);

        expect(_openMenu.evaluate(), isEmpty);
        expect(route?.isCurrent, isTrue);
        expect(keys.isFocusWithin(c.button), isTrue);
      });
    }

    testWidgets('remote can reach every ${c.name} item', (tester) async {
      final keys = await openMenu(tester);

      expect(
        await keys.unreachableIn(
          _openMenu,
          reopen: () => _openMenuWithRemote(keys, c.button, direct: true),
        ),
        isEmpty,
      );
    });

    testWidgets('${c.name} shows clearly where focus is', (tester) async {
      final keys = await openMenu(tester);

      expect(await keys.faintFocus(within: _openMenu), isEmpty);
    });
  }

  final popups = [
    (
      name: 'blacklist add dialog',
      prepare: _openBlacklist,
      button: _iconButton(Symbols.add),
      returnsTo: _iconButton(Symbols.add),
      direct: false,
    ),
    (
      name: 'blacklist sort sheet',
      prepare: _openBlacklist,
      button: _iconButton(Icons.sort),
      returnsTo: _iconButton(Icons.sort),
      direct: false,
    ),
    (
      name: 'blacklist edit dialog',
      prepare: (KeyboardFlowDriver keys) async {
        await _openBlacklist(keys);
        await _openMenuWithRemote(keys, _blacklistTileMenu);
      },
      button: find.ancestor(
        of: find.descendant(of: _openMenu, matching: find.text('Edit')),
        matching: find.byType(KurumiPopupMenuItem),
      ),
      returnsTo: _blacklistTileMenu,
      // The menu closes as soon as an arrow leaves it; its own walk proves
      // the item reachable.
      direct: true,
    ),
    (
      name: 'comments sheet',
      prepare: _openPostInfoWithRemote,
      button: find.byType(CommentPostButton),
      returnsTo: find.byType(CommentPostButton),
      direct: false,
    ),
  ];
  for (final c in popups) {
    Future<KeyboardFlowDriver> openPopup(WidgetTester tester) async {
      final keys = await _mountOnTv(tester, blacklistedTags: ['spoilers']);
      await c.prepare(keys);
      final opener = ModalRoute.of(tester.element(c.returnsTo));
      await (c.direct ? keys.focusOn(c.button) : keys.navigateTo(c.button));
      await keys.select();
      await keys.harness.pumpUntil(
        tester,
        () => opener?.isCurrent == false,
        description: '${c.name} to open',
      );
      await keys.harness.settle(tester);
      return keys;
    }

    for (final k in closeKeys) {
      testWidgets('${k.name} closes the ${c.name} and returns to its button', (
        tester,
      ) async {
        final keys = await openPopup(tester);

        await k.close(keys);
        await keys.harness.settle(tester);

        expect(keys.isFocusWithin(c.returnsTo), isTrue);
      });
    }

    for (final check in screenChecks) {
      testWidgets('the ${c.name} ${check.name}', (tester) async {
        final keys = await openPopup(tester);

        expect(await check.check(keys), isEmpty);
      });
    }
  }

  testWidgets('remote opens a dropdown on its selected option', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openRoute(keys, '$_editProfilePath?q=listing');
    await _openMenuWithRemote(keys, _profileDropdown);

    expect(
      keys.isFocusWithin(
        find.descendant(
          of: _openMenu,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && (widget.properties.selected ?? false),
          ),
        ),
      ),
      isTrue,
    );
  });

  for (final c in screenChecks) {
    testWidgets('the explore screen ${c.name}', (tester) async {
      final keys = await _mountOnTv(tester);
      await _openExplore(keys);

      expect(await c.check(keys), isEmpty);
    });
  }

  final favoriteFormCases = [
    (device: 'a desktop', viewport: kDesktopViewport, centered: true),
    (device: 'a phone', viewport: kMobileViewport, centered: false),
  ];
  for (final c in favoriteFormCases) {
    testWidgets(
      'on ${c.device} the add favorite tag form opens '
      '${c.centered ? 'centered' : 'at the bottom'} with its field focused',
      (tester) async {
        final keys = await _mountOnTv(tester, viewport: c.viewport);
        await _openAddFavoriteTagForm(keys);
        final form = find.byType(EditFavoriteTagSheet);
        final field = find.descendant(
          of: form,
          matching: find.byType(EditableText),
        );

        final rect = tester.getRect(form);
        expect(
          rect.center.dy,
          c.centered
              ? closeTo(c.viewport.height / 2, 24)
              : greaterThan(c.viewport.height / 2),
        );
        expect(keys.isFocusWithin(field), isTrue);
      },
    );
  }

  testWidgets(
    'in a short window, Tab reaches the label field of the add favorite tag '
    'form after showing advanced options, and keeps it in view',
    (tester) async {
      const viewport = Size(1280, 400);
      final keys = await _mountOnTv(tester, viewport: viewport);
      await _openAddFavoriteTagForm(keys);
      await keys.focusOn(find.byType(KurumiSwitchListTile));
      await keys.select();
      await keys.harness.settle(tester);

      final labelField = find
          .descendant(
            of: find.byType(EditFavoriteTagSheet),
            matching: find.byType(EditableText),
          )
          .last;
      for (var i = 0; i < 10 && !keys.isFocusWithin(labelField); i++) {
        await keys.tab();
      }

      expect(keys.isFocusWithin(labelField), isTrue);
      expect(
        (Offset.zero & viewport).contains(
          tester.getRect(labelField).bottomCenter - const Offset(0, 1),
        ),
        isTrue,
      );
    },
  );

  testWidgets('a key press closes the hover preview of a post', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester, viewport: kDesktopViewport);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(postTile(101)));
    await tester.pump(const Duration(seconds: 2));
    await keys.harness.settle(tester);
    expect(find.byType(PostTagPreviewContainer), findsOneWidget);

    await keys.arrow(TraversalDirection.right);
    await keys.harness.settle(tester);

    expect(find.byType(PostTagPreviewContainer), findsNothing);
  });

  testWidgets('arrows move between the action buttons on a post', (
    tester,
  ) async {
    final keys = await _mountOnTv(
      tester,
      viewport: kDesktopViewport,
      thumbnailActions: ThumbnailActions(
        primary: ThumbnailAction.download,
        secondary: ThumbnailAction.bookmark,
      ),
    );
    final download = find.descendant(
      of: postTile(101),
      matching: _iconButton(Symbols.download),
    );
    final bookmark = find.descendant(
      of: postTile(101),
      matching: find.byType(BookmarkPostLikeButtonButton),
    );

    await keys.focusOn(download);
    await keys.arrow(TraversalDirection.up);
    expect(keys.isFocusWithin(bookmark), isTrue);

    await keys.arrow(TraversalDirection.down);
    expect(keys.isFocusWithin(download), isTrue);
  });

  testWidgets('the remote play/pause key pauses and resumes a video post', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester, posts: [_videoPost]);
    await _openPostWithRemote(keys);
    bool playing() => tester
        .widget<PlayPauseButton>(find.byType(PlayPauseButton))
        .isPlaying
        .value;
    final before = playing();

    await keys.press(LogicalKeyboardKey.mediaPlayPause);
    expect(playing(), !before);

    await keys.press(LogicalKeyboardKey.mediaPlayPause);
    expect(playing(), before);
  });

  testWidgets('Tab on the explore screen skips its hidden page', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester, viewport: kDesktopViewport);
    await _openExplore(keys);

    expect(await keys.tabProblems(), isEmpty);
  });

  testWidgets(
    'right along an explore row reaches each post in turn and keeps it in '
    'view',
    (tester) async {
      final keys = await _mountOnTv(tester);
      await _openExplore(keys);
      Finder card(int number) => find.ancestor(
        of: find.descendant(
          of: find.byType(ExploreList).first,
          matching: find.text('$number'),
        ),
        matching: find.byType(ExplicitContentBlockOverlay),
      );
      await keys.focusOn(card(1));

      for (var number = 2; number <= _explorePosts.length; number++) {
        await keys.arrow(TraversalDirection.right);

        expect(keys.isFocusWithin(card(number)), isTrue);
        expect(
          (Offset.zero & kTvViewport).contains(
            keys.focusedNode!.rect.bottomRight - const Offset(1, 1),
          ),
          isTrue,
          reason: 'post $number is out of view',
        );
      }
    },
  );

  for (final c in screenChecks) {
    testWidgets('the details layout manager screen ${c.name}', (tester) async {
      final keys = await _mountOnTv(tester, showPremiumFeatures: true);
      await _openDetailsLayoutManager(keys);

      expect(await c.check(keys), isEmpty);
    });
  }

  for (final c in screenChecks) {
    testWidgets('the original image viewer ${c.name}', (tester) async {
      final keys = await _openOriginalImageViewer(tester);

      expect(await c.check(keys), isEmpty);
    });
  }

  testWidgets(
    'a key press brings back the original image viewer controls hidden by a '
    'tap',
    (tester) async {
      final keys = await _openOriginalImageViewer(tester);
      final close = _iconButton(Symbols.close);

      await tester.tapAt(tester.getCenter(find.byType(OriginalImagePage)));
      await keys.harness.settle(tester);
      expect(close, findsNothing);

      await keys.arrow(TraversalDirection.down);
      await keys.harness.settle(tester);
      expect(keys.isFocusWithin(close), isTrue);

      await keys.select();
      await keys.harness.pumpUntil(
        tester,
        () => find.byType(OriginalImagePage).evaluate().isEmpty,
        description: 'original image viewer to close',
      );
    },
  );

  final screens = [
    (
      name: 'home',
      open: (KeyboardFlowDriver _) => Future<void>.value(),
    ),
    (name: 'post details', open: _openPostWithRemote),
    for (final path in [..._screenPaths, _editProfilePath])
      (name: path, open: (KeyboardFlowDriver keys) => _openRoute(keys, path)),
  ];
  for (final c in screens) {
    testWidgets('the ${c.name} screen has no remote dead ends', (
      tester,
    ) async {
      final keys = await _mountOnTv(tester);
      await c.open(keys);

      expect(await keys.focusProblems(), isEmpty);
    });

    testWidgets('the ${c.name} screen shows clearly where focus is', (
      tester,
    ) async {
      final keys = await _mountOnTv(tester);
      await c.open(keys);

      expect(await keys.faintFocus(), isEmpty);
    });
  }

  final viewports = [
    (name: 'TV', size: kTvViewport),
    (name: 'desktop', size: kDesktopViewport),
  ];
  for (final viewport in viewports) {
    for (final c in screens) {
      testWidgets(
        'Tab reaches every control on the ${c.name} ${viewport.name} screen '
        'in view',
        (tester) async {
          final keys = await _mountOnTv(tester, viewport: viewport.size);
          await c.open(keys);

          expect(await keys.tabProblems(), isEmpty);
        },
      );
    }
  }

  testWidgets('Tab goes through the whole home sidebar before the posts', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    final sidebar = find.byType(KurumiNavigationTile);

    final cycle = await keys.tabCycle();
    final inSidebar = [
      for (final (index, stop) in cycle.indexed)
        if (keys.isNodeWithin(stop.node, sidebar)) index,
    ];
    final post = cycle.indexWhere(
      (stop) => keys.isNodeWithin(stop.node, postTile(101)),
    );

    expect(inSidebar, hasLength(sidebar.evaluate().length));
    expect(inSidebar.last - inSidebar.first, inSidebar.length - 1);
    expect(post, greaterThan(inSidebar.last));
  });

  final phoneScreens = [
    (name: 'home', open: (KeyboardFlowDriver _) => Future<void>.value()),
    (name: 'post details', open: _openPostWithRemote),
    for (final path in ['/search', '/settings', '/bookmarks'])
      (name: path, open: (KeyboardFlowDriver keys) => _openRoute(keys, path)),
  ];
  for (final c in phoneScreens) {
    for (final check in screenChecks) {
      testWidgets('the ${c.name} phone screen ${check.name}', (tester) async {
        final keys = await _mountOnTv(tester, viewport: kMobileViewport);
        await c.open(keys);

        expect(await check.check(keys), isEmpty);
      });
    }
  }
}

/// Screens a remote user reaches from the home sidebar or settings.
const _screenPaths = [
  '/search',
  '/settings?initial=appearance',
  '/settings?initial=language',
  '/settings?initial=download',
  '/settings?initial=data_and_storage',
  '/settings?initial=backup_and_restore',
  '/settings?initial=search',
  '/settings?initial=accessibility',
  '/settings?initial=viewer',
  '/settings?initial=privacy',
  '/bookmarks',
  '/favorites',
  '/artists?name=cat',
  '/download_manager',
  '/bulk_downloads',
  '/bulk_downloads/saved',
  '/bulk_downloads/completed',
  '/favorite_tags',
  '/global_blacklisted_tags',
  '/boorus/add',
  '/changelog',
  '/premium',
  '/donate',
];

final _editProfilePath = '/boorus/${FakeBooruBackend().config.id}/update';

final _searchSuggestions = find.byType(SearchLandingView);

final _searchField = find.descendant(
  of: find.byType(DesktopSearchbar),
  matching: find.byType(EditableText),
);

Finder get _tagSuggestions => find.byType(TagSuggestionItems);

String? _highlightedSuggestion(WidgetTester tester) => tester
    .widgetList<KurumiListboxItem>(find.byType(KurumiListboxItem))
    .where((item) => item.active)
    .map(
      (item) => find
          .descendant(
            of: find.byWidget(item),
            matching: find.byType(TagSuggestionItem),
          )
          .evaluate()
          .map((e) => (e.widget as TagSuggestionItem).tag.value)
          .firstOrNull,
    )
    .firstOrNull;

List<String> _selectedTags(WidgetTester tester) => tester
    .widgetList<SelectedTagChip>(find.byType(SelectedTagChip))
    .map((chip) => chip.tagSearchItem.originalTag)
    .toList();

/// Types [query] into the search bar and waits for its tag suggestions.
Future<void> _typeSearch(KeyboardFlowDriver keys, String query) async {
  final tester = keys.tester;
  tester.state<EditableTextState>(_searchField).widget.focusNode.requestFocus();
  await keys.harness.settle(tester);
  await tester.enterText(_searchField, query);
  await keys.harness.pumpUntilFound(tester, _tagSuggestions);
  await keys.harness.settle(tester);
}

/// Starts typing in the search bar and moves down into its suggestions.
Future<void> _openSearchSuggestions(KeyboardFlowDriver keys) async {
  final tester = keys.tester;
  tester.state<EditableTextState>(_searchField).widget.focusNode.requestFocus();
  await keys.harness.settle(tester);
  await keys.arrow(TraversalDirection.down);
  expect(keys.isFocusWithin(_searchSuggestions), isTrue);
}

Future<void> _openRoute(KeyboardFlowDriver keys, String path) async {
  final tester = keys.tester;
  unawaited(
    GoRouter.of(tester.element(find.byType(Navigator).first)).push(path),
  );
  await keys.harness.settle(tester);
  await tester.pump(const Duration(milliseconds: 500));
  await keys.harness.settle(tester);
}

Future<void> _openPostWithRemote(KeyboardFlowDriver keys) async {
  await keys.navigateTo(postTile(101));
  await keys.select();
  await keys.harness.pumpUntilFound(keys.tester, postDetailsScaffold());
  await keys.harness.settle(keys.tester);
}

final _postMenuButton = find
    .ancestor(of: find.byIcon(Icons.more_horiz), matching: find.byType(Focus))
    .first;

final _openMenu = find.byWidgetPredicate(
  (widget) =>
      widget is FocusScope &&
      widget.focusNode?.debugLabel == 'KurumiAnchorOverlay',
  description: 'open menu',
);

/// Opens the menu behind [button] and expects focus to move into it.
/// [direct] focuses the button without arrows, to restart a walk from a
/// known point once the button is proven reachable.
Future<void> _openMenuWithRemote(
  KeyboardFlowDriver keys,
  Finder button, {
  bool direct = false,
}) async {
  if (_openMenu.evaluate().isNotEmpty) await keys.back();
  await keys.harness.pumpUntil(
    keys.tester,
    () => _openMenu.evaluate().isEmpty,
    description: 'menu to close',
  );
  await (direct ? keys.focusOn(button) : keys.navigateTo(button));
  await keys.select();
  await keys.harness.pumpUntilFound(keys.tester, _openMenu);
  expect(keys.isFocusWithin(_openMenu), isTrue);
}

Future<void> _openBlacklist(KeyboardFlowDriver keys) =>
    _openRoute(keys, '/global_blacklisted_tags');

final _blacklistTileMenu = find
    .ancestor(
      of: find.byIcon(Icons.more_vert),
      matching: find.byType(KurumiPopupMenuButton),
    )
    .first;

Future<KeyboardFlowDriver> _openOriginalImageViewer(
  WidgetTester tester,
) async {
  final keys = await _mountOnTv(
    tester,
    posts: [
      TestPost(id: 101, originalImageUrl: 'https://example.com/101.jpg'),
    ],
  );
  await _openPostInfoWithRemote(keys);
  await _openMenuWithRemote(keys, _postMenuButton);
  await keys.focusOn(_menuItem('View original'));
  await keys.select();
  await keys.harness.pumpUntilFound(tester, find.byType(OriginalImagePage));
  await keys.harness.settle(tester);
  return keys;
}

/// The focusable item labelled [label] in the open menu.
Finder _menuItem(String label) => find
    .ancestor(
      of: find.descendant(of: _openMenu, matching: find.text(label)),
      matching: find.byType(Focus),
    )
    .first;

final _profileDropdown = find
    .byWidgetPredicate((widget) => widget is KurumiOptionDropDownButton)
    .first;

Future<void> _openDetailsLayoutManager(KeyboardFlowDriver keys) async {
  await _openPostInfoWithRemote(keys);
  await keys.navigateTo(find.byType(AddCustomDetailsButton));
  await keys.select();
  await keys.harness.pumpUntilFound(
    keys.tester,
    find.byType(DetailsLayoutManagerPage),
  );
  await keys.harness.settle(keys.tester);
}

Future<void> _openPostInfoWithRemote(KeyboardFlowDriver keys) async {
  await _openPostWithRemote(keys);
  await keys.navigateTo(
    find.ancestor(
      of: find.byType(KurumiInfoCircleIcon),
      matching: find.byType(KurumiCircularIconButton),
    ),
  );
  await keys.select();
  await keys.harness.settle(keys.tester);
}

Future<void> _openAddFavoriteTagForm(KeyboardFlowDriver keys) async {
  await _openRoute(keys, '/favorite_tags');
  await keys.navigateTo(find.byType(km.FloatingActionButton));
  await keys.select();
  await keys.harness.pumpUntilFound(
    keys.tester,
    find.byType(EditFavoriteTagSheet),
  );
  await keys.harness.settle(keys.tester);
  // Lets an autofocused field finish opening the keyboard.
  await keys.tester.pump(const Duration(seconds: 1));
}

final _explorePosts = testPostRange(101, 106);

final _videoPost = TestPost(id: 101, format: '.mp4');

/// The wide explore layout, whose "see more" page waits hidden behind the
/// overview.
Future<void> _openExplore(KeyboardFlowDriver keys) async {
  final tester = keys.tester;
  Navigator.of(tester.element(find.byType(EntryPage))).push(
    km.MaterialPageRoute<void>(
      builder: (context) => km.Scaffold(
        body: ExplorePageDesktop(
          sliverOverviews: [
            for (final title in ['Popular', 'Hot'])
              SliverToBoxAdapter(
                child: ExploreSection(
                  title: title,
                  onPressed: () {},
                  builder: (_) => ExploreList(posts: _explorePosts),
                ),
              ),
          ],
          details: Column(
            children: [
              for (final label in ['Hidden 1', 'Hidden 2'])
                km.TextButton(onPressed: () {}, child: Text(label)),
            ],
          ),
        ),
      ),
    ),
  );
  await keys.harness.settle(tester);
  await tester.pump(const Duration(milliseconds: 500));
  await keys.harness.settle(tester);
}

Future<KeyboardFlowDriver> _mountOnTv(
  WidgetTester tester, {
  bool showChangelog = false,
  bool showPremiumFeatures = false,
  List<TestPost>? posts,
  List<String> blacklistedTags = const [],
  Size viewport = kTvViewport,
  ThumbnailActions? thumbnailActions,
}) async {
  final backend = FakeBooruBackend()
    ..enqueuePosts(page: 1, posts: posts ?? testPostRange(101, 101))
    ..autocompleteTags.addAll(['cat', 'cat_ears', 'cat_tail']);
  backend.comments[101] = [
    SimpleComment(
      id: 1,
      body: 'Nice colors',
      createdAt: DateTime(2026),
      updatedAt: null,
      creatorName: 'tester',
    ),
  ];
  final blacklist = MemoryGlobalBlacklistedTagRepository();
  for (final tag in blacklistedTags) {
    await blacklist.addTag(tag);
  }
  final harness = await HeadlessAppHarness.mount(
    tester,
    booruBackend: backend,
    runtime: backend.createRuntime(globalBlacklistedTagRepository: blacklist),
    viewportSize: viewport,
    additionalOverrides: [
      changelogRepositoryProvider.overrideWith(
        (ref) => _FakeChangelogRepository(showChangelog: showChangelog),
      ),
      deterministicFaviconDioOverride(),
      deterministicImageDioOverride(),
      if (showPremiumFeatures)
        showPremiumFeatsProvider.overrideWith((ref) => true),
      if (thumbnailActions case final actions?)
        thumbnailActionsProvider.overrideWithValue(actions),
    ],
  );
  // A blacklist makes the grid filter posts in a real isolate, which only
  // finishes while real time passes.
  for (var i = 0; i < 50 && postTile(101).evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await harness.pumpUntilFound(tester, postTile(101));
  await harness.settle(tester);

  return KeyboardFlowDriver(tester: tester, harness: harness);
}

Finder _sidebarTile(IconData icon) => find.ancestor(
  of: find.byIcon(icon),
  matching: find.byType(KurumiNavigationTile),
);

Finder _iconButton(IconData icon) =>
    find.ancestor(of: find.byIcon(icon), matching: find.byType(km.IconButton));

Finder _detailsBackButton() => find.ancestor(
  of: find.byIcon(Symbols.arrow_back_ios),
  matching: find.byType(KurumiCircularIconButton),
);

final class _FakeChangelogRepository implements ChangelogRepository {
  _FakeChangelogRepository({required this.showChangelog});

  bool showChangelog;

  @override
  Future<ChangelogData> loadLatestChangelog() async => ChangelogData(
    previousVersion: null,
    version: ReleaseVersion.fromText('9.0.0'),
    content: '- Remote navigation fixes',
  );

  @override
  Future<String> loadFullChangelog() async => '';

  @override
  Future<void> markChangelogAsSeen(ReleaseVersion version) async =>
      showChangelog = false;

  @override
  Future<bool> shouldShowChangelog(ReleaseVersion version) async =>
      showChangelog;
}
