// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config.dart';
import '../../../../core/configs/ref.dart';
import 'data/providers.dart';
import 'types/wiki.dart';

final danbooruWikisProvider =
    NotifierProvider.family<WikisNotifier, Map<String, Wiki?>, BooruConfigAuth>(
      WikisNotifier.new,
    );

final danbooruWikiProvider = Provider.family<WikiState, String>((ref, tag) {
  final config = ref.watchConfigAuth;
  final wikis = ref.watch(danbooruWikisProvider(config));
  if (wikis.containsKey(tag)) {
    return wikis[tag] == null
        ? const WikiStateNotFound()
        : WikiStateLoaded(wikis[tag]!);
  } else {
    ref.read(danbooruWikisProvider(config).notifier).fetchWikiFor(tag);
    return const WikiStateLoading();
  }
});

class WikisNotifier
    extends FamilyNotifier<Map<String, Wiki?>, BooruConfigAuth> {
  @override
  Map<String, Wiki?> build(BooruConfigAuth arg) {
    return {};
  }

  Future<void> fetchWikiFor(String tag) async {
    if (state.containsKey(tag)) return;

    final wiki = await ref.read(danbooruWikiRepoProvider(arg)).getWikiFor(tag);
    if (wiki != null) {
      state = {
        ...state,
        tag: wiki,
      };
    }
  }
}

sealed class WikiState {
  const WikiState();
}

class WikiStateLoading extends WikiState {
  const WikiStateLoading();
}

class WikiStateLoaded extends WikiState {
  const WikiStateLoaded(this.wiki);
  final Wiki wiki;
}

class WikiStateError extends WikiState {
  const WikiStateError(this.message);
  final String message;
}

class WikiStateNotFound extends WikiState {
  const WikiStateNotFound();
}
