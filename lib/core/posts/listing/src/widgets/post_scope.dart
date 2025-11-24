// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../blacklists/providers.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../settings/providers.dart';
import '../../../post/types.dart';
import '../types/page_mode.dart';
import 'post_duplicate_checker.dart';
import 'post_grid_controller.dart';

class PostScope<T extends Post> extends ConsumerStatefulWidget {
  const PostScope({
    required this.fetcher,
    required this.builder,
    super.key,
    this.duplicateCheckMode = DuplicateCheckMode.id,
    this.pageMode,
    this.initialPage,
  });

  final PostGridFetcher<T> fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<T> controller,
  )
  builder;
  final PageMode? pageMode;
  final int? initialPage;
  final DuplicateCheckMode duplicateCheckMode;

  static PostGridController<T>? maybeOf<T extends Post>(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_PostScope<T>>();

    return inherited?.controller;
  }

  static PostGridController<T> of<T extends Post>(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_PostScope<T>>();

    if (inherited == null) {
      throw Exception('No PostScope found in the widget tree');
    }

    return inherited.controller;
  }

  @override
  ConsumerState<PostScope<T>> createState() => _PostScopeState();
}

class _PostScopeState<T extends Post> extends ConsumerState<PostScope<T>> {
  late final PostGridController<T> _controller;

  @override
  void initState() {
    super.initState();

    _controller = PostGridController<T>(
      fetcher: widget.fetcher,
      duplicateTracker: PostDuplicateTracker<T>(
        mode: widget.duplicateCheckMode,
      ),
      blacklistedTagsFetcher: () {
        if (!mounted) return Future.value({});

        return ref.read(blacklistTagsProvider(ref.readConfigFilter).future);
      },
      pageMode:
          widget.pageMode ??
          ref.read(
            imageListingSettingsProvider.select((value) => value.pageMode),
          ),
      blacklistedUrlsFetcher: () async {
        try {
          final settings = ref.read(settingsProvider);

          if (!settings.bookmarkFilterType.shouldFilterBookmarks) {
            return const {};
          }

          final bookmarkState = await ref.read(bookmarkProvider.future);

          return bookmarkState.bookmarks.map((e) => e.url).toSet();
        } catch (_) {
          return const {};
        }
      },
      mountedChecker: () => mounted,
      forcedPageMode: widget.pageMode != null,
      initialPage: widget.initialPage,
      onError: (message) {
        ref.read(loggerProvider).error('Posts', message);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(
        imageListingSettingsProvider.select((value) => value.pageMode),
        (previous, next) {
          if (widget.pageMode != null) return; // Skip if pageMode is forced
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _controller.setPageMode(next);
          });
        },
      )
      ..listen(
        blacklistTagsProvider(ref.watchConfigFilter),
        (previous, next) {
          if (previous != next) {
            next.when(
              data: (tags) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _controller.setBlacklistedTags(tags);
                });
              },
              error: (error, st) {},
              loading: () {},
            );
          }
        },
      );

    return _PostScope<T>(
      controller: _controller,
      child: widget.builder(context, _controller),
    );
  }
}

class RawPostScope<T extends Post> extends ConsumerStatefulWidget {
  const RawPostScope({
    required this.fetcher,
    required this.builder,
    required this.onError,
    super.key,
    this.duplicateCheckMode = DuplicateCheckMode.id,
  });

  final PostGridFetcher<T> fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<T> controller,
  )
  builder;

  final DuplicateCheckMode duplicateCheckMode;
  final void Function(String message) onError;

  @override
  ConsumerState<RawPostScope<T>> createState() => _RawPostScopeState();
}

class _RawPostScopeState<T extends Post>
    extends ConsumerState<RawPostScope<T>> {
  late final _controller = PostGridController<T>(
    fetcher: widget.fetcher,
    duplicateTracker: PostDuplicateTracker<T>(
      mode: widget.duplicateCheckMode,
    ),
    blacklistedTagsFetcher: () async => {},
    pageMode: ref.read(
      imageListingSettingsProvider.select((value) => value.pageMode),
    ),
    mountedChecker: () => mounted,
    onError: widget.onError,
  );

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PostScope<T>(
      controller: _controller,
      child: widget.builder(context, _controller),
    );
  }
}

class _PostScope<T extends Post> extends InheritedWidget {
  const _PostScope({
    required this.controller,
    required super.child,
    super.key,
  });
  final PostGridController<T> controller;

  @override
  bool updateShouldNotify(_PostScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
